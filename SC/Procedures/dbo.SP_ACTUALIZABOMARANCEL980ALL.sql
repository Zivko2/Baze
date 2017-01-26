SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_ACTUALIZABOMARANCEL980ALL]   as

SET NOCOUNT ON 
declare @AR_EMPAQUEUSA int, @AR_RETORNOUSA int, @AR_INSERTO int, @AR_RETRABAJO int

	SELECT     @AR_EMPAQUEUSA=AR_EMPAQUEUSA, @AR_RETORNOUSA=AR_RETORNOUSA, @AR_INSERTO=AR_INSERTO, 
		@AR_RETRABAJO=AR_RETRABAJO
	FROM  configuracion


		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
		update maestro
		set ar_retra=@AR_RETRABAJO
		where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		and (ar_retra=0 or ar_retra is null)


		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
		update maestro
		set ar_impfousa=@AR_RETORNOUSA
		where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		and (ar_impfousa=0 or ar_impfousa is null)


		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='E')) 
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_EMPAQUEUSA
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'E')
		and (ar_impfousa=0 or ar_impfousa is null)	


		if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='R')) 
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_RETORNOUSA
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'R')
		and (ar_impfousa=0 or ar_impfousa is null)

		if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			and BA_TIPOCOSTO='2')
		update bom_arancel
		set AR_CODIGO=@AR_INSERTO
		where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
		and BA_TIPOCOSTO='2' and ar_codigo not in (select ar_codigo from arancel where ar_fraccion like '9802%')
		else
		insert into bom_arancel (ar_codigo, ma_codigo, ba_tipocosto)
		select @AR_INSERTO, ma_codigo, '2' from maestro 
		where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		and ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='2')
		

		if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			and BA_TIPOCOSTO='3')
		update bom_arancel
		set AR_CODIGO=@AR_EMPAQUEUSA
		where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
		and BA_TIPOCOSTO='3' and ar_codigo not in (select ar_codigo from arancel where ar_fraccion like '9801%')
		else
		insert into bom_arancel (ar_codigo, ma_codigo, ba_tipocosto)
		select @AR_EMPAQUEUSA, ma_codigo, '3' from maestro 
		where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		and ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='3')





GO
