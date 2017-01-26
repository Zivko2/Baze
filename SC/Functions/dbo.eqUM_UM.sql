SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE FUNCTION eqUM_UM (@um1 integer,@um2 integer)  
RETURNS decimal(38,6) AS  
BEGIN 
	RETURN (select IsNull(max(eq_cant),1) from equivale 
			where ME_CODIGO1 = @um2 and ME_CODIGO2 = @um2)
END




GO
