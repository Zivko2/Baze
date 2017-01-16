SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ActualizaPIDescarga] (@pi_codigo int)   as

declare @ccp_tipo varchar(5), @ccp_tipoR1 varchar(5), @cp_codigo int, @cp_rectifica int

	if (select pi_movimiento from pedimp where pi_codigo=@pi_codigo)='E'
	begin
		select @cp_codigo=cp_codigo, @cp_rectifica=cp_rectifica from pedimp where pi_codigo=@pi_codigo

		select  @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo =@cp_codigo
		select  @ccp_tipoR1=ccp_tipo from configuraclaveped where cp_codigo =@cp_rectifica
	

		if @ccp_tipo in ('TS') and (select cp_descargable from claveped where cp_codigo=@cp_codigo)='S'
		begin
			UPDATE PIDESCARGA
			SET PIDESCARGA.PI_FEC_ENT=PEDIMPDET.PID_FECHAPEDTRANS
			FROM PIDESCARGA INNER JOIN PEDIMPDET ON PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED
			WHERE PIDESCARGA.PI_CODIGO=@pi_codigo and (PIDESCARGA.PI_FEC_ENT<> PEDIMPDET.PID_FECHAPEDTRANS)
		end	



		if @ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'IA', 'IM', 'ED', 'IE') and (select cp_descargable from claveped where cp_codigo=@cp_codigo)='S'
		begin
			UPDATE PIDESCARGA
			SET PIDESCARGA.PI_FEC_ENT=PEDIMP.PI_FEC_ENT, 
			PI_ACTIVOFIJO=(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
					OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
					PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END)
			FROM PIDESCARGA INNER JOIN PEDIMP ON PIDESCARGA.PI_CODIGO= PEDIMP.PI_CODIGO
				INNER JOIN PEDIMPDET ON PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED
			WHERE PIDESCARGA.PI_CODIGO=@pi_codigo and (PIDESCARGA.PI_FEC_ENT<>PEDIMP.PI_FEC_ENT or
				PI_ACTIVOFIJO<>(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
					OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
					PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END))
		end	


		if (@ccp_tipo = 'RE' and @ccp_tipoR1 in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'IA', 'IM', 'ED', 'IE'))  and (select cp_descargable from claveped where cp_codigo=@cp_rectifica)='S'
		begin

			UPDATE PIDESCARGA
			SET PIDESCARGA.PI_FEC_ENT=PEDIMP.PI_FEC_ENT, 
			PI_ACTIVOFIJO=(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
					OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
					PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END)
			FROM PIDESCARGA INNER JOIN PEDIMP ON PIDESCARGA.PI_CODIGO= PEDIMP.PI_CODIGO
				INNER JOIN PEDIMPDET ON PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED
			WHERE PIDESCARGA.PI_CODIGO=@pi_codigo and (PIDESCARGA.PI_FEC_ENT<>PEDIMP.PI_FEC_ENT or
				PI_ACTIVOFIJO<>(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
					OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
					PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END))

		end	




		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= ROUND(PEDIMPDET.PID_CAN_GEN, 6)
		FROM         PIDescarga INNER JOIN
		                      PEDIMPDET ON PIDescarga.PI_CODIGO = PEDIMPDET.PI_CODIGO AND PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED AND 
		                      PIDescarga.PID_SALDOGEN <> ROUND(PEDIMPDET.PID_CAN_GEN, 6)
		WHERE     (PIDescarga.PI_CODIGO = @pi_codigo)

		exec sp_actualizapedimpvencimiento @pi_codigo, 1
	end


GO
