SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE EliminarTablasCamposR (@Tabla varchar(30))   as


DECLARE @NombreAnterior sysname,@TipoActualizacion sysname, @default sysname

declare cur_Eliminar cursor for
SELECT NombreAnterior,TipoActualizacion 
FROM Original.dbo.NOMBRECAMPOS
WHERE TIPOACTUALIZACION='R' and TABLA=@Tabla

open cur_Eliminar

fetch next from Cur_Eliminar into @NombreAnterior,@TipoActualizacion
WHILE (@@FETCH_STATUS <> -1) 
BEGIN 
if @TipoActualizacion='R'
 begin
   if @NombreAnterior=(Select name from syscolumns where (id=(select id from sysobjects where name=@Tabla)) and (name=@NombreAnterior))
      begin
        --verificar si tiene default
        set @Default=(SELECT NAME FROM SYSOBJECTS WHERE id in (select cdefault from syscolumns where name=@NombreAnterior))
        if @Default is null
           begin
	     --delete from syscolumns where id=(
	     --select id from sysobjects where name=@Tabla) and name=@NombreAnterior
             EXEC('alter table '+@tabla+' drop column '+@NombreAnterior)
 	   end
        else
           begin
             EXEC('alter table '+@tabla+' drop constraint '+@default)
             EXEC('alter table '+@tabla+' drop column '+@NombreAnterior)
	     --delete from syscolumns where id=(
	     --select id from sysobjects where name=@Tabla) and name=@NombreAnterior
           end
      end
 end
FETCH NEXT FROM Cur_Eliminar INTO @NombreAnterior,@TipoActualizacion
END 

CLOSE cur_Eliminar
DEALLOCATE cur_Eliminar
GO
