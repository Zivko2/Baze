SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










-- Contenedor directamente en la factura (en caratula)
CREATE PROCEDURE dbo.SP_DescEmpContenedor (@CodigoFactura Int)   as

SET NOCOUNT ON 

DECLARE @MA_HIJO INT, @FED_CANT decimal(38,6), @ME_CODIGO INT, @Factconv decimal(28,14), @BST_DISCH CHAR(1), @ME_GEN INT


/*Contenedor 1 solamente */

		INSERT INTO bom_desctemp (FE_CODIGO, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
		BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT)

		SELECT     @CodigoFactura, dbo.FACTEXP.CJ_COMPANY1, 1, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, 
		                      MAESTRO_2.ME_COM, 1, 'CT', 'N', 0
		FROM         dbo.MAESTRO MAESTRO_2 RIGHT OUTER JOIN
		                      dbo.FACTEXP LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXP.CJ_COMPANY1 = MAESTRO_1.MA_CODIGO ON 
		                      MAESTRO_2.MA_CODIGO = MAESTRO_1.MA_GENERICO
		WHERE     (MAESTRO_1.MA_DISCHARGE = 'S') AND (dbo.FACTEXP.FE_CODIGO = @CodigoFactura)


GO
