SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE PROCEDURE [dbo].[SP_EstructuraDinamicacopiabom] (@fed_indiced int, @entravigor datetime,@tipo char(1), @bst_pt int)   as

SET NOCOUNT ON 
declare @CODIGOFACTURA int, @countbom INT, @FETR_CODIGO int, @FETR_INDICED int, @MA_HIJO int, @RE_NOPARTE varchar(30), @RE_NOMBRE varchar(150), 
	@RE_NAME varchar(150), @RE_INCORPOR decimal(38,6), @TI_HIJO int, @ME_CODIGO int, @MA_GENERICO int, @ME_GEN int, @RE_INCORPORGEN decimal(38,6),
	 @Factconv decimal(28,14), @CONSECUTIVO INT, @re_indicer INT, @fed_retrabajo char(1), @fed_cant decimal(38,6)
	
	select @countbom = count(*) from bom_struct where  bsu_subensamble=@BST_PT and bst_perini<=@entravigor and bst_perfin>=@entravigor

	if exists(select * from bom_desctemp where fed_indiced=@FED_INDICED and FACT_INV = @tipo)
		delete from bom_desctemp where fed_indiced=@FED_INDICED and FACT_INV = @tipo


	select @CODIGOFACTURA=fe_codigo, @fed_retrabajo=fed_retrabajo, @fed_cant=fed_cant from factexpdet where fed_indiced=@fed_indiced

	if @countbom >0
	begin
		if @tipo = 'F'
			EXEC SP_FILL_BOM_DESCTEMP @FED_INDICED, @BST_PT, @entravigor, 1, @CODIGOFACTURA
		else
		if @tipo = 'I'
			EXEC SP_FILL_BOM_DESCTEMP_INV @FED_INDICED, @BST_PT, @entravigor, 1, @CODIGOFACTURA
	end

	
	if @tipo='F'
	begin
		declare cur_retrabajo cursor for
			SELECT     FE_CODIGO, FED_INDICED, BST_HIJO, MA_NOPARTE, MA_NOMBRE, MA_NAME, SUM(BST_INCORPOR), TI_CODIGO, ME_CODIGO, 
			                      MA_GENERICO, MAX(ME_GEN), SUM(RE_INCORPORGEN), MAX(FACTCONV)
			FROM         dbo.VESTRUCTDINAMCOPIABOM 
			WHERE fed_indiced =@fed_indiced and convert(varchar(20),FED_INDICED) + convert(varchar(20),BST_HIJO)
			not in (select convert(varchar(20),FETR_INDICED) + convert(varchar(20),MA_HIJO) from retrabajo)
			GROUP BY FE_CODIGO, FED_INDICED, BST_HIJO, MA_NOPARTE, MA_NOMBRE, MA_NAME, TI_CODIGO, ME_CODIGO, 
			                      MA_GENERICO
	end
	else
	if @tipo='I'
	begin
		declare cur_retrabajo cursor for
			SELECT     IVF_CODIGO, IVFD_INDICED, BST_HIJO, MA_NOPARTE, MA_NOMBRE, MA_NAME, SUM(BST_INCORPOR), TI_CODIGO, ME_CODIGO, 
			                      MA_GENERICO, MAX(ME_GEN), SUM(RE_INCORPORGEN), MAX(FACTCONV)
			FROM         dbo.VESTRUCTDINAMCOPIABOMINVFIS
			WHERE ivfd_indiced =@fed_indiced and convert(varchar(20),IVFD_INDICED) + convert(varchar(20),BST_HIJO)
			not in (select convert(varchar(20),FETR_INDICED) + convert(varchar(20),MA_HIJO) from retrabajo)
			GROUP BY IVF_CODIGO, IVFD_INDICED, BST_HIJO, MA_NOPARTE, MA_NOMBRE, MA_NAME, TI_CODIGO, ME_CODIGO, 
			                      MA_GENERICO
	end
	open cur_retrabajo

	fetch next from cur_retrabajo into @FETR_CODIGO, @FETR_INDICED, @MA_HIJO, @RE_NOPARTE, @RE_NOMBRE, @RE_NAME, 
		@RE_INCORPOR, @TI_HIJO, @ME_CODIGO, @MA_GENERICO, @ME_GEN, @RE_INCORPORGEN, @FACTCONV

	while (@@fetch_status =0)
	begin
		
		if @fed_retrabajo='D'
		set @RE_INCORPOR=@RE_INCORPOR
		else 
		set @RE_INCORPOR=@RE_INCORPOR*@fed_cant		

		SELECT @CONSECUTIVO=ISNULL(MAX(re_indicer),0) FROM retrabajo
		SET @CONSECUTIVO=@CONSECUTIVO+1
		INSERT INTO RETRABAJO (RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
			TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES)
		values (@CONSECUTIVO, @tipo, @FETR_CODIGO, @FETR_INDICED, @MA_HIJO, @RE_NOPARTE, @RE_NOMBRE, @RE_NAME, 
		@RE_INCORPOR, @TI_HIJO, @ME_CODIGO, @MA_GENERICO, @ME_GEN, @RE_INCORPORGEN, @FACTCONV, 'N')

	fetch next from cur_retrabajo into @FETR_CODIGO, @FETR_INDICED, @MA_HIJO, @RE_NOPARTE, @RE_NOMBRE, @RE_NAME, 
						@RE_INCORPOR, @TI_HIJO, @ME_CODIGO, @MA_GENERICO, @ME_GEN, @RE_INCORPORGEN, @FACTCONV
	end
	CLOSE cur_retrabajo
	DEALLOCATE cur_retrabajo
	select @re_indicer= max(re_indicer) from retrabajo

	update consecutivo
	set cv_codigo =  isnull(@re_indicer,0) + 1
	where cv_tipo = 'RE'






























GO
