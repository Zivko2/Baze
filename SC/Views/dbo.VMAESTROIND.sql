SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VMAESTROIND
AS
SELECT     MA_CODIGO, MA_NOPARTE, MA_NOPARTEAUX
FROM         dbo.MAESTRO
WHERE     (MA_INV_GEN = 'I')
GO
