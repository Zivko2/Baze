SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








































/* descarga manual de los numeros de parte que no se encuentran en pedimentos*/
CREATE PROCEDURE [dbo].[SP_DescargaManualSinPed] (@nFEDINDICED int, @KAP_CantTotADescargar decimal(38,6), @MA_HIJO int)   as

SET NOCOUNT ON 

-- el @ma_hijo en agrupacion es el ma_generico

declare @FechaActual varchar(10), @feddescargado int, @feconped char(1), @FE_CODIGO int, @consecutivo int

	Set @FechaActual =  convert(varchar(10), getdate(),101)

	select @consecutivo=max(kap_codigo)+1 from kardesped

	SELECT @FE_CODIGO=FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=@nFEDINDICED

		INSERT INTO KARDESPED(KAP_CODIGO, KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO, KAP_ESTATUS,
		KAP_CantTotADescargar, KAP_CANTDESC, KAP_Saldo_FED, kap_tipo_desc)

		VALUES(@consecutivo, @FE_CODIGO, @nFEDINDICED, 
                      @MA_HIJO,  'N', @KAP_CantTotADescargar, 0, @KAP_CantTotADescargar, 'MN')


		UPDATE FACTEXPDET
		SET FED_DESCARGADO = 'S'
		WHERE FED_INDICED = @nFEDINDICED


		exec SP_ACTUALIZAESTATUSFACTEXP @FE_CODIGO

		exec ActualizaFeDescItalica @FE_CODIGO







































GO
