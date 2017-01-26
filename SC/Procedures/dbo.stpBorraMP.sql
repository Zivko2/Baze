SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE stpBorraMP (@Bst_Codigo Int, @FechaDelete DateTime, @bmpercambio char(1))   as

SET NOCOUNT ON 

DECLARE @count int, @bsu_subensamble int, @bst_hijo int,  @EntraVigor datetime, @bstcodigoanterior int, @bst_periniant datetime
	

	
	select @bsu_subensamble=bsu_subensamble, @bst_hijo=bst_hijo, @EntraVigor=bst_perini
	 from bom_struct where bst_codigo=@BST_CODIGO


	select @count = count(bst_codigo) from bom_struct where bsu_subensamble =@bsu_subensamble and bst_hijo=@bst_hijo 

	if @count>1
	begin
		-- inmediato anterior
		SELECT @bstcodigoanterior = max(bst_codigo) FROM bom_struct WHERE bsu_subensamble =@bsu_subensamble
		and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo and bst_codigo<@bst_codigo

	end



	
	if (@bmpercambio ='S') 
	begin	
			
		if @EntraVigor<@FechaDelete and
		not exists (select * from Bom_Struct WHERE BSU_SUBENSAMBLE = @bsu_subensamble -- que no exista una que termina en la misma fecha
		AND BST_HIJO = @bst_hijo and bst_perfin = @FechaDelete)
		begin
			Update Bom_Struct
			set bst_perfin= @FechaDelete
			WHERE BST_CODIGO=@Bst_Codigo
		end			
		else	/* en el caso que se haya agregado y borrado 2 veces el mismo dia */
		    begin
			
			delete from Bom_Struct
			WHERE bst_codigo=@bst_codigo

			if not exists (select * from Bom_Struct WHERE BSU_SUBENSAMBLE = @bsu_subensamble  -- cuidando las llaves
			AND BST_HIJO = @bst_hijo and bst_perfin = '01/01/9999') 
		
			update Bom_struct
			set bst_perfin= '01/01/9999'
			WHERE BST_CODIGO=@bstcodigoanterior

 		   end


	end
	else
	begin
	

		if @count > 1  
		begin		
			delete from Bom_Struct
			WHERE bst_codigo=@bst_codigo


			select @bst_periniant=bst_perini from bom_struct where bst_codigo=@bstcodigoanterior

			if not exists (select * from Bom_Struct WHERE BSU_SUBENSAMBLE = @bsu_subensamble
			AND BST_HIJO = @bst_hijo and bst_perini = @bst_periniant and bst_perfin = '01/01/9999')

			 Update Bom_Struct
			set bst_perfin= '01/01/9999'
			WHERE bst_codigo=@bstcodigoanterior



		end
		else
			delete from Bom_Struct
			WHERE bst_codigo=@bst_codigo


	end



























GO
