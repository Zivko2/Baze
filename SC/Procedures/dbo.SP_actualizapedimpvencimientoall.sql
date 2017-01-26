SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





/* procedimiento para actualizar tiempo por tipo, este es el que se corre al entrar por primera vez en el dia */
CREATE PROCEDURE [dbo].[SP_actualizapedimpvencimientoall]     as
			declare @EmpCertificada bit
		set @EmpCertificada = 0
		if (SELECT  CL_EMPCERTIFICADA FROM dbo.CLIENTE WHERE CL_EMPRESA = 'S') is not null
			set @EmpCertificada = 1


		UPDATE dbo.PIDescarga
		SET dbo.PIDescarga.PID_FECHAVENCE = CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
		FROM dbo.PEDIMP INNER JOIN dbo.CONFIGURATIEMPO ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURATIEMPO.CP_CODIGO 
						INNER JOIN dbo.PEDIMPDET ON dbo.CONFIGURATIEMPO.TI_CODIGO = dbo.PEDIMPDET.TI_CODIGO AND dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
						INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
							AND dbo.PEDIMP.pi_fec_ent BETWEEN dbo.CONFIGURATIEMPO.COT_FechaInicial AND dbo.CONFIGURATIEMPO.COT_FechaFinal
		WHERE dbo.PEDIMP.CP_CODIGO in (SELECT cp_codigo FROM configuraclaveped WHERE ccp_tipo IN ('im', 'it', 'iv', 'vt', 'cs'))
              AND IsNull(dbo.PIDescarga.PID_FECHAVENCE,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 

		UPDATE dbo.PIDescarga
		SET     dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PIDescarga.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
		FROM dbo.PEDIMPDET 
			INNER JOIN dbo.CONFIGURATIEMPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIEMPO.TI_CODIGO 
				AND dbo.PEDIMPDET.CP_TRANS = dbo.CONFIGURATIEMPO.CP_CODIGO 
			INNER JOIN dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO 
			INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED 
				AND dbo.PEDIMP.pi_fec_ent BETWEEN dbo.CONFIGURATIEMPO.COT_FechaInicial AND dbo.CONFIGURATIEMPO.COT_FechaFinal
		WHERE dbo.PEDIMP.CP_CODIGO IN (SELECT cp_codigo FROM configuraclaveped WHERE ccp_tipo IN ('ts'))
     		  AND IsNull(dbo.PIDescarga.PID_FECHAVENCE,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PIDescarga.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 

		-- rectificaciones (r1)
			UPDATE dbo.PIDescarga
			SET dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
			FROM dbo.PEDIMP 
				INNER JOIN dbo.CONFIGURATIEMPO ON dbo.PEDIMP.CP_RECTIFICA = dbo.CONFIGURATIEMPO.CP_CODIGO 
				INNER JOIN dbo.PEDIMPDET ON dbo.CONFIGURATIEMPO.TI_CODIGO = dbo.PEDIMPDET.TI_CODIGO 
					AND dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
				INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
				    AND dbo.PEDIMP.pi_fec_ent BETWEEN dbo.CONFIGURATIEMPO.COT_FechaInicial AND dbo.CONFIGURATIEMPO.COT_FechaFinal
			WHERE dbo.PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in('im', 'it', 'iv', 'vt', 'cs')) 
				  AND dbo.PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in('re'))
				  AND isnull(dbo.PIDescarga.PID_FECHAVENCE,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 


			UPDATE dbo.PIDescarga
			SET dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), PEDIMP_1.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
			FROM dbo.PEDIMPDET 
				INNER JOIN dbo.CONFIGURATIEMPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIEMPO.TI_CODIGO 
				INNER JOIN dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO 
				INNER JOIN dbo.PEDIMP PEDIMP_1 ON dbo.PEDIMP.PI_RECTIFICA = PEDIMP_1.PI_CODIGO 
					AND dbo.CONFIGURATIEMPO.CP_CODIGO = PEDIMP_1.CP_CODIGO 
				INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
				    AND dbo.PEDIMP.pi_fec_ent BETWEEN dbo.CONFIGURATIEMPO.COT_FechaInicial AND dbo.CONFIGURATIEMPO.COT_FechaFinal
			WHERE dbo.PEDIMP.CP_RECTIFICA IS NULL 
				  AND dbo.PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in('re'))
				  AND isnull(dbo.PIDescarga.PID_FECHAVENCE,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), PEDIMP_1.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 


			UPDATE PIDescarga
			SET     PID_FECHAVENCE= '01/01/9999'
			FROM         dbo.PIDescarga INNER JOIN
			                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     dbo.PEDIMP.CP_RECTIFICA not in  (select cp_codigo from configuraclaveped where ccp_tipo in('im', 'it', 'iv', 'vt', 'cs')) AND
				  dbo.PEDIMP.CP_CODIGO in  (select cp_codigo from configuraclaveped where ccp_tipo in('re'))
				and PID_FECHAVENCE is null

			


		UPDATE PIDescarga
		SET     PID_FECHAVENCE= '01/01/9999'
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
		                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
		WHERE     dbo.PEDIMP.CP_CODIGO not in  (select cp_codigo from configuraclaveped where ccp_tipo in('im', 'it', 'iv', 'vt', 'cs'))
		and PID_FECHAVENCE is null

		-- compra nacional
		UPDATE PIDescarga
		SET     PID_FECHAVENCE= '01/01/9999'
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
		                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN 
				dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO=dbo.CLAVEPED.CP_CODIGO
		WHERE     dbo.CLAVEPED.CP_CLAVE ='CN' and isnull(PID_FECHAVENCE,'')<> '01/01/9999'


		-- H3 que quedaron vacios por el tipo de material
		UPDATE dbo.PIDescarga
		SET     dbo.PIDescarga.pid_fechavence=CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + 60 * 30.416, 0)) 
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
		                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
		WHERE     (dbo.PEDIMP.CP_CODIGO IN
		                          (SELECT     cp_codigo
		                            FROM          configuraclaveped
		                            WHERE      ccp_tipo IN ('im'))) AND (dbo.PIDescarga.pid_fechavence IS NULL)
		  AND isnull(dbo.PIDescarga.pid_fechavence,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + 60 * 30.416, 0)) 


-- H2 que quedaron vacios por el tipo de material
		/*UPDATE dbo.PIDescarga
		SET     dbo.PIDescarga.pid_fechavence=CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
		                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
		WHERE     (dbo.PEDIMP.CP_CODIGO IN
		                          (SELECT     cp_codigo
		                            FROM          configuraclaveped
		                            WHERE      ccp_tipo IN ('it'))) AND (dbo.PIDescarga.pid_fechavence IS NULL)
		  AND isnull(dbo.PIDescarga.pid_fechavence,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
		*/
		--<GIB> 2011.01.31 Para agregar cambio de temporalidad del RCGMCE XXVII (DOF 2010-12-24)
		DECLARE @FechaMinima as datetime;
		DECLARE @FechaTemporal as datetime;
		SELECT @FechaTemporal = CL_FECHAREGEMPCERTIFICADA FROM dbo.CLIENTE WHERE CL_EMPRESA = 'S'
		--SET @FechaMinima = CASE WHEN (@FechaTemporal > '2009-06-25') THEN @FechaTemporal ELSE '2009-06-25' END

		if @FechaTemporal is null
		begin 
			set @FechaMinima = '1900-01-01'
		end
		else 
		begin
			--2011-03-09
			--SET @FechaMinima = CASE WHEN (@FechaTemporal > '2009-06-25') THEN @FechaTemporal ELSE '2009-06-25' END
			SET @FechaMinima = CASE WHEN (@FechaTemporal > '2010-12-25') THEN @FechaTemporal ELSE CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), convert(datetime,'2010-12-25 00:00:00.000')) - 18 * 30.416, 0)) END
		end



		UPDATE dbo.PIDescarga
		SET dbo.PIDescarga.pid_fechavence = CASE WHEN ISNULL((SELECT cl_empCertificada FROM cliente WHERE cl_empresa = 'S'),'') <>''  AND LTRIM(RTRIM((SELECT cl_empCertificada FROM cliente WHERE cl_empresa = 'S'))) <>''
			AND dbo.PEDIMP.pi_fec_ent >= @FechaMinima and @EmpCertificada = 1 THEN
			   --2011-03-10
			   --CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +36 * 30.416, 0)) 
				case when (select count(*) from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo = dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal) = 0 then 
					CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +36 * 30.416, 0)) 
				else
					CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + (select cot_tiempo from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo =  dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal)    * 30.416, 0)) 
				end
			ELSE 
			   --2011-03-10
			   --CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
				case when (select count(*) from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo = dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal) = 0 then 
					CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
				else
					CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + (select cot_tiempo from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo =  dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal)    * 30.416, 0)) 
				end
			END
		FROM dbo.PIDescarga 
			INNER JOIN dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED 
			INNER JOIN dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
		WHERE (dbo.PEDIMP.CP_CODIGO IN
				( SELECT cp_codigo
		          FROM configuraclaveped
		          WHERE ccp_tipo IN ('it'))
                 ) 
                 AND (dbo.PIDescarga.pid_fechavence IS NULL)
                 AND ISNULL(dbo.PIDescarga.pid_fechavence,'') <> CASE WHEN ISNULL((SELECT cl_empCertificada FROM cliente WHERE cl_empresa = 'S'),'') <>''  AND LTRIM(RTRIM((SELECT cl_empCertificada FROM cliente WHERE cl_empresa = 'S'))) <>''
				 AND dbo.PEDIMP.pi_fec_ent >= @FechaMinima and @EmpCertificada = 1 THEN
			   			--2011-03-10
						--CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +36 * 30.416, 0)) 
						case when (select count(*) from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo = dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal) = 0 then 
							CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +36 * 30.416, 0)) 
						else
							CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + (select cot_tiempo from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo =  dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal)    * 30.416, 0)) 
						end
					ELSE 
			   			--2011-03-10
						--CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
						case when (select count(*) from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo = dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal) = 0 then 
							CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
						else
							CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + (select cot_tiempo from dbo.configuratiempo where dbo.configuratiempo.ti_codigo = dbo.PEDIMPDET.ti_codigo and dbo.configuratiempo.cp_codigo =  dbo.PEDIMP.CP_CODIGO and dbo.PEDIMP.pi_fec_ent between dbo.configuratiempo.cot_fechaInicial and dbo.configuratiempo.cot_fechaFinal)    * 30.416, 0)) 
						end

					END

		UPDATE dbo.PIDescarga
		SET     dbo.PIDescarga.pid_fechavence=CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +dbo.TIPO.TI_PERMCIAMESES * 30.416, 0)) 
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
		                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO INNER JOIN dbo.TIPO ON 
				dbo.PEDIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO
		WHERE     (dbo.PEDIMP.CP_CODIGO IN
		                          (SELECT     cp_codigo
		                            FROM          configuraclaveped
		                            WHERE      ccp_tipo IN ('it', 're','vt')))  AND (dbo.TIPO.TI_PERMCIAMESES<>-1)
		  AND isnull(dbo.PIDescarga.pid_fechavence,'') <> CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +dbo.TIPO.TI_PERMCIAMESES * 30.416, 0))


GO
