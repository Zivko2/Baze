SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VIEW3
AS
SELECT     dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTROCOST.MA_NG_USA, dbo.MAESTRO.MA_INV_GEN, dbo.MAESTRO.TI_CODIGO, 
                      dbo.MAESTRO.MA_TRANS
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO = 16) AND (dbo.MAESTRO.MA_NOPARTE = '0')
GO
