SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSPRODUC] (@CodigoProduc int)   as

SET NOCOUNT ON 
	if exists (select * from producliga where prod_indiced in (select prod_indiced from producdet where pro_codigo=@CodigoProduc))
		update produc
		set pro_estatus='C'
		where pro_codigo=@CodigoProduc
	else
		update produc
		set pro_estatus='S'
		where pro_codigo=@CodigoProduc
















































GO
