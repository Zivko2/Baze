SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION ToTexto  (@valor decimal(38,6))  
RETURNS varchar(8000) AS  
begin

  RETURN(select convert (varchar(8000),isnull(@valor,'0')));
end


























































GO
