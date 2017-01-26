SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* descarga manual peps*/
CREATE PROCEDURE [dbo].[SP_DescargaManualPepsInd] (@nFEDINDICED int, @BST_HIJO int)   as

SET NOCOUNT ON 

	DECLARE @CodigoFactura Int, @FechaActual Varchar(10), @tipodescarga varchar(2), @cuenta int, 
		@CF_DESCARGAVENCIDOS char(1), @cft_tipo char(1), @BST_TIPODESC VARCHAR(5), @consecutivo int

	-- Variables para Cursor con datos de SubEnsables a Descargar
	DECLARE @nFECODIGO INT, @nBSTHIJO INT, @TEmbarque char(1), @COUNTPT int

	SELECT @CodigoFactura=FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=@nFEDINDICED

	  SET @FechaActual = convert(varchar(10), getdate(),101)

	SELECT     @COUNTPT = COUNT(dbo.CONFIGURATIPO.CFT_TIPO)
	FROM         dbo.FACTEXPDET LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.CONFIGURATIPO.CFT_TIPO
	HAVING      (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR
	                      dbo.CONFIGURATIPO.CFT_TIPO = 'S') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)

	SELECT     @TEmbarque = CFQ_TIPO from CONFIGURATEMBARQUE where TQ_CODIGO in
	(select tq_codigo from factexp where FE_CODIGO = @CodigoFactura)


	select @consecutivo=isnull(max(kap_codigo)+1,1) from kardesped
	dbcc checkident (kardespedtemp, reseed, @consecutivo)


	if @TEmbarque='D'
		 SET @tipodescarga='D'
	else
	begin
		IF @COUNTPT>0  --si hay productos terminados o subensambles
			SET @tipodescarga='NM'
		else
			SET @tipodescarga='N'
	end



	--print @tipodescarga


  -- Variables para Cursor con Datos de Pedimentos de Importacion
  DECLARE @nPIDINDICED Int, @fPIDSALDOGEN decimal(38,6)

	-- Variables para Valores Calculados/Obtenidos con algun SP
  DECLARE @fQtyADescargar decimal(38,6), @fQtyTotDesc decimal(38,6), @fSaldoPedimento decimal(38,6), @fSaldoDescargar decimal(38,6), @fFisComp char(1),
		@cDescargaStatus Char(1), @vKapTipoEns Char(1), @CF_USAEQUIVALENTE CHAR(1),@MA_TIP_ENS char(1),
		@fefecha datetime
		



	SELECT     @CF_USAEQUIVALENTE = CF_USAEQUIVALENTE,  @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         dbo.CONFIGURACION


	-- Tabla temporal donde llevamos una cola para asignar el Estatus
  CREATE TABLE [dbo].[#KardespedStatusQueu]
  (	
		TKapCodigo Int NOT NULL
	)
		select @fefecha = fe_fecha from factexp where fe_codigo = @CodigoFactura

  DECLARE curMPNU CURSOR FOR
	SELECT FE_CODIGO, FED_INDICED, CANTDESC, BST_HIJO, MA_TIP_ENS, BST_TIPODESC
	FROM VBOM_DESCTEMP WHERE FED_INDICED=@nFEDINDICED AND BST_HIJO=@BST_HIJO
	and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
	AND CANTDESC>0
  OPEN curMPNU
  FETCH NEXT FROM curMPNU
	INTO @nFECODIGO, @nFEDINDICED, @fQtyADescargar, @nBSTHIJO, @MA_TIP_ENS, @BST_TIPODESC
  WHILE (@@fetch_status <> -1) 
  BEGIN  --1
    IF(@@fetch_status <> -2)
    BEGIN --2

	select @cft_tipo= cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo=@nBSTHIJO)
		
	SET @fQtyTotDesc = @fQtyADescargar
	SET @fSaldoDescargar = @fQtyTotDesc


		if @CF_DESCARGAVENCIDOS='S'
		begin
		        DECLARE curPedimentos CURSOR FOR 
			SELECT PID_INDICED, PID_SALDOGEN 
			FROM VPIDESCARGAALL
			WHERE (PID_SALDOGEN > 0) AND (MA_CODIGO = @nBSTHIJO) 					
			AND (PI_FEC_ENT <= @fefecha) 
			ORDER BY PI_FEC_ENT ASC, PID_INDICED ASC
		end
		else
		begin
		        DECLARE curPedimentos CURSOR FOR 
			SELECT PID_INDICED, PID_SALDOGEN 
			FROM VPIDESCARGAALL
			WHERE (PID_SALDOGEN > 0) AND (MA_CODIGO = @nBSTHIJO) 					
			AND (PI_FEC_ENT <= @fefecha) and pid_fechavence>=@fefecha
			ORDER BY PI_FEC_ENT ASC, PID_INDICED ASC
		end
      OPEN curPedimentos
      FETCH NEXT FROM curPedimentos 

			INTO @nPIDINDICED, @fPIDSALDOGEN
			DELETE #KardespedStatusQueu
			EXEC sp_GetKapTipoEnsPert @nBSTHIJO, @vKapTipoEns OUTPUT


      WHILE (@@fetch_status <> -1)
      BEGIN  --5


	/*KAP_CantTotADescargar = @fQtyTotDesc (cantidad total a descargar)
	KAP_Saldo_FED = @fSaldoDescargar (lo que queda a descargar)
	KAP_CANTDESC = @fQtyADescargar (cantidad descagada)
	KAP_SALDO_PED = @fSaldoPedimento (saldo del pedimento) */


				IF(@@fetch_status <> -2)
				BEGIN --6
					/*Aqui manipulamos las cantidades*/
					SET @fQtyADescargar = @fSaldoDescargar   --Cantidad a descargar (o descargada)  = salod por descargar
					SET @fSaldoPedimento = ROUND(@fPIDSALDOGEN - @fQtyADescargar,6) -- saldo posterior del ped = saldo actual menos cantidad a descargar

					--print @fSaldoDescargar
					
					IF @MA_TIP_ENS = 'A' 
					BEGIN
						SET @fFisComp='S'
					END
					ELSE
					BEGIN
						SET @fFisComp='N'
					END
			
					
					IF(@fSaldoPedimento < 0)  -- si saldo posterior es negativo
					BEGIN --7
						SET @fSaldoDescargar = ABS(@fSaldoPedimento) -- cantidad que queda a descargar = al saldo negativo (absoluto)
						SET @fQtyADescargar =  @fPIDSALDOGEN -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
						SET @fSaldoPedimento = 0 --saldo del pedimento =0
					END --7
					ELSE
					BEGIN --8
						SET @fSaldoDescargar = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
					END --8
				/*********************************/

					INSERT INTO KARDESPEDTemp
					(
						KAP_FACTRANS, 
						KAP_INDICED_FACT, 
						KAP_INDICED_PED, 
						MA_HIJO, 
						KAP_TIPO_DESC, 
						KAP_CANTDESC, 
						KAP_CantTotADescargar,
						KAP_Saldo_FED,
						KAP_FisComp
					)
					VALUES (
						@nFECODIGO, 
						@nFEDINDICED, 
						@nPIDINDICED, 
						@nBSTHIJO, 
						'M'+@BST_TIPODESC, --@tipodescarga, 
						@fQtyADescargar, 
 						@fQtyTotDesc,
						@fSaldoDescargar,
						@fFisComp
					)

					EXEC sp_SetSaldoPedimento @nPIDINDICED, @fSaldoPedimento
							
					if (select count(*) from kardespedtemp)>0
					INSERT INTO #KardespedStatusQueu 
					SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp

					IF (@fSaldoDescargar = 0) 
						BREAK --Jump out of Pedimentou Cycle

					FETCH NEXT FROM curPedimentos 
					INTO @nPIDINDICED, @fPIDSALDOGEN

				END --6
			END  --5
			CLOSE curPedimentos

			/*Aqui determinamos el Status a asignar, basandonos en la Cantidad a descargar Original*/
			IF (@fSaldoDescargar = 0) 
				SET @cDescargaStatus = 'D'
			ELSE
			--HASTA AQUI
			BEGIN --9

				IF (@fSaldoDescargar < @fQtyTotDesc)
					SET @cDescargaStatus = 'P'


				IF (@fSaldoDescargar = @fQtyTotDesc)
				BEGIN --10
					INSERT INTO KARDESPEDTemp(
						KAP_FACTRANS, 
						KAP_INDICED_FACT, 
						MA_HIJO, 
						KAP_TIPO_DESC, 
						KAP_CANTDESC, 
						KAP_CantTotADescargar,
						KAP_Saldo_FED)

					VALUES (
						@nFECODIGO, 
						@nFEDINDICED, 
						@nBSTHIJO, 
						'M'+@BST_TIPODESC, 
						0, 
						@fQtyTotDesc,
						@fSaldoDescargar)
				
					if exists (select * from kardespedtemp)

					INSERT INTO #KardespedStatusQueu SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp
					SET @cDescargaStatus = 'N'
				END --10

			END --9

--			Asignamos el Status a KARDESPED 
			UPDATE KARDESPEDTemp SET KARDESPEDTemp.KAP_ESTATUS = @cDescargaStatus
			FROM KARDESPEDTemp INNER JOIN

				#KardespedStatusQueu ON 
				KARDESPEDTemp.KAP_CODIGO = #KardespedStatusQueu.TKapCodigo

				update factexpdet
				set fed_descargado ='S' where fed_indiced  = @nFEDINDICED and fed_descargado ='N'


		DEALLOCATE curPedimentos
		FETCH NEXT FROM curMPNU
			INTO @nFECODIGO, @nFEDINDICED, @fQtyADescargar, @nBSTHIJO, @MA_TIP_ENS, @BST_TIPODESC
		END --2
	END --1
	CLOSE curMPNU

	DEALLOCATE curMPNU
	


		exec SP_ACTUALIZAESTATUSFACTEXP @nFECODIGO


		exec ActualizaFeDescItalica @nFECODIGO

-- descarga manual peps
GO
