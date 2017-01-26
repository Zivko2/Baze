SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQGENSTRUCT] (@ma_codigo int)   as

SET NOCOUNT ON 
declare @me_com int, @eq_gen decimal(28,14), @bst_codigo int, @cft_tipo varchar(5)

	select @me_com=me_com, @eq_gen=eq_gen from maestro where ma_codigo=@ma_codigo
	select @cft_tipo=cft_tipo from configuratipo where ti_codigo in 
		(select ti_codigo from maestro where ma_codigo =@ma_codigo)	

if exists (select * from bom_struct
         WHERE BST_HIJO=@ma_codigo AND
          BST_PERINI <= CONVERT(varchar(10), GETDATE(), 101) AND 
          BST_PERFIN >= CONVERT(varchar(10), GETDATE(), 101) and me_codigo=@me_com)

begin

	declare cur_eqgen cursor for
	SELECT    BST_CODIGO
	from bom_struct 	WHERE BST_HIJO=@ma_codigo AND
	BST_PERINI <= CONVERT(varchar(10), GETDATE(), 101) AND 
	BST_PERFIN >= CONVERT(varchar(10), GETDATE(), 101) and me_codigo=@me_com

	open cur_eqgen
	fetch next from cur_eqgen into @bst_codigo
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	UPDATE BOM_STRUCT
	SET FACTCONV = @EQ_GEN
	WHERE BST_CODIGO = @bst_codigo


	/* esto por si la um que se esta manejando en el bom_struct no es la misma que esta en el bom_costo */
	fetch next from cur_eqgen into @bst_codigo

	end

close cur_eqgen
deallocate cur_eqgen
end















































GO
