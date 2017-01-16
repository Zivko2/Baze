SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.Comparativo_de_inventarios
AS
SELECT     ISNULL(dbo.[Saldos por parte].PID_NOPARTE, dbo.['Inventrario Fisico$'].NUMBER) AS [No Parte], ISNULL(dbo.[Saldos por parte].Expr1, 
                      dbo.MAESTRO.MA_NOMBRE) AS Descripcion, dbo.['Inventrario Fisico$'].DESCRIPTION, dbo.[Saldos por parte].SALDOGEN, 
                      dbo.['Inventrario Fisico$'].inventario, dbo.[Saldos por parte].ME_CORTO, dbo.['Inventrario Fisico$'].UM, ISNULL(dbo.MAESTROCOST.MA_COSTO, 
                      dbo.[Saldos por parte].[costo uni]) AS [costo unitario]
FROM         dbo.MAESTRO INNER JOIN
                      dbo.['Inventrario Fisico$'] ON dbo.MAESTRO.MA_NOPARTE = dbo.['Inventrario Fisico$'].NUMBER INNER JOIN
                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO FULL OUTER JOIN
                      dbo.[Saldos por parte] ON dbo.['Inventrario Fisico$'].NUMBER = dbo.[Saldos por parte].PID_NOPARTE
GO
