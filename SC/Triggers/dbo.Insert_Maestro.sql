SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE trigger Insert_Maestro on dbo.MAESTRO for  insert as
SET NOCOUNT ON 
begin       

declare @ma_codigo int, @ma_inv_gen char(1), @Fecha varchar(10), @Tipo char(1), @pa_origen int, @ma_peso_lb decimal(38,6), @ma_peso_kg decimal(38,6), @zx datetime,
	@ma_generico int, @noparte varchar(30), @eq_gen decimal(28,14), @eq_impmx decimal(28,14), @eq_impfo decimal(28,14), @cft_tipo varchar(5), @CF_PESOS_IMP CHAR(1),
	@me_com int, @me_gen int, @ar_impmx int, @ar_expmx int, @ar_impfo int, @AR_RETORNOUSA int, @AR_EMPAQUEUSA int
		

	select @ma_codigo = ma_codigo, @ma_inv_gen = ma_inv_gen, @pa_origen = pa_origen, @ma_peso_lb = ma_peso_lb, @ma_peso_kg = ma_peso_kg,
	@ma_generico = ma_generico, @eq_gen=eq_gen, @eq_impmx=eq_impmx, @eq_impfo=eq_impfo, @me_com=me_com, @ar_impmx=ar_impmx,
	@ar_expmx=ar_expmx, @ar_impfo=ar_impfo from  inserted

	select @me_gen=me_com from maestro where ma_codigo=@ma_generico

	select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from  inserted)


	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         dbo.CONFIGURACION

	SET @Fecha = convert(VARCHAR(10),getdate(),101)


	insert into MAESTROALM(MA_CODIGO, MAA_FECHAREVISION)
	SELECT     MA_CODIGO, @fecha  from inserted 
	where ma_codigo not in (select ma_codigo from MAESTROALM)



	IF @CF_PESOS_IMP='K'
	if update(ma_peso_kg)
	if (@ma_peso_lb <> (@ma_peso_kg *2.20462442018378) or @ma_peso_lb  is null)
	begin	
		update maestro 
		set ma_peso_lb = ma_peso_kg * 2.20462442018378
		where ma_codigo in (select ma_codigo from inserted) and
		ma_peso_lb <> ma_peso_kg * 2.20462442018378
	end

	IF @CF_PESOS_IMP='L'
	if update(ma_peso_lb)
	if (@ma_peso_kg <> (@ma_peso_lb/2.20462442018378) or @ma_peso_kg is null)
	begin
		update maestro 
		set ma_peso_kg = ma_peso_lb/2.20462442018378
		where ma_codigo in (select ma_codigo from inserted) and
		ma_peso_kg <> ma_peso_lb/2.20462442018378
	end


	select @noparte = ma_noparte from inserted

	if not exists (select * from maestro where ma_noparte = ltrim(rtrim(@noparte)))
	if (@noparte <> ltrim(rtrim(@noparte))) and update(ma_noparte)
		update maestro 
		set ma_noparte = ltrim(rtrim(@noparte))
		where ma_codigo in (select ma_codigo from inserted)

-- inserta las caracteristicas a la tabla maestrocara


		if exists(select * from configuracara where cfc_tipo=@cft_tipo 
		and cfc_caracteristica not in (select mac_caracteristica from maestrocara where ma_codigo=@ma_codigo))

		insert into maestrocara (ma_codigo, mac_caracteristica, mac_valorcaracteristica)
		select @ma_codigo, cfc_caracteristica, ''
		from configuracara where cfc_tipo=@cft_tipo
		and cfc_caracteristica not in (select mac_caracteristica from maestrocara where ma_codigo=@ma_codigo)


		if (select CF_USATIPOADQUISICION from configuracion)='N'
		begin
			if exists(select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
			and ma_tip_ens<>'F' and ma_codigo in (select ma_codigo from inserted))
			update maestro
			set ma_tip_ens='F'
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
			and ma_tip_ens<>'F' and ma_codigo in (select ma_codigo from inserted)
		
			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
			and ma_tip_ens<>'C' and ma_codigo in (select ma_codigo from inserted))
			update maestro
			set ma_tip_ens='C'
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
			and ma_tip_ens<>'C' and ma_codigo in (select ma_codigo from inserted)
		end

select @AR_RETORNOUSA=AR_RETORNOUSA, @AR_EMPAQUEUSA=AR_EMPAQUEUSA from configuracion 


	if (@cft_tipo='P' or @cft_tipo='S')
	begin
		if @AR_RETORNOUSA<>0 and @AR_RETORNOUSA is not null
		if not exists (select * from bom_arancel where ma_codigo=@ma_codigo and ar_codigo=@AR_RETORNOUSA and ba_tipocosto='2')
		insert into bom_arancel (MA_CODIGO, AR_CODIGO, BA_TIPOCOSTO, BA_COSTO)
		values (@ma_codigo, @AR_RETORNOUSA, '2', 0)

		if @AR_EMPAQUEUSA<>0 and @AR_EMPAQUEUSA is not null
		if not exists (select * from bom_arancel where ma_codigo=@ma_codigo and ar_codigo=@AR_EMPAQUEUSA and ba_tipocosto='3')
		insert into bom_arancel (MA_CODIGO, AR_CODIGO, BA_TIPOCOSTO, BA_COSTO)
		values (@ma_codigo, @AR_EMPAQUEUSA, '3', 0)

	end

	-- actualiza el factor de conversion del grupo generico
	if (@me_gen<>@me_com)  and (@cft_tipo<>'P' and @cft_tipo<>'S') and (@eq_gen is null or @eq_gen=0)
	exec SP_ACTUALIZAEQGEN @ma_codigo


	-- actualiza el factor de conversion de las fracciones arancelarias
		if @ar_impmx<>0 and @ar_impmx is not null and (@cft_tipo<>'P' and @cft_tipo<>'S')
		exec SP_ACTUALIZAEQARANCEL @ar_impmx, @ma_codigo

		if @ar_expmx<>0 and @ar_expmx is not null and (@cft_tipo<>'P' and @cft_tipo<>'S')
		exec SP_ACTUALIZAEQARANCEL @ar_expmx, @ma_codigo
		
		if @ar_impfo<>0 and @ar_impfo is not null and (@cft_tipo<>'P' and @cft_tipo<>'S')
		exec SP_ACTUALIZAEQARANCEL @ar_impfo,  @ma_codigo



	-- costo de mano de obra
	IF @ma_inv_gen ='i'
	begin

		declare @CostLabor decimal(38,6), @PorGastos decimal(38,6), @tco_manufactura int

		SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA FROM dbo.CONFIGURACION



		SELECT  @CostLabor=   dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
		WHERE     (dbo.MAESTRO.MA_CODIGO = @ma_codigo)
		
		if @CostLabor>0 and @CostLabor is not null
		begin

			if ( SELECT  isnull(dbo.CENTROCOSTO.CC_GASIND,0) FROM dbo.MAESTRO LEFT OUTER JOIN dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
			WHERE     (dbo.MAESTRO.MA_CODIGO = @ma_codigo)) > 0
	
			SELECT  @PorGastos=   (dbo.CENTROCOSTO.CC_GASIND/100) * dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO
			FROM         dbo.MAESTRO LEFT OUTER JOIN
			                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
			WHERE     (dbo.MAESTRO.MA_CODIGO = @ma_codigo)
			else 
			set @PorGastos=0
	
			if exists(select * from maestrocost where ma_codigo=@ma_codigo and tco_codigo = @tco_manufactura)
			begin
				update maestrocost
				set ma_grav_mo=isnull(@CostLabor,0)
				where ma_codigo=@ma_codigo and tco_codigo = @tco_manufactura
	
				update maestrocost
				set ma_grav_gi_mx=@PorGastos
				where ma_codigo=@ma_codigo and tco_codigo =@tco_manufactura
				and ( ma_grav_gi_mx is null or ma_grav_gi_mx=0)
			end
			else
			begin
				insert into maestrocost (ma_codigo, ma_grav_mo, tco_codigo, ma_grav_gi_mx)
				values (@ma_codigo, @CostLabor,  @tco_manufactura, @PorGastos)
			end

		end

	end
end






















GO
