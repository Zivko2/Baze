SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_Triggers] (@tipo varchar(7), @tag int)   as

--DISABLE
--ENABLE

declare @enunciado sysname

declare A cursor for
	SELECT     'ALTER TABLE ['+sysobjects_1.name+'] '+@tipo+' TRIGGER ['+ sysobjects.name+']'
	FROM         sysobjects INNER JOIN
	                      sysobjects sysobjects_1 ON sysobjects.parent_obj = sysobjects_1.id
	WHERE     (sysobjects.xtype = 'TR')
		 AND (sysobjects.name NOT LIKE 'DEL%')  AND (sysobjects.name NOT LIKE 'CUENTA%') 
		AND sysobjects_1.name IN (SELECT dbo.IMPORTTABLESDETCONT.IMR_TABLA
					FROM dbo.IMPORTTABLES INNER JOIN
				             dbo.IMPORTTABLESDETCONT ON dbo.IMPORTTABLES.IMT_TABLA = dbo.IMPORTTABLESDETCONT.IMR_TMASTER
		WHERE     dbo.IMPORTTABLES.IMT_NUMFORMA =@tag union
		SELECT dbo.IMPORTTABLES.IMT_TABLA
					FROM dbo.IMPORTTABLES INNER JOIN
				             dbo.IMPORTTABLESDETCONT ON dbo.IMPORTTABLES.IMT_TABLA = dbo.IMPORTTABLESDETCONT.IMR_TMASTER
		WHERE     dbo.IMPORTTABLES.IMT_NUMFORMA =@tag
		GROUP BY dbo.IMPORTTABLES.IMT_TABLA)
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
