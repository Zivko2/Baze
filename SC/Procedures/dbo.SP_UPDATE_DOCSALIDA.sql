SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UPDATE_DOCSALIDA] ( @chkgenerico2 int, @chkeqgen2 int, @chkarexpmx2 int, @chkarimpusa2 int, @chkporcentimpusa2 int, @DtEntradaInicial1 datetime, @DtEntradaFinal1 datetime)   as

SET NOCOUNT ON 
BEGIN
	IF (@chkgenerico2 = 1)
		UPDATE dbo.FACTEXPDET
		SET  dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_GENERICO
		FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTEXP.FE_FECHA >= @DtEntradaInicial1 AND dbo.FACTEXP.FE_FECHA <= @DtEntradaFinal1)
		AND dbo.MAESTRO.MA_GENERICO IS NOT NULL

	IF (@chkeqgen2 = 1)
		UPDATE dbo.FACTEXPDET
		SET  dbo.FACTEXPDET.EQ_GEN = isnull(dbo.MAESTRO.EQ_GEN,1)
		FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTEXP.FE_FECHA >= @DtEntradaInicial1 AND dbo.FACTEXP.FE_FECHA <= @DtEntradaFinal1)


	IF (@chkarexpmx2 = 1)
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.AR_EXPMX = dbo.MAESTRO.AR_EXPMX
		FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTEXP.FE_FECHA >= @DtEntradaInicial1 AND dbo.FACTEXP.FE_FECHA <= @DtEntradaFinal1)
		AND dbo.MAESTRO.AR_EXPMX IS NOT NULL

	IF (@chkporcentimpusa2 = 1)
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.FED_RATEIMPFO = dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPFO, 0, 'G', 0, 0)
		FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTEXP.FE_FECHA >= @DtEntradaInicial1 AND dbo.FACTEXP.FE_FECHA <= @DtEntradaFinal1)

	IF (@chkarimpusa2 = 1)
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.AR_IMPFO = dbo.MAESTRO.AR_IMPFO
		FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTEXP.FE_FECHA >= @DtEntradaInicial1 AND dbo.FACTEXP.FE_FECHA <= @DtEntradaFinal1)
		AND dbo.MAESTRO.AR_IMPFO IS NOT NULL

END

GO
