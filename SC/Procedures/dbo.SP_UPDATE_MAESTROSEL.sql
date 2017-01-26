SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/*Actualiza Maestro Por Seleccion -- forma actualizacion de datos*/
CREATE PROCEDURE dbo.SP_UPDATE_MAESTROSEL (@MA_CODIGO INT, @TIPOTASA CHAR(1), @TRATADO SMALLINT, @SECTOR INT, @FARANCELARIA INT, @PAIS INT, @chkTTasa INT, @chkSPI INT, @chkSector INT, @chkarImpmx INT, @chkPais INT, @TI_CODIGO INT, @TI_CODIGO2 int, @chkTipo int, @MA_INV_GEN CHAR(1),@chkIndividual INT)   as

SET NOCOUNT ON 
declare @TCO_MANUFACTURA int, @TCO_COMPRA int, @tco_codigo int



	if @chkTTasa = 1
	begin
		UPDATE MAESTRO SET MA_DEF_TIP = @TIPOTASA 
		WHERE MA_CODIGO = @MA_CODIGO
--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO


	end

	if @chkSPI = 1
	begin	
		UPDATE MAESTRO SET SPI_CODIGO = @TRATADO 
		WHERE MA_CODIGO = @MA_CODIGO
--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkSector = 1
	begin
		UPDATE MAESTRO SET MA_SEC_IMP = @SECTOR 
		WHERE MA_CODIGO = @MA_CODIGO
--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkarImpmx = 1
	begin
		UPDATE MAESTRO SET AR_IMPMX = @FARANCELARIA WHERE MA_CODIGO = @MA_CODIGO		
--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkPais = 1
	begin
		UPDATE MAESTRO SET PA_ORIGEN = @PAIS WHERE MA_CODIGO = @MA_CODIGO		
--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkTipo = 1
	begin
		UPDATE MAESTRO 
		SET TI_CODIGO = @TI_CODIGO2 
		WHERE MA_CODIGO = @MA_CODIGO
		
		SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA FROM dbo.CONFIGURACION
		
		if @TI_CODIGO2 in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		begin
			set @tco_codigo=@TCO_MANUFACTURA

			UPDATE MAESTRO 
			SET MA_TIP_ENS = 'F'
			WHERE MA_CODIGO = @MA_CODIGO
		end
		else
		begin 
			set @tco_codigo=@TCO_COMPRA

			UPDATE MAESTRO 
			SET MA_TIP_ENS = 'C'
			WHERE MA_CODIGO = @MA_CODIGO

		end

		/*if exists (select * from bom_struct where bst_hijo=@MA_CODIGO)
		begin
			update bom_struct
			set ti_codigo=@TI_CODIGO2
			where bst_hijo=@MA_CODIGO
		end*/
                           --actualiza documentos
		if exists (select * from pcklistdet where ma_codigo = @ma_codigo)
		begin
		  update pcklistdet set ti_codigo = @ti_codigo2
		  where ma_codigo = @ma_codigo        
		end

		if exists (select * from listaexpdet where ma_codigo = @ma_codigo)
		begin
		  update listaexpdet set ti_codigo = @ti_codigo2
		  where ma_codigo = @ma_codigo
		end

		if exists (select * from factimpdet where ma_codigo = @ma_codigo)
		begin
		  update factimpdet set ti_codigo = @ti_codigo2
		  where ma_codigo = @ma_codigo        
		end

		if exists (select * from factexpdet where ma_codigo = @ma_codigo)
		begin
		  update factexpdet set ti_codigo = @ti_codigo2
		  where ma_codigo = @ma_codigo
		end

		if exists (select * from pedimpdet where ma_codigo=@ma_codigo)
		begin
		 update pedimpdet set ti_codigo = @ti_codigo2
		 where ma_codigo = @ma_codigo
		end



		if exists (select * from maestrocost where ma_codigo=@MA_CODIGO) and not exists (select * from maestrocost where ma_codigo=@MA_CODIGO and tco_codigo=@tco_codigo)
		update maestrocost
		set tco_codigo=@tco_codigo
		where ma_codigo=@MA_CODIGO


--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkIndividual = 1
	begin
		UPDATE MAESTRO SET MA_INV_GEN = @MA_INV_GEN WHERE MA_CODIGO = @MA_CODIGO		
--		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	EXEC SP_GETPORCENTARA_DEFUNI @MA_CODIGO



GO
