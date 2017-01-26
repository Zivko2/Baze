SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_Listacopiabom] (@end_indiced int, @entravigor datetime,@bst_pt int)   as

SET NOCOUNT ON 
declare @CODIGOFACTURA int, @countbom INT, @EN_CODIGO int, @EN_INDICED int, @MA_HIJO int, @ENT_NOPARTE varchar(30), @ENT_NOMBRE varchar(150), 
	@ENT_NAME varchar(150), @ENT_INCORPOR decimal(38,6), @TI_HIJO int, @ME_CODIGO int, @MA_GENERICO int, @ME_ALM int, @ENT_INCORPORGEN decimal(38,6),
	 @FACTCONV  decimal(28,14), @CONSECUTIVO INT, @ENT_indicer INT
	
	select @countbom = count(*) from bom_struct where  bsu_subensamble=@BST_PT and bst_perini<=@entravigor and bst_perfin>=@entravigor
	if exists(select * from bom_desctemp where FED_indiced=@END_INDICED and FACT_INV = 'F')
		delete from bom_desctemp where FED_indiced=@END_INDICED and FACT_INV = 'F'
	select @CODIGOFACTURA=en_codigo from entsalalmdet where end_indiced=@end_indiced
	if @countbom >0
		EXEC SP_FILL_BOM_DESCTEMP @END_INDICED, @BST_PT, @entravigor, 1, @CODIGOFACTURA
		declare cur_ENTSALALMLISTA cursor for
			SELECT     EN_CODIGO, END_INDICED, BST_HIJO, MA_NOPARTE, MA_NOMBRE, MA_NAME, BST_INCORPOR, TI_CODIGO, ME_CODIGO, 
			                      ME_ALM, FACTCONVALM, ENT_INCORPORGEN
			FROM         dbo.VLISTACOPIABOM
			WHERE END_indiced =@END_indiced and convert(varchar(20),END_INDICED) + convert(varchar(20),BST_HIJO)
			not in (select convert(varchar(20),END_INDICED) + convert(varchar(20),MA_HIJO) from ENTSALALMLISTA)
	open cur_ENTSALALMLISTA
	fetch next from cur_ENTSALALMLISTA into @EN_CODIGO, @EN_INDICED, @MA_HIJO, @ENT_NOPARTE, @ENT_NOMBRE, @ENT_NAME, 
		@ENT_INCORPOR, @TI_HIJO, @ME_CODIGO, @ME_ALM, @ENT_INCORPORGEN, @FACTCONV
	while (@@fetch_status =0)
	begin
		SELECT @CONSECUTIVO=ISNULL(MAX(ENT_indicer),0) FROM ENTSALALMLISTA
		SET @CONSECUTIVO=@CONSECUTIVO+1
		INSERT INTO ENTSALALMLISTA (ENT_INDICER, EN_CODIGO, END_INDICED, MA_HIJO, ENT_NOPARTE, ENT_NOMBRE, ENT_NAME, ENT_INCORPOR,
			TI_HIJO, ME_CODIGO, ME_ALM, FACTCONV)
		values (@CONSECUTIVO,  @EN_CODIGO, @EN_INDICED, @MA_HIJO, @ENT_NOPARTE, @ENT_NOMBRE, @ENT_NAME, 
		@ENT_INCORPOR, @TI_HIJO, @ME_CODIGO, @ME_ALM, @FACTCONV)
	fetch next from cur_ENTSALALMLISTA into @EN_CODIGO, @EN_INDICED, @MA_HIJO, @ENT_NOPARTE, @ENT_NOMBRE, @ENT_NAME, 
		@ENT_INCORPOR, @TI_HIJO, @ME_CODIGO, @ME_ALM, @ENT_INCORPORGEN, @FACTCONV
	end
	CLOSE cur_ENTSALALMLISTA
	DEALLOCATE cur_ENTSALALMLISTA
	select @ENT_indicer= max(ENT_indicer) from ENTSALALMLISTA
	update consecutivo
	set cv_codigo =  isnull(@ENT_indicer,0) + 1
	where cv_tipo = 'ENT'

GO
