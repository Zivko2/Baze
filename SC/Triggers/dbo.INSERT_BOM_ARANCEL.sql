SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE trigger INSERT_BOM_ARANCEL on dbo.BOM_ARANCEL for update, insert as
begin       
	declare @ma_codigo int, @ma_grav_mp decimal(38,6), @ma_grav_add decimal(38,6),@ma_grav_emp decimal(38,6), 
	@ma_grav_gi decimal(38,6), @ma_grav_gi_mx decimal(38,6), @ma_grav_mo decimal(38,6), @ma_ng_usa decimal(38,6),
	@ma_ng_mp decimal(38,6), @ma_ng_add decimal(38,6), @ma_ng_emp decimal(38,6), @ma_ng_va decimal(38,6), 
	@ma_ng_gi decimal(38,6), @ma_ng_gi_mx decimal(38,6), @ma_ng_mo decimal(38,6), @ma_costo decimal(38,6),  
	@Fecha datetime, @Tipo char(1), @cft_tipo char(1), @tco_codigo smallint, @TCO_MANUFACTURA INT, @TCO_COMPRA INT,
	@consecutivo int, @consecutivo1 int, @consecutivo2 int, @ba_tipocosto char(1),
	@ma_ng_mp2 decimal(38,6), @ma_ng_add2 decimal(38,6), @ma_ng_emp2 decimal(38,6), @ma_grav_mp2 decimal(38,6), @ma_grav_add2 decimal(38,6), @ma_grav_emp2 decimal(38,6), 
	@ma_grav_gi2 decimal(38,6), @ma_grav_gi_mx2 decimal(38,6), @ma_grav_mo2 decimal(38,6), @ma_costo2 decimal(38,6), @ma_ng_usa2 decimal(38,6)

	IF (SELECT CF_USACLASSCOSTO FROM CONFIGURACION)='S'
	BEGIN
		declare crBomArancelInsert cursor for
			select ma_codigo, ba_tipocosto
			from inserted
		open crBomArancelInsert
			fetch next from crBomArancelInsert into @ma_codigo, @ba_tipocosto
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
				if exists(select ba_costo from bom_arancel where ba_tipocosto='1' and ma_codigo=@ma_codigo)
				select @ma_grav_mp = sum(ba_costo) from bom_arancel where ba_tipocosto='1' and ma_codigo =@ma_codigo
				else
				set @ma_grav_mp=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='6' and ma_codigo=@ma_codigo)
				select @ma_grav_add = sum(ba_costo) from bom_arancel where ba_tipocosto='6' and ma_codigo =@ma_codigo
				else
				set @ma_grav_add=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='8' and ma_codigo=@ma_codigo)
				select @ma_grav_emp = sum(ba_costo) from bom_arancel where ba_tipocosto='8' and ma_codigo =@ma_codigo
				else
				set @ma_grav_emp=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='2' and ma_codigo=@ma_codigo)
				select @ma_ng_mp = sum(ba_costo) from bom_arancel where ba_tipocosto='2' and ma_codigo =@ma_codigo
				else
				set @ma_ng_mp=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='7' and ma_codigo=@ma_codigo)	
				select @ma_ng_add = sum(ba_costo) from bom_arancel where ba_tipocosto='7' and ma_codigo =@ma_codigo
				else
				set @ma_ng_add=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='3' and ma_codigo=@ma_codigo)
				select @ma_ng_emp = sum(ba_costo) from bom_arancel where ba_tipocosto='3' and ma_codigo =@ma_codigo
				else
				set @ma_ng_emp=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='4' and ma_codigo=@ma_codigo)
				select @ma_grav_gi = sum(ba_costo) from bom_arancel where ba_tipocosto='4'
				and ma_codigo =@ma_codigo
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='9' and ma_codigo=@ma_codigo)
				select @ma_grav_gi_mx = sum(ba_costo) from bom_arancel where ba_tipocosto='9' and ma_codigo =@ma_codigo
				else
				set @ma_grav_gi_mx=0
		
				if exists(select ba_costo from bom_arancel where ba_tipocosto='5' and ma_codigo=@ma_codigo)
				select @ma_grav_mo = sum(ba_costo) from bom_arancel where ba_tipocosto='5' and ma_codigo =@ma_codigo
				else
				set @ma_grav_mo=0

				/* costo no gravable usa, este costo no pertenece a la suma de coto ng y grav del costo unitario, es solo de consulta */
				if exists(select ba_costo from bom_arancel where ba_tipocosto='N' and ma_codigo=@ma_codigo)
				select @ma_ng_usa = sum(ba_costo) from bom_arancel where ba_tipocosto='N' and ma_codigo =@ma_codigo
				else
				set @ma_ng_usa= isnull(@ma_ng_mp,0)+isnull(@ma_ng_add,0)
		
			
				SET @Fecha = convert(datetime, convert(varchar(11), getdate(),101))
			
				select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo in (select ma_codigo from inserted))
				SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA FROM dbo.CONFIGURACION
			
				if @cft_tipo='P' or @cft_tipo='S' 
				set @tco_codigo=@TCO_MANUFACTURA
				else
				set @tco_codigo=@TCO_COMPRA
		
				if (@cft_tipo = 'S') or (@cft_tipo = 'P')
					set @ma_costo = isnull(@ma_grav_mp,0) + isnull(@ma_grav_add,0) + isnull(@ma_grav_emp, 0) + isnull(@ma_grav_gi,0) + 
					isnull(@ma_grav_gi_mx,0) + isnull(@ma_grav_mo,0) + isnull(@ma_ng_mp,0) + isnull(@ma_ng_add,0) + isnull(@ma_ng_emp,0) 
				
				else
					select @ma_costo=sum(ba_costo) from bom_arancel where ba_tipocosto='X' and ma_codigo =@ma_codigo
		
				select @ma_ng_mp2=ma_ng_mp, @ma_ng_add2=ma_ng_add, @ma_ng_emp2=ma_ng_emp, @ma_grav_mp2=ma_grav_mp, 
				@ma_grav_add2=ma_grav_add, @ma_grav_emp2=ma_grav_emp, @ma_grav_gi2=ma_grav_gi, @ma_grav_gi_mx2=ma_grav_gi_mx, 
				@ma_grav_mo2=ma_grav_mo, @ma_costo2=ma_costo, @ma_ng_usa2=ma_ng_usa
				from maestrocost where ma_codigo=@ma_codigo and tco_codigo=@tco_codigo
		
		
			/* actualiza maestrocost */
				if exists (select * from maestrocost where ma_codigo =@ma_codigo and tco_codigo=@tco_codigo)
				begin
					if update(ba_costo) and @ba_tipocosto='1' and @ma_grav_mp<>@ma_grav_mp2
					update maestrocost
					set ma_grav_mp = @ma_grav_mp
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='3' and @ma_ng_emp<>@ma_ng_emp2					update maestrocost
					set ma_ng_emp = @ma_ng_emp
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
		
					if update(ba_costo) and @ba_tipocosto='6' and @ma_grav_add<>@ma_grav_add2
					update maestrocost
					set ma_grav_add = @ma_grav_add
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='2' and @ma_ng_mp<>@ma_ng_mp2
					update maestrocost
					set ma_ng_mp = @ma_ng_mp
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='7' and @ma_ng_add<>@ma_ng_add2
					update maestrocost
					set ma_ng_add = @ma_ng_add
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='8' and @ma_grav_emp<>@ma_grav_emp2
					update maestrocost
					set ma_grav_emp = @ma_grav_emp
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='4' and @ma_grav_gi<>@ma_grav_gi2
					update maestrocost
					set ma_grav_gi = @ma_grav_gi
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='9' and @ma_grav_gi_mx<>@ma_grav_gi_mx2
					update maestrocost
					set ma_grav_gi_mx = @ma_grav_gi_mx
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo) and @ba_tipocosto='5' and @ma_grav_mo<>@ma_grav_mo2
					update maestrocost
					set ma_grav_mo = @ma_grav_mo
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
					if update(ba_costo)  and @ba_tipocosto in ('1', '2', '3', '4', '5', '6', '7', '8', '9') and @ma_costo<>@ma_costo2
					update maestrocost
					set ma_costo = @ma_costo
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo
		
								
					if update(ba_costo) and @ba_tipocosto='X' and @ma_costo<>@ma_costo2
					update maestrocost
					set ma_costo = @ma_costo
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo


					if update(ba_costo) and @ba_tipocosto='N' and @ma_ng_usa<>@ma_ng_usa2
					update maestrocost
					set ma_ng_usa = @ma_ng_usa
					where ma_codigo = @ma_codigo and tco_codigo=@tco_codigo


				end
				else
				begin
					insert into maestrocost(ma_codigo, ma_ng_mp, ma_ng_add, ma_ng_emp, ma_grav_mp, ma_grav_add, ma_grav_emp, ma_grav_gi, ma_grav_gi_mx, ma_grav_mo, ma_costo, tco_codigo, ma_ng_usa)
					values (@ma_codigo, isnull(@ma_ng_mp,0), isnull(@ma_ng_add,0), isnull(@ma_ng_emp,0), isnull(@ma_grav_mp,0), isnull(@ma_grav_add,0), isnull(@ma_grav_emp,0), isnull(@ma_grav_gi,0), isnull(@ma_grav_gi_mx,0), isnull(@ma_grav_mo,0), isnull(@ma_costo,0), @tco_codigo, isnull(@ma_ng_usa,0))
				end
		

			fetch next from crBomArancelInsert into @ma_codigo, @ba_tipocosto
			END
		
		CLOSE crBomArancelInsert
		DEALLOCATE crBomArancelInsert

	END
end




























GO
