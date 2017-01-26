SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























































CREATE TRIGGER [INSERT_FACTEXPBOM_ARANCEL] ON [dbo].[FACTEXPBOM_ARANCEL] 
FOR INSERT, UPDATE
AS

	declare @fed_indiced int, @fed_gra_mp decimal(38,6), @fed_gra_add decimal(38,6),@fed_gra_emp decimal(38,6), 
	@fed_gra_gi decimal(38,6), @fed_gra_gi_mx decimal(38,6), @fed_gra_mo decimal(38,6), @fed_ng_usa decimal(38,6),
	@fed_ng_mp decimal(38,6), @fed_ng_add decimal(38,6), @fed_ng_emp decimal(38,6), @fed_ng_va decimal(38,6), 
	@fed_ng_gi decimal(38,6), @fed_ng_gi_mx decimal(38,6), @fed_ng_mo decimal(38,6), @fed_costo decimal(38,6),  
	@Fecha datetime, @Tipo char(1), @cft_tipo char(1), @tco_codigo smallint, @TCO_MANUFACTURA INT, @TCO_COMPRA INT,
	@consecutivo int, @consecutivo1 int, @consecutivo2 int, @fed_tipocosto char(1),
	@fed_ng_mp2 decimal(38,6), @fed_ng_add2 decimal(38,6), @fed_ng_emp2 decimal(38,6), @fed_gra_mp2 decimal(38,6), @fed_gra_add2 decimal(38,6), @fed_gra_emp2 decimal(38,6), 
	@fed_gra_gi2 decimal(38,6), @fed_gra_gi_mx2 decimal(38,6), @fed_gra_mo2 decimal(38,6), @fed_costo2 decimal(38,6), @fed_ng_usa2 decimal(38,6),
	@ti_codigo int

	IF (SELECT CF_USACLASSCOSTO FROM CONFIGURACION)='S'
	BEGIN
		declare crFEBomArancelInsert cursor for
			select fed_indiced, fed_tipocosto
			from inserted
		open crFEBomArancelInsert
			fetch next from crFEBomArancelInsert into @fed_indiced, @fed_tipocosto
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='1' and fed_indiced=@fed_indiced)
				select @fed_gra_mp = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='1' and fed_indiced =@fed_indiced
				else
				set @fed_gra_mp=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='6' and fed_indiced=@fed_indiced)
				select @fed_gra_add = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='6' and fed_indiced =@fed_indiced
				else
				set @fed_gra_add=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='8' and fed_indiced=@fed_indiced)
				select @fed_gra_emp = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='8' and fed_indiced =@fed_indiced
				else
				set @fed_gra_emp=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='2' and fed_indiced=@fed_indiced)
				select @fed_ng_mp = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='2' and fed_indiced =@fed_indiced
				else
				set @fed_ng_mp=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='7' and fed_indiced=@fed_indiced)	
				select @fed_ng_add = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='7' and fed_indiced =@fed_indiced
				else
				set @fed_ng_add=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='3' and fed_indiced=@fed_indiced)
				select @fed_ng_emp = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='3' and fed_indiced =@fed_indiced
				else
				set @fed_ng_emp=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='4' and fed_indiced=@fed_indiced)
				select @fed_gra_gi = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='4'
				and fed_indiced =@fed_indiced
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='9' and fed_indiced=@fed_indiced)
				select @fed_gra_gi_mx = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='9' and fed_indiced =@fed_indiced
				else
				set @fed_gra_gi_mx=0
		
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='5' and fed_indiced=@fed_indiced)
				select @fed_gra_mo = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='5' and fed_indiced =@fed_indiced
				else
				set @fed_gra_mo=0

				/* costo no gravable usa, este costo no pertenece a la suma de coto ng y grav del costo unitario, es solo de consulta */
				if exists(select fed_costo from factexpbom_arancel where fed_tipocosto='N' and fed_indiced=@fed_indiced)
				select @fed_ng_usa = sum(fed_costo) from factexpbom_arancel where fed_tipocosto='N' and fed_indiced =@fed_indiced
				else
				set @fed_ng_usa= isnull(@fed_ng_mp,0)+isnull(@fed_ng_add,0)
		
			
				SET @Fecha = convert(datetime, convert(varchar(11), getdate(),101))
			
				select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from factexpdet where fed_indiced in (select fed_indiced from inserted))
				SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA FROM dbo.CONFIGURACION
			
				if @cft_tipo='P' or @cft_tipo='S' 
				set @tco_codigo=@TCO_MANUFACTURA
				else
				set @tco_codigo=@TCO_COMPRA
		
				if (@cft_tipo = 'S') or (@cft_tipo = 'P')
					set @fed_costo = isnull(@fed_gra_mp,0) + isnull(@fed_gra_add,0) + isnull(@fed_gra_emp, 0) + isnull(@fed_gra_gi,0) + 
					isnull(@fed_gra_gi_mx,0) + isnull(@fed_gra_mo,0) + isnull(@fed_ng_mp,0) + isnull(@fed_ng_add,0) + isnull(@fed_ng_emp,0) 
				
				else
					select @fed_costo=sum(fed_costo) from factexpbom_arancel where fed_tipocosto='X' and fed_indiced =@fed_indiced
		
				select @fed_ng_mp2=fed_ng_mp, @fed_ng_add2=fed_ng_add, @fed_ng_emp2=fed_ng_emp, @fed_gra_mp2=fed_gra_mp, 
				@fed_gra_add2=fed_gra_add, @fed_gra_emp2=fed_gra_emp, @fed_gra_gi2=fed_gra_gi, @fed_gra_gi_mx2=fed_gra_gi_mx, 
				@fed_gra_mo2=fed_gra_mo, @fed_costo2=fed_cos_uni, @fed_ng_usa2=fed_ng_usa, @ti_codigo=ti_codigo
				from factexpdet where fed_indiced=@fed_indiced and tco_codigo=@tco_codigo
		
		
			/* actualiza factexpdet */
				if exists (select * from factexpdet where fed_indiced =@fed_indiced and tco_codigo=@tco_codigo)
				begin
					if update(fed_costo) and @fed_tipocosto='1' and @fed_gra_mp<>@fed_gra_mp2
					update factexpdet
					set fed_gra_mp = @fed_gra_mp
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='3' and @fed_ng_emp<>@fed_ng_emp2					update factexpdet
					set fed_ng_emp = @fed_ng_emp
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
		
					if update(fed_costo) and @fed_tipocosto='6' and @fed_gra_add<>@fed_gra_add2
					update factexpdet
					set fed_gra_add = @fed_gra_add
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='2' and @fed_ng_mp<>@fed_ng_mp2
					update factexpdet
					set fed_ng_mp = @fed_ng_mp
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='7' and @fed_ng_add<>@fed_ng_add2
					update factexpdet
					set fed_ng_add = @fed_ng_add
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='8' and @fed_gra_emp<>@fed_gra_emp2
					update factexpdet
					set fed_gra_emp = @fed_gra_emp
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='4' and @fed_gra_gi<>@fed_gra_gi2
					update factexpdet
					set fed_gra_gi = @fed_gra_gi
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='9' and @fed_gra_gi_mx<>@fed_gra_gi_mx2
					update factexpdet
					set fed_gra_gi_mx = @fed_gra_gi_mx
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo) and @fed_tipocosto='5' and @fed_gra_mo<>@fed_gra_mo2
					update factexpdet
					set fed_gra_mo = @fed_gra_mo
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
					if update(fed_costo)  and @fed_tipocosto in ('1', '2', '3', '4', '5', '6', '7', '8', '9') and @fed_costo<>@fed_costo2
					update factexpdet
					set fed_cos_uni = @fed_costo
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo
		
								
					if update(fed_costo) and @fed_tipocosto='X' and @fed_costo<>@fed_costo2
					update factexpdet
					set fed_cos_uni = @fed_costo
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo


					if update(fed_costo) and @fed_tipocosto='N' and @fed_ng_usa<>@fed_ng_usa2
					update factexpdet
					set fed_ng_usa = @fed_ng_usa
					where fed_indiced = @fed_indiced and tco_codigo=@tco_codigo


				end
/*
				else
				begin
					insert into factexpdet(fed_indiced, fed_ng_mp, fed_ng_add, fed_ng_emp, fed_gra_mp, fed_gra_add, fed_gra_emp, fed_gra_gi, fed_gra_gi_mx, fed_gra_mo, fed_cos_uni, tco_codigo, fed_ng_usa, ti_codigo)
					values (@fed_indiced, isnull(@fed_ng_mp,0), isnull(@fed_ng_add,0), isnull(@fed_ng_emp,0), isnull(@fed_gra_mp,0), isnull(@fed_gra_add,0), isnull(@fed_gra_emp,0), isnull(@fed_gra_gi,0), isnull(@fed_gra_gi_mx,0), isnull(@fed_gra_mo,0), isnull(@fed_costo,0), @tco_codigo, isnull(@fed_ng_usa,0), @ti_codigo)
				end
*/
		

			fetch next from crFEBomArancelInsert into @fed_indiced, @fed_tipocosto
			END
		
		CLOSE crFEBomArancelInsert
		DEALLOCATE crFEBomArancelInsert

	END






























































































GO
