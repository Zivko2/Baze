SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VFACTIMPPAIS
with encryption as
SELECT     TOP 100 PERCENT MA_CODIGO, PA_CODIGO, COUNT(*) AS COUNTPAIS
FROM         dbo.FACTIMPDET
GROUP BY MA_CODIGO, PA_CODIGO


















































GO
