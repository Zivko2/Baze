SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE FUNCTION dbo.FloatToCurr(@fValor decimal(38,6))
RETURNS Money  AS  
BEGIN 
	return CAST(@fValor AS Money)
END













GO
