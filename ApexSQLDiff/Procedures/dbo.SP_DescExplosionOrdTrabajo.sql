SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE [dbo].[SP_DescExplosionOrdTrabajo] (@CodigoFactura Int)   as

SET NOCOUNT ON 
declare @FED_INDICED INT, @BST_PT INT, @FED_CANT decimal(38,6), @FED_FECHA_STRUCT DATETIME, @countbom int

/* se corren los stored para cada uno de los pt o sub del detalle de la factura*/


declare CUR_DETALLEFACTPT cursor for
-- selecciona Producto Terminados o Subensambles para esa Factura
SELECT     dbo.ORDTRABAJODET.OTD_INDICED, dbo.ORDTRABAJODET.MA_CODIGO, dbo.ORDTRABAJODET.OTD_SIZELOTE
FROM         dbo.ORDTRABAJODET 
WHERE     (dbo.ORDTRABAJODET.OTD_SIZELOTE > 0)  --  AND dbo.ORDTRABAJODET.OTD_DESCARGADO='N'
AND (dbo.ORDTRABAJODET.OT_CODIGO = @CodigoFactura)
ORDER BY dbo.ORDTRABAJODET.MA_CODIGO 

 OPEN CUR_DETALLEFACTPT

  FETCH NEXT FROM CUR_DETALLEFACTPT
	INTO @FED_INDICED, @BST_PT, @FED_CANT

  WHILE (@@fetch_status = 0) 
  BEGIN  

	SET @FED_FECHA_STRUCT = convert(datetime, convert(varchar(11), getdate(),101))			

	select @countbom = count(*) from bom_struct where  bsu_subensamble=@BST_PT and bst_perini<=@FED_FECHA_STRUCT and bst_perfin>=@FED_FECHA_STRUCT

	if exists(select * from TempImpOrdTrabajo where otd_indiced=@FED_INDICED)
	delete from TempImpOrdTrabajo where otd_indiced=@FED_INDICED

	if @countbom >0
	EXEC SP_FILL_TempImpOrdTrabajo @FED_INDICED, @BST_PT, @FED_FECHA_STRUCT, @FED_CANT, @CODIGOFACTURA

	FETCH NEXT FROM CUR_DETALLEFACTPT INTO @FED_INDICED, @BST_PT, @FED_CANT

END

	CLOSE CUR_DETALLEFACTPT
	DEALLOCATE CUR_DETALLEFACTPT





















GO
