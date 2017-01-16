SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZA9999] (@bm_perfin datetime, @ma_subensamble int)   as

SET NOCOUNT ON 
declare @bst_codigo int, @bst_hijo int , @minbst_codigo int, @countreg int

	declare cur_9999 cursor for
		select bst_codigo, bst_hijo from bom_struct
		where bsu_subensamble = @ma_subensamble
		and bst_perfin = @bm_perfin 
	open cur_9999
	fetch next from cur_9999 into @bst_codigo, @bst_hijo
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

		if not exists (select * from bom_struct where bst_perfin = '01/01/9999' 
			and bsu_subensamble=@ma_subensamble and bst_hijo=@bst_hijo)
			update bom_struct
			set bst_perfin = '01/01/9999'
			where bst_codigo=@bst_codigo
		else
			begin
				-- se borra porque si no existirian 2 registros iguales pero con fecha diferente y uno de ellos ya no existe en la tabla bom
	
				select @countreg= count(*) from bom_struct where bst_perfin = '01/01/9999'  
				and bsu_subensamble=@ma_subensamble and bst_hijo=@bst_hijo

				select @minbst_codigo= min(bst_codigo) from bom_struct where bst_perfin = '01/01/9999'  
				and bsu_subensamble=@ma_subensamble and bst_hijo=@bst_hijo
	
				if @countreg >1 
				delete from bom_struct
				where bst_perfin = '01/01/9999'  
				and bsu_subensamble=@ma_subensamble and bst_hijo=@bst_hijo and bst_codigo <>@minbst_codigo
			end

		fetch next from cur_9999 into @bst_codigo, @bst_hijo
	
		END
	
	CLOSE cur_9999
	DEALLOCATE cur_9999


GO
