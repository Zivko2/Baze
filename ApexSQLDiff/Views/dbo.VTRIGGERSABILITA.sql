SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW dbo.VTRIGGERSABILITA
with encryption as
	SELECT     'ALTER TABLE ['+sysobjects_1.name collate database_default +'] ENABLE TRIGGER ['+ sysobjects.name collate database_default +']' AS Enunciado
	FROM         sysobjects INNER JOIN
	                      sysobjects sysobjects_1 ON sysobjects.parent_obj = sysobjects_1.id
	WHERE     (sysobjects.xtype = 'TR')
		 AND (sysobjects.name NOT LIKE 'DEL%') AND (sysobjects.name NOT LIKE 'CUENTA%') 






























GO
