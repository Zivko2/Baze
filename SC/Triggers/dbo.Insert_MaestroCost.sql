SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





















CREATE trigger Insert_MaestroCost on dbo.MAESTROCOST for update, insert as
SET NOCOUNT ON 
begin       
	declare @ma_codigo int, @ma_costo decimal(38,6),  
	@Fecha datetime, @Tipo char(1), @zx datetime,
	@cft_tipo char(1), @tco_codigo smallint, @TCO_MANUFACTURA INT, @TCO_COMPRA INT, @consecutivo int, @ba_codigo int,
	@Fechaactual datetime, @mac_codigo int

		SET @Fechaactual = convert(datetime, convert(varchar(11), getdate(),101))			
		SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA FROM dbo.CONFIGURACION


		select @ma_codigo = ma_codigo, @mac_codigo=mac_codigo,
		@tco_codigo=tco_codigo from inserted


	
		select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo =@ma_codigo)

	

	/* actualiza bom_costo */	
		/*if (SELECT CF_USACOSTOBOM FROM CONFIGURACION)='S'
		if (((@cft_tipo='P' or @cft_tipo='S') and @tco_codigo=@TCO_MANUFACTURA) or 
			((@cft_tipo<>'P' and @cft_tipo<>'S') and @tco_codigo=@TCO_COMPRA))
		and exists (select * from bom_struct where bsu_subensamble=@ma_codigo or bst_hijo=@ma_codigo)
		begin
			exec sp_actualizaBomCostoCal @ma_codigo, @Fechaactual
		end*/

	
		IF (SELECT CF_USACLASSCOSTO FROM CONFIGURACION)='S'
		begin
			if (@cft_tipo<>'P' and @cft_tipo<>'S') and @tco_codigo=@TCO_COMPRA
	 			if not exists(select * from bom_arancel where ma_codigo=@ma_codigo and ba_tipocosto='X')
					insert into bom_arancel (ba_costo, ba_tipocosto, ma_codigo, ar_codigo)
					values(isnull(@ma_costo,0), 'X', @ma_codigo, 0)
		end



	/*	if exists(select * from maestrocost where tco_codigo=@tco_codigo
			and ma_codigo=@ma_codigo and mac_codigo <>@mac_codigo)
		exec SP_MAESTROCOST_ACTUALIZAFECHAS @mac_codigo,  'S', 'N', @perini, @perfin

		if update(ma_perini) and not update(ma_perfin) and exists(select * from maestrocost where tco_codigo=@tco_codigo
		and ma_codigo=@ma_codigo and mac_codigo <>@mac_codigo)
		exec SP_MAESTROCOST_ACTUALIZAFECHAS @mac_codigo,  'S', 'N', @perini, @perfin

		if update(ma_perini) and update(ma_perfin) and exists(select * from maestrocost where tco_codigo=@tco_codigo
		and ma_codigo=@ma_codigo and mac_codigo <>@mac_codigo)
		exec SP_MAESTROCOST_ACTUALIZAFECHAS @mac_codigo,  'S', 'S', @perini, @perfin

		if not update(ma_perini) and update(ma_perfin) and exists(select * from maestrocost where tco_codigo=@tco_codigo
		and ma_codigo=@ma_codigo and mac_codigo <>@mac_codigo)
		exec SP_MAESTROCOST_ACTUALIZAFECHAS @mac_codigo,  'N', 'S', @perini, @perfin*/

	

end





















GO
