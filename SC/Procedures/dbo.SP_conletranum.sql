SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_conletranum(@posicion int, @digito int,  @valor varchar(30), @letra2 VARCHAR(250) OUTPUT)   as

SET NOCOUNT ON 
declare @letra varchar(250)

	set @letra=''

	if @digito=4 and @posicion=1 
	begin
		if @valor=1 
		set @letra=@letra+'mil'

	end

	if @digito=1 or (@digito=3  and (@posicion=1 or @posicion=3))
	or (@digito=4 and (@posicion=4 or @posicion=1 or @posicion=2))
	or (@digito=5 and (@posicion=2 or @posicion=5))
	or (@digito=6 and (@posicion=1 or @posicion=6))
	or (@digito=7 and (@posicion=1 or @posicion=7))
	begin
		if @valor=1 and (@digito=1 or @digito=4 or @digito=6 or @digito=7 )
		or (@digito=3 and @posicion=3)
		set @letra='uno'
		
		if @valor=1 and (@digito=3) and (@posicion=1)
		set @letra='ciento'

		if @valor=1 and @digito=5 and @posicion=2
		set @letra='un '

		if @valor=2
		set @letra='dos'
		
		if @valor=3
		set @letra='tres'
		
		if @valor=4
		set @letra='cuatro'
		
		if @valor=5
		set @letra='cinco'
		
		if @valor=6
		set @letra='seis'
		
		if @valor=7
		set @letra='siete'
		
		if @valor=8
		set @letra='ocho'
		
		if @valor=9
		set @letra='nueve'

		if --(@digito=4 and @posicion=2)or
		 ((@digito=6) and @posicion=1)
		or (@posicion=2 and @digito=4)
		set @letra=@letra+'cientos'

		if (@digito=4 and @posicion=1 and @valor<>1)
		or (@digito=5 and @posicion=2)
		set @letra=@letra+'mil'

		if (@digito=7 and @posicion=1)
		set @letra=@letra+'millones'

	end

	if @digito=2  or (@digito=7 and @posicion=6)
	or (@digito=6 and @posicion=5)
	begin

		if @valor=10
		set @letra=@letra+'diez'

		if @valor=11
		set @letra=@letra+'once'
		
		if @valor=12
		set @letra=@letra+'doce'
		
		if @valor=13
		set @letra=@letra+'trece'
		
		if @valor=14
		set @letra=@letra+'catorce'
	
		if @valor=15
		set @letra=@letra+'quince'

		if @valor=16
		set @letra=@letra+'dieciseis'

		if @valor=18
		set @letra=@letra+'dieciocho'
	end





	if ((@digito=3 or @digito=6) and @posicion=2)
	   or (@digito=5 and @posicion=1)
	   or (@digito=2 and @posicion=1)
  	   or (@digito=7 and @posicion=6)
  	   or (@digito=4 and @posicion=3)
	begin

		if left(@valor,1)=1
		set @letra=@letra+'diez'

		if left(@valor,1)=2
		set @letra=@letra+'veinte'

		if left(@valor,1)=3
		set @letra=@letra+'treinta'

		if left(@valor,1)=4
		set @letra=@letra+'cuarenta'

		if left(@valor,1)=5
		set @letra=@letra+'cincuenta'

		if left(@valor,1)=6
		set @letra=@letra+'sesenta'

		if left(@valor,1)=7
		set @letra=@letra+'setenta'

		if left(@valor,1)=8
		set @letra=@letra+'ochenta'

		if left(@valor,1)=9
		set @letra=@letra+'noventa'


	end

	   if (@digito=5 and @posicion=3)
	   or (@digito=6 and @posicion=4)
  	begin
		if @valor=5
		set @letra=@letra+'quinientos'

		if @valor=7
		set @letra=@letra+'setecientos'

	end


	set @letra2=@letra

RETURN



GO
