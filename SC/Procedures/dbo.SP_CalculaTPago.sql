SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_CalculaTPago] (@picodigo int, @pi_movimiento char(1))   as

SET NOCOUNT ON 
declare @activofijo char(1), @cf_pagocontribucion char(1), @CCP_TIPO varchar(5), @CL_VIRTPAGACONTRIB char(1), @pr_codigo int,
@coniva char(1), @CP_CODIGO INT, @pg_codigo int



		if exists (select * from pedimp where pi_codigo =@picodigo and (cp_codigo in 
			(SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('CN', 'OC', 'RG', 'ED')) or
			 (cp_codigo in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('IE')) and pi_movimiento='E')))
		begin
			set @coniva='S'
		end
		else
		begin
			set @coniva='N'
		end

		SELECT @CP_CODIGO=CP_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo

		SELECT     @pg_codigo=PG_CODIGO
		FROM         CONFIGURACONTRIBTPAGO
		WHERE     (CP_CODIGO = @CP_CODIGO) AND (CFC_MOVIMIENTO = @pi_movimiento) AND CON_CODIGO in (select con_codigo from contribucion where con_clave='6')

		if @pg_codigo is null
		set @pg_codigo=0


		SELECT @CCP_TIPO=CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO=@CP_CODIGO


		select @CL_VIRTPAGACONTRIB=CL_VIRTPAGACONTRIB from cliente where cl_codigo=@pr_codigo

	

	if exists (select * from pedimp where pi_codigo =@picodigo and 
		 (cp_codigo in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('IA', 'IM')) and pi_movimiento='E'))
	begin
		set @activofijo='S'
	end
	else
	begin
		set @activofijo='N'
	end




	if (select cf_pagocontribucion from configuracion)='E' or (select pi_pagado from pedimp where pi_codigo=@picodigo)='S'
	begin
		set @cf_pagocontribucion='E'
	end
	else
	begin 
		set @cf_pagocontribucion='S'
	end


	if @pi_movimiento='E'
	begin
		-- 6 pago pendiente
		-- 13 pago ya efectuado, este se utiliza en la export o virtual

		if @CCP_TIPO='CN' 
		begin
			UPDATE TempPedImpDetF4
			set PG_CODIGO= case when @pg_codigo=0 then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') else @pg_codigo end
			WHERE PI_CODIGO=@picodigo
		end
		else
		begin
			UPDATE TempPedImpDet
			SET PG_CODIGO=(case when (@coniva='S' and @CCP_TIPO<>'ED') or @cf_pagocontribucion='E' or @activofijo='S' 
				then (case when PID_SERVICIO='S' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='5') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end)
				else (case when pid_pagacontrib='N' or PID_POR_DEF=0 then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='5') else (case when @pg_codigo = 0 then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else @pg_codigo end) end) end)
			WHERE PI_CODIGO=@picodigo

		end
	end
	else
	begin
			if @CCP_TIPO='VT' 
			begin
				UPDATE TempPedImpDet
				SET PG_CODIGO=case when PID_POR_DEF=0  OR @coniva='S' or @cf_pagocontribucion='E' or @activofijo='S' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') else (case when pid_pagacontrib='N'  or @CL_VIRTPAGACONTRIB='S' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='13') else (case when @pg_codigo=0 then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else @pg_codigo end) end) end
				WHERE PI_CODIGO=@picodigo
			end
			else
			begin
				UPDATE TempPedImpDet
				SET PG_CODIGO=case when @pg_codigo=0 then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') else @pg_codigo end
				WHERE PI_CODIGO=@picodigo
			end


	end





GO
