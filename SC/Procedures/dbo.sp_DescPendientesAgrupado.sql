SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- <GI> 20091110
CREATE PROCEDURE [dbo].[sp_DescPendientesAgrupado] (@CodigoFactura Int, @MetodoDescarga Varchar(4), @FechaActual Varchar(10), @tipodescarga varchar(2))   as

--CREATE PROCEDURE [sp_DescPendientesAgrupado] (@MetodoDescarga Varchar(4), @FechaActual Varchar(10), @tipodescarga varchar(2)) with encryption as

	-- Variables para Cursor con datos de SubEnsables a Descargar
	DECLARE @KAP_CODIGO int, @nFECODIGO Int, @nFEDINDICED Int, @nFEDCANT Float, @nBSTHIJO Int, 
		@nBSUSUBENSAMBLE Int, @fBSTINCORPOR Float, @fFACTCONV Float, @BST_TIPODESC VARCHAR(5),
		@ma_generico INT, @equivaleFC int, @countbom2 int, @cft_tipo char(1), @BST_TIPOCOSTO CHAR(1)--, @CodigoFactura INT

  -- Variables para Cursor con Datos de Pedimentos de Importacion
  DECLARE @nPIDINDICED Int, @fPIDSALDOGEN Float, @MA_CODIGO int

	-- Variables para Valores Calculados/Obtenidos con algun SP
  DECLARE @fQtyADescargar Float, @fQtyTotDesc Float, @fSaldoPedimento Float, @fSaldoDescargar Float, 
		@cDescargaStatus Char(1), @vKapTipoEns Char(1), @fefecha datetime, @FED_FECHA_STRUCT datetime, @countbom INT


	-- Tabla temporal donde llevamos una cola para asignar el Estatus
  CREATE TABLE #KardespedStatusQueu
  (	
		TKapCodigo Int NOT NULL
	)



  DECLARE curPendienteMP CURSOR FOR
/*	SELECT     dbo.KARDESPED.KAP_FACTRANS, dbo.KARDESPED.KAP_INDICED_FACT, dbo.FACTEXPDET.FED_CANT, 28000, 
	                      dbo.KARDESPED.KAP_CantTotADescargar / dbo.FACTEXPDET.FED_CANT, 1, 'N', 'A'
	FROM         dbo.KARDESPED INNER JOIN
	                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED INNER JOIN
	                      dbo.MAESTRO ON dbo.KARDESPED.MA_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE     (dbo.MAESTRO.MA_NOMBRE = 'TELEVI') AND (dbo.KARDESPED.KAP_ESTATUS = 'N')  */
--	AND dbo.KARDESPED.KAP_FACTRANS=@CodigoFactura
	
/*

	SELECT     dbo.FACTEXP.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, SUM(dbo.FACTEXPDET.FED_CANT), 27996, 1,
	1, 'N', 'A'
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
	WHERE     (dbo.FACTEXPDET.FED_NOMBRE LIKE 'ASPIRADORA%') AND (dbo.FACTEXP.FE_DESCARGADA = 'S') AND 
	                      (dbo.FACTEXP.FE_FECHA <= CONVERT(DATETIME, '2000-12-31 00:00:00', 102))
	AND dbo.FACTEXP.FE_CODIGO=@CodigoFactura
	GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED
*/

	SELECT     dbo.FACTEXP.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, SUM(dbo.FACTEXPDET.FED_CANT), 27870, 1,
	1, 'N', 'A'
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
	WHERE     (dbo.FACTEXPDET.FED_NOMBRE LIKE 'ASPIRADORA%') AND (dbo.FACTEXP.FE_DESCARGADA = 'S') AND (dbo.FACTEXP.FE_FECHA <= CONVERT(DATETIME, '2002-09-30 00:00:00', 102))
	AND dbo.FACTEXP.FE_CODIGO=@CodigoFactura  
	AND dbo.FACTEXPDET.FED_INDICED NOT IN 	(SELECT     dbo.KARDESPEDresp.KAP_INDICED_FACT
			FROM         dbo.KARDESPEDresp INNER JOIN
            		          dbo.MAESTRO ON dbo.KARDESPEDresp.MA_HIJO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.MAESTRO.MA_NOPARTE LIKE 'RTHM%'  AND KAP_CantTotADescargar=dbo.FACTEXPDET.FED_CANT))
	GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED
	OPEN curPendienteMP
	  FETCH NEXT FROM curPendienteMP INTO @nFECODIGO, @nFEDINDICED, @nFEDCANT, @nBSTHIJO, 
		@fBSTINCORPOR, @fFACTCONV, @BST_TIPODESC, @BST_TIPOCOSTO
  WHILE (@@fetch_status <> -1) 
  BEGIN  --1
    IF(@@fetch_status <> -2)
    BEGIN --2

	SET @CodigoFactura=@nFECODIGO;


	select @fefecha = fe_fecha from factexp where fe_codigo = @CodigoFactura

	select @cft_tipo= cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo=@nBSTHIJO)
		
		if @BST_TIPOCOSTO='Z' and @cft_tipo='E' 
			SET @fQtyADescargar = @fBSTINCORPOR * @fFACTCONV
		else
			SET @fQtyADescargar = @nFEDCANT * @fBSTINCORPOR * @fFACTCONV

			SET @fQtyTotDesc = @fQtyADescargar
			SET @fSaldoDescargar = @fQtyTotDesc

--			select @ma_generico=ma_generico from maestro where ma_codigo=@nBSTHIJO


			IF @MetodoDescarga = 'PEPS'
			BEGIN --3a
				   /*     DECLARE curPendientePed CURSOR FOR 
					SELECT PEDIMPDET.PID_INDICED, PEDIMPDET.PID_SALDOGEN, PEDIMPDET.MA_CODIGO
					FROM PEDIMP LEFT OUTER JOIN
					                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
					                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
					WHERE (PEDIMPDET.PID_SALDOGEN > 0) AND (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND 
							(PEDIMPDET.MA_GENERICO = @nBSTHIJO) AND (CLAVEPED.CP_DESCARGABLE = 'S') 
							AND (PEDIMP.PI_FEC_ENT <= @fefecha) AND (PEDIMP.PI_MOVIMIENTO='E') 
							and (pedimpdet.pid_descargable='S')
					ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC
					*/
						--Yolanda Avila (2009-11-10)
				        DECLARE curPendientePed CURSOR FOR 
					SELECT PEDIMPDET.PID_INDICED, (SELECT PIDESCARGA.PID_SALDOGEN FROM PIDESCARGA WHERE PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED) as pid_saldogen, PEDIMPDET.MA_CODIGO
					FROM PEDIMP LEFT OUTER JOIN
					                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
					                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
					WHERE ((SELECT PIDESCARGA.PID_SALDOGEN FROM PIDESCARGA WHERE PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED) > 0) AND (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND 
							(PEDIMPDET.MA_GENERICO = @nBSTHIJO) AND (CLAVEPED.CP_DESCARGABLE = 'S') 
							AND (PEDIMP.PI_FEC_ENT <= @fefecha) AND (PEDIMP.PI_MOVIMIENTO='E') 
							and (pedimpdet.pid_descargable='S')
					ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC



			      END--3a
			ELSE
			      BEGIN --4a
					/*
					DECLARE curPendientePed CURSOR FOR 
					SELECT PEDIMPDET.PID_INDICED, PEDIMPDET.PID_SALDOGEN, PEDIMPDET.MA_CODIGO
					FROM PEDIMP LEFT OUTER JOIN
					                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
					                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
					WHERE (PEDIMPDET.PID_SALDOGEN > 0) AND (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND 
							(PEDIMPDET.MA_GENERICO = @nBSTHIJO) AND 	(CLAVEPED.CP_DESCARGABLE = 'S') 
							AND (PEDIMP.PI_FEC_ENT <= @fefecha) AND (PEDIMP.PI_MOVIMIENTO='E') 
							and (pedimpdet.pid_descargable='S')

				        ORDER BY PEDIMP.PI_FEC_ENT DESC, PEDIMP. PI_CODIGO DESC
				     */
						--Yolanda Avila (2009-11-10)
					DECLARE curPendientePed CURSOR FOR 
					SELECT PEDIMPDET.PID_INDICED, (SELECT PIDESCARGA.PID_SALDOGEN FROM PIDESCARGA WHERE PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED) as PID_SALDOGEN, PEDIMPDET.MA_CODIGO
					FROM PEDIMP LEFT OUTER JOIN
					                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
					                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
					WHERE ((SELECT PIDESCARGA.PID_SALDOGEN FROM PIDESCARGA WHERE PIDESCARGA.PID_INDICED = PEDIMPDET.PID_INDICED) > 0) AND (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND 
							(PEDIMPDET.MA_GENERICO = @nBSTHIJO) AND 	(CLAVEPED.CP_DESCARGABLE = 'S') 
							AND (PEDIMP.PI_FEC_ENT <= @fefecha) AND (PEDIMP.PI_MOVIMIENTO='E') 
							and (pedimpdet.pid_descargable='S')

				        ORDER BY PEDIMP.PI_FEC_ENT DESC, PEDIMP. PI_CODIGO DESC						
			      END --4a


      OPEN curPendientePed
      FETCH NEXT FROM curPendientePed 

			INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO


			DELETE #KardespedStatusQueu

			EXEC sp_GetKapTipoEnsPert @nBSTHIJO, @vKapTipoEns OUTPUT

      WHILE (@@fetch_status <> -1)
      BEGIN  --5


				IF(@@fetch_status <> -2)
				BEGIN --6
					/*Aqui manipulamos las cantidades*/
					SET @fQtyADescargar = @fSaldoDescargar   --Cantidad a descargar (o descargada)  = salod por descargar
					SET @fSaldoPedimento = ROUND(@fPIDSALDOGEN - @fQtyADescargar,5) -- saldo posterior del ped = saldo actual menos cantidad a descargar
						
					
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

					INSERT INTO KARDESPED
					(
						KAP_FACTRANS, 
						KAP_INDICED_FACT, 
						KAP_INDICED_PED, 
						--Yolanda Avila (2009-11-10)
						--KAP_FECHADESC, 
						MA_HIJO, 
						KAP_TIPO_DESC, 
						KAP_CANTDESC, 
						--Yolanda Avila (2009-11-10)
						--KAP_SALDO_PED, 
						------->EQ_GENHIJO,
						KAP_CantTotADescargar,
						KAP_Saldo_FED
					)
					VALUES (
						@nFECODIGO, 
						@nFEDINDICED, 
						@nPIDINDICED, 
						--Yolanda Avila (2009-11-10)						
						--@FechaActual, 
						@MA_CODIGO,
						@BST_TIPODESC, --@tipodescarga, 
						@fQtyADescargar, 
						--Yolanda Avila (2009-11-10)						
						--@fSaldoPedimento, 
						--->@fFACTCONV,	
 						@fQtyTotDesc,
						@fSaldoDescargar
					)


--					delete from kardesped where kap_codigo = @kap_codigo and kap_estatus='N'

					EXEC sp_SetSaldoPedimento @nPIDINDICED, @fSaldoPedimento
							
					if exists (select * from kardesped)
					INSERT INTO #KardespedStatusQueu SELECT MAX(KAP_CODIGO) FROM KARDESPED
					IF (@fSaldoDescargar = 0) 
						BREAK --Jump out of Pedimentou Cycle

					FETCH NEXT FROM curPendientePed 
					INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO

				END --6
			END  --5
			CLOSE curPendientePed

			/*Aqui determinamos el Status a asignar, basandonos en la Cantidad a descargar Original*/
			IF (@fSaldoDescargar = 0) 
				SET @cDescargaStatus = 'D'

			ELSE
			--HASTA AQUI
			BEGIN --9
			
					IF (@fSaldoDescargar < @fQtyTotDesc)
						SET @cDescargaStatus = 'P'

			END --9

--			Asignamos el Status a KARDESPED 
			UPDATE KARDESPED SET KARDESPED.KAP_ESTATUS = @cDescargaStatus
			FROM KARDESPED INNER JOIN

				#KardespedStatusQueu ON 
				KARDESPED.KAP_CODIGO = #KardespedStatusQueu.TKapCodigo

				update factexpdet
				set fed_descargado ='S' where fed_indiced  = @nFEDINDICED and fed_descargado ='N'


		DEALLOCATE curPendientePed
		FETCH NEXT FROM curPendienteMP
			INTO @nFECODIGO, @nFEDINDICED, @nFEDCANT, @nBSTHIJO, @fBSTINCORPOR, @fFACTCONV, 
			@BST_TIPODESC, @BST_TIPOCOSTO

		END --2
	END --1
	CLOSE curPendienteMP

	DEALLOCATE curPendienteMP
GO
