SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* cursor para todos los consecutivos*/
CREATE PROCEDURE [dbo].[SP_ACTUALIZACONSECUTIVOTABLA]  (@CV_TIPO VARCHAR(5))   as

SET NOCOUNT ON 
declare @tabla varchar(50), @campo varchar(70)

SELECT     @tabla=CV_TABLA, @campo=CV_CAMPO
FROM         dbo.CONSECUTIVO
WHERE CV_TIPO=@CV_TIPO

/*	if exists (select * from dbo.sysobjects where name=@tabla)
 	 exec ('declare @maximo int select @maximo = max('+@campo+')+1 from '+@tabla+
	 ' update consecutivo set cv_codigo=isnull(@maximo,0)+1 where cv_campo='''+@campo+''' and cv_tabla='''+@tabla+'''' )
	else
 	 exec (' update consecutivo set cv_codigo=1 where cv_campo='''+@campo+''' and cv_tabla='''+@tabla+'''' )*/

	if exists (select * from dbo.sysobjects where name=@tabla)
 	 exec ('declare @maximo int, @maximo2 int

	  select @maximo = isnull(max('+@campo+'),0)+1 from '+@tabla+'

	if '''+@tabla+'''=''MAESTRO''
	begin
	    select @maximo2 = isnull(max(MA_CODIGO),0)+1 from MAESTROREFER

 	    if @maximo2>@maximo 
	      set @maximo=@maximo2
	end

	 update consecutivo set cv_codigo=isnull(@maximo,0)+1 where cv_campo='''+@campo+''' and cv_tabla='''+@tabla+'''' )
	else
 	 exec (' update consecutivo set cv_codigo=1 where cv_campo='''+@campo+''' and cv_tabla='''+@tabla+'''' )


GO
