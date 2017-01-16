SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_actualizaBomCosto ( @bst_codigo int)   as

SET NOCOUNT ON 


	declare @ma_grav_mp decimal(38,6), @ma_grav_add decimal(38,6),@ma_grav_emp decimal(38,6), 
	@ma_grav_gi decimal(38,6), @ma_grav_gi_mx decimal(38,6), @ma_grav_mo decimal(38,6), 
	@ma_ng_mp decimal(38,6), @ma_ng_add decimal(38,6), @ma_ng_emp decimal(38,6), @ma_ng_va decimal(38,6), 
	@ma_costo decimal(38,6),  @ma_inv_gen char(1), @tco_codigo int,
	@ma_grava_va char (1), @CFT_TIPO varchar(1), @MA_NG_USA decimal(38,6), @subensamble int,
	@ma_codigo int

	select @subensamble=bsu_subensamble, @ma_codigo=bst_hijo from bom_struct where bst_codigo=@bst_codigo

	select @ma_grav_mp = isnull(ma_grav_mp,0), @ma_grav_add = isnull(ma_grav_add,0), 
	@ma_grav_emp = isnull(ma_grav_emp,0), @ma_ng_mp = isnull(ma_ng_mp,0), @ma_ng_add = isnull(ma_ng_add,0), 
	@ma_ng_emp = isnull(ma_ng_emp,0), @ma_grav_gi = isnull(ma_grav_gi,0), @ma_grav_gi_mx = isnull(ma_grav_gi_mx,0),
	@ma_grav_mo = ma_grav_mo,  @ma_costo = ma_costo, @tco_codigo=tco_codigo,
	@ma_ng_usa = isnull(ma_ng_usa,0)
	from vmaestrocost where ma_codigo =@ma_codigo 



		if exists (select * from BOM_COSTO where bst_codigo=@bst_codigo)
		begin
	
			if @ma_costo is not null
			update dbo.bom_costo
			set dbo.bom_costo.bst_grav_mp = @ma_grav_mp, dbo.bom_costo.bst_grav_add = @ma_grav_add, 
			dbo.bom_costo.bst_grav_emp = @ma_grav_emp, dbo.bom_costo.bst_ng_mp = @ma_ng_mp, 
			dbo.bom_costo.bst_ng_add = @ma_ng_add, dbo.bom_costo.bst_ng_emp = @ma_ng_emp,
			dbo.bom_costo.bst_grav_gi = @ma_grav_gi, dbo.bom_costo.bst_grav_gi_mx = @ma_grav_gi_mx, 
			dbo.bom_costo.bst_grav_mo = @ma_grav_mo, dbo.bom_costo.bst_costo = @ma_costo,
			dbo.bom_costo.bst_ng_usa = @ma_ng_usa
			where bst_codigo = @bst_codigo
		end
		else	--cuando no existe 
		begin

			if @ma_costo is not null
			insert into bom_costo (bst_codigo, bst_ng_mp, bst_ng_add, bst_ng_emp, bst_grav_mp, bst_grav_add,
			 bst_grav_emp, bst_grav_gi, bst_grav_gi_mx, bst_grav_mo, bst_costo, tco_codigo, 
			bst_ng_usa)

			values (@BST_CODIGO, @MA_NG_MP, @MA_NG_ADD, 	
			@MA_NG_EMP, @MA_GRAV_MP, @MA_GRAV_ADD, @MA_GRAV_EMP, @MA_GRAV_GI, 
			@MA_GRAV_GI_MX, @MA_GRAV_MO, @MA_COSTO, @TCO_CODIGO, @MA_NG_USA)
	
		end




GO
