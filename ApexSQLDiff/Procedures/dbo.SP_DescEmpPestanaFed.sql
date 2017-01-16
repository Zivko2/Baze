SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



-- Empaque directamente en la factura (con pestaa)
CREATE PROCEDURE dbo.SP_DescEmpPestanaFed (@CodigoFactura int, @fed_indiced Int, @Retorno char(1)='N')   as

SET NOCOUNT ON 

DECLARE @MA_HIJO INT, @FED_CANT decimal(38,6), @ME_CODIGO INT, @FACTCONV decimal(28,14), @BST_DISCH CHAR(1), @ME_GEN INT 



		if @Retorno='N'
		begin
			if exists(select * FROM dbo.VDESCEMPAQUEPESTANA WHERE FE_CODIGO = @CodigoFactura)

			INSERT INTO bom_desctemp (FE_CODIGO, fed_indiced, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
			BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT,  TI_CODIGO, BST_TIPOCOSTO)

			SELECT     @CodigoFactura, @fed_indiced, MA_HIJO, 1, ME_COM, EQ_GEN, MA_DISCHARGE, ME_GEN, Cantidad,
			'EP', 'N', 0, 'E', 'Z'
			FROM         dbo.VDESCEMPAQUEPESTANA
			WHERE FE_CODIGO = @CodigoFactura

		end
		else
		begin
			if exists(select * FROM dbo.VDESCEMPAQUEPESTANA WHERE FE_CODIGO = @CodigoFactura)

			INSERT INTO bom_desctemp (FE_CODIGO, fed_indiced, BST_HIJO, FED_CANT, ME_CODIGO, FACTCONV,
			BST_DISCH, ME_GEN, BST_INCORPOR,  bst_nivel, bst_tipodesc, BST_PT,  TI_CODIGO, BST_TIPOCOSTO)

			SELECT     @CodigoFactura, @fed_indiced, MA_HIJO, 1, ME_COM, EQ_GEN, MA_DISCHARGE, ME_GEN, Cantidad,
			'EP', 'N', 0, 'E', 'Z'
			FROM         dbo.VDESCEMPAQUEPESTANA
			WHERE FE_CODIGO = @CodigoFactura and MA_GENERA_EMP in ('R', 'T')

		end


GO
