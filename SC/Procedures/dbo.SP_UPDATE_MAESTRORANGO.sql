SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/*Actualiza Maestro Por rango -- forma actualizacion de datos*/
CREATE PROCEDURE dbo.SP_UPDATE_MAESTRORANGO (@MA_NOPARTEINI VARCHAR(30), @MA_NOPARTEFIN VARCHAR(30), @TIPOTASA CHAR(1), @TRATADO SMALLINT, @SECTOR INT, @FARANCELARIA INT, @PAIS INT,  @chkTTasa INT, @chkSPI INT, @chkSector INT, @chkarImpmx INT, @chkPais INT, @TI_CODIGO INT, @TI_CODIGO2 int,@chkTipo int,@MA_INV_GEN CHAR(1), @chkIndividual int)   as

SET NOCOUNT ON 

	if @chkTTasa = 1 
	begin
		UPDATE MAESTRO
		SET MA_DEF_TIP = @TIPOTASA WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkSPI = 1
	begin	
		UPDATE MAESTRO
		SET SPI_CODIGO = @TRATADO WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkSector = 1
	begin
		UPDATE MAESTRO
		SET MA_SEC_IMP = @SECTOR WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkarImpmx = 1
	begin
		UPDATE MAESTRO
		SET AR_IMPMX = @FARANCELARIA WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end


	if @chkPais = 1
	begin
		UPDATE MAESTRO
		SET PA_ORIGEN = @PAIS WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end

	if @chkTipo = 1
	begin
		UPDATE MAESTRO SET TI_CODIGO = @TI_CODIGO2 WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND MA_INV_GEN ='I' and TI_CODIGO =@TI_CODIGO
	end
          
	if @chkIndividual = 1
	begin
		UPDATE MAESTRO
		SET MA_INV_GEN = @MA_INV_GEN WHERE MA_NOPARTE >= @MA_NOPARTEINI AND MA_NOPARTE <= @MA_NOPARTEFIN
		AND TI_CODIGO =@TI_CODIGO
	end



GO