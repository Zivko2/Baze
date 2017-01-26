SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





















CREATE TRIGGER [UPDATE_BOM_STRUCT] ON dbo.BOM_STRUCT 
FOR UPDATE
AS
SET NOCOUNT ON 

	declare @TipoLetra char(1), @bst_codigo int, @bsu_subensamble int, @bst_hijo  int, @perini  varchar(10),
	@dummy char(1), @codigo int, @Factconv decimal(28,14), @pa_codigo int, @pa_origen int, @AYER datetime, @hoy  datetime, @bstcodigoactual int,
	@bstcodigoanterior  int, @count int, @bmperfinanterior datetime, @entravigorantes datetime, @entravigor1 datetime, @perfin varchar(10),
	@bmentravigorposterior datetime, @bstcodigoposterior int, @perfinantes datetime, @bmperfin1 datetime, @bst_trans char(1),
	@me_codigo int, @bst_peso_kg decimal(38,6)


	/*-------------------------------------------------------*/

	if update(bst_perini) and not update(bst_perfin) or update(bst_trans) 
	begin
		declare crBOMUpdates cursor for
			select  bst_codigo, bsu_subensamble, me_codigo, 
			bst_hijo, convert(varchar(10), bst_perini,101), factconv, convert(varchar(10), bst_perfin,101), bst_trans  from inserted
		open crBOMUpdates
		fetch next from crBOMUpdates into @bst_codigo, @bsu_subensamble, @me_codigo, 
			@bst_hijo, @perini, @factconv, @perfin, @bst_trans
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
				if update(bst_perini) and not update(bst_perfin) and exists(select * from bom_struct where bsu_subensamble=@bsu_subensamble
				and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo)
				exec SP_BOM_STRUCTACTUALIZAFECHAS @BST_CODIGO,  'S', 'N', @perini, @perfin
	
				if update(bst_perini) and update(bst_perfin) and exists(select * from bom_struct where bsu_subensamble=@bsu_subensamble
				and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo)
				exec SP_BOM_STRUCTACTUALIZAFECHAS @BST_CODIGO,  'S', 'S', @perini, @perfin
	
				if not update(bst_perini) and update(bst_perfin) and exists(select * from bom_struct where bsu_subensamble=@bsu_subensamble
				and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo)
				exec SP_BOM_STRUCTACTUALIZAFECHAS @BST_CODIGO,  'N', 'S', @perini, @perfin
	
				if @factconv=0
				update bom_struct
				set factconv=1
				where bst_codigo =@bst_codigo
	
	
			-- actualiza el tipo de costo del hijo que se esta modificando 
				/*if update(bst_trans) or update(pa_codigo) or update(ti_codigo)
				begin
					exec stpTipoCosto @bst_codigo,  @bst_trans, @pa_codigo, @tipocosto=@dummy output
	
					update bom_struct set bst_tipocosto = @dummy 
					where bst_codigo = @bst_codigo
				end*/


	
		fetch next from crBOMUpdates into @bst_codigo, @bsu_subensamble, @me_codigo,
			@bst_hijo, @perini, @factconv, @perfin, @bst_trans
		END
		CLOSE crBOMUpdates
		DEALLOCATE crBOMUpdates


		/*if update(bst_peso_kg)
		begin
			select  @bst_codigo=bst_codigo, @me_codigo=me_codigo, @bst_peso_kg=bst_peso_kg,
			@bst_hijo=bst_hijo  from inserted
	
			if (@bst_peso_kg>0) and exists (select * from bom_struct where me_codigo=@me_codigo and bst_hijo=@bst_hijo
			and bst_peso_kg<>@bst_peso_kg)
				update bom_struct
				set bst_peso_kg=@bst_peso_kg
				where me_codigo=@me_codigo and bst_hijo=@bst_hijo
				and (bst_peso_kg<>@bst_peso_kg or bst_peso_kg is null) and bst_codigo<>@bst_codigo
		end*/

	end





















GO
