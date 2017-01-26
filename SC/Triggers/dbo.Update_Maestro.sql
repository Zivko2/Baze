SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE trigger Update_Maestro on dbo.MAESTRO for update as
SET NOCOUNT ON 
begin       
declare @ma_codigo int, @ma_inv_gen char(1), @Fecha datetime, @Tipo char(1), @pa_origen int, @ma_peso_lb decimal(38,6), @ma_peso_kg decimal(38,6), @zx datetime,
	@ma_generico int, @noparte varchar(30), @eq_gen decimal(28,14), @eq_impmx decimal(28,14), @eq_impfo decimal(28,14), @cft_tipo varchar(5), @CF_PESOS_IMP CHAR(1),
	@ti_codigo int, @me_com int, @ar_impmx int, @ar_expmx int, @ar_impfo int, @me_gen int, @ma_tip_ens char(1), @fechaact varchar(10)
		
	select @ma_codigo = ma_codigo, @ma_inv_gen = ma_inv_gen, @pa_origen = pa_origen, @ma_peso_lb = ma_peso_lb, @ma_peso_kg = ma_peso_kg,
	@ma_generico = ma_generico, @eq_gen=eq_gen, @eq_impmx=eq_impmx, @eq_impfo=eq_impfo, @me_com=me_com, @ar_impmx=ar_impmx,
	@ar_expmx=ar_expmx, @ar_impfo=ar_impfo, @ma_tip_ens=ma_tip_ens from  inserted

	select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from  inserted)


	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         dbo.CONFIGURACION

	SET @Fecha = convert(datetime, convert(varchar(11), getdate(),101))

	if update(me_com) and @ma_inv_gen = 'G' 
	begin

		exec SP_ACTUALIZAUMGENSTRUCT @ma_codigo
	end



	SET @fechaact = convert(VARCHAR(10),getdate(),101)

	UPDATE MAESTROALM
	SET MAA_FECHAREVISION=@fechaact
	WHERE MA_CODIGO= @ma_codigo

	/* ya esta en codigo

	if update(ma_peso_kg) and @ma_inv_gen = 'I' and (@ma_peso_kg>0)
	 and exists(select * from bom_struct where bst_hijo=@MA_CODIGO and me_codigo=@me_com)
	begin
		Exec SP_ACTUALIZAPESOSTRUCT @MA_CODIGO
	
	end*/


	if update(ma_generico) and @ma_inv_gen = 'I' AND ((@cft_tipo<>'P' AND @cft_tipo<>'S') or ((@cft_tipo='P' or @cft_tipo='S') and @ma_tip_ens='C'))
	begin
		exec SP_ACTUALIZAGENSTRUCT @ma_generico
	end


	if update(eq_gen) and @ma_inv_gen = 'I'  AND ((@cft_tipo<>'P' AND @cft_tipo<>'S') or ((@cft_tipo='P' or @cft_tipo='S') and @ma_tip_ens='C'))
	begin
		exec SP_ACTUALIZAEQGENSTRUCT @ma_codigo
	end

	/*if exists (select bst_hijo from bom_struct  where bst_hijo =@ma_codigo group by bst_hijo)
	begin
		if update(pa_origen) and (@ma_inv_gen = 'I') 

		exec SP_ACTUALIZABOMSTRUCTPAIS @ma_codigo, @pa_origen


		if update(ma_def_tip) and (@ma_inv_gen = 'I') 
		exec SP_ACTUALIZATIPOCOSTOMAESTRO  @ma_codigo

		if update(ti_codigo) and (@ma_inv_gen = 'I') 

		exec  SP_ACTUALIZATIPOMATMAESTRO  @ma_codigo, @ti_codigo


	end*/


	/* actualizacion de factores de conversion */

		if update(eq_gen) and  ((@eq_gen)=0 or @eq_gen is null)
		update maestro
		set eq_gen=1
		where ma_codigo in (select ma_codigo from inserted)	
		and (eq_gen=0 or eq_gen is null)
	
		if update(eq_impmx) and ((@eq_impmx)=0 or @eq_impmx is null)
		update maestro
		set eq_impmx=1
		where ma_codigo in (select ma_codigo from inserted)	
		and (eq_impmx=0 or eq_impmx is null)
	
		if update(eq_impfo) and ((@eq_impfo)=0 or @eq_impfo is null)
		update maestro
		set eq_impfo=1
		where ma_codigo in (select ma_codigo from inserted)	
		and  (eq_impfo=0 or eq_impfo is null)



		if update(ma_servicio)
		exec SP_ACTUALIZATIPOCOSTOBOM @ma_codigo



	IF @CF_PESOS_IMP='K'
	if update(ma_peso_kg)
	if (@ma_peso_lb <> (round(@ma_peso_kg *2.20462442018378,6)) or @ma_peso_lb  is null)
	begin	
		update maestro 
		set ma_peso_lb = round(ma_peso_kg * 2.20462442018378,6)
		where ma_codigo in (select ma_codigo from inserted) and
		ma_peso_lb <> round(ma_peso_kg * 2.20462442018378,6)


		/*if exists (select bst_hijo from bom_struct  where bst_hijo =@ma_codigo group by bst_hijo)
		UPDATE dbo.BOM_STRUCT
		SET     dbo.BOM_STRUCT.BST_PESO_KG= ROUND(dbo.MAESTRO.MA_PESO_KG,6)
		FROM         dbo.MAESTRO INNER JOIN
		      dbo.BOM_STRUCT ON dbo.MAESTRO.MA_CODIGO = dbo.BOM_STRUCT.BST_HIJO
		WHERE dbo.BOM_STRUCT.BST_PESO_KG IS NULL OR 
			dbo.BOM_STRUCT.BST_PESO_KG<> ROUND(dbo.MAESTRO.MA_PESO_KG,6)
		AND dbo.MAESTRO.MA_CODIGO=@ma_codigo*/


	end

	IF @CF_PESOS_IMP='L'
	if update(ma_peso_lb)
	if (@ma_peso_kg <> (round(@ma_peso_lb/2.20462442018378,6)) or @ma_peso_kg is null)
	begin
		update maestro 
		set ma_peso_kg = round(ma_peso_lb/2.20462442018378,6)
		where ma_codigo in (select ma_codigo from inserted) and
		ma_peso_kg <> round(ma_peso_lb/2.20462442018378,6)

		/*if exists (select bst_hijo from bom_struct  where bst_hijo =@ma_codigo group by bst_hijo)
		UPDATE dbo.BOM_STRUCT
		SET     dbo.BOM_STRUCT.BST_PESO_KG= ROUND(dbo.MAESTRO.MA_PESO_KG/2.20462442018378,6)
		FROM         dbo.MAESTRO INNER JOIN
		      dbo.BOM_STRUCT ON dbo.MAESTRO.MA_CODIGO = dbo.BOM_STRUCT.BST_HIJO
		WHERE dbo.BOM_STRUCT.BST_PESO_KG IS NULL OR 
			dbo.BOM_STRUCT.BST_PESO_KG<> ROUND(dbo.MAESTRO.MA_PESO_KG/2.20462442018378,6)
		AND dbo.MAESTRO.MA_CODIGO=@ma_codigo*/



	end


end






















GO
