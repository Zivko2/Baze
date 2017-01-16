SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_ExplosionaSustInv (@ma_codigo integer, @CantXDesc decimal(38,6), @tipo char(1), @fed_indiced integer, @bst_pt integer)   as

SET NOCOUNT ON 
declare @ma_codigosust integer, @eq_cant decimal(28,14), @pid_saldogen decimal(38,6)
declare curMaestroSust cursor for
select MA_CODIGOSUST, EQ_CANT from MAESTROSUST
where MA_CODIGO = @ma_codigo
open curMaestroSust
fetch next from curMaestroSust into @ma_codigosust, @eq_cant
while (@@fetch_status = 0) and (@CantXDesc > 0)
begin
	if exists (select MA_CODIGO from TEMP_INVENTARIOS where MA_CODIGO = @ma_codigosust and PID_SALDOGEN > 0)
	begin
		select @pid_saldogen = PID_SALDOGEN from TEMP_INVENTARIOS where MA_CODIGO = @ma_codigosust
		if @pid_saldogen >= (@CantXDesc * @eq_cant)
		begin
			update TEMP_INVENTARIOS set FED_SALDOGEN = FED_SALDOGEN + (@CantXDesc * @eq_cant)
							where MA_CODIGO = @ma_codigosust and TIPO = @tipo
			
			--insertar en BOM_DESCTEMP el registro del sustituto
			
			insert into BOM_DESCTEMP (FE_CODIGO, FED_INDICED, BST_PT,BST_ENTRAVIGOR,BST_HIJO,BST_INCORPOR,BST_DISCH,TI_CODIGO,ME_CODIGO,FACTCONV,BST_PERINI,BST_PERFIN,ME_GEN,BST_TRANS,BST_TIPOCOSTO, MA_TIP_ENS,FED_CANT,
                                                              BST_NIVEL,BST_TIPODESC,BST_PERTENECE,BST_CONTESTATUS,FACT_INV ,BST_DESCARGADO)
                                                    select FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, @ma_codigosust, 1.0, BST_DISCH, TI_CODIGO, ME_CODIGO, 1.0, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, (@CantXDesc * @eq_cant),
                                                              BST_NIVEL, BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV,'N' from BOM_DESCTEMP where FED_INDICED = @fed_indiced and BST_PT = @bst_pt and BST_HIJO = @ma_codigo and FACT_INV = 'F'
			
			-- decrementar el valor original a descargar del no. de parte original
			update BOM_DESCTEMP set FED_CANT = FED_CANT - (@CantXDesc * @eq_cant / BST_INCORPOR) where FED_INDICED = @fed_indiced and BST_PT = @bst_pt and BST_HIJO = @ma_codigo and FACT_INV = 'F'

			select @CantXDesc = 0
		end
		else
		begin
			update TEMP_INVENTARIOS set FED_SALDOGEN = FED_SALDOGEN + @pid_saldogen
							where MA_CODIGO = @ma_codigosust and TIPO = @tipo
			
			--insertar en BOM_DESCTEMP el registro del sustituto
			
			insert into BOM_DESCTEMP (FE_CODIGO, FED_INDICED, BST_PT,BST_ENTRAVIGOR,BST_HIJO,BST_INCORPOR,BST_DISCH,TI_CODIGO,ME_CODIGO,FACTCONV,BST_PERINI,BST_PERFIN,ME_GEN,BST_TRANS,BST_TIPOCOSTO, MA_TIP_ENS,FED_CANT,
                                                              BST_NIVEL,BST_TIPODESC,BST_PERTENECE,BST_CONTESTATUS,FACT_INV ,BST_DESCARGADO)
                                                    select FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, @ma_codigosust, 1.0, BST_DISCH, TI_CODIGO, ME_CODIGO, 1.0, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, @pid_saldogen,
                                                              BST_NIVEL, BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV,'N' from BOM_DESCTEMP where FED_INDICED = @fed_indiced and BST_PT = @bst_pt and BST_HIJO = @ma_codigo and FACT_INV = 'F'
			
			-- decrementar el valor original a descargar del no. de parte original
			update BOM_DESCTEMP set FED_CANT = FED_CANT - (@pid_saldogen / BST_INCORPOR) where FED_INDICED = @fed_indiced and BST_PT = @bst_pt and BST_HIJO = @ma_codigo and FACT_INV = 'F'
			select @CantXDesc = @CantXDesc - (@pid_saldogen / @eq_cant)
		end
		
	end
	fetch next from curMaestroSust into @ma_codigosust, @eq_cant
end
close curMaestroSust
deallocate curMaestroSust















































GO
