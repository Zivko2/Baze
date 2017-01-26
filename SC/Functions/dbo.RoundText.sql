SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE FUNCTION [RoundText] (@valor varchar(2000), @BUM_DECIMAL int)
RETURNS decimal(38,6) AS  
BEGIN 
		--select @ValorNvo=round(convert(decimal(38,6),@ValorCampo),@BUM_REDONDEO) 
		Return round(convert(decimal(38,6),isnull(@Valor,0)),@BUM_DECIMAL)


END



























GO
