SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





















CREATE TRIGGER [DELETE_BOM_STRUCT] ON dbo.BOM_STRUCT 
FOR DELETE 
AS
SET NOCOUNT ON 



/*	if exists (select * from bom_costo where bst_codigo in (select bst_codigo from deleted))
		Delete from bom_costo where bst_codigo in (select bst_codigo from deleted)

*/
	if exists (select * from bom where ma_subensamble in (select bsu_subensamble from deleted)) and not exists (select * from bom_struct  where bsu_subensamble in (select bsu_subensamble from deleted))
		Delete from bom where ma_subensamble in (select bsu_subensamble from deleted)





















GO
