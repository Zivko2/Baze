SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PEDIMPSaldo] (@PI_CODIGO int)   as



		ALTER TABLE PIDESCARGA DISABLE TRIGGER INSERT_PIDESCARGA


		insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, DI_DEST_ORIGEN)
		SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, PID_CAN_GEN, PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, 
		CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS')) then ISNULL(PEDIMPDET.PID_FECHAPEDTRANS,PEDIMP.PI_FEC_ENTPED) 
			else PEDIMP.PI_FEC_ENT end, 
		'PI_ACTIVOFIJO'=CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
					OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
					PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
		PEDIMP.DI_DEST_ORIGEN
		FROM PEDIMP LEFT OUTER JOIN
		                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
		                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
		WHERE (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (PEDIMP.PI_MOVIMIENTO='E') 
				and ((CLAVEPED.CP_DESCARGABLE = 'S' and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo not in ('RE'))) 
					or (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('RE'))  and PI_GENERASALDOF4 ='S'))
				and (pedimpdet.pid_descargable='S') 
				--AND pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
				  AND (pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga where PIDescarga.PID_INDICED =  pedimpdet.PID_INDICED))
		and ((PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED'))
		        or (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED'))
			and  CLAVEPED.cp_descargable='S'))) AND PEDIMP.PI_ESTATUS<>'R'
		AND PEDIMP.PI_CODIGO= @PI_CODIGO
		ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC




		--if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S'
		-- se les debe de generar saldo a los pedimentos que PI_GENERASALDOF4 ='S' aunque no tengan seleccionado CF_USASALDOPEDIMPDEFINITO 
		begin 
			insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
			SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, 0, PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, 
			CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS')) then ISNULL(PEDIMPDET.PID_FECHAPEDTRANS,PEDIMP.PI_FEC_ENTPED) 
			else PEDIMP.PI_FEC_ENT end, 
			'PI_ACTIVOFIJO'=CASE WHEN PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
			'S', PEDIMP.DI_DEST_ORIGEN
			FROM PEDIMP LEFT OUTER JOIN
			                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN	
			                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
			WHERE (PEDIMP.PI_MOVIMIENTO='E') and (pedimpdet.pid_descargable='S')  
			--AND pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
			  AND (pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga where PIDescarga.PID_INDICED =  pedimpdet.PID_INDICED))
			and (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IE', 'RG', 'SI', 'CN')) and PI_GENERASALDOF4 ='S')
			AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND PEDIMP.PI_ESTATUS<>'R'
			AND PEDIMP.PI_CODIGO= @PI_CODIGO
			ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC


		end



		UPDATE PIDESCARGA
		SET     PID_SALDOGEN= PEDIMPDET.PID_CAN_GEN
		FROM         PIDESCARGA INNER JOIN PEDIMPDET ON PIDESCARGA.PID_INDICED=PEDIMPDET.PID_INDICED
		WHERE round(PIDESCARGA.PID_SALDOGEN,6) <> round(PEDIMPDET.PID_CAN_GEN,6) 
		AND PIDESCARGA.PI_CODIGO= @PI_CODIGO	

	
		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0))  ,6)
		FROM         PEDIMPDET INNER JOIN
		                      PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN
		                      PIDescarga ON PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED LEFT OUTER JOIN
		                        (SELECT     SUM(KAP_CANTDESC) AS KAP_CANTDESC, KAP_INDICED_PED
		                              FROM         KARDESPED
		                              WHERE     KAP_INDICED_PED IS NOT NULL
					GROUP BY KAP_INDICED_PED) CANTDESC ON PEDIMPDET.PID_INDICED=CANTDESC.KAP_INDICED_PED LEFT OUTER JOIN
					(SELECT     SUM(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) CANTLIGA, FACTEXPDET.PID_INDICED
		                              FROM         FACTEXPDET INNER JOIN
		                                                    FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
		                              WHERE     FACTEXP.FE_ESTATUS IN ('D', 'P') AND FACTEXPDET.PID_INDICED<>-1
					GROUP BY FACTEXPdet.PID_INDICED) CANTLIGADA ON PEDIMPDET.PID_INDICED=CANTLIGADA.pid_indiced 
		WHERE     (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_MOVIMIENTO = 'E') AND (PIDescarga.PID_INDICED IS NOT NULL)
		AND PIDescarga.PID_SALDOGEN<> round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)) ,6)
		AND PEDIMP.PI_CODIGO= @PI_CODIGO		
		

	ALTER TABLE PIDESCARGA ENABLE TRIGGER INSERT_PIDESCARGA

	
	print 'actualizando el estatus del pedimento'
	EXEC SP_ACTUALIZAESTATUSPEDIMP @PI_CODIGO


		DELETE FROM PIDescarga
		WHERE PI_CODIGO IN
		(SELECT     PIDescarga.PI_CODIGO
		FROM         CLAVEPED INNER JOIN
		                      PEDIMP ON CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO INNER JOIN
		                      PIDescarga ON PEDIMP.PI_CODIGO = PIDescarga.PI_CODIGO
		WHERE     (CLAVEPED.CP_DESCARGABLE = 'N' AND isnull(PEDIMP.PI_GENERASALDOF4,'N')<>'S') OR 
			  (isnull(PEDIMP.PI_GENERASALDOF4,'N')<>'S' AND PEDIMP.PI_ESTATUS in ('R', 'E', 'F', 'G', 'N'))
		AND PEDIMP.PI_CODIGO= @PI_CODIGO		
		GROUP BY PIDescarga.PI_CODIGO)


	exec SP_actualizapedimpvencimiento @PI_CODIGO

GO
