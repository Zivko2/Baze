SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* descarga manual*/
CREATE PROCEDURE [dbo].[SP_DescargaManual] (@fQtyADescargar decimal(38,6), @nPIDINDICED INT, @nFEDINDICED int, @Factconv decimal(28,14), @KAP_Saldo_FED decimal(38,6), @fQtyTotDesc decimal(38,6), @nMACODIGO int, @MAEQUIVALE int=0)   as

SET NOCOUNT ON 
-- en caso de descargda por genericos @nMACODIGO=ma_generico

	DECLARE @nPMACODIGO Int, @fPIDSALDOGEN decimal(38,6), @nFEDCANT decimal(38,6), @PID_SECUENCIA INT,
		@fSaldoDescargar decimal(38,6), @fSaldoPedimento decimal(38,6), @FechaActual Datetime, @nFECODIGO int, @FETipo char(1),
		@fFACTCONV decimal(38,6), @pid_indiced int, @estatusdesc char(1), @nMACODIGO1 int, @KAP_PADRESUST int, @consecutivo int



	Set @FechaActual =  convert(varchar(10), getdate(),101)

	select @pid_indiced = pid_indiced from factexpdet where fed_indiced=@nFEDINDICED

	select @consecutivo=IsNull(max(kap_codigo)+1,1) from kardesped


		/* Select de la factura*/
		SELECT    @nFECODIGO= FE_CODIGO, @nFEDCANT=FED_CANT, @fFACTCONV = EQ_GEN
		FROM FACTEXPDET
		WHERE FED_INDICED =  @nFEDINDICED
		
		
--		SET @fQtyTotDesc =  @nFEDCANT * @fFACTCONV -- Solo para saber cuando va a ser a descargar en total

	
		/* Select del pedimento */
		SELECT @nPMACODIGO= PEDIMPDET.MA_CODIGO,  @fPIDSALDOGEN = PIDESCARGA.PID_SALDOGEN,
		@PID_SECUENCIA=PID_SECUENCIA
		FROM PEDIMPDET left outer join PIDESCARGA ON PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
		WHERE (PEDIMPDET.PID_INDICED = @nPIDINDICED) 
	
				SET @fSaldoPedimento = round(ROUND(@fPIDSALDOGEN,6) - (@fQtyADescargar),6)


		set @estatusdesc='D'

		if @MAEQUIVALE<>0
		begin
			SET @nMACODIGO1=@MAEQUIVALE
			set @KAP_PADRESUST=@nMACODIGO
		end
		else
		begin
			SET @nMACODIGO1=@nMACODIGO
			set @KAP_PADRESUST=0
		end

	
	
	
					/*********************************/
						INSERT INTO KARDESPED
						(
							KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, 
--							KAP_FECHADESC, 
							MA_HIJO, KAP_TIPO_DESC, 
							KAP_CANTDESC, /*KAP_SALDO_PED, */
							KAP_CantTotADescargar,
							KAP_ESTATUS, KAP_Saldo_FED,
							KAP_PADRESUST, KAP_CODIGO
							
						)
						VALUES (
							@nFECODIGO, 
							@nFEDINDICED, 
							@nPIDINDICED, 
							@nMACODIGO1,
							'MN', 
							@fQtyADescargar, 
							@fQtyTotDesc,
							@estatusdesc, @KAP_Saldo_FED,
							@KAP_PADRESUST, @consecutivo						)

				if @pid_indiced = -1	
				EXEC sp_SetSaldoPedimento @nPIDINDICED, @fSaldoPedimento

	
			UPDATE FACTEXPDET
			SET FED_DESCARGADO = 'S', FED_SECF4=@PID_SECUENCIA
			WHERE FED_INDICED = @nFEDINDICED


		exec SP_ACTUALIZAESTATUSFACTEXP @nFECODIGO


		exec ActualizaFeDescItalica @nFECODIGO

GO
