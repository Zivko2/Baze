SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARANCELFACTEXPALL] (@fe_fechaini datetime, @fe_fechafin datetime)   as

SET NOCOUNT ON 

declare @ar_codigo int, @ar_fraccion varchar(30)

declare cur_actualizaeqarancelfactexpall cursor for
	SELECT dbo.FACTEXPDET.AR_EXPMX 
	FROM dbo.FACTEXP INNER JOIN dbo.FACTEXPDET 
		ON dbo.FACTEXP.fe_CODIGO = dbo.FACTEXPDET.fe_CODIGO
	WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) 
	UNION 
	SELECT dbo.FACTEXPDET.AR_IMPFO 
	FROM dbo.FACTEXP INNER JOIN dbo.FACTEXPDET 
		ON dbo.FACTEXP.fe_CODIGO = dbo.FACTEXPDET.fe_CODIGO
	WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) 


open cur_actualizaeqarancelfactexpall


	FETCH NEXT FROM cur_actualizaeqarancelfactexpall INTO @ar_codigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @ar_fraccion=ar_fraccion from arancel where ar_codigo=@ar_codigo

	print '<==========' + convert(varchar(50), @ar_codigo) +' '+ @ar_fraccion + '==========>' 


	EXEC SP_ACTUALIZAEQARANCELFACTEXP @ar_codigo, @fe_fechaini, @fe_fechafin


	FETCH NEXT FROM cur_actualizaeqarancelfactexpall INTO @ar_codigo

END

CLOSE cur_actualizaeqarancelfactexpall
DEALLOCATE cur_actualizaeqarancelfactexpall
















































GO
