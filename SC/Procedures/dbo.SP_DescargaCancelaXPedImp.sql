SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























/* procedimiento que cancela las descargas de las facturas de exportacion que afectaron un pedimento
que se desea liberar, se le pasa como parametro el codigo del pedimento de importacion*/
CREATE PROCEDURE [dbo].[SP_DescargaCancelaXPedImp]  (@pi_codigo int)   as

SET NOCOUNT ON 

declare @fe_codigo int

declare cur_CancelaXpedimp cursor for
SELECT     TOP 100 PERCENT dbo.KARDESPED.KAP_FACTRANS
FROM         dbo.KARDESPED INNER JOIN
                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED INNER JOIN
                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
GROUP BY dbo.KARDESPED.KAP_FACTRANS, dbo.FACTEXP.FE_FECHADESCARGA
ORDER BY dbo.KARDESPED.KAP_FACTRANS, dbo.FACTEXP.FE_FECHADESCARGA




open cur_CancelaXpedimp


	FETCH NEXT FROM cur_CancelaXpedimp INTO @fe_codigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	EXEC sp_DescargaCancela @fe_codigo


	FETCH NEXT FROM cur_CancelaXpedimp INTO @fe_codigo

END

CLOSE cur_CancelaXpedimp
DEALLOCATE cur_CancelaXpedimp



























GO
