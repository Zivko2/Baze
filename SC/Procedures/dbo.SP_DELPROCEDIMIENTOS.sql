SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DELPROCEDIMIENTOS] (@VALOR VARCHAR(50))   as

declare @NOMBRE varchar(150)



	
	declare cur_procedimientos cursor for
		SELECT     name
		FROM         sysobjects
		WHERE     (type = 'P')
		AND (name LIKE @VALOR)
	
	open cur_procedimientos
	
	
		FETCH NEXT FROM cur_procedimientos INTO @NOMBRE
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
	
		EXEC('if exists (select * from dbo.sysobjects where id = object_id(N'''+@NOMBRE+''') and OBJECTPROPERTY(id, N''IsProcedure'') = 1) drop procedure ['+@NOMBRE+']')
	
	
		FETCH NEXT FROM cur_procedimientos INTO @NOMBRE
	
	END
	
	CLOSE cur_procedimientos
	DEALLOCATE cur_procedimientos



GO
