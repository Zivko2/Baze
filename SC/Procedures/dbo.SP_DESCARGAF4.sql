SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_DESCARGAF4]   as

DECLARE @F4_CANTDESC decimal(38,6), @PI_CODIGO int, @MA_CODIGO int, @FED_INDICED int, @PID_INDICED int, @PID_SALDOGEN decimal(38,6),
@fQtyADescargar decimal(38,6),  @kap_estatus char(1), @fSaldoPedimento decimal(38,6), @fQtyTotDesc decimal(38,6), @FE_FECHA varchar(11)
, @FE_CODIGO  int, @MA_NOPARTE VARCHAR(30), @PEDIMENTO VARCHAR(15), @DI_PROD INT


--borra los errores generados en otras importaciones
DELETE FROM IMPORTLOG WHERE IML_CBFORMA=51

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS


	
	UPDATE dbo.DESCARGAF4
	SET     dbo.DESCARGAF4.FED_INDICED= dbo.FACTEXPDET.FED_INDICED 
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
	                      dbo.DESCARGAF4 ON dbo.FACTEXP.FE_FOLIO = dbo.DESCARGAF4.F4_FOLIO AND 
	                      dbo.FACTEXPDET.FED_NOPARTE = dbo.DESCARGAF4.F4_NOPARTEEXP AND dbo.FACTEXPDET.FED_CANT = dbo.DESCARGAF4.F4_CANTIDADEXP 
	WHERE dbo.DESCARGAF4.FED_INDICED IS NULL




declare cur_DescargaF4_1 cursor for
	SELECT     dbo.FACTEXP.FE_CODIGO, CONVERT(VARCHAR(11),dbo.FACTEXP.FE_FECHA,101), dbo.FACTEXP.DI_PROD
	FROM        dbo.DESCARGAF4 INNER JOIN 
	                      dbo.FACTEXP ON dbo.DESCARGAF4.F4_FOLIO = dbo.FACTEXP.FE_FOLIO
	where F4_FOLIO is not null and F4_FOLIO<>''
	GROUP BY  dbo.FACTEXP.FE_CODIGO, CONVERT(VARCHAR(11),dbo.FACTEXP.FE_FECHA,101), dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.DI_PROD
	ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
open cur_DescargaF4_1
	FETCH NEXT FROM cur_DescargaF4_1 INTO @FE_CODIGO, @FE_FECHA, @DI_PROD
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		   EXEC SP_CreaVPIDescarga 'M', @fe_fecha, @DI_PROD



		declare cur_DescargaF4 cursor for
			SELECT     TOP 100 PERCENT ROUND(dbo.DESCARGAF4.F4_CANTDESC, 6), dbo.VPEDIMP.PI_CODIGO, dbo.MAESTRO.MA_CODIGO, 
			                      dbo.DESCARGAF4.FED_INDICED, ROUND(F4_CANTTOTDESC,6), dbo.MAESTRO.MA_NOPARTE, F4_PATENTEIMP+'-'+F4_PEDIMENTOIMP
			FROM         dbo.VPEDIMP INNER JOIN
			                      dbo.DESCARGAF4 ON dbo.VPEDIMP.PI_FOLIO = dbo.DESCARGAF4.F4_PEDIMENTOIMP INNER JOIN
			                      dbo.MAESTRO ON dbo.DESCARGAF4.F4_NOPARTEDESC = dbo.MAESTRO.MA_NOPARTE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.DESCARGAF4.FED_INDICED = dbo.FACTEXPDET.FED_INDICED INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
			                      dbo.AGENCIAPATENTE ON dbo.VPEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO AND 
			                      dbo.DESCARGAF4.F4_PATENTEIMP = dbo.AGENCIAPATENTE.AGT_PATENTE
			WHERE dbo.FACTEXPDET.FE_CODIGO=@FE_CODIGO
			ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO, dbo.VPEDIMP.PI_FEC_ENT, dbo.DESCARGAF4.F4_CODIGO
		
		open cur_DescargaF4
			FETCH NEXT FROM cur_DescargaF4 INTO @F4_CANTDESC, @PI_CODIGO, @MA_CODIGO, @FED_INDICED, @fQtyTotDesc, @MA_NOPARTE, @PEDIMENTO
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		
				--set @fQtyTotDesc=@F4_CANTDESC

	
					if (SELECT     count(PID_INDICED)
					FROM         vPIDescarga
					WHERE     (PI_CODIGO = @PI_CODIGO) AND (MA_CODIGO = @MA_CODIGO)
						and PID_SALDOGEN>0 AND PI_FEC_ENT <= @FE_FECHA)>0
					begin
						-- si solo se encuentra un solo registro en el pedimento con ese numero de parte
						if (SELECT     count(PID_INDICED)
						FROM         vPIDescarga
						WHERE     (PI_CODIGO = @PI_CODIGO) AND (MA_CODIGO = @MA_CODIGO)
							and PID_SALDOGEN>0 AND PI_FEC_ENT <= @FE_FECHA)=1
						begin
			
							SELECT     @PID_INDICED=PID_INDICED, @PID_SALDOGEN=PID_SALDOGEN
							FROM         vPIDescarga
							WHERE     (PI_CODIGO = @PI_CODIGO) AND (MA_CODIGO = @MA_CODIGO)
								and PID_SALDOGEN>0 AND PI_FEC_ENT <= @FE_FECHA
							
							/*Aqui manipulamos las cantidades*/
							if ROUND(@PID_SALDOGEN,6) >= round(@F4_CANTDESC,6) 
							begin
								set @fQtyADescargar = ROUND(@F4_CANTDESC,6) 
								set @F4_CANTDESC  = 0
			
								if ROUND(@PID_SALDOGEN,6) > round(@fQtyADescargar,6)
								set @fSaldoPedimento = ROUND(ROUND(@PID_SALDOGEN,6) - round(@fQtyADescargar,6),6)
								else
								set @fSaldoPedimento = 0
			
							end
							else
							begin
								set @fQtyADescargar = ROUND(@PID_SALDOGEN,6) 
								set @fSaldoPedimento = 0
								set @F4_CANTDESC  = round((@F4_CANTDESC - @fQtyADescargar),6)
							end
			/*
			
							if @F4_CANTDESC>0 
							set @kap_estatus ='P'
							else
							set @kap_estatus ='D'*/
			
							INSERT INTO KARDESPEDtemp(KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, 
										KAP_CANTDESC, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_FisComp)
										
									VALUES (@FE_CODIGO, @FED_INDICED, @PID_INDICED, @MA_CODIGO, 'N',
										@fQtyADescargar, @fQtyTotDesc, @F4_CANTDESC, 'N')
							
							update pidescarga
							set pid_saldogen=@fSaldoPedimento
							where pid_indiced=@PID_INDICED
										
			
				
				
						end
						else
						begin
				
							declare cur_DescargaPedF4 cursor for
								SELECT     PID_INDICED, PID_SALDOGEN
								FROM         vPIDescarga
								WHERE     (PI_CODIGO = @PI_CODIGO) AND (MA_CODIGO = @MA_CODIGO)
									and PID_SALDOGEN>0 AND PI_FEC_ENT <= @FE_FECHA
							open cur_DescargaPedF4
								FETCH NEXT FROM cur_DescargaPedF4 INTO @PID_INDICED, @PID_SALDOGEN
								WHILE (@@FETCH_STATUS = 0) 
								BEGIN
									
									if @F4_CANTDESC>0
									begin
										/*Aqui manipulamos las cantidades*/
										if ROUND(@PID_SALDOGEN,6) >= round(@F4_CANTDESC,6) 
										begin
											set @fQtyADescargar = ROUND(@F4_CANTDESC,6) 
											set @F4_CANTDESC  = 0
						
											if ROUND(@PID_SALDOGEN,6) > round(@fQtyADescargar,6)
											set @fSaldoPedimento = ROUND(ROUND(@PID_SALDOGEN,6) - round(@fQtyADescargar,6),6)
											else
											set @fSaldoPedimento = 0
						
										end
										else
										begin
											set @fQtyADescargar = ROUND(@PID_SALDOGEN,6) 
											set @fSaldoPedimento = 0
											set @F4_CANTDESC  = round((@F4_CANTDESC - @fQtyADescargar),6)
										end
						
			/*
										if @F4_CANTDESC>0 
										set @kap_estatus ='P'
										else
										set @kap_estatus ='D'*/
						
						
										INSERT INTO KARDESPEDtemp(KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, 
													KAP_CANTDESC, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_FisComp)
													
												VALUES (@FE_CODIGO, @FED_INDICED, @PID_INDICED, @MA_CODIGO, 'N',
													@fQtyADescargar, @fQtyTotDesc, @F4_CANTDESC, 'N')

										/*
										PRINT @FE_CODIGO
										PRINT  @FED_INDICED
										PRINT @PID_INDICED 
										PRINT @MA_CODIGO
										PRINT @fQtyADescargar
										PRINT  @fQtyTotDesc
										PRINT @F4_CANTDESC*/

										
										update pidescarga
										set pid_saldogen=@fSaldoPedimento
										where pid_indiced=@PID_INDICED
									end
				
				
				
								FETCH NEXT FROM cur_DescargaPedF4 INTO @PID_INDICED, @PID_SALDOGEN
							
							END
							
							CLOSE cur_DescargaPedF4
							DEALLOCATE cur_DescargaPedF4
						end
					end
					else
					begin

						INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
						VALUES('No se puede importar La Descarga del No. Parte : ' + @MA_NOPARTE + ' porque no existe en el Pedimento '+@PEDIMENTO, 51)

					end


					    exec SP_ESTATUSKARDESPEDFED @fed_indiced
		
			FETCH NEXT FROM cur_DescargaF4 INTO @F4_CANTDESC, @PI_CODIGO, @MA_CODIGO, @FED_INDICED, @fQtyTotDesc, @MA_NOPARTE, @PEDIMENTO
		
		END
		
		CLOSE cur_DescargaF4
		DEALLOCATE cur_DescargaF4


	
		EXEC SP_FILL_KARDESPED
	
		update factexp
		set fe_fechadescarga=getdate(),
		fe_descargada='S', fe_descmanual='S'
		where fe_codigo=@FE_CODIGO and (fe_fechadescarga is null or fe_fechadescarga='')


		FETCH NEXT FROM cur_DescargaF4_1 INTO @FE_CODIGO, @FE_FECHA, @DI_PROD

END

CLOSE cur_DescargaF4_1
DEALLOCATE cur_DescargaF4_1




/*llena la tabl de kardesped y el estatus de la factura */



	EXEC sp_reestructuradescargas 1

GO
