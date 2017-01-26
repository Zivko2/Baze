SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE trigger Update_FactExpDet on dbo.FACTEXPDET for update, insert as 
SET NOCOUNT ON
/*begin        
	declare @fed_indiced int, @fed_gra_mp decimal(38,6), @fed_gra_emp decimal(38,6), @fed_ng_mp decimal(38,6), @fed_ng_emp decimal(38,6), 
	@fed_gra_gi decimal(38,6), @fed_gra_gi_mx decimal(38,6), @fed_gra_mo decimal(38,6),  @fed_ng_add decimal(38,6),  
	@fed_gra_add decimal(38,6), @fed_cant decimal(38,6),  
	 @fed_ng_mat_co decimal(38,6), @fed_gra_mat_co decimal(38,6),  
	@fed_emp_co decimal(38,6), @fed_va_co decimal(38,6), @eq_gen decimal(28,14), @fed_pes_net decimal(38,6), @fed_pes_bru decimal(38,6), @fed_pes_netlb decimal(38,6), 
	@fed_pes_uni decimal(38,6), @ti_codigo int, @fed_cos_uni decimal(38,6), @fed_pes_unilb decimal(38,6), @pesouni decimal(38,6), @pesonet decimal(38,6), 
	@fed_retrabajo char(1), @cf_pesos_exp char(1), @Tipo char(1), @FED_PES_BRULB decimal(38,6), @fed_cos_tot decimal(38,6), 
	@FED_SALDO  decimal(38,6), @fed_cos_uni_co decimal(38,6), @fed_cantgen decimal(38,6), @CodigoFactura int, 
	@fed_descargado char(1), @cs_codigo smallint, @TEmbarque char(1), @fed_saldotrans decimal(38,6), @fed_usotrans char(1), @fed_usosaldo char(1),
	@fed_fecha_struct datetime, @ma_codigo int, @fe_fecha datetime, @FED_DESTNAFTA char(1), @fe_estatus char(1), @fe_tipo char(1),
	@TCO_MANUFACTURA int, @TCO_COMPRA int, @tco_codigo int

 
	select    @CodigoFactura = factexpdet.fe_codigo, @fed_indiced = fed_indiced, @fed_gra_mp = fed_gra_mp, @fed_gra_emp = fed_gra_emp, @fed_ng_mp = fed_ng_mp, 
		@fed_ng_emp = fed_ng_emp, @fed_ng_add = fed_ng_add,  @ma_codigo=ma_codigo,
		@fed_gra_gi = fed_gra_gi, @fed_gra_gi_mx = fed_gra_gi_mx, @fed_gra_mo = fed_gra_mo,  
		@fed_gra_add = fed_gra_add, @fed_cant = fed_cant, 
		@fed_ng_mat_co = fed_ng_mat_co, @fed_gra_mat_co = fed_gra_mat_co,  
		@fed_emp_co = fed_emp_co, @fed_va_co = fed_va_co, @eq_gen = eq_gen, @fed_pes_net = fed_pes_net, @fed_pes_bru = fed_pes_bru, 
		@fed_pes_uni = fed_pes_uni, @fed_pes_unilb = fed_pes_unilb, @fed_pes_netlb = fed_pes_netlb, @ti_codigo = ti_codigo,  
		@fed_cos_uni = fed_cos_uni, @fed_retrabajo = fed_retrabajo, @pesonet =fed_pes_net, @pesouni = fed_pes_unilb, @pesonet = fed_pes_netlb, 
		@FED_PES_BRULB = FED_PES_BRULB, @FED_SALDO = FED_SALDO, @fed_cos_tot = fed_cos_tot, 
		@fed_cos_uni_co =fed_cos_uni_co, @fed_cantgen = fed_cantgen, @fed_descargado =fed_descargado,
		@cs_codigo =cs_codigo, @fed_saldotrans=fed_saldotrans, @fed_usotrans=fed_usotrans, @fed_usosaldo=fed_usosaldo,
		@fed_fecha_struct=fed_fecha_struct, @FED_DESTNAFTA=FED_DESTNAFTA,
		@fe_tipo=fe_tipo, @tco_codigo=tco_codigo
	from factexpdet left outer join factexp on factexpdet.fe_codigo=factexp.fe_codigo
	where fed_indiced in (select fed_indiced from inserted) 
 
	select @Tipo = cft_tipo from configuratipo where ti_codigo in (select ti_codigo from inserted) 

	
	select @cf_pesos_exp = cf_pesos_exp, @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA from configuracion 

	select @fe_fecha=fe_fecha, @fe_estatus=fe_estatus from factexp where fe_codigo=@CodigoFactura
	

	SELECT     @TEmbarque= CFQ_TIPO
	FROM         CONFIGURATEMBARQUE
	WHERE TQ_CODIGO IN (SELECT TQ_CODIGO FROM FACTEXP WHERE FE_CODIGO=@CodigoFactura)




-- =================================== calculos ================================



	if @TEmbarque<>'D' and @TEmbarque<>'T' and @fe_tipo<>'V'
	begin
		if (@Tipo = 'S') or (@Tipo = 'P') 
		begin 
	
			if update(FED_NG_MP) or update(FED_NG_EMP) or update(FED_NG_ADD) or update(FED_GRA_GI) or
			update(FED_GRA_MP) or update(FED_GRA_EMP) or update(FED_GRA_ADD) or update(FED_GRA_MO) or update(FED_GRA_GI_MX)
			update factexpdet 
			set FED_COS_UNI = isnull(FED_GRA_MP,0) + isnull(FED_GRA_EMP,0) + isnull(FED_GRA_ADD,0) + isnull(FED_GRA_MO,0) + isnull(FED_GRA_GI_MX,0) +isnull(FED_NG_MP,0) + isnull(FED_NG_EMP,0) + isnull(FED_NG_ADD,0) +isnull(FED_GRA_GI,0)
			where fed_indiced  in (select fed_indiced from inserted)  
	
	
	
			if update(fed_cant) or update(FED_cos_uni) or update(FED_cos_tot)
			begin
				if update (FED_COS_UNI) and (@FED_COS_UNI)<>0
				if @FED_COS_TOT <> (@FED_COS_UNI * @fed_cant) or @FED_COS_TOT is null
				update factexpdet
				set FED_COS_TOT = FED_COS_UNI * fed_cant
				from factexpdet where FED_indiced in (select FED_indiced from inserted)
				and FED_COS_TOT <> (FED_COS_UNI * fed_cant) or FED_COS_TOT is null
			end	
	
			if update(FED_NG_MP) or update(FED_NG_ADD)
			if (@FED_NG_MAT_CO <> (isnull(@FED_NG_MP,0) + isnull(@FED_NG_ADD,0)) or @FED_NG_MAT_CO is null) 
				update factexpdet 
				set FED_NG_MAT_CO = isnull(FED_NG_MP,0) + isnull(FED_NG_ADD,0) 
				where fed_indiced  in (select fed_indiced from inserted)  
				and (FED_NG_MAT_CO <> (isnull(FED_NG_MP,0) + isnull(FED_NG_ADD,0)) or FED_NG_MAT_CO is null) 
	
			if update(FED_GRA_MP) or update(FED_GRA_ADD)
			if (@FED_GRA_MAT_CO <> (@FED_GRA_MP + @FED_GRA_ADD) or @FED_GRA_MAT_CO is null) 
				update factexpdet 
				set FED_GRA_MAT_CO = isnull(FED_GRA_MP,0) + isnull(FED_GRA_ADD,0)
				where fed_indiced  in (select fed_indiced from inserted)  
				and (FED_GRA_MAT_CO <> (FED_GRA_MP + FED_GRA_ADD) or FED_GRA_MAT_CO is null) 
	
			if update(FED_GRA_EMP) or update(FED_NG_EMP)
			if ((@FED_EMP_CO <> (@FED_GRA_EMP + @FED_NG_EMP)) or @FED_EMP_CO is null) 
				update factexpdet 
				set FED_EMP_CO = isnull(FED_GRA_EMP,0) + isnull(FED_NG_EMP,0)
				where fed_indiced  in (select fed_indiced from inserted)  
				and ((FED_EMP_CO <> (FED_GRA_EMP + FED_NG_EMP)) or FED_EMP_CO is null) 
	
			if update(FED_GRA_MO) or update (FED_GRA_GI_MX) or update(FED_VA_CO) 
			if ((@FED_VA_CO <> (@FED_GRA_MO  + @FED_GRA_GI_MX)) or @FED_VA_CO is null) 
				update factexpdet 
				set FED_VA_CO = isnull(FED_GRA_MO,0) + isnull(FED_GRA_GI_MX,0)
				where fed_indiced  in (select fed_indiced from inserted)  
				and ((FED_VA_CO <> (FED_GRA_MO +  FED_GRA_GI_MX)) or FED_VA_CO is null) 
	
			if update(FED_NG_MP) or update(FED_NG_ADD) or update(FED_GRA_MP) or update(FED_GRA_ADD) or update(FED_GRA_EMP) or update(FED_NG_EMP) or update(FED_GRA_MO)  or update (FED_GRA_GI_MX)
			if (@FED_COS_UNI_CO <> (isnull(@FED_NG_MP,0) + isnull(@FED_NG_ADD,0) +isnull(@FED_GRA_MP,0) + isnull(@FED_GRA_ADD,0) + isnull(@FED_GRA_EMP,0) + isnull(@FED_NG_EMP,0) + isnull(@FED_GRA_MO,0) + isnull(@FED_GRA_GI_MX,0)))
				update factexpdet 
				set FED_COS_UNI_CO =  isnull(FED_NG_MP,0) + isnull(FED_NG_ADD,0) +isnull(FED_GRA_MP,0) + isnull(FED_GRA_ADD,0) + isnull(FED_GRA_EMP,0) + isnull(FED_NG_EMP,0) + isnull(FED_GRA_MO,0)  + isnull(FED_GRA_GI_MX,0)
				from factexpdet where fed_indiced = @fed_indiced 
				and (FED_COS_UNI_CO <> (isnull(FED_NG_MP,0) + isnull(FED_NG_ADD,0) +isnull(FED_GRA_MP,0) + isnull(FED_GRA_ADD,0) + isnull(FED_GRA_EMP,0) + isnull(FED_NG_EMP,0) + isnull(FED_GRA_MO,0)  + isnull(FED_GRA_GI_MX,0))
				 or FED_COS_UNI_CO is null )
	
		end
		else
		begin 
			if update(fed_cant) or update(FED_cos_uni) or update(FED_cos_tot)
			begin
				if update (FED_COS_UNI) and (@FED_COS_UNI)<>0
				if @FED_COS_TOT <> (@FED_COS_UNI * @fed_cant) or @FED_COS_TOT is null
				update factexpdet
				set FED_COS_TOT = FED_COS_UNI * fed_cant
				from factexpdet where FED_indiced in (select FED_indiced from inserted)
				and FED_COS_TOT <> (FED_COS_UNI * fed_cant) or FED_COS_TOT is null
			end
			else
			begin
				if update (FED_COS_TOT) and (@FED_COS_TOT)<>0 and @fed_cant >0
				if @FED_COS_UNI <> (@FED_COS_TOT / @fed_cant) or @FED_COS_UNI is null
				update factexpdet
				set FED_COS_UNI =  FED_COS_TOT/ fed_cant
				from factexpdet where FED_indiced in (select FED_indiced from inserted)
				and FED_COS_UNI <> (FED_COS_TOT / fed_cant) or FED_COS_UNI is null
			end
	
		end	 
	end
	else
	begin
			if update(fed_cant) or update(FED_cos_uni) or update(FED_cos_tot)
			begin
				if update (FED_COS_UNI) and (@FED_COS_UNI)<>0
				if @FED_COS_TOT <> (@FED_COS_UNI * @fed_cant) or @FED_COS_TOT is null
				update factexpdet
				set FED_COS_TOT = FED_COS_UNI * fed_cant
				from factexpdet where FED_indiced in (select FED_indiced from inserted)
				and FED_COS_TOT <> (FED_COS_UNI * fed_cant) or FED_COS_TOT is null
			end
			else
			begin
				if update (FED_COS_TOT) and (@FED_COS_TOT)<>0 and @fed_cant >0
				if @FED_COS_UNI <> (@FED_COS_TOT / @fed_cant) or @FED_COS_UNI is null
				update factexpdet
				set FED_COS_UNI =  FED_COS_TOT/ fed_cant
				from factexpdet where FED_indiced in (select FED_indiced from inserted)
				and FED_COS_UNI <> (FED_COS_TOT / fed_cant) or FED_COS_UNI is null
			end
	end



	if update(FED_RETRABAJO) and @fed_retrabajo = 'N' 
	if exists(select * from retrabajo where fetr_indiced = @fed_indiced) 
		delete from retrabajo where fetr_indiced = @fed_indiced 

	if (update(fed_CANT) and (@fed_SALDO is null or @fed_SALDO=0) and @fed_usosaldo='N') 
	begin 
		update factexpdet 
		set fed_SALDO = fed_CANT 
		from factexpdet where fed_indiced = @fed_indiced 
	end 

	if (update(fed_CANT) and (@fed_SALDOTRANS is null or @fed_SALDOTRANS=0) and @fed_usotrans='N') 
	begin 
		update factexpdet 
		set fed_SALDOTRANS = fed_CANT
		from factexpdet left outer join factexp on factexpdet.fe_codigo = factexp.fe_codigo
		where fed_indiced = @fed_indiced and fe_tipo='C'
	end 



	--actualizacion de pesos 

	IF @CF_PESOS_EXP ='K'
	begin
	
		if update(FED_PES_UNI) 
		if (@FED_PES_UNILB <> (@FED_PES_UNI * 2.20462442018378)  or @FED_PES_UNILB is null) 
		update factexpdet 
		set FED_PES_UNILB =FED_PES_UNI * 2.20462442018378
		from factexpdet where FED_indiced = @FED_indiced 
		and (FED_PES_UNILB <> (@FED_PES_UNI * 2.20462442018378)  or FED_PES_UNILB is null) 

				
		if (update(FED_PES_UNI)  or update (FED_CANT) ) --and (not update (FED_PES_NET))
		begin
			if (@FED_PES_NET <> (@FED_PES_UNI * @FED_CANT) or @FED_PES_NET is null) 
			update factexpdet 
			set FED_PES_NET = FED_PES_UNI * FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_NET <> (@FED_PES_UNI * @FED_CANT) or FED_PES_NET is null) 

			if (@FED_PES_BRU is null) or (@FED_PES_BRU=0) or (@FED_PES_BRU < @FED_PES_NET)
			update factexpdet 
			set FED_PES_BRU = FED_PES_UNI * FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRU < (FED_PES_UNI * FED_CANT) or FED_PES_BRU is null) 


			if (@FED_PES_NETLB <> (@FED_PES_UNI * @FED_CANT * 2.20462442018378) or @FED_PES_NETLB is null) 
			update factexpdet 
			set FED_PES_NETLB = (FED_PES_UNI * FED_CANT) * 2.20462442018378 
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_NETLB <> (@FED_PES_UNI * @FED_CANT * 2.20462442018378) or FED_PES_NETLB is null) 

			if (@FED_PES_BRULB<> @FED_PES_BRU *2.20462442018378)
			if (@FED_PES_BRULB <> ((@FED_PES_UNI * @FED_CANT)  * 2.20462442018378) or @FED_PES_BRULB is null) 
			update factexpdet 
			set FED_PES_BRULB = (FED_PES_UNI * FED_CANT) * 2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRULB <> ((FED_PES_UNI * FED_CANT) *  2.20462442018378) or FED_PES_BRULB is null) 
		end
		
		if  (update(FED_PES_NET) or update(FED_CANT) ) and (not update(FED_PES_UNI))
		begin
			if (@FED_CANT > 0) and (@FED_PES_UNI <> (@FED_PES_NET/@FED_CANT) or @FED_PES_UNI is null) 
			update factexpdet 
			set FED_PES_UNI = FED_PES_NET / FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_UNI <> (FED_PES_NET/FED_CANT) or FED_PES_UNI is null) 
		

			if (@FED_CANT > 0) 
			if (@FED_PES_UNILB <> (@FED_PES_UNI*2.20462442018378) or @FED_PES_UNILB is null) 
			update factexpdet 
			set FED_PES_UNILB = FED_PES_UNI*2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_UNILB <> (FED_PES_UNI*2.20462442018378) or FED_PES_UNILB is null) 

		end		
		

		if update(FED_PES_NET) 
		begin
			if (@FED_PES_NETLB <> (@FED_PES_NET*2.20462442018378) or @FED_PES_NETLB is null) 
			update factexpdet 
			set FED_PES_NETLB = FED_PES_NET*2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_NETLB <> (FED_PES_NET*2.20462442018378) or FED_PES_NETLB is null) 


			if (@FED_PES_BRU < (@FED_PES_NET) or @FED_PES_BRU is null) 
			update factexpdet 
			set FED_PES_BRU = FED_PES_NET
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRU < (FED_PES_NET) or FED_PES_BRU is null) 
		

			if (@FED_PES_BRULB < (@FED_PES_NET*2.20462442018378) or @FED_PES_BRULB is null) 
			update factexpdet 
			set FED_PES_BRULB = FED_PES_NET*2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRULB < (FED_PES_NET*2.20462442018378) or FED_PES_BRULB is null) 
		
		end		
		
		if update(FED_PES_BRU) 
		if (@FED_PES_BRULB <> (@FED_PES_BRU*2.20462442018378) or @FED_PES_BRULB is null) 
		update factexpdet 
		set FED_PES_BRULB = FED_PES_BRU*2.20462442018378
		from factexpdet where FED_indiced = @FED_indiced 
		and (FED_PES_BRULB <> (FED_PES_BRU*2.20462442018378) or FED_PES_BRULB is null) 
	
	end
	
	
	-- pesos en libras
	
	IF @CF_PESOS_EXP ='L'
	begin
	
		if update(FED_PES_UNILB) 
		if (@FED_PES_UNI <> (@FED_PES_UNILB / 2.20462442018378)  or @FED_PES_UNI is null) 
		update factexpdet 
		set FED_PES_UNI = (FED_PES_UNILB / 2.20462442018378)
		from factexpdet where FED_indiced = @FED_indiced 
		and (FED_PES_UNI <> (FED_PES_UNILB / 2.20462442018378)  or FED_PES_UNI is null) 
		
		if (update(FED_PES_UNILB)  or update (FED_CANT))  and not update(FED_PES_NETLB)
		begin
			if (@FED_PES_NETLB <> (@FED_PES_UNILB * @FED_CANT) or @FED_PES_NETLB is null) 
			update factexpdet 
			set FED_PES_NETLB = FED_PES_UNILB * FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_NETLB <> (FED_PES_UNILB * FED_CANT) or FED_PES_NETLB is null) 
	
	
			if (@FED_PES_NET <> ((@FED_PES_UNILB * @FED_CANT) / 2.20462442018378) or @FED_PES_NET is null) 
			update factexpdet 
			set FED_PES_NET = (FED_PES_UNILB * FED_CANT)/  2.20462442018378 
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_NET <> ((FED_PES_UNILB * FED_CANT)/  2.20462442018378) or FED_PES_NET is null) 
		

			if (@FED_PES_BRULB < (@FED_PES_UNILB * @FED_CANT) or @FED_PES_BRULB is null) 
			update factexpdet 
			set FED_PES_BRULB = FED_PES_UNILB * FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRULB < (FED_PES_UNILB * FED_CANT) or FED_PES_BRULB is null) 


			if (@FED_PES_BRU < ((@FED_PES_UNILB/2.20462442018378) * @FED_CANT) or @FED_PES_BRU is null) 
			update factexpdet 
			set FED_PES_BRU = (FED_PES_UNILB / 2.20462442018378) * FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRU < ((FED_PES_UNILB /2.20462442018378)* FED_CANT) or FED_PES_BRU is null) 
		end
		
		if  (update(FED_PES_NETLB) or update(FED_CANT)) and not update(FED_PES_UNILB)
		begin
			if (@FED_CANT > 0) and (@FED_PES_UNILB <> (@FED_PES_NETLB/@FED_CANT) or @FED_PES_UNILB is null) 
			update factexpdet 
			set FED_PES_UNILB = FED_PES_NETLB / FED_CANT
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_UNILB <> (FED_PES_NETLB/FED_CANT) or FED_PES_UNILB is null) 
		

			if (@FED_CANT > 0) 
			if (@FED_PES_UNI <> ((@FED_PES_NETLB/@FED_CANT)/2.20462442018378) or @FED_PES_UNI is null) 
			update factexpdet 
			set FED_PES_UNI = (FED_PES_NETLB/FED_CANT)/2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_UNI <> ((FED_PES_NETLB/FED_CANT)/2.20462442018378) or FED_PES_UNI is null) 

		end		


		if update(FED_PES_NETLB) 
		begin
			if (@FED_PES_NET <> (@FED_PES_NETLB/2.20462442018378) or @FED_PES_NET is null) 
			update factexpdet 
			set FED_PES_NET =FED_PES_NETLB/2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_NET <> (FED_PES_NETLB/2.20462442018378) or FED_PES_NET is null) 


			if (@FED_PES_BRULB < (@FED_PES_NETLB) or @FED_PES_BRULB is null) 
			update factexpdet 
			set FED_PES_BRULB = FED_PES_NETLB
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRULB < (FED_PES_NETLB) or FED_PES_BRULB is null) 
		

			if (@FED_PES_BRU < (@FED_PES_NETLB/2.20462442018378) or @FED_PES_BRU is null) 
			update factexpdet 
			set FED_PES_BRU = FED_PES_NETLB/2.20462442018378
			from factexpdet where FED_indiced = @FED_indiced 
			and (FED_PES_BRU < (FED_PES_NETLB/2.20462442018378) or FED_PES_BRU is null) 
		
		end		
		
		if update(FED_PES_BRULB) 
		if (@FED_PES_BRU <> (@FED_PES_BRULB/2.20462442018378) or @FED_PES_BRU is null) 
		update factexpdet 
		set FED_PES_BRU = FED_PES_BRULB/2.20462442018378
		from factexpdet where FED_indiced = @FED_indiced 
		and (FED_PES_BRU <> (FED_PES_BRULB/2.20462442018378) or FED_PES_BRU is null) 
	
	end

--	if update (fed_descargado) and @fed_descargado='S'
--		exec SP_ACTUALIZAESTATUSFACTEXP @CodigoFactura


	if update(cs_codigo) and @cs_codigo=6
	update factexpdet
	set fed_discharge='N'
	where FED_indiced = @FED_indiced 


	if @fed_fecha_struct is null or @fed_fecha_struct=''
	if exists (select * from bom_struct where bsu_subensamble =@ma_codigo and bst_perini <=@fe_fecha and bst_perfin >=@fe_fecha)
		update factexpdet
		set fed_fecha_struct=@fe_fecha
		where FED_indiced = @FED_indiced 
	else
	begin
 		if exists (select * from bom_struct where bsu_subensamble =@ma_codigo)		
			update factexpdet
			set fed_fecha_struct=(SELECT MAX(BST_PERINI) FROM BOM_STRUCT WHERE BSU_SUBENSAMBLE=@ma_codigo)
			where FED_indiced = @FED_indiced
		else
			update factexpdet
			set fed_fecha_struct=NULL
			where FED_indiced = @FED_indiced 
	end


	if @FED_DESTNAFTA is null
	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.FED_DESTNAFTA= CASE 
	when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
	 when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
	then 'N'  WHEN 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
	then 'U' when 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
	then 'A'  else 'F' end
	FROM         dbo.FACTEXPDET INNER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
	                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
	where FED_indiced = @FED_indiced and FED_DESTNAFTA is null 



	-- actualiza tipo de costo 
	if (@Tipo='P' or @Tipo='S') and @tco_codigo is null
	update factexpdet
	set tco_codigo=@TCO_MANUFACTURA
	where FED_indiced = @FED_indiced and tco_codigo is null 
	 

	if (@Tipo<>'P' and @Tipo<>'S') and @tco_codigo is null
	update factexpdet
	set tco_codigo=@TCO_COMPRA
	where FED_indiced = @FED_indiced and tco_codigo is null 

	
end*/






GO
