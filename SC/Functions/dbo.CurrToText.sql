SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE FUNCTION CurrToText (@valor money,@mask int)  
RETURNS varchar(8000) AS  
BEGIN 

/*

style  0 = sin coma 2 decimales
style  1 = con coma 2 decimales
style  2 = sin coma 4 decimales

*/
	RETURN (select convert(varchar(8000),@valor,@mask));
END

























































GO
