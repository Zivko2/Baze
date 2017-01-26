SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_TriggersCar] (@tipo varchar(7), @tag int)   as

--DISABLE
--ENABLE

declare @enunciado sysname

declare A cursor for
	SELECT     'ALTER TABLE ['+sysobjects_1.name+'] '+@tipo+' TRIGGER ['+ sysobjects.name+']'
	FROM         sysobjects INNER JOIN
	                      sysobjects sysobjects_1 ON sysobjects.parent_obj = sysobjects_1.id
	WHERE     (sysobjects.xtype = 'TR')
		 AND (sysobjects.name NOT LIKE 'DEL%')  AND (sysobjects.name NOT LIKE 'CUENTA%') 
		AND sysobjects_1.name IN (SELECT IMT_TABLA FROM IMPORTTABLES WHERE IMT_NUMFORMA = @tag)
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
