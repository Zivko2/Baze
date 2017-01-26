SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_CalculaAdvalorem] (@picodigo int, @pi_movimiento char(1), @user int)   as

SET NOCOUNT ON 
declare @hora varchar(15), @FechaActual datetime, @em_codigo int, @CCP_TIPO varchar(5), @pi_ft_act decimal(38,6),
@CP_CODIGO INT, @coniva char(1), @cf_pagocontribucion char(1), @activofijo char(1), @pg_codigo int, @pr_codigo int, @CL_VIRTPAGACONTRIB char(1),
@PgEfectivo int, @PgTempNoPaga int, @PgPendiente int, @PgEfectuado int


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


		SELECT @PgEfectivo=PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0'
		SELECT @PgTempNoPaga=PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='5'
		SELECT @PgPendiente=PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6'
		SELECT @PgEfectuado=PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='13'


		SELECT @CP_CODIGO=CP_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo

		SELECT     @pg_codigo=PG_CODIGO
		FROM         CONFIGURACONTRIBTPAGO
		WHERE     (CP_CODIGO = @CP_CODIGO) AND (CFC_MOVIMIENTO = @pi_movimiento) AND CON_CODIGO in (select con_codigo from contribucion where con_clave='6')

		if @pg_codigo is null
		set @pg_codigo=0


		SELECT @CCP_TIPO=CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO=@CP_CODIGO


		select @pi_ft_act=isnull(pi_ft_act,0), @pr_codigo=pr_codigo from pedimp where pi_codigo=@picodigo


		select @CL_VIRTPAGACONTRIB=CL_VIRTPAGACONTRIB from cliente where cl_codigo=@pr_codigo



		SET @FechaActual = convert(varchar(10), getdate(),101)

		select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
		(select replace(convert(sysname,db_name()),'intrade',''))

		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
		values (@user, 2, 'Calculando Advalorem ', 'Calculating Advalorem ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
	


	if exists (select * from pedimpdetbcontribucion where pi_codigo =@picodigo and con_codigo in (select con_codigo from contribucion where con_clave='6'))
	delete from pedimpdetbcontribucion where pi_codigo=@picodigo and con_codigo in (select con_codigo from contribucion where con_clave='6')


	if exists (select * from pedimp where pi_codigo =@picodigo and 
		 (cp_codigo in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('IA', 'IM')) and pi_movimiento='E'))
	begin
		set @activofijo='S'
	end
	else
	begin
		set @activofijo='N'
	end

	select @cf_pagocontribucion=cf_pagocontribucion from configuracion


	if @pi_movimiento='E'
	begin
		-- 6 pago pendiente
		-- 13 pago ya efectuado, este se utiliza en la export o virtual

		if @CCP_TIPO='CN' 
		begin
			--Se comento temporalmente la multiplicacion del factor de actualizacion hasta saber cuando aplica y cuando no Manuel G. 13-Mar-2012
			insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
			SELECT     @picodigo, isnull(dbo.PEDIMPDET.PG_CODIGO,(case when @pg_codigo=0 then @PgEfectivo else @pg_codigo end)), 
				(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_clave='6'), dbo.PEDIMPDET.PID_POR_DEF, 	
					isnull(ROUND(SUM(dbo.PEDIMPDET.PID_VAL_ADU * (dbo.PEDIMPDET.PID_POR_DEF/100)),0),0)/**@pi_ft_act*/ AS importe, 
			                      dbo.PEDIMPDET.PIB_INDICEB
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.PEDIMPDET.PIB_INDICEB is not null AND PIB_INDICEB
				NOT IN (SELECT PIB_INDICEB FROM pedimpdetbcontribucion WHERE CON_CODIGO in(select con_codigo from contribucion where con_clave='6'))
			GROUP BY dbo.PEDIMPDET.PI_CODIGO, isnull(dbo.PEDIMPDET.PG_CODIGO,(case when @pg_codigo=0 then @PgEfectivo else @pg_codigo end)), dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.PIB_INDICEB
		end
		else
		begin
			insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
			SELECT     @picodigo, isnull(dbo.PEDIMPDET.PG_CODIGO, (case when (@coniva='S' and @CCP_TIPO<>'ED') or @cf_pagocontribucion='E' or @activofijo='S' 
				then (case when (PID_SERVICIO)='S' then @PgTempNoPaga else @PgEfectivo end)
				 else (case when (pid_pagacontrib)='N' or dbo.PEDIMPDET.PID_POR_DEF=0 then @PgTempNoPaga else (case when @pg_codigo = 0 then @PgPendiente else @pg_codigo end) end) end)), 
				(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
					(select con_codigo from contribucion where con_clave='6'), dbo.PEDIMPDET.PID_POR_DEF, 	
					isnull(ROUND(SUM(dbo.PEDIMPDET.PID_VAL_ADU * (dbo.PEDIMPDET.PID_POR_DEF/100)),0),0) AS importe, 
			                      dbo.PEDIMPDET.PIB_INDICEB
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.PEDIMPDET.PIB_INDICEB is not null AND PIB_INDICEB
				NOT IN (SELECT PIB_INDICEB FROM pedimpdetbcontribucion WHERE CON_CODIGO in(select con_codigo from contribucion where con_clave='6'))
			GROUP BY dbo.PEDIMPDET.PI_CODIGO, dbo.PEDIMPDET.PID_POR_DEF, 
			                      dbo.PEDIMPDET.PIB_INDICEB, isnull(dbo.PEDIMPDET.PG_CODIGO, (case when (@coniva='S' and @CCP_TIPO<>'ED') or @cf_pagocontribucion='E' or @activofijo='S' 
				then (case when (PID_SERVICIO)='S' then @PgTempNoPaga else @PgEfectivo end)
				 else (case when (pid_pagacontrib)='N' or dbo.PEDIMPDET.PID_POR_DEF=0 then @PgTempNoPaga else (case when @pg_codigo = 0 then @PgPendiente else @pg_codigo end) end) end))
		end
	end
	else
	begin


			if @CCP_TIPO='VT' 
			begin
				insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
				SELECT     @picodigo, isnull(dbo.PEDIMPDET.PG_CODIGO, (case when dbo.PEDIMPDET.PID_POR_DEF=0  OR @coniva='S' or @cf_pagocontribucion='E' or @activofijo='S' then @PgEfectivo else (case when pid_pagacontrib='N'  or @CL_VIRTPAGACONTRIB='S' then @PgEfectuado else (case when @pg_codigo=0 then @PgPendiente else @pg_codigo end) end) end)),
				 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_clave='6'), dbo.PEDIMPDET.PID_POR_DEF, 	
						isnull(ROUND(SUM(dbo.PEDIMPDET.PID_VAL_ADU * (dbo.PEDIMPDET.PID_POR_DEF/100)),0),0) AS importe, 
				                      dbo.PEDIMPDET.PIB_INDICEB
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.PEDIMPDET.PIB_INDICEB is not null AND PIB_INDICEB
					NOT IN (SELECT PIB_INDICEB FROM pedimpdetbcontribucion WHERE CON_CODIGO in(select con_codigo from contribucion where con_clave='6'))
				GROUP BY dbo.PEDIMPDET.PI_CODIGO, isnull(dbo.PEDIMPDET.PG_CODIGO, (case when dbo.PEDIMPDET.PID_POR_DEF=0  OR @coniva='S' or @cf_pagocontribucion='E' or @activofijo='S' then @PgEfectivo else (case when pid_pagacontrib='N'  or @CL_VIRTPAGACONTRIB='S' then @PgEfectuado else (case when @pg_codigo=0 then @PgPendiente else @pg_codigo end) end) end)), dbo.PEDIMPDET.PID_POR_DEF, 
				                      dbo.PEDIMPDET.PIB_INDICEB
			end
			else
			begin

				insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)				
				SELECT     @picodigo, isnull(dbo.PEDIMPDET.PG_CODIGO, (case when @pg_codigo=0 then @PgEfectivo else @pg_codigo end)), 
					(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_clave='6'), 0, 0, dbo.PEDIMPDET.PIB_INDICEB
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.PEDIMPDET.PIB_INDICEB is not null AND PIB_INDICEB
					NOT IN (SELECT PIB_INDICEB FROM pedimpdetbcontribucion WHERE CON_CODIGO in(select con_codigo from contribucion where con_clave='6'))
				GROUP BY dbo.PEDIMPDET.PI_CODIGO, isnull(dbo.PEDIMPDET.PG_CODIGO, (case when @pg_codigo=0 then @PgEfectivo else @pg_codigo end)), dbo.PEDIMPDET.PID_POR_DEF, 
				                      dbo.PEDIMPDET.PIB_INDICEB

			end


	end
GO
