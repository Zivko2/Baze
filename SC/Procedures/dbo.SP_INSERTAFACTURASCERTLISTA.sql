SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_INSERTAFACTURASCERTLISTA] (@CMP_CODIGO INT)   as



		INSERT INTO CERTORIGMPDET (CMP_CODIGO, MA_CODIGO, CMP_CLASE, CMP_FABRICA, CMP_CRITERIO, CMP_NETCOST, CMP_OTRASINST, 
		CMP_CANT, ME_CODIGO, CMP_FACTURA, AR_CODIGO, AR_ALTER, CMP_NOPARTE, CMP_NOPARTEAUX)
	
	SELECT    @CMP_CODIGO, dbo.MAESTRO.MA_CODIGO, MAX(dbo.NAFTA.NFT_CLASE), MAX(dbo.NAFTA.NFT_FABRICA), MAX(dbo.NAFTA.NFT_CRITERIO), 
	                      MAX(dbo.NAFTA.NFT_NETCOST), MAX(dbo.NAFTA.NFT_OTRASINST), SUM(dbo.FACTEXPDET.FED_CANT), MAX(dbo.FACTEXPDET.ME_CODIGO), 
	                      dbo.FACTEXP.FE_FOLIO, max(left(replace(isnull(ARANCEL_1.AR_FRACCION,0),'.',''),6)), max(left(replace(isnull(ARANCEL_2.AR_FRACCION,0),'.',''),6)),
			     dbo.FACTEXPDET.FED_NOPARTE, isnull(dbo.FACTEXPDET.FED_NOPARTEAUX,'')
	FROM         dbo.MAESTRO INNER JOIN
	                      dbo.FACTEXPDET ON dbo.MAESTRO.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO INNER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
	                      dbo.NAFTA ON dbo.MAESTRO.MA_CODIGO = dbo.NAFTA.MA_CODIGO  LEFT OUTER JOIN dbo.ARANCEL ARANCEL_1 ON
			        dbo.MAESTRO.AR_EXPMX = ARANCEL_1.AR_CODIGO LEFT OUTER JOIN dbo.ARANCEL ARANCEL_2 ON
			        dbo.MAESTRO.AR_IMPFO = ARANCEL_2.AR_CODIGO
	WHERE dbo.FACTEXP.FE_SEL = 'S' AND dbo.MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM CERTORIGMPDET WHERE CMP_CODIGO = @CMP_CODIGO
			and CMP_FACTURA = dbo.FACTEXP.FE_FOLIO)
	GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXPDET.FED_NOPARTE, dbo.FACTEXPDET.FED_NOPARTEAUX





















GO