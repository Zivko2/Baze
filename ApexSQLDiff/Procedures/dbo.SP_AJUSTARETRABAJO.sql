SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_AJUSTARETRABAJO] (@fecha datetime)   as

declare @RestaDescargar decimal(38,6), @MA_CODIGO int, @MA_GENERICO int, @PI_FEC_ENT datetime, @PID_FECHAVENCE datetime,
@FED_INDICED INT, @fed_cant decimal(38,6), @fQtyADescargar decimal(38,6)
	


-- los pedimentos a cerrar, que incluyen pt's
declare cur_ajustaretrabajo cursor for
	SELECT     SUM(PIDescarga.PID_SALDOGEN) AS CANTIDAD, PIDescarga.MA_CODIGO, PIDescarga.MA_GENERICO, PIDescarga.PI_FEC_ENT, 
	                      PIDescarga.pid_fechavence
	FROM         PIDescarga INNER JOIN
	                      MAESTRO ON PIDescarga.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
	                      PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
	                      PEDIMP ON PIDescarga.PI_CODIGO = PEDIMP.PI_CODIGO
	WHERE     (MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO  FROM CONFIGURATIPO WHERE CFT_TIPO = 'P')) 
		     AND (PIDescarga.PI_ACTIVOFIJO = 'N') AND PIDescarga.PID_SALDOGEN>0
	  	     AND PIDescarga.PI_FEC_ENT<=@fecha
	GROUP BY PIDescarga.MA_CODIGO, PIDescarga.MA_GENERICO, PIDescarga.PI_FEC_ENT, PIDescarga.pid_fechavence
	ORDER BY SUM(PIDescarga.PID_SALDOGEN), PIDescarga.MA_CODIGO

open cur_ajustaretrabajo

	FETCH NEXT FROM cur_ajustaretrabajo INTO @RestaDescargar, @MA_CODIGO, @MA_GENERICO, @PI_FEC_ENT, @PID_FECHAVENCE

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

			declare cur_ajustafactsinDescargar cursor for		
				-- busqueda de fed_indiced donde se pueden descargar que sean producto terminado o subensamble, que la fecha de la factura sea menor a la fecha de vencimiento,
				-- que la fecha de la factura sea mayor que las del pedimento, que la fecha de la factura sea menor que la fecha final (para que se descargen solo las que corresponden al periodo)
				-- que no esten descargadas
				SELECT dbo.FACTEXPDET.FED_INDICED
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
		              		        dbo.CONFIGURATFACT ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO
				WHERE     dbo.FACTEXP.FE_FECHA < @PID_FECHAVENCE AND dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT
				            AND dbo.FACTEXP.FE_DESCARGADA='N' AND dbo.FACTEXP.FE_CANCELADO='N'
					    AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') 
					AND (dbo.FACTEXP.TQ_CODIGO = 3 OR
				                      dbo.FACTEXP.TQ_CODIGO = 12) 
					AND dbo.FACTEXPDET.FED_INDICED IN (SELECT     dbo.FACTEXPDET.FED_INDICED
									FROM         dbo.FACTEXPDET INNER JOIN
									                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
									WHERE     (dbo.FACTEXPDET.MA_CODIGO =@MA_CODIGO OR dbo.FACTEXPDET.MA_GENERICO = @MA_GENERICO) AND
										   dbo.FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO  FROM CONFIGURATIPO
														       WHERE      CFT_TIPO = 'P') AND 
									                      dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT and dbo.FACTEXPDET.FED_CANT >0
											      AND dbo.FACTEXPDET.FED_RETRABAJO='N')
				
				group by dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
				ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
			open cur_ajustafactsinDescargar
			
				FETCH NEXT FROM cur_ajustafactsinDescargar INTO @FED_INDICED
			
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN
	
					select @fed_cant=fed_cant from factexpdet where fed_indiced=@FED_INDICED
	
	
						if @RestaDescargar>0
						begin
							if @fed_cant>=@RestaDescargar
							begin
								set @fQtyADescargar=@RestaDescargar
								set @RestaDescargar=0
							end
							
							if @fed_cant<@RestaDescargar
							begin
								set @fQtyADescargar=@fed_cant
								set @RestaDescargar=@RestaDescargar-@fed_cant
	
							end
	
							update factexpdet 
							set fed_retrabajo ='R'
							where fed_indiced=@FED_INDICED
						end
	
						if @RestaDescargar=0
						break
	
	
				FETCH NEXT FROM cur_ajustafactsinDescargar INTO @FED_INDICED
	
				END
				
				CLOSE cur_ajustafactsinDescargar
				DEALLOCATE cur_ajustafactsinDescargar
	
	



	FETCH NEXT FROM cur_ajustaretrabajo INTO @RestaDescargar, @MA_CODIGO, @MA_GENERICO, @PI_FEC_ENT, @PID_FECHAVENCE

END

CLOSE cur_ajustaretrabajo
DEALLOCATE cur_ajustaretrabajo






























GO
