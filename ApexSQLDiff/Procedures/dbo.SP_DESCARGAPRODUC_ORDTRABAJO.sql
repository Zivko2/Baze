SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_DESCARGAPRODUC_ORDTRABAJO] (@pro_codigo int)   as

SET NOCOUNT ON 

declare @MA_CODIGO int, @PROD_CANT decimal(38,6), @PROD_INDICED int, @PRO_FECHA datetime,
@OTD_SALDO decimal(38,6), @OT_CODIGO int, @OTD_INDICED int, @fQtyADescargar  decimal(38,6), @fSaldoOrdTrabajo decimal(38,6), @fSaldoDescargar decimal(38,6),
@FechaActual datetime, @cantpendiente decimal(38,6), @prod_tipodescarga char(1), @OTDP_INDICEP INT, @CantDescargada decimal(38,6)
						
  SET @FechaActual = convert(varchar(10), getdate(),101)						

declare cur_descproduc cursor for

	SELECT     dbo.PRODUCDET.MA_CODIGO, dbo.PRODUCDET.PROD_CANT, dbo.PRODUCDET.PROD_INDICED, dbo.PRODUC.PRO_FECHA
	FROM         dbo.PRODUCDET INNER JOIN
	                      dbo.PRODUC ON dbo.PRODUCDET.PRO_CODIGO = dbo.PRODUC.PRO_CODIGO
	WHERE     (dbo.PRODUCDET.PRO_CODIGO = @PRO_CODIGO) and (dbo.PRODUCDET.PROD_CANTPEND > 0)

open cur_descproduc


	FETCH NEXT FROM cur_descproduc INTO @MA_CODIGO, @PROD_CANT, @PROD_INDICED, @PRO_FECHA

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		-- es produccion normal o retrabajo
		select @prod_tipodescarga=prod_tipodescarga from PRODUCDET where PROD_INDICED=@PROD_INDICED
		set @CantDescargada=0

		if exists (SELECT     dbo.ORDTRABAJODETENTPARCIAL.OTDP_SALDO
			FROM         dbo.ORDTRABAJODET INNER JOIN
			                      dbo.ORDTRABAJO ON dbo.ORDTRABAJODET.OT_CODIGO = dbo.ORDTRABAJO.OT_CODIGO LEFT OUTER JOIN
			                      dbo.ORDTRABAJODETENTPARCIAL ON dbo.ORDTRABAJODET.OTD_INDICED = dbo.ORDTRABAJODETENTPARCIAL.OTD_INDICED
			WHERE     (dbo.ORDTRABAJODET.MA_CODIGO = @MA_CODIGO) AND (dbo.ORDTRABAJO.OT_FECHAINI <= @PRO_FECHA) 
					AND (dbo.ORDTRABAJO.OT_ESTATUS <> 'K') AND (dbo.ORDTRABAJODETENTPARCIAL.OTDP_SALDO > 0))
--				and dbo.ORDTRABAJO.OT_TIPO=@prod_tipodescarga)
		begin
			declare cur_descordtrabajo cursor for
			SELECT     TOP 100 PERCENT dbo.ORDTRABAJODETENTPARCIAL.OTDP_SALDO, dbo.ORDTRABAJODET.OT_CODIGO, dbo.ORDTRABAJODET.OTD_INDICED, 
			                      dbo.ORDTRABAJODETENTPARCIAL.OTDP_INDICEP
			FROM         dbo.ORDTRABAJODET INNER JOIN
			                      dbo.ORDTRABAJO ON dbo.ORDTRABAJODET.OT_CODIGO = dbo.ORDTRABAJO.OT_CODIGO LEFT OUTER JOIN
			                      dbo.ORDTRABAJODETENTPARCIAL ON dbo.ORDTRABAJODET.OTD_INDICED = dbo.ORDTRABAJODETENTPARCIAL.OTD_INDICED
			WHERE     (dbo.ORDTRABAJODET.MA_CODIGO = @MA_CODIGO) AND (dbo.ORDTRABAJO.OT_FECHAINI <= @PRO_FECHA) 
					AND (dbo.ORDTRABAJO.OT_ESTATUS <> 'K') AND (dbo.ORDTRABAJODETENTPARCIAL.OTDP_SALDO > 0) 
--				and dbo.ORDTRABAJO.OT_TIPO=@prod_tipodescarga
			ORDER BY dbo.ORDTRABAJODETENTPARCIAL.OTDP_FECHA
		end
		else
		begin
			declare cur_descordtrabajo cursor for
			SELECT     dbo.ORDTRABAJODET.OTD_SALDO, dbo.ORDTRABAJODET.OT_CODIGO, dbo.ORDTRABAJODET.OTD_INDICED, 0
			FROM         dbo.ORDTRABAJODET INNER JOIN
			                      dbo.ORDTRABAJO ON dbo.ORDTRABAJODET.OT_CODIGO = dbo.ORDTRABAJO.OT_CODIGO
			WHERE     (dbo.ORDTRABAJODET.MA_CODIGO = @MA_CODIGO) AND (dbo.ORDTRABAJODET.OTD_SALDO > 0) AND 
			          (dbo.ORDTRABAJO.OT_FECHAINI <= @PRO_FECHA) 
				   AND (dbo.ORDTRABAJO.OT_ESTATUS <> 'K') --and dbo.ORDTRABAJO.OT_TIPO=@prod_tipodescarga
			ORDER BY dbo.ORDTRABAJO.OT_FECHAINI
		end	
			open cur_descordtrabajo			
			FETCH NEXT FROM cur_descordtrabajo INTO @OTD_SALDO, @OT_CODIGO, @OTD_INDICED, @OTDP_INDICEP
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

					if @CantDescargada<@PROD_CANT
					begin

						if @OTD_SALDO<@PROD_CANT
						begin
							set @CantDescargada=@CantDescargada+@OTD_SALDO
							set @fSaldoOrdTrabajo=0
	
							INSERT INTO dbo.PRODUCLIGA (PROD_INDICED, OTD_INDICED, LIP_CANTDESC, LIP_FECHADESC, LIP_SALDOORDTRA, OTDP_INDICEP)
							VALUES (@PROD_INDICED, @OTD_INDICED, @OTD_SALDO, @FechaActual, @fSaldoOrdTrabajo, @OTDP_INDICEP)
			
						end
	
	
						if @OTD_SALDO>=@PROD_CANT
						begin
							set @CantDescargada=@CantDescargada+@PROD_CANT
							set @fSaldoOrdTrabajo=@OTD_SALDO-@PROD_CANT
	
							INSERT INTO dbo.PRODUCLIGA (PROD_INDICED, OTD_INDICED, LIP_CANTDESC, LIP_FECHADESC, LIP_SALDOORDTRA, OTDP_INDICEP)
							VALUES (@PROD_INDICED, @OTD_INDICED, @PROD_CANT, @FechaActual, @fSaldoOrdTrabajo, @OTDP_INDICEP)
	
						end

						exec sp_SetSaldoOrdTrabajo @OTD_INDICED, @fSaldoOrdTrabajo, @OTDP_INDICEP
					end
					/*Aqui manipulamos las cantidades*/
/*					SET @fQtyADescargar = @PROD_CANT   --Cantidad a descargar (o descargada)  = salod por descargar
					SET @fSaldoOrdTrabajo = ROUND(@OTD_SALDO - @fQtyADescargar,6) -- saldo posterior de la orden = saldo actual menos cantidad a descargar
						
					
					IF(@fSaldoOrdTrabajo < 0)  -- si saldo posterior es negativo
					BEGIN --7
						SET @fSaldoDescargar = ABS(@fSaldoOrdTrabajo) -- cantidad que queda a descargar = al saldo negativo (absoluto)
						SET @fQtyADescargar =  @OTD_SALDO -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
						SET @fSaldoOrdTrabajo = 0 --saldo de la orden =0
					END --7
					ELSE
					BEGIN --8
						SET @fSaldoDescargar = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
					END --8


		


						INSERT INTO dbo.PRODUCLIGA (PROD_INDICED, OTD_INDICED, LIP_CANTDESC, LIP_FECHADESC, LIP_SALDOORDTRA, OTDP_INDICEP)
						VALUES (@PROD_INDICED, @OTD_INDICED, @fQtyADescargar, @FechaActual, @fSaldoOrdTrabajo, @OTDP_INDICEP)
			
			
						exec sp_SetSaldoOrdTrabajo @OTD_INDICED, @fSaldoOrdTrabajo, @OTDP_INDICEP
			
				*/			
		
			FETCH NEXT FROM cur_descordtrabajo INTO @OTD_SALDO, @OT_CODIGO, @OTD_INDICED, @OTDP_INDICEP


	
		END
		
		CLOSE cur_descordtrabajo
		DEALLOCATE cur_descordtrabajo
		
		
		
	FETCH NEXT FROM cur_descproduc INTO @MA_CODIGO, @PROD_CANT, @PROD_INDICED, @PRO_FECHA

END

CLOSE cur_descproduc
DEALLOCATE cur_descproduc


		update produc
		set pro_estatus='C'
		where pro_codigo=@pro_codigo

--	exec SP_ACTUALIZAESTATUSPRODUC @pro_codigo








































GO
