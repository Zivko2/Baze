SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_arancel980] (@AR_CODIGO int, @TIPO char(1))  as

SET NOCOUNT ON 
/*@tipo 
E=empaque,
R=Retorno,
I=Inserto,
T=Retrabajo
*/

		if @TIPO='T'
		begin
			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			update maestro
			set ar_retra=@AR_CODIGO
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
			and (ar_retra=0 or ar_retra is null)

		end

		if @TIPO='R'
		begin
			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			update maestro
			set ar_impfousa=@AR_CODIGO
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
			and (ar_impfousa=0 or ar_impfousa is null)


			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='R')) 
			UPDATE dbo.MAESTRO
			SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_CODIGO
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'R')
			and (ar_impfousa=0 or ar_impfousa is null)

		end


		if @TIPO='E'
		begin
			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='E')) 
			UPDATE dbo.MAESTRO
			SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_CODIGO
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'E')
			and (ar_impfousa=0 or ar_impfousa is null)	


			if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
				where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
				and BA_TIPOCOSTO='3')
			update bom_arancel
			set AR_CODIGO=@AR_CODIGO
			where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
			and BA_TIPOCOSTO='3' and ar_codigo not in (select ar_codigo from arancel where ar_fraccion like '9801%')
			else
			insert into bom_arancel (ar_codigo, ma_codigo, ba_tipocosto)
			select @AR_CODIGO, ma_codigo, '3' from maestro 
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
			and ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='3')
	


		end

	

		if @TIPO='I'
		begin
			if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
				where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
				and BA_TIPOCOSTO='2')
			update bom_arancel
			set AR_CODIGO=@AR_CODIGO
			where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
			and BA_TIPOCOSTO='2' and ar_codigo not in (select ar_codigo from arancel where ar_fraccion like '9802%')
			else
			insert into bom_arancel (ar_codigo, ma_codigo, ba_tipocosto)
			select @AR_CODIGO, ma_codigo, '2' from maestro 
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
			and ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='2')
		end



/*

		if @TIPO='T'
		begin


			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
			update maestro
			set ar_retra=@AR_CODIGO
			where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') 
			and (ar_retra=0 or ar_retra is null) and MAESTRO.MA_CODIGO in
			         (SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO	WHERE SPI.SPI_CLAVE = 'NAFTA'
			         and NFT_CALIFICO='S' AND NFT_PERINI<=GETDATE() AND NFT_PERFIN>=GETDATE()) 


		end

		if @TIPO='R'
		begin

			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='R')) 
			UPDATE dbo.MAESTRO
			SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_CODIGO
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'R')
			and (ar_impfousa=0 or ar_impfousa is null)



		end


		if @TIPO='E'
		begin
			if exists (select * from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='E')) 
			UPDATE dbo.MAESTRO
			SET     dbo.MAESTRO.AR_IMPFOUSA=@AR_CODIGO
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'E') 
			and (ar_impfousa=0 or ar_impfousa is null)

			if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
				where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
				and BA_TIPOCOSTO='3')
				update bom_arancel
				set AR_CODIGO=@AR_CODIGO
				where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') 
					and MA_CODIGO in
						         (SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO	WHERE SPI.SPI_CLAVE = 'NAFTA'
						         and NFT_CALIFICO='S' AND NFT_PERINI<=GETDATE() AND NFT_PERFIN>=GETDATE()))
				and BA_TIPOCOSTO='3' and ar_codigo not in (select ar_codigo from arancel where ar_fraccion like '9801%')
			else
				insert into bom_arancel (ar_codigo, ma_codigo, ba_tipocosto)
				select @AR_CODIGO, ma_codigo, '3' from maestro 
				where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
				and ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='3')


		end

	

		if @TIPO='I'
		begin
			if exists (select * from bom_arancel where ma_codigo in (select ma_codigo from maestro 
				where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')) 
				and BA_TIPOCOSTO='2')

				update bom_arancel
				set AR_CODIGO=@AR_CODIGO
				where ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') 
					and MA_CODIGO in
						         (SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO	WHERE SPI.SPI_CLAVE = 'NAFTA'
						         and NFT_CALIFICO='S' AND NFT_PERINI<=GETDATE() AND NFT_PERFIN>=GETDATE()))
				and BA_TIPOCOSTO='2' and ar_codigo not in (select ar_codigo from arancel where ar_fraccion like '9802%')
			else
				insert into bom_arancel (ar_codigo, ma_codigo, ba_tipocosto)
				select @AR_CODIGO, ma_codigo, '2' from maestro 
				where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
				and ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='2')
		end*/



GO
