SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_UpdateNulos] (@tabla varchar(200))   as

declare @enunciado2 varchar(8000)


declare UpdateNulo cursor for

	SELECT 'Nulo'=CASE WHEN vista.tipocampo like '%Varchar%' or vista.tipocampo like '%char%' 
			or vista.tipocampo like '%date%' then
			'UPDATE '+lower(vista.tabla)+' SET '+vista.columna+'='''' WHERE '+vista.columna+' IS NULL ' ELSE
			'UPDATE '+lower(vista.tabla)+' SET '+vista.columna+'=0 WHERE '+vista.columna+' IS NULL ' END
	FROM original.dbo.vbasedatos vista
	WHERE  vista.columna in 
			(SELECT     lla.COLUMN_NAME
			FROM         original.dbo.vllaves lla
			WHERE     lla.CONSTRAINT_NAME LIKE 'pk%' AND lla.TABLE_NAME = vista.tabla)
		AND vista.tabla=@tabla
		and vista.[identity]<>1
	GROUP BY vista.tabla, vista.columna, vista.tipocampo, vista.[identity]
open UpdateNulo
	FETCH NEXT FROM UpdateNulo INTO @Enunciado2

	WHILE (@@FETCH_STATUS = 0) 
	begin
		exec(@enunciado2)



	FETCH NEXT FROM UpdateNulo INTO @Enunciado2
end
CLOSE UpdateNulo
DEALLOCATE UpdateNulo











GO
