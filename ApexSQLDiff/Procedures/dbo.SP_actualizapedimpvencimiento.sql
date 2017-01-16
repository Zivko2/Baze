SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_actualizapedimpvencimiento] (@picodigo int, @user int=1)   as

SET NOCOUNT ON 
declare @ccp_tipo varchar(5), @FechaActual varchar(10), @hora varchar(15), @em_codigo int, @ccp_tipo2 varchar(5)
--<GIB> 2011.01.31 Para agregar cambio de temporalidad del RCGMCE XXVII (DOF 2010-12-24)
declare @EmpCertificada bit
set @EmpCertificada = 0
if (SELECT  CL_EMPCERTIFICADA FROM dbo.CLIENTE WHERE CL_EMPRESA = 'S') is not null
	set @EmpCertificada = 1


	SET @FechaActual = convert(varchar(10), getdate(),101)
	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)


	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Actualizando fecha de vencimiento detalle ', 'Updating Detail Exparation Date ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@picodigo)


	if exists (select * from pedimpdet where pi_codigo=@picodigo)
	begin
		if @ccp_tipo in ('ts') --aviso de traslado
		begin
			UPDATE dbo.PIDescarga
			SET dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PIDescarga.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
			FROM dbo.CONFIGURATIEMPO 
				INNER JOIN dbo.PEDIMPDET ON dbo.CONFIGURATIEMPO.TI_CODIGO = dbo.PEDIMPDET.TI_CODIGO 
					AND dbo.CONFIGURATIEMPO.CP_CODIGO = dbo.PEDIMPDET.CP_TRANS 
				INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED
				inner join dbo.pedimp on dbo.pidescarga.pi_codigo = dbo.pedimp.pi_codigo
	                AND dbo.PEDIMP.pi_fec_ent BETWEEN CONFIGURATIEMPO.COT_FechaInicial AND CONFIGURATIEMPO.COT_FechaFinal
			WHERE (dbo.PEDIMPDET.PI_CODIGO = @picodigo) 
		end
		else
		if @ccp_tipo in ('im', 'it', 'iv', 'vt', 're', 'cs') 
		begin
			if @ccp_tipo in ('im', 'it', 'iv', 'vt', 'cs') 
			UPDATE dbo.PIDescarga
			SET dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
			FROM dbo.PEDIMP 
				INNER JOIN dbo.CONFIGURATIEMPO ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURATIEMPO.CP_CODIGO 
				INNER JOIN dbo.PEDIMPDET ON dbo.CONFIGURATIEMPO.TI_CODIGO = dbo.PEDIMPDET.TI_CODIGO 
				   AND dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
				INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
				   AND dbo.PEDIMP.pi_fec_ent BETWEEN CONFIGURATIEMPO.COT_FechaInicial AND CONFIGURATIEMPO.COT_FechaFinal
			WHERE (dbo.PEDIMP.PI_CODIGO = @picodigo) 


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
			AND (dbo.PEDIMP.PI_CODIGO = @picodigo) 



			-- H2 que quedaron vacios por el tipo de material
			/*UPDATE dbo.PIDescarga
			SET     dbo.PIDescarga.pid_fechavence=CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) +18 * 30.416, 0)) 
			FROM         dbo.PIDescarga INNER JOIN
			                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED INNER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMP.CP_CODIGO IN
			                          (SELECT cp_codigo
			                            FROM configuraclaveped
			                            WHERE ccp_tipo IN ('it'))) AND (dbo.PIDescarga.pid_fechavence IS NULL)
			AND (dbo.PEDIMP.PI_CODIGO = @picodigo) 
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
				AND (dbo.PEDIMP.PI_CODIGO = @picodigo) 



			if @ccp_tipo in ('re') 
			begin
				select @ccp_tipo2=ccp_tipo from configuraclaveped where cp_codigo in (select cp_rectifica from pedimp where pi_codigo=@picodigo)

				if @ccp_tipo2 in ('im', 'it', 'iv', 'vt', 'cs') 
				begin
					if (select cp_rectifica from pedimp where pi_codigo=@picodigo) is not null
						UPDATE dbo.PIDescarga
						SET dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
						FROM dbo.PEDIMP 
							INNER JOIN dbo.CONFIGURATIEMPO ON dbo.PEDIMP.CP_RECTIFICA = dbo.CONFIGURATIEMPO.CP_CODIGO 
							INNER JOIN dbo.PEDIMPDET ON dbo.CONFIGURATIEMPO.TI_CODIGO = dbo.PEDIMPDET.TI_CODIGO 
								AND dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
							INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
								AND dbo.PEDIMP.pi_fec_ent BETWEEN CONFIGURATIEMPO.COT_FechaInicial AND CONFIGURATIEMPO.COT_FechaFinal
						WHERE (dbo.PEDIMP.PI_CODIGO = @picodigo)
					else
						UPDATE dbo.PIDescarga
						SET dbo.PIDescarga.PID_FECHAVENCE= CONVERT(DATETIME, ROUND(CONVERT(decimal(38,6), PEDIMP_1.PI_FEC_ENT) + dbo.CONFIGURATIEMPO.COT_TIEMPO * 30.416, 0)) 
						FROM dbo.PEDIMPDET 
						        inner join dbo.CONFIGURATIEMPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIEMPO.TI_CODIGO
							INNER JOIN dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO 
							INNER JOIN dbo.PEDIMP PEDIMP_1 ON dbo.PEDIMP.PI_RECTIFICA = PEDIMP_1.PI_CODIGO 
								AND dbo.CONFIGURATIEMPO.CP_CODIGO = PEDIMP_1.CP_CODIGO 
							INNER JOIN dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
								AND dbo.PEDIMP.pi_fec_ent BETWEEN dbo.CONFIGURATIEMPO.COT_FechaInicial AND dbo.CONFIGURATIEMPO.COT_FechaFinal
						WHERE (dbo.PEDIMP.PI_CODIGO = @picodigo)
				end
				else
					UPDATE PIDescarga
					SET     PID_FECHAVENCE= '01/01/9999' 
					FROM PEDIMPDET INNER JOIN PIDescarga ON
					PEDIMPDET.PID_INDICED=PIDescarga.PID_INDICED
					WHERE (PEDIMPDET.PI_CODIGO = @picodigo) 
	
			end



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
			AND (dbo.PEDIMP.PI_CODIGO = @picodigo) 


		end
		else
		begin
			UPDATE PIDescarga
			SET     PID_FECHAVENCE= '01/01/9999' 
			FROM PEDIMPDET INNER JOIN PIDescarga ON
			PEDIMPDET.PID_INDICED=PIDescarga.PID_INDICED
			WHERE (PEDIMPDET.PI_CODIGO = @picodigo) 

		end
	end
GO
