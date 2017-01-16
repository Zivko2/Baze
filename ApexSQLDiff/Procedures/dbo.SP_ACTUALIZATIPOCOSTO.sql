SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














/* actualiza el tipo de costo del registro en cuestion */
CREATE PROCEDURE [dbo].[SP_ACTUALIZATIPOCOSTO]  (@bst_codigo int)   as

SET NOCOUNT ON 

declare @bst_trans char(1), @dummy char(1), @pa_codigo int


	SELECT     @bst_trans=BST_TRANS, @pa_codigo=pa_origen
	FROM BOM_STRUCT LEFT OUTER JOIN MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO
	WHERE BST_CODIGO=@bst_codigo



		exec stpTipoCosto @bst_codigo,  @bst_trans, @pa_codigo, @tipocosto=@dummy output


		update maestro
		set bst_tipocosto = @dummy 
		where ma_codigo in (select bst_hijo from bom_struct where bst_codigo = @bst_codigo)




GO
