SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW dbo.vwTmpAlterTR
with encryption as
SELECT     'ALTER TABLE [' + sysobjects_1.name collate database_default + '] ENABLE TRIGGER [' + dbo.sysobjects.name collate database_default + '];' AS Uno
FROM         dbo.sysobjects INNER JOIN
                      dbo.sysobjects sysobjects_1 ON dbo.sysobjects.parent_obj = sysobjects_1.id
WHERE     (dbo.sysobjects.xtype = 'TR') AND (dbo.sysobjects.name NOT LIKE 'DEL%') AND (dbo.sysobjects.name NOT LIKE 'CUENTA%')











GO
