SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.[estructuras dic 2003]
AS
SELECT     TOP 100 PERCENT BSU_NOPARTE, BST_NOPARTE, BST_INCORPOR, BST_PERINI, BST_PERFIN
FROM         dbo.BOM_STRUCT
WHERE     (BST_PERINI = CONVERT(DATETIME, '2004-01-01 00:00:00', 102))
GO