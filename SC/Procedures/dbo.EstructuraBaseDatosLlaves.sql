SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.EstructuraBaseDatosLlaves (@Tabla VarChar(30))   as

SELECT     c_obj.name AS CONSTRAINT_NAME, t_obj.name AS TABLE_NAME, col.name AS COLUMN_NAME
FROM         sysobjects c_obj, sysobjects t_obj, syscolumns col, sysreferences ref
WHERE     c_obj.uid = user_id() AND c_obj.xtype IN ('F') AND t_obj.id = c_obj.parent_obj AND t_obj.id = col.id AND col.colid IN (ref.fkey1, ref.fkey2, ref.fkey3, 
                      ref.fkey4, ref.fkey5, ref.fkey6, ref.fkey7, ref.fkey8, ref.fkey9, ref.fkey10, ref.fkey11, ref.fkey12, ref.fkey13, ref.fkey14, ref.fkey15, ref.fkey16) AND 
                      c_obj.id = ref.constid AND t_obj.name=@Tabla 
UNION
SELECT     i.name AS CONSTRAINT_NAME, t_obj.name AS TABLE_NAME, col.name AS COLUMN_NAME
FROM         sysobjects c_obj, sysobjects t_obj, syscolumns col, master.dbo.spt_values v, sysindexes i
WHERE     c_obj.uid = user_id() AND t_obj.id = c_obj.parent_obj AND t_obj.xtype = 'U' AND t_obj.id = col.id AND col.name = index_col(t_obj.name, i.indid, 
                      v.number) AND t_obj.id = i.id AND c_obj.name = i.name AND v.number > 0 AND v.number <= i.keycnt AND v.type = 'P'
	AND t_obj.name=@Tabla










GO
