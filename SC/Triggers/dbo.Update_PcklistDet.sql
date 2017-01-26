SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE trigger Update_PcklistDet on dbo.PCKLISTDET for Update, insert as
SET NOCOUNT ON 
BEGIN     
	declare @pld_indiced int, @pld_cant_st decimal(38,6), @pld_cos_uni decimal(38,6), @pld_cos_tot decimal(38,6),
	 @eq_gen decimal(28,14), @pld_pes_uni decimal(38,6), @pld_pes_net decimal(38,6), @pld_pes_bru decimal(38,6), @cf_pesos_imp char(1),
	@pld_pes_unilb decimal(38,6), @pld_pes_netlb decimal(38,6), @pld_pes_brulb decimal(38,6), @pld_SALDO decimal(38,6), @pld_enuso char(1)
	
	select @pld_indiced = pld_indiced, @pld_cant_st = pld_cant_st, @pld_cos_uni = pld_cos_uni, @pld_cos_tot = pld_cos_tot,
		@eq_gen = eq_gen, @pld_pes_uni = pld_pes_uni,
		@pld_pes_net = pld_pes_net, @pld_pes_bru = pld_pes_bru,
		@pld_pes_unilb = pld_pes_unilb,
		@pld_pes_netlb = pld_pes_netlb, @pld_pes_brulb = pld_pes_brulb,
		@pld_enuso=pld_enuso
		from Pcklistdet where pld_indiced in (select pld_indiced from inserted)



	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         dbo.CONFIGURACION

	if (update(pld_cant_st) or update(pld_cos_uni)) and not update(pld_cos_tot)
	begin
		if @pld_COS_TOT <> (@pld_COS_UNI * @pld_CANT_ST) or @pld_COS_TOT is null
		update pcklistdet
		set pld_COS_TOT = pld_COS_UNI * pld_CANT_ST
		from pcklistdet where pld_indiced in (select pld_indiced from inserted)
		and pld_COS_TOT <> (pld_COS_UNI * pld_CANT_ST) or pld_COS_TOT is null
	end

	if (update(pld_cant_st) or update(pld_cos_tot)) and not update(pld_cos_uni)
	begin
		if update (pld_COS_TOT) and @pld_cant_st >0
		if @pld_COS_UNI <> (@pld_COS_TOT / @pld_CANT_ST) or @pld_COS_UNI is null
		update pcklistdet
		set pld_COS_UNI =  pld_COS_TOT/ pld_CANT_ST
		from pcklistdet where pld_indiced in (select pld_indiced from inserted)
		and pld_COS_UNI <> (pld_COS_TOT / pld_CANT_ST) or pld_COS_UNI is null
	end


	if @pld_enuso='N'
	if (update(pld_CANT_ST) and (@pld_SALDO <> @pld_CANT_ST) or @pld_SALDO is null) 
	update pcklistdet
	set pld_saldo = pld_cant_st
	from pcklistdet 
	where pld_indiced in (select pld_indiced from inserted)
	and pld_saldo <> pld_cant_st and pld_enuso='N'


	if update(pld_CANT_ST)
	if ((@pld_SALDO = @pld_CANT_ST) or @pld_SALDO is null) 
	update pcklistdet
	set pld_enuso='N'
	from pcklistdet where pld_indiced in (select pld_indiced from inserted)

-- actualizacion de pesos 

	IF @CF_PESOS_IMP ='K'
	begin
	
		if update(PLD_PES_UNI) 
		if (@PLD_PES_UNILB <> (@PLD_PES_UNI * 2.20462442018378)  or @PLD_PES_UNILB is null) 
		update pcklistdet 
		set PLD_PES_UNILB = PLD_PES_UNI * 2.20462442018378 
		from pcklistdet where PLD_indiced = @PLD_indiced 
		and (PLD_PES_UNILB <> (PLD_PES_UNI * 2.20462442018378)  or PLD_PES_UNILB is null) 
		
		if (update(PLD_PES_UNI)  or update (PLD_CANT_ST)) and not update(PLD_PES_NET)
		begin
			if (@PLD_PES_NET <> (@PLD_PES_UNI * @PLD_CANT_ST) or @PLD_PES_NET is null) 
			update pcklistdet 
			set PLD_PES_NET = PLD_PES_UNI * PLD_CANT_ST
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_NET <> (PLD_PES_UNI * PLD_CANT_ST) or PLD_PES_NET is null) 
	
	
			if (@PLD_PES_NETLB <> (@PLD_PES_UNI * @PLD_CANT_ST * 2.20462442018378) or @PLD_PES_NETLB is null) 
			update pcklistdet 
			set PLD_PES_NETLB = PLD_PES_UNI * PLD_CANT_ST * 2.20462442018378 
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_NETLB <> (PLD_PES_UNI * PLD_CANT_ST * 2.20462442018378) or PLD_PES_NETLB is null) 
		

			if (@PLD_PES_BRU < (@PLD_PES_UNI * @PLD_CANT_ST) or @PLD_PES_BRU is null) 
			update pcklistdet 
			set PLD_PES_BRU = PLD_PES_UNI * PLD_CANT_ST
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRU < (PLD_PES_UNI * PLD_CANT_ST) or PLD_PES_BRU is null) 


			if (@PLD_PES_BRULB < (@PLD_PES_UNI*2.20462442018378 * @PLD_CANT_ST) or @PLD_PES_BRULB is null) 
			update pcklistdet 
			set PLD_PES_BRULB = PLD_PES_UNI * 2.20462442018378 * PLD_CANT_ST
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRULB < (PLD_PES_UNI *2.20462442018378* PLD_CANT_ST) or PLD_PES_BRULB is null) 
		end
		
		if  (update(PLD_PES_NET) or update(PLD_CANT_ST)) and not update(PLD_PES_UNI)
		begin
			if (@PLD_CANT_ST > 0) and (@PLD_PES_UNI <> (@PLD_PES_NET/@PLD_CANT_ST) or @PLD_PES_UNI is null) 
			update pcklistdet 
			set PLD_PES_UNI = PLD_PES_NET / PLD_CANT_ST 
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_UNI <> (PLD_PES_NET/PLD_CANT_ST) or PLD_PES_UNI is null) 
		

			if (@PLD_CANT_ST > 0) 
			if (@PLD_PES_UNILB <> ((@PLD_PES_NET/@PLD_CANT_ST)*2.20462442018378) or @PLD_PES_UNILB is null) 
			update pcklistdet 
			set PLD_PES_UNILB = (PLD_PES_NET/PLD_CANT_ST)*2.20462442018378
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_UNILB <> ((PLD_PES_NET/PLD_CANT_ST)*2.20462442018378) or PLD_PES_UNILB is null) 

		end		


		if update(PLD_PES_NET) 
		begin
			if (@PLD_PES_NETLB <> (@PLD_PES_NET*2.20462442018378) or @PLD_PES_NETLB is null) 
			update pcklistdet 
			set PLD_PES_NETLB = PLD_PES_NET*2.20462442018378
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_NETLB <> (PLD_PES_NET*2.20462442018378) or PLD_PES_NETLB is null) 


			if (@PLD_PES_BRU < (@PLD_PES_NET) or @PLD_PES_BRU is null) 
			update pcklistdet 
			set PLD_PES_BRU = PLD_PES_NET
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRU < (PLD_PES_NET) or PLD_PES_BRU is null) 
		

			if (@PLD_PES_BRULB < (@PLD_PES_NET*2.20462442018378) or @PLD_PES_BRULB is null) 
			update pcklistdet 
			set PLD_PES_BRULB = PLD_PES_NET*2.20462442018378
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRULB < (PLD_PES_NET*2.20462442018378) or PLD_PES_BRULB is null) 
		
		end		
		
		if update(PLD_PES_BRU) 
		if (@PLD_PES_BRULB <> (@PLD_PES_BRU*2.20462442018378) or @PLD_PES_BRULB is null) 
		update pcklistdet 
		set PLD_PES_BRULB = PLD_PES_BRU*2.20462442018378
		from pcklistdet where PLD_indiced = @PLD_indiced 
		and (PLD_PES_BRULB <> (PLD_PES_BRU*2.20462442018378) or PLD_PES_BRULB is null) 
	
	end
	
	
	-- pesos en libras
	
	IF @CF_PESOS_IMP ='L'
	begin
	
		if update(PLD_PES_UNILB) 
		if (@PLD_PES_UNI <> (@PLD_PES_UNILB / 2.20462442018378)  or @PLD_PES_UNI is null) 
		update pcklistdet 
		set PLD_PES_UNI = PLD_PES_UNILB / 2.20462442018378 
		from pcklistdet where PLD_indiced = @PLD_indiced 
		and (PLD_PES_UNI <> (PLD_PES_UNILB / 2.20462442018378)  or PLD_PES_UNI is null) 
		
		if (update(PLD_PES_UNILB)  or update (PLD_CANT_ST)) and not update(PLD_PES_NETLB)
		begin
			if (@PLD_PES_NETLB <> (@PLD_PES_UNILB * @PLD_CANT_ST) or @PLD_PES_NETLB is null) 
			update pcklistdet 
			set PLD_PES_NETLB = PLD_PES_UNILB * PLD_CANT_ST
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_NETLB <> (PLD_PES_UNILB * PLD_CANT_ST) or PLD_PES_NETLB is null) 
	
	
			if (@PLD_PES_NET <> ((@PLD_PES_UNILB * @PLD_CANT_ST) / 2.20462442018378) or @PLD_PES_NET is null) 
			update pcklistdet 
			set PLD_PES_NET = (PLD_PES_UNILB * PLD_CANT_ST)/  2.20462442018378 
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_NET <> ((PLD_PES_UNILB * PLD_CANT_ST)/  2.20462442018378) or PLD_PES_NET is null) 
		

			if (@PLD_PES_BRULB < (@PLD_PES_UNILB * @PLD_CANT_ST) or @PLD_PES_BRULB is null) 
			update pcklistdet 
			set PLD_PES_BRULB = PLD_PES_UNILB * PLD_CANT_ST
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRULB < (PLD_PES_UNILB * PLD_CANT_ST) or PLD_PES_BRULB is null) 


			if (@PLD_PES_BRU < ((@PLD_PES_UNILB/2.20462442018378) * @PLD_CANT_ST) or @PLD_PES_BRU is null) 
			update pcklistdet 
			set PLD_PES_BRU = (PLD_PES_UNILB / 2.20462442018378) * PLD_CANT_ST
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRU < ((PLD_PES_UNILB /2.20462442018378)* PLD_CANT_ST) or PLD_PES_BRU is null) 
		end
		
		if  (update(PLD_PES_NETLB) or update(PLD_CANT_ST)) and not update(PLD_PES_UNILB)
		begin
			if (@PLD_CANT_ST > 0) and (@PLD_PES_UNILB <> (@PLD_PES_NETLB/@PLD_CANT_ST) or @PLD_PES_UNILB is null) 
			update pcklistdet 
			set PLD_PES_UNILB = PLD_PES_NETLB / PLD_CANT_ST 
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_UNILB <> (PLD_PES_NETLB/PLD_CANT_ST) or PLD_PES_UNILB is null) 
		

			if (@PLD_CANT_ST > 0) 
			if (@PLD_PES_UNI <> ((@PLD_PES_NETLB/@PLD_CANT_ST)/2.20462442018378) or @PLD_PES_UNI is null) 
			update pcklistdet 
			set PLD_PES_UNI = (PLD_PES_NETLB/PLD_CANT_ST)/2.20462442018378
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_UNI <> ((PLD_PES_NETLB/PLD_CANT_ST)/2.20462442018378) or PLD_PES_UNI is null) 

		end		


		if update(PLD_PES_NETLB) 
		begin
			if (@PLD_PES_NET <> (@PLD_PES_NETLB/2.20462442018378) or @PLD_PES_NET is null) 
			update pcklistdet 
			set PLD_PES_NET = PLD_PES_NETLB/2.20462442018378
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_NET <> (PLD_PES_NETLB/2.20462442018378) or PLD_PES_NET is null) 


			if (@PLD_PES_BRULB < (@PLD_PES_NETLB) or @PLD_PES_BRULB is null) 
			update pcklistdet 
			set PLD_PES_BRULB = PLD_PES_NETLB
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRULB < (PLD_PES_NETLB) or PLD_PES_BRULB is null) 
		

			if (@PLD_PES_BRU < (@PLD_PES_NETLB/2.20462442018378) or @PLD_PES_BRU is null) 
			update pcklistdet 
			set PLD_PES_BRU = PLD_PES_NETLB/2.20462442018378
			from pcklistdet where PLD_indiced = @PLD_indiced 
			and (PLD_PES_BRU < (PLD_PES_NETLB/2.20462442018378) or PLD_PES_BRU is null) 
		
		end		
		
		if update(PLD_PES_BRULB) 
		if (@PLD_PES_BRU <> (@PLD_PES_BRULB/2.20462442018378) or @PLD_PES_BRU is null) 
		update pcklistdet 
		set PLD_PES_BRU = PLD_PES_BRULB/2.20462442018378
		from pcklistdet where PLD_indiced = @PLD_indiced 
		and (PLD_PES_BRU <> (PLD_PES_BRULB/2.20462442018378) or PLD_PES_BRU is null) 
	
	end
end




































GO
