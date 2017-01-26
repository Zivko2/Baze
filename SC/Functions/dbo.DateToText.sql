SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE FUNCTION DateToText (@fecha datetime,@mask int)  
RETURNS varchar(8000) AS  
BEGIN 
	RETURN (select convert(varchar(8000),@fecha,@mask));
END

























































GO
