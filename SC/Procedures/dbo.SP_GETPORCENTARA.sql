SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_GETPORCENTARA (@FRACC INTEGER, @PAIS INTEGER, @FACTCONVERT decimal(38,6), @AR_PORCENT decimal(38,6) OUTPUT, @ESP_VALUE decimal(38,6) OUTPUT, @POR_DEF decimal(38,6) OUTPUT)   as

DECLARE @TIMPUESTO VARCHAR(1);   
DECLARE @CANTUM decimal(38,6);
BEGIN
     -- El uso o no de Fraccion-Pais para cada porcentaje no importa siempre se hace la busqueda
     -- del Porcentaje en base a Fraccion-Pais.
     DECLARE arancel_cursor CURSOR
     FOR SELECT AR_TIPOIMPUESTO, AR_ADVDEF, AR_CANTUMESP, AR_ADVDEF 
         FROM ARANCEL
         WHERE AR_CODIGO = @FRACC
         OPEN arancel_cursor
     FETCH NEXT FROM arancel_cursor 
     INTO @TIMPUESTO, @AR_PORCENT, @CANTUM, @POR_DEF 
     IF @TIMPUESTO = 'A'
        SET @ESP_VALUE = 0.0;
   
     IF @TIMPUESTO = 'E'
     BEGIN     
   	SET @ESP_VALUE = @CANTUM * @FACTCONVERT;
        	SET @AR_PORCENT = 0.0;
    END


   CLOSE arancel_cursor
   DEALLOCATE arancel_cursor
END



























GO
