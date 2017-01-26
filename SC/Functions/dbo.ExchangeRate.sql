SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE FUNCTION ExchangeRate (@fecha datetime)  
RETURNS decimal(38,6) AS  
BEGIN 
	declare @tc decimal(38,6);
	select @tc = isNull(max(tc_cant),1) from tcambio where tc_fecha = @fecha;
	return (@tc)
END




































GO
