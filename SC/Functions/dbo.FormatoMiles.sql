SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE FUNCTION [FormatoMiles] (@valor varchar(500), @decimal int=-1)  
RETURNS varchar(500) AS  
BEGIN 

declare @Entero varchar(500), @decimales varchar(500),
@valorFinal varchar(500), @3valor varchar(500), @inicio int, @restante varchar(5)
	
--	set @valor='1980908098.000'
	
	if @valor is null
	set @valor=''

	select @Entero=left(@valor,charIndex('.',@valor)-1)

	--formato decimales

	set @decimales=replace(@valor,@Entero+'.','')

	if @decimal<>-1	
	begin
	    if @decimal= 0 
	    set @decimales=''
	   else
                 if @decimal> 0
	   begin
  	        if len(@decimales)>=@decimal
	         set @decimales=left(@decimales, @decimal)
	       else
	         set @decimales=@decimales+replicate('0',@decimal-len(@decimales))
	    end
	end
	
	set @inicio=len(@Entero)-2
	set @valorFinal=''
	set @3valor=substring(@Entero, @inicio, 3)
	set @Entero=left(@Entero, @inicio)
	set @inicio=@inicio-3
	set @valorFinal=@3valor+@valorFinal
	while len(@Entero) >3
	begin
		set @3valor=substring(@Entero, @inicio, 3)+','
		set @Entero=left(@Entero, @inicio)
		set @inicio=@inicio-3
		set @valorFinal=@3valor+@valorFinal
	end
	
	--set @valorFinal=@valorFinal
	
	set @restante =left(left(@valor,charIndex('.',@valor)-1),len(left(@valor,charIndex('.',@valor)-1))-len(replace(@valorFinal,',','')))
	
	if @decimales<>''
	set @valorFinal=@restante+','+@valorFinal+'.'+@decimales
	else
	set @valorFinal=@restante+','+@valorFinal
	
	return @valorFinal
END



































GO
