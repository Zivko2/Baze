SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION [RepiteStr] (@StringOrig varchar(1500), @caracter char(1))  
RETURNS smallint AS  
BEGIN 
	declare @String varchar(1500), @Posicion smallint, @Resultado smallint

	if @StringOrig is null
	set @StringOrig=''

	select @Posicion=charindex(@caracter, @StringOrig)+1
	select @String=@StringOrig

	set @Resultado=0

	if (@Posicion>1) 
	set @Resultado=1

	while (@Posicion>1) 
	begin

		select @String=substring(@String, @Posicion,len(@String))
		select @Posicion=charindex(@caracter, @String)+1
		
		if @Posicion>1 
		set @Resultado=@Resultado+1

	end


	return(@Resultado)

END
































GO
