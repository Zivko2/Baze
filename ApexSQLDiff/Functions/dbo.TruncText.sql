SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION dbo.TruncText (@valor varchar(2000),@precision int)  
RETURNS varchar(2000) AS  
BEGIN 
	RETURN (select left(isnull(@valor,''), @precision));
END











































GO
