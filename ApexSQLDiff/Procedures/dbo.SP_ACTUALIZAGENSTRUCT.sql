SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAGENSTRUCT] (@ma_codigo int)   as

SET NOCOUNT ON 
-- componente que se le esta cambiando el generico
declare @me_com int, @eq_gen decimal(28,14), @bst_codigo int, @cft_tipo varchar(5), @me_gen int


	select @ME_GEN=me_com, @EQ_GEN=eq_gen from maestro where ma_codigo in (select ma_generico from maestro where ma_codigo=@ma_codigo)



	select @cft_tipo=cft_tipo from configuratipo where ti_codigo in 
		(select ti_codigo from maestro where ma_codigo=@ma_codigo)	


if exists (SELECT    BST_CODIGO
		from bom_struct WHERE BST_HIJO=@ma_codigo AND
		me_codigo in (select me_com from maestro where ma_codigo=@ma_codigo))

begin
	declare cur_gen cursor for
		SELECT    BST_CODIGO
		from bom_struct WHERE BST_HIJO =@ma_codigo AND
		me_codigo in (select me_com from maestro where ma_codigo=@ma_codigo)
	open cur_gen
	fetch next from cur_gen into @bst_codigo
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		UPDATE BOM_STRUCT
		SET FACTCONV = @EQ_GEN, ME_GEN = @ME_GEN
		WHERE BST_CODIGO = @bst_codigo

	fetch next from cur_gen into @bst_codigo

	end

close cur_gen
deallocate cur_gen
end
















































GO
