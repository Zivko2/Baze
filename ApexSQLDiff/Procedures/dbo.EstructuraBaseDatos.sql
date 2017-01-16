SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure dbo.EstructuraBaseDatos (@Tabla varchar(30))  as
      /*ejecutar vista de estructura de base de datos sin llaves*/
SELECT     obj.name AS tabla, col.name AS columna, col.colid AS orden, com.text AS defaultcampo, col.isnullable AS permitenulos, 
                      MIN(spt_dtp.LOCAL_TYPE_NAME) AS tipocampo, col.length + spt_dtp.charbin AS tamano, COLUMNPROPERTY(obj.id, col.name,'Isidentity') as [identity],col.xprec as preci,col.xscale as escala
FROM         dbo.syscomments com RIGHT OUTER JOIN
                      dbo.sysobjects obj LEFT OUTER JOIN
                      dbo.syscolumns col ON obj.id = col.id LEFT OUTER JOIN
                      dbo.systypes typ ON col.xusertype = typ.xusertype ON com.id = col.cdefault LEFT OUTER JOIN
                      master.dbo.spt_datatype_info spt_dtp ON typ.xtype = spt_dtp.ss_dtype
WHERE     (spt_dtp.ODBCVer IS NULL OR
                      spt_dtp.ODBCVer = 2) AND (obj.xtype IN ('U'))
AND obj.name =@Tabla
GROUP BY obj.name, col.name, col.colid, com.text, col.isnullable, col.length + spt_dtp.charbin, permissions(obj.id, col.name), COLUMNPROPERTY(obj.id, col.name,'Isidentity'),col.xprec,col.xscale
HAVING      (permissions(obj.id, col.name) <> 0)
ORDER BY obj.name, col.colid



GO
