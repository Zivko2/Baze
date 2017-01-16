SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























/* cursor para todos los productos terminados que estan en el permiso */
CREATE PROCEDURE [dbo].[SP_FILLPERMISOMP]  (@pecodigo int)   as

SET NOCOUNT ON 
declare @pt int, @FechaActual varchar(10)

  SET @FechaActual = convert(varchar(10), getdate(),101)

declare cur_pt cursor for
SELECT     dbo.MAESTRO.MA_CODIGO
FROM         dbo.PERMISODET LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.PERMISODET.MA_GENERICO = dbo.MAESTRO.MA_GENERICO
WHERE     (dbo.PERMISODET.PED_REGISTROTIPO = 1) AND (dbo.PERMISODET.PED_ID_SUBORD = 0) 
	AND (dbo.PERMISODET.PE_CODIGO = @pecodigo)

open cur_pt


	FETCH NEXT FROM cur_pt INTO @pt

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	DELETE FROM TempBOM_CALCULABASE WHERE BST_PT = @pt

	EXEC SP_FILL_BOMDESCTEMPbase @pt



	FETCH NEXT FROM cur_pt INTO @pt

END

CLOSE cur_pt
DEALLOCATE cur_pt



























GO
