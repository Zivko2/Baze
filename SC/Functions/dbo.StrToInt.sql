SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION StrToInt (@cadena varchar(8000))  
RETURNS int AS  
BEGIN 
	RETURN (select convert(int,isnull(@cadena,'0')))
END

























































GO
