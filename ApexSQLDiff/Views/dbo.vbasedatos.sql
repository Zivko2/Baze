SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.vbasedatos
with encryption as
SELECT     TOP 100 PERCENT obj.name AS tabla, col.name AS columna, col.colid AS orden, com.text AS defaultcampo, col.isnullable AS permitenulos, 
                      MIN(typ.name) AS tipocampo, col.length + case when typ.name in ('varbinary', 'varchar', 'binary', 'char', 'timestamp','nvarchar', 'nchar', 'image', 'text', 'sql_variant', 'ntext') then 0 else null end AS tamano, 
           COLUMNPROPERTY(obj.id, col.name,'Isidentity') as [identity],col.xprec as preci,col.xscale as escala

FROM         dbo.syscomments com RIGHT OUTER JOIN
                      dbo.sysobjects obj LEFT OUTER JOIN
                      dbo.syscolumns col ON obj.id = col.id LEFT OUTER JOIN
                      dbo.systypes typ ON col.xusertype = typ.xusertype ON com.id = col.cdefault 
WHERE     (obj.xtype IN ('U')) 
GROUP BY obj.name, col.name, col.colid, com.text, col.isnullable, col.length, typ.name, permissions(obj.id, col.name), 
COLUMNPROPERTY(obj.id, col.name,'Isidentity'),col.xprec,col.xscale
HAVING      (permissions(obj.id, col.name) <> 0)
ORDER BY obj.name, col.colid



GO
