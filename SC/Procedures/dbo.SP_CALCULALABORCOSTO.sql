SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* calcula los costos del los subensambles en orden ascendente es decir del 12 al 1 */
CREATE PROCEDURE [dbo].[SP_CALCULALABORCOSTO]  (@bst_pt int, @Entravigor datetime, @spi_codigo int =22)   as

SET NOCOUNT ON 
declare @fecha varchar(10), @nivelmax int, @ConsCal int

SET @Fecha =convert(varchar(10), @Entravigor,102)


	--EXEC SP_FILL_BOMRep @BST_PT, @Fecha
	exec SP_FILL_TempBOMNivel @BST_PT, @Fecha


	EXEC SP_CALCULALABORCOSTO2 @BST_PT, @spi_codigo /* se actualizan los subensambles y el pt que tienen subensambles dentro */


GO
