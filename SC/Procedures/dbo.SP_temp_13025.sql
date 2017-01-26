SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE PROCEDURE [dbo].[SP_temp_13025]   as



		UPDATE PEDIMP
	SET PI_DESP_EQUIPO='S'
	WHERE PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV'))
	AND PI_CODIGO IN (SELECT PI_CODIGO FROM PEDIMPDET INNER JOIN CONFIGURATIPO ON PEDIMPDET.TI_CODIGO=CONFIGURATIPO.TI_CODIGO
			WHERE CFT_TIPO IN ('C','H','Q','X') GROUP BY PI_CODIGO)
	AND (PI_DESP_EQUIPO<>'S' OR PI_DESP_EQUIPO IS NULL)


	UPDATE PIDESCARGA
	SET PI_ACTIVOFIJO=(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
				OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) THEN 'S' ELSE 'N' END)
	FROM PEDIMP LEFT OUTER JOIN PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO INNER JOIN PIDESCARGA
		ON PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
	WHERE PI_ACTIVOFIJO<>(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
				OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) THEN 'S' ELSE 'N' END) 




GO
