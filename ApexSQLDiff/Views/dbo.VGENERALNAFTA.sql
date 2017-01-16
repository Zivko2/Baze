SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW dbo.VGENERALNAFTA
with encryption as
SELECT     TOP 100 PERCENT dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.TIPO.TI_NOMBRE
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.TIPO ON dbo.MAESTRO.TI_CODIGO = dbo.TIPO.TI_CODIGO INNER JOIN
                          (SELECT     MA_CODIGO
                            FROM          NAFTA
                            GROUP BY MA_CODIGO) NFT ON NFT.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
ORDER BY dbo.MAESTRO.MA_NOPARTE




















GO
