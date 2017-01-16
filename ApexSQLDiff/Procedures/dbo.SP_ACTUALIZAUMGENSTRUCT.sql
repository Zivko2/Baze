SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAUMGENSTRUCT] (@ma_generico int)   as

SET NOCOUNT ON 
declare @me_com int, @eq_gen decimal(28,14), @bst_codigo int, @cft_tipo varchar(5), @me_gen int



if exists (SELECT    BST_CODIGO
		from bom_struct WHERE BST_HIJO in(select ma_codigo from maestro where ma_generico=@ma_generico) AND
		me_codigo in (select me_com from maestro where ma_codigo=bom_struct.bst_hijo))

begin
	declare cur_umgen cursor for
		SELECT    BST_CODIGO
		from bom_struct WHERE BST_HIJO in(select ma_codigo from maestro where ma_generico=@ma_generico) AND
		me_codigo in (select me_com from maestro where ma_codigo=bom_struct.bst_hijo)
	open cur_umgen
	fetch next from cur_umgen into @bst_codigo
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @ME_GEN=me_com, @EQ_GEN=eq_gen from maestro where ma_codigo in (select bst_hijo from bom_struct where bst_codigo=@bst_codigo)

	select @cft_tipo=cft_tipo from configuratipo where ti_codigo in 
		(select ti_codigo from bom_struct where bst_codigo=@bst_codigo)	

	UPDATE BOM_STRUCT
	SET FACTCONV = @EQ_GEN, ME_GEN = @ME_GEN
	WHERE BST_CODIGO = @bst_codigo


	fetch next from cur_umgen into @bst_codigo

	end

close cur_umgen
deallocate cur_umgen
end
















































GO
