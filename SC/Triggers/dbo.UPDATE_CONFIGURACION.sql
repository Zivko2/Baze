SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [UPDATE_CONFIGURACION] ON dbo.CONFIGURACION 
FOR UPDATE
AS
declare @AR_EMPAQUEUSA int, @AR_RETORNOUSA int, @AR_RETRABAJO int, @CF_UPDATEARCAMBIO char(1)
/*

	SELECT     @AR_EMPAQUEUSA=AR_EMPAQUEUSA, @AR_RETORNOUSA=AR_RETORNOUSA, @AR_RETRABAJO=AR_RETRABAJO, 
	@CF_UPDATEARCAMBIO=CF_UPDATEARCAMBIO
	FROM         inserted


		IF (update(AR_RETORNOUSA) OR update(AR_RETRABAJO)) AND @CF_UPDATEARCAMBIO='S' 
		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
		update maestro
		set ar_impfousa=@AR_RETORNOUSA,
		ar_retra=@AR_RETRABAJO
		where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')

		IF update(AR_EMPAQUEUSA) AND @CF_UPDATEARCAMBIO='S' 
		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='E')) 
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_EMPAQUEUSA
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'E')

		IF update(AR_RETORNOUSA) AND @CF_UPDATEARCAMBIO='S' 
		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='R')) 
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_RETORNOUSA
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'R')
	
		IF update(AR_RETORNOUSA) AND @CF_UPDATEARCAMBIO='S' 
		if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			and BA_TIPOCOSTO='2')
		update bom_arancel
		set AR_CODIGO=@AR_RETORNOUSA
		where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
		and BA_TIPOCOSTO='2'

		IF update(AR_EMPAQUEUSA) AND @CF_UPDATEARCAMBIO='S' 
		if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			and BA_TIPOCOSTO='3')
		update bom_arancel
		set AR_CODIGO=@AR_EMPAQUEUSA
		where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
		and BA_TIPOCOSTO='3'


*/



GO
