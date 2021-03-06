SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



--- Empaque directamente en la factura como adicional
CREATE PROCEDURE dbo.SP_DescEmpAdicional (@CodigoFactura Int, @Retorno char(1)='N')   as

SET NOCOUNT ON 
DECLARE @MA_HIJO INT, @FED_CANT decimal(38,6), @ME_CODIGO INT, @Factconv decimal(28,14), @BST_DISCH CHAR(1), @ME_GEN INT,
@fed_indiced int

	select @fed_indiced=min(fed_indiced) from factexpdet where fe_codigo=@CodigoFactura

/* Empaque 1*/

	if @Retorno='N'
	begin
		INSERT INTO bom_desctemp (FE_CODIGO, fed_indiced, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
		BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT,  TI_CODIGO, BST_TIPOCOSTO)

		SELECT     @CodigoFactura, @fed_indiced, dbo.FACTEXPEMPAQUEADICIONAL.MA_CODIGO, 1, MAESTRO_1.ME_COM, 
		                      MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, 
				SUM(dbo.FACTEXPEMPAQUEADICIONAL.FEAD_CANTIDAD), 'EA', 'N', 0, 'E', 'Z'
		FROM         dbo.MAESTRO MAESTRO_2 RIGHT OUTER JOIN
		                      dbo.FACTEXPEMPAQUEADICIONAL LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPEMPAQUEADICIONAL.MA_CODIGO = MAESTRO_1.MA_CODIGO ON 
		                      MAESTRO_2.MA_CODIGO = MAESTRO_1.MA_GENERICO
		GROUP BY dbo.FACTEXPEMPAQUEADICIONAL.FE_CODIGO, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, 
		                      MAESTRO_2.ME_COM, MAESTRO_1.ME_COM, dbo.FACTEXPEMPAQUEADICIONAL.MA_CODIGO
		HAVING      (MAESTRO_1.MA_DISCHARGE = 'S') AND (dbo.FACTEXPEMPAQUEADICIONAL.FE_CODIGO = @CodigoFactura)

	end
	else
	begin
		INSERT INTO bom_desctemp (FE_CODIGO, fed_indiced, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
		BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT,  TI_CODIGO, BST_TIPOCOSTO)

		SELECT     @CodigoFactura, @fed_indiced, dbo.FACTEXPEMPAQUEADICIONAL.MA_CODIGO, 1, MAESTRO_1.ME_COM, 
		                      MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, 
				SUM(dbo.FACTEXPEMPAQUEADICIONAL.FEAD_CANTIDAD), 'EA', 'N', 0, 'E', 'Z'
		FROM         dbo.MAESTRO MAESTRO_2 RIGHT OUTER JOIN
		                      dbo.FACTEXPEMPAQUEADICIONAL LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPEMPAQUEADICIONAL.MA_CODIGO = MAESTRO_1.MA_CODIGO ON 
		                      MAESTRO_2.MA_CODIGO = MAESTRO_1.MA_GENERICO
		WHERE MAESTRO_1.MA_GENERA_EMP IN ('R', 'T')
		GROUP BY dbo.FACTEXPEMPAQUEADICIONAL.FE_CODIGO, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, 
		                      MAESTRO_2.ME_COM, MAESTRO_1.ME_COM, dbo.FACTEXPEMPAQUEADICIONAL.MA_CODIGO
		HAVING      (MAESTRO_1.MA_DISCHARGE = 'S') AND (dbo.FACTEXPEMPAQUEADICIONAL.FE_CODIGO = @CodigoFactura)


	end



























GO
