SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION dbo.Ccantidadsmedida(@ma_generico int, @fed_cant decimal(38,6), @eq_gen decimal(28,14))
RETURNS decimal(38,6)  AS  
begin
   if (@ma_generico = 0 or @ma_generico = NULL)
    begin
	RETURN (@fed_cant);   
    end
 RETURN (@fed_cant * @eq_gen);
end






























GO
