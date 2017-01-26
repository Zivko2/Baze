SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE FUNCTION Entero  (@valor1 int, @valor2 int)  
RETURNS int AS  
begin
  RETURN(select (isnull(@valor1,0)%@valor2));
   
end
























































GO
