SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








































-- descarga manual peps
CREATE PROCEDURE [dbo].[SP_DescargaManualPepsGR] (@nFEDINDICED int, @MA_GENERICO int)   as

SET NOCOUNT ON 
	DECLARE @CodigoFactura Int, @MetodoDescarga Varchar(4), @FechaActual Varchar(10), @tipodescarga varchar(2), @consecutivo int

	-- Variables para Cursor con datos de SubEnsables a Descargar
	DECLARE @nFECODIGO Int, @nFEDCANT decimal(38,6), @nBSTHIJO Int, 
		@nBSUSUBENSAMBLE Int, @fBSTINCORPOR decimal(38,6), @fFACTCONV decimal(38,6), @BST_TIPODESC VARCHAR(5),
		@CF_DESCARGAVENCIDOS char(1), @TEmbarque char(1), @COUNTPT int, @MA_CODIGO int, @BST_TIPOCOSTO char(1), @cft_tipo char(1)

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


	if @TEmbarque='D'
		 SET @tipodescarga='D'
	else
	begin
		IF @COUNTPT>0  --si hay productos terminados o subensambles
			SET @tipodescarga='NM'
		else
			SET @tipodescarga='N'
	end

	select @consecutivo=max(kap_codigo)+1 from kardesped
	dbcc checkident (kardespedtemp, reseed, @consecutivo)

  -- Variables para Cursor con Datos de Pedimentos de Importacion
  DECLARE @nPIDINDICED Int, @fPIDSALDOGEN decimal(38,6)

	-- Variables para Valores Calculados/Obtenidos con algun SP
  DECLARE @fQtyADescargar decimal(38,6), @fQtyTotDesc decimal(38,6), @fSaldoPedimento decimal(38,6), @fSaldoDescargar decimal(38,6), @fFisComp char(1),
		@cDescargaStatus Char(1), @vKapTipoEns Char(1), @CF_USAEQUIVALENTE CHAR(1),@MA_TIP_ENS char(1),
		@SUMKAP_CANTDESC decimal(38,6), @SE_CODIGO smallint, @MA_CODIGOSUST INT,  @MADEFTIP char(1), @fefecha datetime,
		@FED_FECHA_STRUCT datetime, @countbom INT



	SELECT     @CF_USAEQUIVALENTE = CF_USAEQUIVALENTE,  @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         dbo.CONFIGURACION


	-- Tabla temporal donde llevamos una cola para asignar el Estatus
  CREATE TABLE [dbo].[#KardespedStatusQueu]
  (	
		TKapCodigo Int NOT NULL
	)


  DECLARE curMPNU CURSOR FOR


	SELECT     FE_CODIGO, FED_INDICED, FED_CANT, MA_GENERICO, BST_INCORPOR, FACTCONV, SE_CODIGO, MA_DEF_TIP, BST_TIPODESC, 
	                      BST_TIPOCOSTO
	FROM         VDESCARGAGR
	WHERE    (MA_GENERICO=@MA_GENERICO) and FED_INDICED=@nFEDINDICED AND MA_GENERICO>0
	GROUP BY FE_CODIGO, FED_INDICED, FED_CANT, MA_GENERICO, BST_INCORPOR, FACTCONV, SE_CODIGO, MA_DEF_TIP, BST_TIPODESC, 
	                      BST_TIPOCOSTO
	HAVING      (FE_CODIGO = @CodigoFactura) AND (BST_INCORPOR > 0) AND (FED_CANT > 0) AND (MA_GENERICO IS NOT NULL) 
		and (BST_TIPODESC=left(@tipodescarga,1) or BST_TIPODESC=right(@tipodescarga,1))


  OPEN curMPNU
  FETCH NEXT FROM curMPNU
	INTO @nFECODIGO, @nFEDINDICED, @nFEDCANT, @nBSTHIJO, @fBSTINCORPOR, @fFACTCONV, 
		@SE_CODIGO, @MADEFTIP, @BST_TIPODESC,@BST_TIPOCOSTO

		select @fefecha = fe_fecha from factexp where fe_codigo = @CodigoFactura

  WHILE (@@fetch_status <> -1) 
  BEGIN  --1
    IF(@@fetch_status <> -2)
    BEGIN --2


	select @cft_tipo= cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo=@nBSTHIJO)
		
		if @BST_TIPOCOSTO='Z' and @cft_tipo='E' 
			SET @fQtyADescargar = @fBSTINCORPOR * @fFACTCONV
		else
			SET @fQtyADescargar = @nFEDCANT * @fBSTINCORPOR * @fFACTCONV

			SET @fQtyTotDesc = @fQtyADescargar
			SET @fSaldoDescargar = @fQtyTotDesc



				if @CF_DESCARGAVENCIDOS='S'
				begin
				        DECLARE curPedimentos CURSOR FOR 
					SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
					FROM VPIDESCARGAALL
					WHERE (PID_SALDOGEN > 0) AND
					     (MA_GENERICO = @nBSTHIJO) AND (PI_FEC_ENT <= @fefecha)  
					ORDER BY PI_FEC_ENT ASC, PID_INDICED ASC
				end
				else
				begin
				        DECLARE curPedimentos CURSOR FOR 
					SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
					FROM VPIDESCARGAALL
					WHERE (PID_SALDOGEN > 0) AND pid_fechavence>=@fefecha AND
					     (MA_GENERICO = @nBSTHIJO) AND (PI_FEC_ENT <= @fefecha)  
					ORDER BY PI_FEC_ENT ASC, PID_INDICED ASC

				end
      OPEN curPedimentos
      FETCH NEXT FROM curPedimentos 

			INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO


			DELETE #KardespedStatusQueu

			EXEC sp_GetKapTipoEnsPert @nBSTHIJO, @vKapTipoEns OUTPUT

      WHILE (@@fetch_status <> -1)
      BEGIN  --5


	/*KAP_CantTotADescargar = @fQtyTotDesc (cantidad total a descargar)
	KAP_Saldo_FED = @fSaldoDescargar (lo que queda a descargar)
	KAP_CANTDESC = @fQtyADescargar (cantidad descagada)*/


				IF(@@fetch_status <> -2)
				BEGIN --6
					/*Aqui manipulamos las cantidades*/
					SET @fQtyADescargar = @fSaldoDescargar   --Cantidad a descargar (o descargada)  = salod por descargar
					SET @fSaldoPedimento = ROUND(@fPIDSALDOGEN - @fQtyADescargar,6) -- saldo posterior del ped = saldo actual menos cantidad a descargar
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
--						KAP_FECHADESC, 
						MA_HIJO, 
						KAP_TIPO_DESC, 
						KAP_CANTDESC, 
						/*KAP_SALDO_PED, */
						KAP_CantTotADescargar,
						KAP_Saldo_FED,
						KAP_FisComp
					)
					VALUES (
						@nFECODIGO, 
						@nFEDINDICED, 
						@nPIDINDICED, 
--						@FechaActual, 
						@MA_CODIGO, 
						'M'+@BST_TIPODESC, --@tipodescarga, 
						@fQtyADescargar, 
						/*@fSaldoPedimento, */
 						@fQtyTotDesc,
						@fSaldoDescargar,
						@fFisComp
					)



					EXEC sp_SetSaldoPedimento @nPIDINDICED, @fSaldoPedimento
							
					if exists (select * from kardespedtemp)
					INSERT INTO #KardespedStatusQueu SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp
					IF (@fSaldoDescargar = 0) 
						BREAK --Jump out of Pedimentou Cycle

					FETCH NEXT FROM curPedimentos 
					INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO

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

					if @nBSTHIJO=0
                                                                   set @nBSTHIJO=@MA_CODIGO


					IF (@fSaldoDescargar = @fQtyTotDesc)
					BEGIN --10
						INSERT INTO KARDESPEDTemp(
							KAP_FACTRANS, 
							KAP_INDICED_FACT, 
--							KAP_FECHADESC, 
							MA_HIJO, 
							KAP_TIPO_DESC, 
							KAP_CANTDESC, 							KAP_CantTotADescargar,
							KAP_Saldo_FED)
						VALUES (
							@nFECODIGO, 
							@nFEDINDICED, 
--							@FechaActual, 
							@nBSTHIJO, 
							'M'+@BST_TIPODESC, --@tipodescarga, 
							0, 
							@fQtyTotDesc,
							@fSaldoDescargar
								)
					
						if exists (select * from kardespedTemp)

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
			INTO @nFECODIGO, @nFEDINDICED, @nFEDCANT, @nBSTHIJO, @fBSTINCORPOR, @fFACTCONV, 
				@SE_CODIGO, @MADEFTIP, @BST_TIPODESC,@BST_TIPOCOSTO
		END --2
	END --1
	CLOSE curMPNU

	DEALLOCATE curMPNU
	


		exec SP_ACTUALIZAESTATUSFACTEXP @nFECODIGO



		exec ActualizaFeDescItalica @nFECODIGO
GO
