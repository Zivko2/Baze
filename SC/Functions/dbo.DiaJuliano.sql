SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION DiaJuliano (@Fecha datetime)  
RETURNS VARCHAR(3) AS  
BEGIN 
   RETURN(replicate('0',3-len(convert(varchar(3),datepart(dy,@Fecha))))+convert(varchar(3),datepart(dy,@Fecha)))

END


























GO
