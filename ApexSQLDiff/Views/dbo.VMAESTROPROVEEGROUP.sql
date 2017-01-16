SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE VIEW dbo.VMAESTROPROVEEGROUP
with encryption as
SELECT     dbo.MAESTROPROVEE.MA_CODIGO, dbo.MAESTROPROVEE.PA_CODIGO
FROM         dbo.MAESTROPROVEE INNER JOIN
                      dbo.MAESTRO ON dbo.MAESTROPROVEE.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I')
GROUP BY dbo.MAESTROPROVEE.PA_CODIGO, dbo.MAESTROPROVEE.MA_CODIGO



























GO
