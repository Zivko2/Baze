SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_DELSELFACTENTRY] (@ET_CODIGO INT)   as



		if (select count(*) from factexp where et_codigo=@ET_CODIGO)=0
	begin
		update factexpdet set eta_codigo=-1 where eta_codigo in 
		(select eta_codigo from entrysumara where et_codigo=@ET_CODIGO)
	
		delete from entrysumara where et_codigo=@ET_CODIGO
	end

























GO
