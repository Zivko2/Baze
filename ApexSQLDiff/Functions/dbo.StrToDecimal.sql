SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION dbo.StrToDecimal(@cadena varchar(8000))  
RETURNS decimal(38,6) AS  
BEGIN 
	RETURN (select convert(decimal(19,6),isnull(@cadena,'0')))
END













































GO
