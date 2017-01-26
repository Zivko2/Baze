SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE FUNCTION Rellena (@valor varchar(2000),@Size int, @tipocampo char(1), @Caracter varchar(5))  
RETURNS varchar(2000) AS  
BEGIN 
declare @resultado varchar(2000)

       -- @tipocampo='T'  texto
       --@tipocampo='N'  numerico
       
        if @tipocampo='T' 
        begin

	      if @valor is null 
		set @valor=''

	        if len(@valor)<=@Size 
	        begin
	          set @resultado = @valor+replicate(@Caracter, @size-len(@valor))
	        end
	       else
	          set @resultado = left(@valor,@Size)
        end
        else
          begin
	      if @valor is null 
		set @valor='0'


	       if @Caracter=''
	      set @Caracter='0'

 	        if len(@valor)<=@Size 
	        begin
	          set @resultado = replicate(@Caracter, @size-len(@valor))+@valor
	        end
	       else                 
	          set @resultado = left(@valor,@Size)

          end

        RETURN (@resultado)

END











































GO
