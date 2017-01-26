SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE FUNCTION RellenaTexto (@valor varchar(2000),@Size int, @Caracter varchar(5))  
RETURNS varchar(2000) AS  
BEGIN 
declare @resultado varchar(2000)


      if @valor is null 
	set @valor=''

        if len(@valor)<=@Size 
        begin
          set @resultado = @valor+replicate(@Caracter, @size-len(@valor))
        end
       else
          set @resultado = left(@valor,@Size)


        RETURN (@resultado)

END









































GO
