SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VIEW2
AS
SELECT     MA_NOPARTE, MA_CODIGO, TI_CODIGO
FROM         dbo.MAESTRO
WHERE     (NOT (MA_CODIGO IN
                          (SELECT     ma_codigo
                            FROM          maestrocost)))


GO
