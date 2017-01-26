SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE FUNCTION eqUM_HTS (@um integer,@ar_codigo varchar(30))  
RETURNS decimal(38,6) AS  
BEGIN 
	RETURN (select IsNull(max(eq_cant),1) from equivale 
			where ME_CODIGO1 = @um and ME_CODIGO2 = (select max(me_codigo) from arancel where ar_codigo = @ar_codigo))
END




































GO
