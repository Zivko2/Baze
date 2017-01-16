SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























-- actualiza las fechas de entrada envigor del registro posterior o fecha final anterior de acuerdo a la que fue modificada
CREATE PROCEDURE [dbo].[SP_BOM_STRUCTACTUALIZAFECHAS] (@BST_CODIGO int,  @Modificaperini char(1), @Modificaperfin char(1), @EntraVigorNvo varchar(10), @PerFinNvo varchar(10))   as

SET NOCOUNT ON 
declare @bsu_subensamble int, @bst_hijo int, @bstcodigoanterior int, @bstcodigoposterior int, @bmperfinanterior datetime, @bmperinianterior datetime, 
@entravigor1 datetime, @entravigorantes datetime, @count int, @perini datetime, @perfin datetime, @bmperfin1 datetime, @bmentravigorposterior datetime,
@bmperfinposterior datetime

	if @Modificaperfin='S'
	update bom_struct
	set bst_perfin=@PerFinNvo
	where bst_codigo=@BST_CODIGO

	if @Modificaperini='S'
	update bom_struct
	set bst_perini= @EntraVigorNvo
	where bst_codigo=@BST_CODIGO


	select @bsu_subensamble=bsu_subensamble, @bst_hijo=bst_hijo, @perini=bst_perini,  @perfin=bst_perfin
	 from bom_struct where bst_codigo=@BST_CODIGO


		select @count = count(bst_codigo) from bom_struct where bsu_subensamble =@bsu_subensamble and bst_hijo=@bst_hijo 

		if @count>1
		begin
			-- inmediato anterior
			SELECT @bstcodigoanterior = max(bst_codigo) FROM bom_struct WHERE bsu_subensamble =@bsu_subensamble
			and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo and bst_codigo<@bst_codigo

			SELECT @bstcodigoposterior = min(bst_codigo) FROM bom_struct WHERE bsu_subensamble =@bsu_subensamble
			and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo and bst_codigo >@bst_codigo

	
			--actualiza la fecha final del bom anterior al que se esta insertando si se traslapa
			if @Modificaperini='S'
			begin
				select @bmperfinanterior = bst_perfin, @bmperinianterior=bst_perini from bom_struct where bst_codigo = @bstcodigoanterior
			
				if @bmperinianterior < @perini-1
				begin
					set @entravigor1=@perini-1
					set @entravigorantes=@bmperfinanterior+1
	
					if not exists (select * from bom_struct where bst_perfin = @entravigor1 and bsu_subensamble = @bsu_subensamble
						and bst_hijo=@bst_hijo and bst_perini=@perini) 
						and @bmperfinanterior >=@perini -- traslape
					update bom_struct
					set bst_perfin = @entravigor1
				 	where bst_codigo = @bstcodigoanterior
				end
		
			end

			--actualiza la fecha inicial del bom posterior al que se esta insertando si se traslapa
			if @Modificaperfin='S'
			begin
				select @bmentravigorposterior=bst_perini, @bmperfinposterior=bst_perfin from bom_struct where bst_codigo = @bstcodigoposterior

				if @bmperfinposterior > @perfin+1 
				begin
					set @bmperfin1=@perfin+1
	
					if not exists (select * from bom_struct where bst_perini = @bmperfin1 and bsu_subensamble = @bsu_subensamble
							and bst_hijo=@bst_hijo and bst_perfin=@perfin)
						      and @perfin>=@bmentravigorposterior -- traslape
					update bom_struct
					set bst_perini = @bmperfin1
				 	where bst_codigo=@bstcodigoposterior
				end
			end



		end



























GO
