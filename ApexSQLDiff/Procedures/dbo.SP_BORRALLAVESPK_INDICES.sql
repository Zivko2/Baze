SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE [dbo].[SP_BORRALLAVESPK_INDICES]   as

declare @enunciado sysname, @enunciado2 sysname


-- BORRA LAS TABLAS VACIAS con identity
declare TVACIA cursor for
	SELECT     'IF (SELECT COUNT(*) FROM ['+obj.tabla +'])=0  DROP TABLE ['+obj.tabla +'] '
	FROM         original.dbo.vbasedatos obj
	WHERE     obj.[identity] =1
		and obj.tabla not in (SELECT     obj0.tabla 
				FROM       vbasedatos obj0
				WHERE obj0.[identity] =1
				GROUP BY obj0.tabla)
		and obj.tabla in (SELECT     obj1.tabla 
				FROM       vbasedatos obj1
				GROUP BY obj1.tabla)
	GROUP BY obj.tabla
open TVACIA
	FETCH NEXT FROM TVACIA INTO @enunciado

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		exec(@enunciado)

	FETCH NEXT FROM TVACIA INTO @enunciado
END
CLOSE TVACIA
DEALLOCATE TVACIA


declare TVACIA2 cursor for
	SELECT     'DROP TABLE ['+obj1.tabla +'] '
	FROM         dbo.vbasedatos obj1
	WHERE    obj1.tabla like 'TempImport1%'
	GROUP BY obj1.tabla
	ORDER BY obj1.tabla
open TVACIA2
	FETCH NEXT FROM TVACIA2 INTO @enunciado

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		exec(@enunciado)

	FETCH NEXT FROM TVACIA2 INTO @enunciado
END
CLOSE TVACIA2
DEALLOCATE TVACIA2


-- BORRA LLAVES PRIMARIAS (esta deshabilitado, porque son alguno es clustered y son iguales se no le debe de hacer nada)
/*declare PK cursor for

		SELECT     'ALTER TABLE '+TABLE_NAME+' DROP CONSTRAINT ['+CONSTRAINT_NAME+']'
		FROM         vllaves
		WHERE     (CONSTRAINT_NAME LIKE N'PK%' OR CONSTRAINT_NAME LIKE N'IX%')
		GROUP BY TABLE_NAME, CONSTRAINT_NAME
open PK
	FETCH NEXT FROM PK INTO @enunciado

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		exec(@enunciado)

	FETCH NEXT FROM PK INTO @enunciado
END
CLOSE PK
DEALLOCATE PK
*/


-- borra solo los indices o constraints que no se encuentran en la de original
	declare A cursor for
			select 'ENUNCIADO'=CASE WHEN ISNULL(( (INDEXPROPERTY(OBJECT_ID(t_obj.name),i.name,'IsUnique'))),0)=1 then
			'if exists (select name from sysobjects where name ='''+i.name+ ''''  +') ALTER TABLE '+t_obj.name+' DROP CONSTRAINT ['+i.name + '] '
			else
			'if exists (select name from sysindexes where name ='''+i.name+  '''' +') DROP INDEX '+t_obj.name+'.'+i.name + ' '
			 end
	              	from sysobjects t_obj, syscolumns col, master.dbo.spt_values v, 
				sysindexes i, sysindexkeys k  
			where t_obj.id	= col.id
	                and col.name	= index_col(t_obj.name,i.indid,v.number)
	                and t_obj.id	= i.id
	                and (i.indid = 1) and (k.indid = 1)
	              	and v.type 	= 'P' and (i.name LIKE 'IX%') and k.id = t_obj.id and k.colid = col.colid 
				and i.name not in (select i2.name 
				              	from original.dbo.sysobjects t_obj2, original.dbo.syscolumns col2, master.dbo.spt_values v2, 
							original.dbo.sysindexes i2, original.dbo.sysindexkeys k2  
						where t_obj2.id	= col2.id
				                and col2.name	= index_col(t_obj2.name,i2.indid,v2.number)
				                and t_obj2.id	= i2.id
				                and (i2.indid = 1) and (k2.indid = 1)
				              	and v2.type 	= 'P' and (i2.name LIKE 'IX%') and k2.id = t_obj2.id and k2.colid = col2.colid 
					       group by t_obj2.name, i2.name)		
		       group by t_obj.name, i.name
	               order by t_obj.name, i.name
	open A
	
		FETCH NEXT FROM A INTO @enunciado
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			exec(@enunciado)
	
		FETCH NEXT FROM A INTO @enunciado
	END
	CLOSE A
	DEALLOCATE A


	
	



























GO
