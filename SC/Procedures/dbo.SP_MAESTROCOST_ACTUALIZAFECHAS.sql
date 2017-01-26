SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- actualiza las fechas de entrada envigor del registro posterior o fecha final anterior de acuerdo a la que fue modificada
CREATE PROCEDURE [dbo].[SP_MAESTROCOST_ACTUALIZAFECHAS] (@MAC_CODIGO int,  @Modificaperini char(1), @Modificaperfin char(1), @EntraVigorNvo varchar(10), @PerFinNvo varchar(10))   as

SET NOCOUNT ON 
declare @tco_codigo int, @ma_codigo int, @maccodigoanterior int, @maccodigoposterior int, @perfinanterior datetime, @perinianterior datetime, 
@entravigor1 datetime, @entravigorantes datetime, @count int, @perini datetime, @perfin datetime, @perfin1 datetime, @entravigorposterior datetime,
@perfinposterior datetime

	/*if @Modificaperfin='S'
	update maestrocost
	set ma_perfin=@PerFinNvo
	where MAC_CODIGO=@MAC_CODIGO

	if @Modificaperini='S'
	update maestrocost
	set ma_perini= @EntraVigorNvo
	where MAC_CODIGO=@MAC_CODIGO


	select @tco_codigo=tco_codigo, @ma_codigo=ma_codigo, @perini=ma_perini,  @perfin=ma_perfin
	 from maestrocost where MAC_CODIGO=@MAC_CODIGO


		select @count = count(MAC_CODIGO) from maestrocost where tco_codigo =@tco_codigo and ma_codigo=@ma_codigo 

		if @count>1
		begin
			-- inmediato anterior
			SELECT @maccodigoanterior = max(MAC_CODIGO) FROM maestrocost WHERE tco_codigo =@tco_codigo
			and ma_codigo=@ma_codigo and MAC_CODIGO <>@MAC_CODIGO and MAC_CODIGO<@MAC_CODIGO

			SELECT @maccodigoposterior = min(MAC_CODIGO) FROM maestrocost WHERE tco_codigo =@tco_codigo
			and ma_codigo=@ma_codigo and MAC_CODIGO <>@MAC_CODIGO and MAC_CODIGO >@MAC_CODIGO

	
			--actualiza la fecha final del bom anterior al que se esta insertando si se traslapa
			if @Modificaperini='S'
			begin
				select @perfinanterior = ma_perfin, @perinianterior=ma_perini from maestrocost where MAC_CODIGO = @maccodigoanterior
			
				if @perinianterior < @perini-1
				begin
					set @entravigor1=@perini-1
					set @entravigorantes=@perfinanterior+1
	
					if not exists (select * from maestrocost where ma_perfin = @entravigor1 and tco_codigo = @tco_codigo
						and ma_codigo=@ma_codigo and ma_perini=@perini) 
						and @perfinanterior >=@perini -- traslape
					update maestrocost
					set ma_perfin = @entravigor1
				 	where MAC_CODIGO = @maccodigoanterior
				end
		
			end

			--actualiza la fecha inicial del bom posterior al que se esta insertando si se traslapa
			if @Modificaperfin='S'
			begin
				select @entravigorposterior=ma_perini, @perfinposterior=ma_perfin from maestrocost where MAC_CODIGO = @maccodigoposterior

				if @perfinposterior > @perfin+1 
				begin
					set @perfin1=@perfin+1
	
					if not exists (select * from maestrocost where ma_perini = @perfin1 and tco_codigo = @tco_codigo
							and ma_codigo=@ma_codigo and ma_perfin=@perfin)
						      and @perfin>=@entravigorposterior -- traslape
					update maestrocost
					set ma_perini = @perfin1
				 	where MAC_CODIGO=@maccodigoposterior
				end
			end



		end

*/



























GO
