SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.EliminarTablasCampos   as


declare @Tabla sysname,@NombreAnterior sysname,@TipoActualizacion sysname, @default sysname

declare cur_Eliminar cursor for
SELECT Tabla,NombreAnterior,TipoActualizacion 
FROM Original.dbo.NOMBRECAMPOS
WHERE TIPOACTUALIZACION='C' or TipoActualizacion='T' or TipoActualizacion='S' or TipoActualizacion='V' or TipoActualizacion='G'

open cur_Eliminar

fetch next from Cur_Eliminar into @Tabla,@NombreAnterior,@TipoActualizacion
WHILE (@@FETCH_STATUS <> -1) 
BEGIN 
	if @TipoActualizacion='C'
	 begin
                 if @NombreAnterior=(Select name from syscolumns where (id=(select id from sysobjects where name=@Tabla)) and (name=@NombreAnterior))
                       begin
                           --verificar si tiene default
                             set @Default=(SELECT NAME FROM SYSOBJECTS WHERE id in (select cdefault from syscolumns where name=@NombreAnterior and id=(select id from sysobjects where name=@Tabla))) 
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
   	if @TipoActualizacion='T' 
	 begin
              if exists (select * from sysobjects where id = object_id(N'['+@tabla+']') and OBJECTPROPERTY(id, N'IsTable') = 1)
                begin
		  EXEC('DROP TABLE ['+@TABLA+']')
 	        end 	
	 end

	if @TipoActualizacion='S'
   	  begin
              if exists (select * from sysobjects where id = object_id(N'['+@tabla+']') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
               Exec('DROP PROCEDURE ['+@TABLA+']')    
	  end	
       if @TipoActualizacion='V'
          begin
              if exists (select * from sysobjects where id = object_id(N'['+@tabla+']') and OBJECTPROPERTY(id, N'IsView') = 1)
               Exec('DROP VIEW ['+@TABLA+']')    
          end 
       if @TipoActualizacion='G'
          begin
              if exists (select * from sysobjects where id = object_id(N'['+@tabla+']') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
               Exec('DROP TRIGGER ['+@TABLA+']')    
          end 
FETCH NEXT FROM Cur_Eliminar INTO @Tabla,@NombreAnterior,@TipoActualizacion
END 

CLOSE cur_Eliminar
DEALLOCATE cur_Eliminar
GO
