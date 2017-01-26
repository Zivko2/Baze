SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



-- Empaque directamente en la factura (en detalle)
CREATE PROCEDURE dbo.SP_DescEmpDetalleFed (@CodigoFactura Int, @fed_indiced int, @Retorno char(1)='N')   as

SET NOCOUNT ON 

DECLARE @MA_HIJO INT, @FED_CANT decimal(38,6), @ME_CODIGO INT, @FACTCONV decimal(28,14), @BST_DISCH CHAR(1), @ME_GEN INT

-- Empaque 1
		if @Retorno='N'
		begin
			INSERT INTO bom_desctemp (FE_CODIGO, fed_indiced, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
			BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT,  TI_CODIGO, BST_TIPOCOSTO)
	
			SELECT     @CodigoFactura, @fed_indiced, dbo.FACTEXPDET.MA_EMPAQUE, 1, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, 
			                      MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, SUM(dbo.FACTEXPDET.FED_CANTEMP), 'ED', 'N', 0, 'E', 'Z'
			FROM         dbo.FACTEXPDET LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_2 RIGHT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON MAESTRO_2.MA_CODIGO = MAESTRO_1.MA_GENERICO ON 
			                      dbo.FACTEXPDET.MA_EMPAQUE = MAESTRO_1.MA_CODIGO
			GROUP BY dbo.FACTEXPDET.FE_CODIGO, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, 
			                      MAESTRO_1.ME_COM, dbo.FACTEXPDET.MA_EMPAQUE
			HAVING      (MAESTRO_1.MA_DISCHARGE = 'S') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)
		end
		else
		begin
			INSERT INTO bom_desctemp (FE_CODIGO, fed_indiced, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
			BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT,  TI_CODIGO, BST_TIPOCOSTO)
	
			SELECT     @CodigoFactura, @fed_indiced, dbo.FACTEXPDET.MA_EMPAQUE, 1, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, 
			                      MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, SUM(dbo.FACTEXPDET.FED_CANTEMP), 'ED', 'N', 0, 'E', 'Z'
			FROM         dbo.FACTEXPDET LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_2 RIGHT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON MAESTRO_2.MA_CODIGO = MAESTRO_1.MA_GENERICO ON 
			                      dbo.FACTEXPDET.MA_EMPAQUE = MAESTRO_1.MA_CODIGO
			WHERE MAESTRO_1.MA_GENERA_EMP IN ('R', 'T')
			GROUP BY dbo.FACTEXPDET.FE_CODIGO, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, 
			                      MAESTRO_1.ME_COM, dbo.FACTEXPDET.MA_EMPAQUE
			HAVING      (MAESTRO_1.MA_DISCHARGE = 'S') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)

		end


GO
