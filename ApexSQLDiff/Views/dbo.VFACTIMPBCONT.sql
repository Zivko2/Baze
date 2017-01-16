SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.VFACTIMPBCONT
with encryption as
SELECT     dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.AR_IMPMX, dbo.FACTIMPCONT.FIC_MARCA, dbo.FACTIMPCONT.FIC_MODELO, 
                      dbo.FACTIMPCONT.FIC_SERIE, dbo.FACTIMPCONT.FIC_EQUIPADOCON
FROM         dbo.FACTIMPDET LEFT OUTER JOIN
                      dbo.FACTIMPCONT ON dbo.FACTIMPDET.FID_INDICED = dbo.FACTIMPCONT.FID_INDICED
GROUP BY dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.AR_IMPMX, dbo.FACTIMPCONT.FIC_MARCA, dbo.FACTIMPCONT.FIC_MODELO, 
                      dbo.FACTIMPCONT.FIC_SERIE, dbo.FACTIMPCONT.FIC_EQUIPADOCON
HAVING      (dbo.FACTIMPCONT.FIC_MARCA IS NOT NULL) OR
                      (dbo.FACTIMPCONT.FIC_MODELO IS NOT NULL) OR
                      (dbo.FACTIMPCONT.FIC_SERIE IS NOT NULL) OR
                      (dbo.FACTIMPCONT.FIC_EQUIPADOCON IS NOT NULL)


































































GO
