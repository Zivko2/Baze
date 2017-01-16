SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* descarga manual peps*/
CREATE PROCEDURE [dbo].[SP_DescargaManualPeps] (@nFEDINDICED int, @BST_HIJO int)   as

SET NOCOUNT ON 
-- en caso de la agrupada el @BST_HIJO=ma_generico
DECLARE @CF_DESCARGASBUS CHAR(1), @CodigoFactura int

	SELECT @CF_DESCARGASBUS = CF_DESCARGASBUS
	FROM CONFIGURACION

	select @CodigoFactura=fe_codigo from factexpdet where fed_indiced=@nFEDINDICED

	IF @CF_DESCARGASBUS='G'
		exec SP_DescargaManualPepsGR @nFEDINDICED, @BST_HIJO
	else
		exec SP_DescargaManualPepsInd @nFEDINDICED, @BST_HIJO


		exec SP_ESTATUSKARDESPEDFED @nFEDINDICED

		if exists (select * from kardespedtemp where kap_indiced_fact=@nFEDINDICED)
		EXEC SP_FILL_KARDESPED

/*	exec SP_ESTATUSKARDESPEDFACT @CodigoFactura

	if exists (select * from kardespedtemp where kap_factrans=@CodigoFactura)
	EXEC SP_FILL_KARDESPED*/

		exec ActualizaFeDescItalica @CodigoFactura







































GO
