SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE PROCEDURE [dbo].[SP_IMPORTACTUALIZASALDO] (@tabla varchar(150), @user int)   as


Declare @PI_CODIGO INT



		DECLARE cur_generasaldosimp CURSOR FOR
			SELECT     PI_CODIGO
			FROM         VPEDIMP
			WHERE     PI_TIPO IN ('A', 'T', 'N') AND PI_FOLIO IN
				(SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'PI_FOLIO = ','') 
							FROM REGISTROSIMPORTADOS
							WHERE RI_REGISTRO LIKE 'PI_FOLIO%' AND RI_TIPO='I')

			AND AGT_CODIGO IN 
			(select REPLACE(right(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-3),' AGT_CODIGO = ','') from REGISTROSIMPORTADOS)
		open cur_generasaldosimp  
		
		
			FETCH NEXT FROM cur_generasaldosimp into @PI_CODIGO
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		

				delete from pidescarga where pi_codigo=@PI_CODIGO

				insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, DI_DEST_ORIGEN)
				SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, round(PID_CAN_GEN,6), PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
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
				and (pedimpdet.pid_descargable='S') AND PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
				and ((PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED'))
				        or (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED', 'IE'))
					and  CLAVEPED.cp_descargable='S'))) AND PEDIMP.PI_CODIGO=@PI_CODIGO
				ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC



				EXEC sp_actualizapedimpvencimiento @PI_CODIGO
		
			FETCH NEXT FROM cur_generasaldosimp into @PI_CODIGO
		
		END
		
		CLOSE cur_generasaldosimp
		DEALLOCATE cur_generasaldosimp























GO
