SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE FUNCTION eqUM_GrupoGen (@um integer,@grupo_gen varchar(30))  
RETURNS decimal(38,6) AS  
BEGIN 

	RETURN (select IsNull(max(eq_cant),1) from equivale 
			where ME_CODIGO1 = @um and ME_CODIGO2 = (select max(me_com) from maestro where ma_inv_gen='G' and ma_noparte = @grupo_gen))
END




































GO
