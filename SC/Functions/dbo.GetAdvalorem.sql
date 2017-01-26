SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION GetAdvalorem (@FRACC INTEGER, @PAIS INTEGER, @TSECTOR VARCHAR(1), @SECTOR INTEGER, @SPI SMALLINT)
RETURNS decimal(38,6) AS  
BEGIN
	DECLARE @TIMPUESTO VARCHAR(1), @CANTUM decimal(38,6), @AR_PORCENT decimal(38,6), @TIPO CHAR(1)


	IF (SELECT PA_CODIGO FROM ARANCEL WHERE AR_CODIGO=@FRACC)=154
	SET @TIPO='M'
	ELSE
	SET @TIPO='X'

	IF @TIPO='M'
	BEGIN
		IF @TSECTOR = 'G' or @TSECTOR = 'E'
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

		IF @TSECTOR = 'F' 
		begin
			if exists 	(select * FROM ARANCEL WHERE AR_CODIGO = @FRACC) 
		  	      begin
				SELECT @AR_PORCENT = AR_ADVFRONTERA
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
	ELSE
	BEGIN

		if @TSECTOR = 'P'
			set @AR_PORCENT = 0
		else
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


	END

	IF @AR_PORCENT IS NULL
	SET @AR_PORCENT=-1

	RETURN @AR_PORCENT
END


































GO
