SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Noms] (@ARP_PERMISO VARCHAR(1500))  
RETURNS varchar(100) AS  
BEGIN 
    DECLARE @CARACTER Char(1), @CADENA Varchar(100), @INDICE SmallInt
    
   SET @INDICE=CHARINDEX('NOM-',@ARP_PERMISO)
   SET @CADENA=''
   SET @CARACTER='&'

    WHILE not @CARACTER in (', ', ' ','.')
    begin
      SET @CARACTER=SUBSTRING(@ARP_PERMISO, @INDICE,1)

      if not @CARACTER in (', ', ' ','.')
      SET @CADENA =@CADENA + @CARACTER
      SET @INDICE=@INDICE+1
    end	

    RETURN(@CADENA)
 
END

























GO
