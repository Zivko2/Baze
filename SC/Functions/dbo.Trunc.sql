SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION Trunc (@valor decimal(38,6),@precision int)  
RETURNS decimal(38,6) AS  
BEGIN 

--	RETURN (select round(isnull(@valor,0),@precision,1));

	RETURN (select round(@valor,@precision))
END





















































GO
