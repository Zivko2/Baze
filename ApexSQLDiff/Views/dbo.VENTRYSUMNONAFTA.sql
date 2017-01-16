SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE VIEW dbo.VENTRYSUMNONAFTA
with encryption as
SELECT     COUNT(dbo.ENTRYSUMARA.ETA_CODIGO) AS NONAFTA, dbo.ENTRYSUM.ET_CODIGO
FROM         dbo.ENTRYSUMARA RIGHT OUTER JOIN
                      dbo.ENTRYSUM ON dbo.ENTRYSUMARA.ET_CODIGO = dbo.ENTRYSUM.ET_CODIGO
WHERE     (dbo.ENTRYSUMARA.MA_NAFTA = 'N')
GROUP BY dbo.ENTRYSUM.ET_CODIGO



















































GO
