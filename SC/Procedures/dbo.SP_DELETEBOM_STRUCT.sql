SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_DELETEBOM_STRUCT] (@bsu_subensamble INT, @bm_entravigor datetime)   as

SET NOCOUNT ON 
DECLARE @codigo int

		declare crDeleteBomstruct cursor for
			select bst_codigo from bom_struct
			where bsu_subensamble = @bsu_subensamble
			and bst_perini = @bm_entravigor 
		open crDeleteBomstruct
		fetch next from crDeleteBomstruct into @codigo

		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			--print @bm_entravigor
			delete from bom_struct 
			where bst_codigo = @codigo

			fetch next from crDeleteBomstruct into @codigo

		END

		CLOSE crDeleteBomstruct
		DEALLOCATE crDeleteBomstruct





GO
