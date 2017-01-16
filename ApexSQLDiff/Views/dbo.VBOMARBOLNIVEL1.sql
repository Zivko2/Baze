SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



























CREATE VIEW dbo.VBOMARBOLNIVEL1
with encryption as
SELECT     dbo.BOM_STRUCT.*
FROM         dbo.BOM_STRUCT
WHERE     (GETDATE() between BST_PERINI AND BST_PERFIN)



GO
