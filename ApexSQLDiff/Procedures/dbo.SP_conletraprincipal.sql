SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_conletraprincipal]   as

SET NOCOUNT ON 

declare @valor decimal(38,6), @tamano int, @letra varchar(250), @decimal varchar(30),
@digito int, @letra2 varchar(250), @letra1 varchar(250), @valora varchar(30),
@posicion int
set  @valor=90000.15

/*saca la cantidad de digitos de los enteros*/
set @tamano= len(convert(varchar(30),convert( int, @valor)))
set @decimal= convert (varchar(30), round(@valor,2),2)

if @tamano=1 
begin
	set @valora= convert(varchar(30),convert(int,@valor))
	exec sp_conletranum 1, 1,  @valora, @letra2=@letra1 OUTPUT 

	set @letra=@letra1
end

if @tamano=2
begin
	if (left(convert(varchar(30),convert(int,@valor)),1))=1
	begin
		set @valora= convert(varchar(30),convert(int,@valor))
		exec sp_conletranum 1, 2,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra1
	end
	else
	begin

		set @valora= convert(varchar(30),convert(int,@valor))
		exec sp_conletranum 1, 2,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra1

		set @valora= right(convert(varchar(30),convert(int,@valor)),1)
		exec sp_conletranum 7, 7,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+' y '+@letra1
	end

end

if @tamano=3
begin

	if (convert(varchar(30),convert(int,@valor)))=100
	begin
		set @letra='cien'
	end
	else
	begin
		set @valora= left(convert(varchar(30),convert(int,@valor)),1)
		exec sp_conletranum 1, 3,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra1

		if (left(right(convert(varchar(30),convert(int,@valor)),2),1))=1
		begin
			set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),2)
			exec sp_conletranum 5, 6,  @valora, @letra2=@letra1 OUTPUT 
			set @letra=@letra+@letra1
		end
		else
		begin

			set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),1)
			if @valora<>0
			begin
				exec sp_conletranum 2, 3,  @valora, @letra2=@letra1 OUTPUT 
				set @letra=@letra+@letra1
			end
	
			set @valora= right(convert(varchar(30),convert(int,@valor)),1)
			if @valora<>0
			begin
				exec sp_conletranum 3, 3,  @valora, @letra2=@letra1 OUTPUT 
				--print @valora
				set @letra=@letra+' y '+@letra1
			end
	
		end
	end
end

if @tamano=4
begin
	if (convert(varchar(30),convert(int,@valor)))=1000
	begin
		set @letra='mil'
	end
	else
		begin
	
		set @valora= left(convert(varchar(30),convert(int,@valor)),1)
		exec sp_conletranum 1, 4,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra1


		if (right(convert(varchar(30),convert(int,@valor)),3))=100
		begin
			set @valora=right(convert(varchar(30),convert(int,@valor)),3)
			set @letra=@letra+'cien'	
		end
		else
		begin
		
	
			set @valora= left(right(convert(varchar(30),convert(int,@valor)),3),1)
			if @valora <>0
			begin
				exec sp_conletranum 2, 4,  @valora, @letra2=@letra1 OUTPUT 
				set @letra=@letra+@letra1
			end
		
			if (left(right(convert(varchar(30),convert(int,@valor)),2),1))=1
			begin
				set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),2)
				exec sp_conletranum 5, 6,  @valora, @letra2=@letra1 OUTPUT 
				set @letra=@letra+@letra1
		
			end
			else
			begin
		
				set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),1)
				if @valora<>0
				begin
					exec sp_conletranum 3, 4,  @valora, @letra2=@letra1 OUTPUT 
					set @letra=@letra+@letra1
				end
		
				set @valora= right(convert(varchar(30),convert(int,@valor)),1)
				if @valora<>0
				begin
					exec sp_conletranum 4, 4,  @valora, @letra2=@letra1 OUTPUT 
					set @letra=@letra+' y '+@letra1
				end	
			end
		end		
	end


end
--AQUI ME QUETE
if @tamano=5
begin
	set @valora= left(convert(varchar(30),convert(int,@valor)),1)
	exec sp_conletranum 1, 5,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra1


	set @valora= right(left(convert(varchar(30),convert(int,@valor)),2),1)
	exec sp_conletranum 2, 5,  @valora, @letra2=@letra1 OUTPUT 
	if @valora<>0
		begin
			set @letra=@letra+' y '+@letra1
		end
		else 	
		begin
			set @letra=@letra+@letra1
		end

	set @valora= left(right(convert(varchar(30),convert(int,@valor)),3),1)
	exec sp_conletranum 3, 5,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra+@letra1


	if (left(right(convert(varchar(30),convert(int,@valor)),2),1))=1
	begin
		set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),2)
		exec sp_conletranum 5, 6,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+@letra1
	end
	else
	begin
		set @valora= right(convert(varchar(30),convert(int,@valor)),1)
		if @valora <>0
		begin
			exec sp_conletranum 5, 5,  @valora, @letra2=@letra1 OUTPUT 
			set @letra=@letra+' y '+@letra1
		end
	end



end

if @tamano=6
begin
	set @valora= left(convert(varchar(30),convert(int,@valor)),1)
	exec sp_conletranum 1, 6,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra1


	if (right(left(convert(varchar(30),convert(int,@valor)),2),1))=1
	begin
		set @valora= right(left(convert(varchar(30),convert(int,@valor)),3),2)
		exec sp_conletranum 5, 6,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+@letra1+' mil'
	end
	else
	begin
		set @valora= right(left(convert(varchar(30),convert(int,@valor)),3),1)
		exec sp_conletranum 2, 6,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+@letra1+'mil y '
	end


	set @valora= left(right(convert(varchar(30),convert(int,@valor)),3),1)
	exec sp_conletranum 2, 4,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=' '+@letra+' '+@letra1

	if (left(right(convert(varchar(30),convert(int,@valor)),2),1))=1
	begin
		set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),2)
		exec sp_conletranum 5, 6,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+@letra1
	end
	else
	begin
		set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),1)
		exec sp_conletranum 1, 5,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+@letra1

		set @valora= right(convert(varchar(30),convert(int,@valor)),1)
		exec sp_conletranum 6, 6,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+' y '+@letra1

	end

end
--set  @valor=6357423.15
if @tamano=7
begin
	set @valora= left(convert(varchar(30),convert(int,@valor)),1)
	exec sp_conletranum 1, 7,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra1+ ' '

	set @valora= right(left(convert(varchar(30),convert(int,@valor)),2),1)
	exec sp_conletranum 1, 6, @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra+@letra1

	set @valora= right(left(convert(varchar(30),convert(int,@valor)),3),1)
	exec sp_conletranum 2, 6,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra+@letra1+' y '

	set @valora= right(left(convert(varchar(30),convert(int,@valor)),4),1)
	exec sp_conletranum 2, 5,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=@letra+@letra1

	set @valora= left(right(convert(varchar(30),convert(int,@valor)),3),1)
	exec sp_conletranum 1, 6,  @valora, @letra2=@letra1 OUTPUT 
	set @letra=' '+@letra+' '+@letra1

	if (left(right(convert(varchar(30),convert(int,@valor)),2),1))=1
	begin
		set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),2)
		exec sp_conletranum 6, 7,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+' '+@letra1
	end
	else
	begin
		set @valora= left(right(convert(varchar(30),convert(int,@valor)),2),1)
		exec sp_conletranum 6, 7,  @valora, @letra2=@letra1 OUTPUT 
		set @letra=@letra+' '+@letra1+' y '


		set @valora= right(convert(varchar(30),convert(int,@valor)),1)
		exec sp_conletranum 7, 7,  @valora, @letra2=@letra1 OUTPUT 
		--print @valora
		set @letra=@letra+@letra1

	end


end


--print @letra+' '+@decimal+'/100'
--print @tamano



GO
