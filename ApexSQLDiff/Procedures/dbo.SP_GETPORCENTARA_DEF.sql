SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_GETPORCENTARA_DEF (@FRACC INTEGER, @PAIS INTEGER, @TSECTOR VARCHAR(1), @SECTOR INTEGER, @SPI SMALLINT, @AR_PORCENT decimal(38,6) OUTPUT)   as

DECLARE @TIMPUESTO VARCHAR(1);   
DECLARE @CANTUM decimal(38,6);
BEGIN

	IF @TSECTOR = 'G' 
	begin
		if exists 	(select * FROM ARANCEL WHERE AR_CODIGO = @FRACC) 
	  	      begin
			SELECT @AR_PORCENT = AR_ADVDEF
			FROM ARANCEL
			WHERE AR_CODIGO = @FRACC
		     end
		     else
		     begin
			set @AR_PORCENT = -1
		     end
	end

	if @TSECTOR = 'R'
	begin
		if exists (select * FROM ARANCEL WHERE AR_CODIGO = @FRACC) 
		     BEGIN
			SELECT @AR_PORCENT = AR_PORCENT_8VA
			FROM ARANCEL
			WHERE AR_CODIGO = @FRACC 

		     END
		     else
			begin
				set @AR_PORCENT = -1
	  	    end
	end


	if @TSECTOR = 'P'
	begin
		if exists (select * FROM PAISARA WHERE AR_CODIGO = @FRACC AND PA_CODIGO = @PAIS AND
			SPI_CODIGO=@SPI) 
		     BEGIN
			SELECT @AR_PORCENT = PAR_BEN
			FROM PAISARA 
			WHERE AR_CODIGO = @FRACC AND PA_CODIGO = @PAIS AND
			SPI_CODIGO=@SPI
		     END
		else
		begin
			set @AR_PORCENT = -1
		end
	end


	if @TSECTOR = 'S'
	begin
		if exists (select * 	FROM SECTORARA WHERE AR_CODIGO = @FRACC AND SE_CODIGO = @SECTOR)
		begin
			SELECT @AR_PORCENT = SA_PORCENT
			FROM SECTORARA 
			WHERE AR_CODIGO = @FRACC AND SE_CODIGO = @SECTOR 
		end
		else
		begin
			set @AR_PORCENT = -1
		end
	end
END



























GO
