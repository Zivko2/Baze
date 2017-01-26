SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION Ccantidad(@ma_generico int, @fed_cant decimal(38,6), @eq_gen decimal(28,14))
RETURNS decimal(38,6) AS
begin
     if(@ma_generico = 0 or @ma_generico = NULL)
     begin
          return (@fed_cant);
     end
     
   return (@fed_cant * @eq_gen);          
end





























GO
