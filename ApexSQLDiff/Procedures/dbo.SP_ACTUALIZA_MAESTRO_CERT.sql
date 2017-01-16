SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_ACTUALIZA_MAESTRO_CERT] (@CMP_CODIGO INT)   as


		UPDATE dbo.NAFTA
	SET     dbo.NAFTA.NFT_CLASE= dbo.CERTORIGMPDET.CMP_CLASE, 
		dbo.NAFTA.NFT_FABRICA= dbo.CERTORIGMPDET.CMP_FABRICA, 
	             dbo.NAFTA.NFT_CRITERIO= dbo.CERTORIGMPDET.CMP_CRITERIO, 
		dbo.NAFTA.NFT_NETCOST= dbo.CERTORIGMPDET.CMP_NETCOST, 
	             dbo.NAFTA.NFT_OTRASINST= dbo.CERTORIGMPDET.CMP_OTRASINST
	FROM         dbo.CERTORIGMPDET INNER JOIN
	                      dbo.NAFTA ON dbo.CERTORIGMPDET.MA_CODIGO = dbo.NAFTA.MA_CODIGO
	WHERE     (dbo.CERTORIGMPDET.CMP_CODIGO = @CMP_CODIGO)
	
/*	UPDATE dbo.MAESTRO
	SET     dbo.MAESTRO.MA_NAFTA='S'
	FROM         dbo.CERTORIGMPDET INNER JOIN
	                      dbo.MAESTRO ON dbo.CERTORIGMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
	WHERE     (dbo.CERTORIGMPDET.CMP_CODIGO = @CMP_CODIGO)

*/





























GO
