SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* hace la suma de subensamble y lo inserta a la tabla TempBomCosto */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOSUB1] (@spi_codigo int)    as

SET NOCOUNT ON 

		BEGIN TRAN
		INSERT INTO TempBomCosto (MA_CODIGO, MA_GRAV_MP, MA_GRAV_ADD, MA_GRAV_EMP, MA_GRAV_GI,
		MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP, MA_NG_ADD, MA_NG_EMP, MA_NG_USA, MA_NG_MX)
		SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, round(isnull(SUM(VMAESTROCOST.MA_GRAV_MP * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_ADD * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_EMP * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_GI * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_GI_MX * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_MO * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_MP * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_ADD * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_EMP * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_USA * BOM_STRUCT.BST_INCORPOR),0),6),
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_MX * BOM_STRUCT.BST_INCORPOR),0),6)
		FROM         BOM_STRUCT LEFT OUTER JOIN MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN 
		                      VMAESTROCOST ON BOM_STRUCT.BST_HIJO = VMAESTROCOST.MA_CODIGO INNER JOIN
		                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO INNER JOIN CalculandoCosto
				ON BOM_STRUCT.BSU_SUBENSAMBLE=CalculandoCosto.BST_PERTENECE 
		WHERE     (BOM_STRUCT.BST_PERINI <= CalculandoCosto.BST_PERINI) AND (BOM_STRUCT.BST_PERFIN >= CalculandoCosto.BST_PERINI)
			   AND VMAESTROCOST.SPI_CODIGO=@spi_codigo
		--Yolanda Avila
		--2010-10-04
		--Se agrego esta linea para que no incluya en el calculo del costo los componentes que tienen tipo de Adquisicion "FANTASMA"
		and BOM_STRUCT.bst_tip_ens <>'P'
		GROUP BY CONFIGURATIPO.CFT_TIPO, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BST_TIP_ENS, 
		                      VMAESTROCOST.TCO_CODIGO,CalculandoCosto.BST_PERINI
		HAVING      (CONFIGURATIPO.CFT_TIPO = 'S' OR
		                      CONFIGURATIPO.CFT_TIPO = 'P')

		COMMIT TRAN
GO
