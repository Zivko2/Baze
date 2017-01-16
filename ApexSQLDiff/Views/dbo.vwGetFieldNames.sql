SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW dbo.vwGetFieldNames
with encryption as
SELECT     dbo.sysobjects.name, dbo.syscolumns.name AS ColumnName, dbo.sysobjects.type, dbo.syscolumns.xtype
FROM         dbo.sysobjects INNER JOIN
                      dbo.syscolumns ON dbo.sysobjects.id = dbo.syscolumns.id
WHERE     (dbo.sysobjects.type = 'U') AND (dbo.sysobjects.name = N'TReporte')









GO
