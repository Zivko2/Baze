SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.VFACTEXPENTELA
with encryption as
SELECT     dbo.FACTEXPENT.FEN_CODIGO, dbo.FACTEXPENT.FED_INDICED, dbo.FACTEXPENT.MA_HIJO, dbo.FACTEXPENT.FEN_FEC_ENT, 
                      dbo.FACTEXPENT.PA_CODIGO, dbo.FACTEXPENT.FEN_PAISLETRA, dbo.FACTEXPENT.FEN_COS_UNI, dbo.FACTEXPDET.FE_CODIGO, 
                      dbo.FACTEXPENT.FEN_CANT, dbo.FACTEXPENT.ME_CODIGO, 1 AS CL_CODIGO
FROM         dbo.FACTEXPENT INNER JOIN
                      dbo.MAESTRO ON dbo.FACTEXPENT.MA_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXPENT.FED_INDICED = dbo.FACTEXPDET.FED_INDICED
WHERE     (dbo.MAESTRO.MA_NOMBRE LIKE 'tela%') OR
                      (dbo.MAESTRO.MA_NOMBRE LIKE '%tela%') OR
                      (dbo.MAESTRO.MA_NOMBRE LIKE '%tela')























































GO
