SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE trigger Update_FactImpDet on dbo.FACTIMPDET for Update, insert as
SET NOCOUNT ON
/*BEGIN     
	declare @fid_indiced int, @fid_cant_st decimal(38,6), @fid_cos_uni decimal(38,6), @fid_cos_tot decimal(38,6),
	 @eq_gen decimal(28,14), @fid_pes_uni decimal(38,6), @fid_pes_net decimal(38,6), @fid_pes_bru decimal(38,6), @cf_pesos_imp char(1),
	@fid_pes_unilb decimal(38,6), @fid_pes_netlb decimal(38,6), @fid_pes_brulb decimal(38,6), @fid_def_tip char(1),
	@fi_codigo int, @fid_saldo decimal(38,6), @fid_enuso char(1), @ar_impmx int, @ma_codigo int,
	@TCO_MANUFACTURA int, @TCO_COMPRA int, @tco_codigo int, @Tipo char(1)

	select @fid_indiced = fid_indiced, @fid_cant_st = fid_cant_st, @fid_cos_uni = fid_cos_uni, @fid_cos_tot = fid_cos_tot,
		@eq_gen = eq_gen, @fid_pes_uni = fid_pes_uni, @fi_codigo=fi_codigo, 
		@fid_pes_net = fid_pes_net, @fid_pes_bru = fid_pes_bru, @fid_saldo=fid_saldo, @fid_enuso=fid_enuso,
		@fid_pes_unilb = fid_pes_unilb, @fid_def_tip = fid_def_tip, @ma_codigo=ma_codigo, @ar_impmx=ar_impmx,
		@fid_pes_netlb = fid_pes_netlb, @fid_pes_brulb = fid_pes_brulb, @tco_codigo=tco_codigo
		from factimpdet where fid_indiced in (select fid_indiced from inserted)

	select @cf_pesos_imp = cf_pesos_imp, @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA from configuracion 

	select @Tipo = cft_tipo from configuratipo where ti_codigo in (select ti_codigo from inserted) 


	if update(fid_cant_st) or update(fid_cos_uni) or update(fid_cos_tot)
	begin
		if update (FID_COS_UNI) and (@FID_COS_UNI)<>0
		if @FID_COS_TOT <> (@FID_COS_UNI * @FID_CANT_ST) or @FID_COS_TOT is null
		update factimpdet
		set FID_COS_TOT = FID_COS_UNI * FID_CANT_ST
		from factimpdet where fid_indiced in (select fid_indiced from inserted)
		and FID_COS_TOT <> (FID_COS_UNI * FID_CANT_ST) or FID_COS_TOT is null
	end
	else
	begin
		if update (FID_COS_TOT) and (@FID_COS_TOT)<>0 and @fid_cant_st >0
		if @FID_COS_UNI <> (@FID_COS_TOT / @FID_CANT_ST) or @FID_COS_UNI is null
		update factimpdet
		set FID_COS_UNI =  (FID_COS_TOT/ FID_CANT_ST)
		from factimpdet where fid_indiced in (select fid_indiced from inserted)
		and FID_COS_UNI <> (FID_COS_TOT / FID_CANT_ST) or FID_COS_UNI is null
	end


-- actualizacion de pesos 

	IF @CF_PESOS_IMP ='K'
	begin
	
		if update(FID_PES_UNI) 
		if (@FID_PES_UNILB <> (@FID_PES_UNI * 2.20462442018378)  or @FID_PES_UNILB is null) 
		update factimpdet 
		set FID_PES_UNILB = FID_PES_UNI * 2.20462442018378 
		from factimpdet where fid_indiced = @fid_indiced 
		and (FID_PES_UNILB <> (FID_PES_UNI * 2.20462442018378)  or FID_PES_UNILB is null) 
		
		if (update(FID_PES_UNI)  or update (FID_CANT_ST)) --and not update(FID_PES_NET)
		begin
			if (@FID_PES_NET <> (@FID_PES_UNI * @FID_CANT_ST) or @FID_PES_NET is null) 
			update factimpdet 
			set FID_PES_NET = FID_PES_UNI * FID_CANT_ST
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_NET <> (FID_PES_UNI * FID_CANT_ST) or FID_PES_NET is null) 
	
	
			if (@FID_PES_NETLB <> (@FID_PES_UNI * @FID_CANT_ST * 2.20462442018378) or @FID_PES_NETLB is null) 
			update factimpdet 
			set FID_PES_NETLB = FID_PES_UNI * FID_CANT_ST * 2.20462442018378
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_NETLB <> (FID_PES_UNI * FID_CANT_ST * 2.20462442018378) or FID_PES_NETLB is null) 
		

			if (@FID_PES_BRU < (@FID_PES_UNI * @FID_CANT_ST) or @FID_PES_BRU is null) 
			update factimpdet 
			set FID_PES_BRU = FID_PES_UNI * FID_CANT_ST
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRU < (FID_PES_UNI * FID_CANT_ST) or FID_PES_BRU is null) 


			if (@FID_PES_BRULB < (@FID_PES_UNI*2.20462442018378 * @FID_CANT_ST) or @FID_PES_BRULB is null) 
			update factimpdet 
			set FID_PES_BRULB = FID_PES_UNI * 2.20462442018378 * FID_CANT_ST
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRULB < (FID_PES_UNI *2.20462442018378* FID_CANT_ST) or FID_PES_BRULB is null) 
		end
		
		if  (update(FID_PES_NET) or update(FID_CANT_ST)) and not update(FID_PES_UNI)
		begin
			if (@FID_CANT_ST > 0) and (@FID_PES_UNI <> (@FID_PES_NET/@FID_CANT_ST) or @FID_PES_UNI is null) 
			update factimpdet 
			set FID_PES_UNI = FID_PES_NET / FID_CANT_ST
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_UNI <> (FID_PES_NET/FID_CANT_ST) or FID_PES_UNI is null) 
		

			if (@FID_CANT_ST > 0) 
			if (@FID_PES_UNILB <> ((@FID_PES_NET/@FID_CANT_ST)*2.20462442018378) or @FID_PES_UNILB is null) 
			update factimpdet 
			set FID_PES_UNILB = (FID_PES_NET/FID_CANT_ST)*2.20462442018378
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_UNILB <> ((FID_PES_NET/FID_CANT_ST)*2.20462442018378) or FID_PES_UNILB is null) 

		end		


		if update(FID_PES_NET) 
		begin
			if (@FID_PES_NETLB <> (@FID_PES_NET*2.20462442018378) or @FID_PES_NETLB is null) 
			update factimpdet 
			set FID_PES_NETLB = FID_PES_NET*2.20462442018378
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_NETLB <> (FID_PES_NET*2.20462442018378) or FID_PES_NETLB is null) 


			-- en este caso actualiza el peso bruto de acuerdo al peso neto, pero si el peso bruto se modfica a cero esta parte no se procesa porque el que se actualiza directamente es el peso bruto y no el neto

			if (@FID_PES_BRU is null or @FID_PES_BRU < (@FID_PES_NET)) 
			update factimpdet 
			set FID_PES_BRU = FID_PES_NET
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRU < (FID_PES_NET) or FID_PES_BRU is null) 


			if (@FID_PES_BRULB is null or @FID_PES_BRULB < (@FID_PES_NET*2.20462442018378)) 
			update factimpdet 
			set FID_PES_BRULB = FID_PES_NET*2.20462442018378
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRULB < (FID_PES_NET*2.20462442018378) or FID_PES_BRULB is null) 

		end		
		
		if update(FID_PES_BRU) 
			if (@FID_PES_BRULB <> (@FID_PES_BRU*2.20462442018378) or @FID_PES_BRULB is null) 
			update factimpdet 
			set FID_PES_BRULB = FID_PES_BRU*2.20462442018378
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRULB <> (FID_PES_BRU*2.20462442018378) or FID_PES_BRULB is null) 
	end

	-- pesos en libras
	
	IF @CF_PESOS_IMP ='L'
	begin
	
		if update(FID_PES_UNILB) 
		if (@FID_PES_UNI <> (@FID_PES_UNILB / 2.20462442018378)  or @FID_PES_UNI is null) 
		update factimpdet 
		set FID_PES_UNI = FID_PES_UNILB / 2.20462442018378 
		from factimpdet where fid_indiced = @fid_indiced 
		and (FID_PES_UNI <> (FID_PES_UNILB / 2.20462442018378)  or FID_PES_UNI is null) 
		
		if (update(FID_PES_UNILB)  or update (FID_CANT_ST)) and not update(FID_PES_NETLB)
		begin
			if (@FID_PES_NETLB <> (@FID_PES_UNILB * @FID_CANT_ST) or @FID_PES_NETLB is null) 
			update factimpdet 
			set FID_PES_NETLB = FID_PES_UNILB * FID_CANT_ST
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_NETLB <> (FID_PES_UNILB * FID_CANT_ST) or FID_PES_NETLB is null) 
	
	
			if (@FID_PES_NET <> ((@FID_PES_UNILB * @FID_CANT_ST) / 2.20462442018378) or @FID_PES_NET is null) 
			update factimpdet 
			set FID_PES_NET = (FID_PES_UNILB * FID_CANT_ST)/  2.20462442018378
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_NET <> ((FID_PES_UNILB * FID_CANT_ST)/  2.20462442018378) or FID_PES_NET is null) 
		

			if (@FID_PES_BRULB < (@FID_PES_UNILB * @FID_CANT_ST) or @FID_PES_BRULB is null) 
			update factimpdet 
			set FID_PES_BRULB = round(FID_PES_UNILB * FID_CANT_ST,6)
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRULB < round((FID_PES_UNILB * FID_CANT_ST),6) or FID_PES_BRULB is null) 


			if (@FID_PES_BRU < ((@FID_PES_UNILB/2.20462442018378) * @FID_CANT_ST) or @FID_PES_BRU is null) 
			update factimpdet 
			set FID_PES_BRU = round((FID_PES_UNILB / 2.20462442018378) * FID_CANT_ST,6)
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRU < round(((FID_PES_UNILB /2.20462442018378)* FID_CANT_ST),6) or FID_PES_BRU is null) 
		end
		
		if  (update(FID_PES_NETLB) or update(FID_CANT_ST)) and not update(FID_PES_UNILB)
		begin
			if (@FID_CANT_ST > 0) and (@FID_PES_UNILB <> (@FID_PES_NETLB/@FID_CANT_ST) or @FID_PES_UNILB is null) 
			update factimpdet 
			set FID_PES_UNILB = round(FID_PES_NETLB / FID_CANT_ST,6) 
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_UNILB <> round((FID_PES_NETLB/FID_CANT_ST),6) or FID_PES_UNILB is null) 
		

			if (@FID_CANT_ST > 0) 
			if (@FID_PES_UNI <> ((@FID_PES_NETLB/@FID_CANT_ST)/2.20462442018378) or @FID_PES_UNI is null) 
			update factimpdet 
			set FID_PES_UNI = round((FID_PES_NETLB/FID_CANT_ST)/2.20462442018378,6)
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_UNI <> round(((FID_PES_NETLB/FID_CANT_ST)/2.20462442018378),6) or FID_PES_UNI is null) 

		end		


		if update(FID_PES_NETLB) 
		begin
			if (@FID_PES_NET <> (@FID_PES_NETLB/2.20462442018378) or @FID_PES_NET is null) 
			update factimpdet 
			set FID_PES_NET = round(FID_PES_NETLB/2.20462442018378,6)
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_NET <> round((FID_PES_NETLB/2.20462442018378),6) or FID_PES_NET is null) 


			if (@FID_PES_BRULB is null or @FID_PES_BRULB < (@FID_PES_NETLB)) 
			update factimpdet 
			set FID_PES_BRULB = FID_PES_NETLB
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRULB < (FID_PES_NETLB) or FID_PES_BRULB is null) 
		

			if (@FID_PES_BRU is null or @FID_PES_BRU < (@FID_PES_NETLB/2.20462442018378)) 
			update factimpdet 
			set FID_PES_BRU = round(FID_PES_NETLB/2.20462442018378,6)
			from factimpdet where fid_indiced = @fid_indiced 
			and (FID_PES_BRU < round((FID_PES_NETLB/2.20462442018378),6) or FID_PES_BRU is null) 
		
		end		
		
		if update(FID_PES_BRULB) 
		if (@FID_PES_BRU <> (@FID_PES_BRULB/2.20462442018378) or @FID_PES_BRU is null) 
		update factimpdet 
		set FID_PES_BRU = round(FID_PES_BRULB/2.20462442018378,6)
		from factimpdet where fid_indiced = @fid_indiced 
		and (FID_PES_BRU <> round((FID_PES_BRULB/2.20462442018378),6) or FID_PES_BRU is null) 
	
	end



	if @fid_enuso='N'
	if (update(fid_cant_st) and (@fid_saldo <> @fid_cant_st) or @fid_saldo is null) 
	update factimpdet
	set fid_saldo = @fid_cant_st
	where fid_indiced in (select fid_indiced from inserted) 


	-- actualizacion del fid_enuso 
	if update(fid_cant_st) or update(fid_saldo)
	if (@fid_cant_st > @fid_saldo) and (@fid_enuso <> 'S')
		update factimpdet 
		set fid_enuso = 'S' 
		where fid_indiced in (select fid_indiced from inserted) 

	if update(fid_cant_st) or update(fid_saldo)
	if (@fid_cant_st = @fid_saldo) and (@fid_enuso <> 'N')	
		update factimpdet 
		set fid_enuso = 'N'
		where fid_indiced in (select fid_indiced from inserted) 



	-- actualiza tipo de costo 
	if (@Tipo='P' or @Tipo='S') and @tco_codigo is null
	update factimpdet
	set tco_codigo=@TCO_MANUFACTURA
	where FiD_indiced = @FiD_indiced and tco_codigo is null 
	 

	if (@Tipo<>'P' and @Tipo<>'S') and @tco_codigo is null
	update factimpdet
	set tco_codigo=@TCO_COMPRA
	where FiD_indiced = @FiD_indiced and tco_codigo is null 


end*/














GO
