SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE trigger Update_listaexpDet on dbo.LISTAEXPDET for update, insert as 
SET NOCOUNT ON 
begin        
	declare @led_indiced int, @led_gra_mp decimal(38,6), @led_gra_emp decimal(38,6), @led_ng_mp decimal(38,6), @led_ng_emp decimal(38,6), 
	@led_gra_gi decimal(38,6), @led_gra_gi_mx decimal(38,6), @led_gra_mo decimal(38,6),  @led_ng_add decimal(38,6),  
	@led_gra_va decimal(38,6), @led_gra_add decimal(38,6), @tot_grav_uni decimal(38,6), @led_cant decimal(38,6),  
	@Tot_ng_uni decimal(38,6),  @eq_gen decimal(28,14), @led_pes_net decimal(38,6), @led_pes_bru decimal(38,6), @led_pes_netlb decimal(38,6), 
	@led_pes_uni decimal(38,6), @ti_codigo int, @led_cos_uni decimal(38,6), @led_pes_unilb decimal(38,6), @pesouni decimal(38,6), @pesonet decimal(38,6), 
	@led_retrabajo char(1), @cf_pesos_exp char(1), @Tipo char(1), @led_PES_BRULB decimal(38,6), @led_GRA_TOT decimal(38,6), @led_cos_tot decimal(38,6), 
	@led_SALDO  decimal(38,6), @led_ng_tot decimal(38,6), @led_cantgen decimal(38,6), @CodigoFactura int, @led_enuso char(1)
	 
	select    @CodigoFactura = le_codigo, @led_indiced = led_indiced, @led_gra_mp = led_gra_mp, @led_gra_emp = led_gra_emp, @led_ng_mp = led_ng_mp, 
		@led_ng_emp = led_ng_emp, @led_ng_add = led_ng_add,  
		@led_gra_gi = led_gra_gi, @led_gra_gi_mx = led_gra_gi_mx, @led_gra_mo = led_gra_mo,  
		@led_gra_va = led_gra_va, @led_gra_add = led_gra_add, @tot_grav_uni = tot_grav_uni, @led_cant = led_cant, 
		@Tot_ng_uni = tot_ng_uni,  @eq_gen = eq_gen, @led_pes_net = led_pes_net, @led_pes_bru = led_pes_bru, 
		@led_pes_uni = led_pes_uni, @led_pes_unilb = led_pes_unilb, @led_pes_netlb = led_pes_netlb, @ti_codigo = ti_codigo,  
		@led_cos_uni = led_cos_uni, @pesonet =led_pes_net, @pesouni = led_pes_unilb, @pesonet = led_pes_netlb, 
		@led_PES_BRULB = led_PES_BRULB, @led_SALDO = led_SALDO, @led_GRA_TOT = led_GRA_TOT, @led_cos_tot = led_cos_tot, 
		@led_ng_tot = led_ng_tot, @led_enuso = led_enuso from listaexpdet where led_indiced in (select led_indiced from inserted) 
 
	select @Tipo = cft_tipo from configuratipo where ti_codigo in (select ti_codigo from inserted) 
	
	select @cf_pesos_exp = cf_pesos_exp from configuracion 

	if (@Tipo = 'S') or (@Tipo = 'P') 
	begin 
		if update(led_GRA_MO) or update(led_GRA_GI) or update(led_GRA_GI_MX)
		if @led_GRA_VA <> @led_GRA_MO + @led_GRA_GI + @led_GRA_GI_MX 
			update listaexpdet 
			set led_GRA_VA = led_GRA_MO + led_GRA_GI + led_GRA_GI_MX 
			from listaexpdet where led_indiced= @led_indiced 
			and led_GRA_VA <> led_GRA_MO + led_GRA_GI + led_GRA_GI_MX 

		if update(led_GRA_MP) or update(led_GRA_EMP) or update(led_GRA_ADD) or update(led_GRA_MO) or update(led_GRA_GI_MX)
 		if (@TOT_GRAV_UNI <> (@led_GRA_MP + @led_GRA_EMP + @led_GRA_ADD + @led_GRA_MO + @led_GRA_GI_MX) or @TOT_GRAV_UNI is null) 
			update listaexpdet 
			set TOT_GRAV_UNI = isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) 
			from listaexpdet where led_indiced= @led_indiced 
			and (TOT_GRAV_UNI <> (led_GRA_MP + led_GRA_EMP + led_GRA_ADD + led_GRA_MO + led_GRA_GI_MX) or TOT_GRAV_UNI is null) 

		if update(led_GRA_MP) or update(led_GRA_EMP) or update(led_GRA_ADD) or update(led_GRA_MO) or update(led_GRA_GI_MX)
		if (@led_GRA_TOT <> (@TOT_GRAV_UNI * @led_CANT) or @led_GRA_TOT is null) 
			update listaexpdet 
			set led_GRA_TOT = (isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) ) * isnull(led_CANT,0) 
			from listaexpdet where led_indiced= @led_indiced 
			and (led_GRA_TOT <> ((isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) ) * isnull(led_CANT,0)) or led_GRA_TOT is null) 


		if update(led_NG_MP) or update(led_NG_EMP) or update(led_NG_ADD) or update(led_GRA_GI) or update(led_CANT)
		if (@TOT_NG_UNI <> (isnull(@led_NG_MP,0) + isnull(@led_NG_EMP,0) + isnull(@led_NG_ADD,0) +isnull(@led_GRA_GI,0))  
		or @TOT_NG_UNI is null) 
			update listaexpdet 
			set TOT_NG_UNI = isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0) 
			where led_indiced  in (select led_indiced from inserted)  
			and (TOT_NG_UNI <> isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0)
			or TOT_NG_UNI is null)


		if update(led_NG_MP) or update(led_NG_EMP) or update(led_NG_ADD) or update(led_GRA_GI) or update(led_CANT)
		if ((@led_NG_TOT <> (isnull(@TOT_NG_UNI,0) * isnull(@led_CANT,0))) or @led_NG_TOT is null) 
			update listaexpdet 
			set led_NG_TOT = (isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0) ) * isnull(led_CANT,0) 
			where led_indiced  in (select led_indiced from inserted)  
			and ((led_NG_TOT <> ((isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0) ) * isnull(led_CANT,0))) or led_NG_TOT is null) 



		if update(led_NG_MP) or update(led_NG_EMP) or update(led_NG_ADD) or update(led_GRA_GI) or
		update(led_GRA_MP) or update(led_GRA_EMP) or update(led_GRA_ADD) or update(led_GRA_MO) or update(led_GRA_GI_MX)
		update listaexpdet 
		set led_COS_UNI = isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) +isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0)
		where led_indiced  in (select led_indiced from inserted)  
		--and (led_COS_UNI <> isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) +isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0) 
		--or led_COS_UNI is null)



		if update(led_NG_MP) or update(led_NG_EMP) or update(led_NG_ADD) or update(led_GRA_GI) or
		update(led_GRA_MP) or update(led_GRA_EMP) or update(led_GRA_ADD) or update(led_GRA_MO) or update(led_GRA_GI_MX) or update(led_CANT) 
		update listaexpdet 
		set led_COS_TOT = (isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) +isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0))*isnull(led_CANT,0)
		where led_indiced  in (select led_indiced from inserted)  
		and (led_COS_TOT <> isnull(led_GRA_MP,0) + isnull(led_GRA_EMP,0) + isnull(led_GRA_ADD,0) + isnull(led_GRA_MO,0) + isnull(led_GRA_GI_MX,0) +isnull(led_NG_MP,0) + isnull(led_NG_EMP,0) + isnull(led_NG_ADD,0) +isnull(led_GRA_GI,0) 
		or led_COS_TOT is null)

	end
	else
		if update(led_cant) or update(led_cos_uni) or update(led_cos_tot)
		begin
			if update (led_COS_UNI) and (@led_COS_UNI)<>0
			if @led_COS_TOT <> (@led_COS_UNI * @led_cant) or @led_COS_TOT is null
			update listaexpdet
			set led_COS_TOT = led_COS_UNI * led_cant
			from listaexpdet where led_indiced in (select led_indiced from inserted)
			and led_COS_TOT <> (led_COS_UNI * led_cant) or led_COS_TOT is null
		end
		else
		begin
			if update (led_COS_TOT) and (@led_COS_TOT)<>0 and @led_cant >0
			if @led_COS_UNI <> (@led_COS_TOT / @led_cant) or @led_COS_UNI is null
			update listaexpdet
			set led_COS_UNI =  led_COS_TOT/ led_cant
			from listaexpdet where led_indiced in (select led_indiced from inserted)
			and led_COS_UNI <> (led_COS_TOT / led_cant) or led_COS_UNI is null
		end



	if @led_enuso='N'	if (update(led_CANT) and (@led_SALDO <> @led_CANT) or @led_SALDO is null) 
	begin 
		update listaexpdet 
		set led_SALDO = @led_CANT 
		from listaexpdet where led_indiced = @led_indiced 
	end 

	if update(led_CANT)
	if ((@led_SALDO = @led_CANT) or @led_SALDO is null) 
	update listaexpdet
	set led_enuso='N'
	from listaexpdet where led_indiced in (select led_indiced from inserted)

	IF @CF_PESOS_EXP ='K'
	begin
	
		if update(LED_PES_UNI) 
		if (@LED_PES_UNILB <> (@LED_PES_UNI * 2.20462442018378)  or @LED_PES_UNILB is null) 
		update listaexpdet 
		set LED_PES_UNILB = LED_PES_UNI * 2.20462442018378 
		from listaexpdet where LED_indiced = @LED_indiced 
		and (LED_PES_UNILB <> (LED_PES_UNI * 2.20462442018378)  or LED_PES_UNILB is null) 
		
		if (update(LED_PES_UNI)  or update (LED_CANT)) and not update(LED_PES_NET)
		begin
			if (@LED_PES_NET <> (@LED_PES_UNI * @LED_CANT) or @LED_PES_NET is null) 
			update listaexpdet 
			set LED_PES_NET = LED_PES_UNI * LED_CANT
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_NET <> (LED_PES_UNI * LED_CANT) or LED_PES_NET is null) 
	
	
			if (@LED_PES_NETLB <> (@LED_PES_UNI * @LED_CANT * 2.20462442018378) or @LED_PES_NETLB is null) 
			update listaexpdet 
			set LED_PES_NETLB = LED_PES_UNI * LED_CANT * 2.20462442018378 
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_NETLB <> (LED_PES_UNI * LED_CANT * 2.20462442018378) or LED_PES_NETLB is null) 
		

			if (@LED_PES_BRU < (@LED_PES_UNI * @LED_CANT) or @LED_PES_BRU is null) 
			update listaexpdet 
			set LED_PES_BRU = LED_PES_UNI * LED_CANT
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRU < (LED_PES_UNI * LED_CANT) or LED_PES_BRU is null) 


			if (@LED_PES_BRULB < (@LED_PES_UNI*2.20462442018378 * @LED_CANT) or @LED_PES_BRULB is null) 
			update listaexpdet 
			set LED_PES_BRULB = LED_PES_UNI * 2.20462442018378 * LED_CANT
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRULB < (LED_PES_UNI *2.20462442018378* LED_CANT) or LED_PES_BRULB is null) 
		end
		
		if  (update(LED_PES_NET) or update(LED_CANT)) and not update(LED_PES_UNI)
		begin
			if (@LED_CANT > 0) and (@LED_PES_UNI <> (@LED_PES_NET/@LED_CANT) or @LED_PES_UNI is null) 
			update listaexpdet 
			set LED_PES_UNI = LED_PES_NET / LED_CANT 
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_UNI <> (LED_PES_NET/LED_CANT) or LED_PES_UNI is null) 
		

			if (@LED_CANT > 0) 
			if (@LED_PES_UNILB <> ((@LED_PES_NET/@LED_CANT)*2.20462442018378) or @LED_PES_UNILB is null) 
			update listaexpdet 
			set LED_PES_UNILB = (LED_PES_NET/LED_CANT)*2.20462442018378
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_UNILB <> ((LED_PES_NET/LED_CANT)*2.20462442018378) or LED_PES_UNILB is null) 

		end		


		if update(LED_PES_NET) 
		begin
			if (@LED_PES_NETLB <> (@LED_PES_NET*2.20462442018378) or @LED_PES_NETLB is null) 
			update listaexpdet 
			set LED_PES_NETLB = LED_PES_NET*2.20462442018378
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_NETLB <> (LED_PES_NET*2.20462442018378) or LED_PES_NETLB is null) 


			if (@LED_PES_BRU < (@LED_PES_NET) or @LED_PES_BRU is null) 
			update listaexpdet 
			set LED_PES_BRU = LED_PES_NET
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRU < (LED_PES_NET) or LED_PES_BRU is null) 
		

			if (@LED_PES_BRULB < (@LED_PES_NET*2.20462442018378) or @LED_PES_BRULB is null) 
			update listaexpdet 
			set LED_PES_BRULB = LED_PES_NET*2.20462442018378
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRULB < (LED_PES_NET*2.20462442018378) or LED_PES_BRULB is null) 
		
		end		
		
		if update(LED_PES_BRU) 
		if (@LED_PES_BRULB <> (@LED_PES_BRU*2.20462442018378) or @LED_PES_BRULB is null) 
		update listaexpdet 
		set LED_PES_BRULB = LED_PES_BRU*2.20462442018378
		from listaexpdet where LED_indiced = @LED_indiced 
		and (LED_PES_BRULB <> (LED_PES_BRU*2.20462442018378) or LED_PES_BRULB is null) 
	
	end
	
	
	-- pesos en libras
	
	IF @CF_PESOS_EXP ='L'
	begin
	
		if update(LED_PES_UNILB) 
		if (@LED_PES_UNI <> (@LED_PES_UNILB / 2.20462442018378)  or @LED_PES_UNI is null) 
		update listaexpdet 
		set LED_PES_UNI = LED_PES_UNILB / 2.20462442018378 
		from listaexpdet where LED_indiced = @LED_indiced 
		--and (LED_PES_UNI <> (LED_PES_UNILB / 2.20462442018378)  or LED_PES_UNI is null) 
		
		if (update(LED_PES_UNILB)  or update (LED_CANT)) and not update(LED_PES_NETLB)
		begin
			if (@LED_PES_NETLB <> (@LED_PES_UNILB * @LED_CANT) or @LED_PES_NETLB is null) 
			update listaexpdet 
			set LED_PES_NETLB = LED_PES_UNILB * LED_CANT
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_NETLB <> (LED_PES_UNILB * LED_CANT) or LED_PES_NETLB is null) 
	
	
			if (@LED_PES_NET <> ((@LED_PES_UNILB * @LED_CANT) / 2.20462442018378) or @LED_PES_NET is null) 
			update listaexpdet 
			set LED_PES_NET = (LED_PES_UNILB * LED_CANT)/  2.20462442018378 
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_NET <> ((LED_PES_UNILB * LED_CANT)/  2.20462442018378) or LED_PES_NET is null) 
		

			if (@LED_PES_BRULB < (@LED_PES_UNILB * @LED_CANT) or @LED_PES_BRULB is null) 
			update listaexpdet 
			set LED_PES_BRULB = LED_PES_UNILB * LED_CANT
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRULB < (LED_PES_UNILB * LED_CANT) or LED_PES_BRULB is null) 


			if (@LED_PES_BRU < ((@LED_PES_UNILB/2.20462442018378) * @LED_CANT) or @LED_PES_BRU is null) 
			update listaexpdet 
			set LED_PES_BRU = (LED_PES_UNILB / 2.20462442018378) * LED_CANT
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRU < ((LED_PES_UNILB /2.20462442018378)* LED_CANT) or LED_PES_BRU is null) 
		end
		
		if  (update(LED_PES_NETLB) or update(LED_CANT)) and not update(LED_PES_UNILB)
		begin
			if (@LED_CANT > 0) and (@LED_PES_UNILB <> (@LED_PES_NETLB/@LED_CANT) or @LED_PES_UNILB is null) 
			update listaexpdet 
			set LED_PES_UNILB = LED_PES_NETLB / LED_CANT 
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_UNILB <> (LED_PES_NETLB/LED_CANT) or LED_PES_UNILB is null) 
		

			if (@LED_CANT > 0) 
			if (@LED_PES_UNI <> ((@LED_PES_NETLB/@LED_CANT)/2.20462442018378) or @LED_PES_UNI is null) 
			update listaexpdet 
			set LED_PES_UNI = (LED_PES_NETLB/LED_CANT)/2.20462442018378
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_UNI <> ((LED_PES_NETLB/LED_CANT)/2.20462442018378) or LED_PES_UNI is null) 

		end		


		if update(LED_PES_NETLB) 
		begin
			if (@LED_PES_NET <> (@LED_PES_NETLB/2.20462442018378) or @LED_PES_NET is null) 
			update listaexpdet 
			set LED_PES_NET = LED_PES_NETLB/2.20462442018378
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_NET <> (LED_PES_NETLB/2.20462442018378) or LED_PES_NET is null) 


			if (@LED_PES_BRULB < (@LED_PES_NETLB) or @LED_PES_BRULB is null) 
			update listaexpdet 
			set LED_PES_BRULB = LED_PES_NETLB
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRULB < (LED_PES_NETLB) or LED_PES_BRULB is null) 
		

			if (@LED_PES_BRU < (@LED_PES_NETLB/2.20462442018378) or @LED_PES_BRU is null) 
			update listaexpdet 
			set LED_PES_BRU = LED_PES_NETLB/2.20462442018378
			from listaexpdet where LED_indiced = @LED_indiced 
			and (LED_PES_BRU < (LED_PES_NETLB/2.20462442018378) or LED_PES_BRU is null) 
		
		end		
		
		if update(LED_PES_BRULB) 
		if (@LED_PES_BRU <> (@LED_PES_BRULB/2.20462442018378) or @LED_PES_BRU is null) 
		update listaexpdet 
		set LED_PES_BRU = LED_PES_BRULB/2.20462442018378
		from listaexpdet where LED_indiced = @LED_indiced 
		and (LED_PES_BRU <> (LED_PES_BRULB/2.20462442018378) or LED_PES_BRU is null) 
	
	end

end
























GO
