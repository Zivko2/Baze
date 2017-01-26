SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ESTATUSKARDESPEDnullAll]   as

SET NOCOUNT ON 
declare @kap_codigo int
	exec sp_droptable 'estatuskap'
	SELECT     dbo.KARDESPED.KAP_CODIGO
	INTO dbo.estatuskap
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.KARDESPED ON dbo.FACTEXP.FE_CODIGO = dbo.KARDESPED.KAP_FACTRANS
	WHERE    KAP_ESTATUS IS NULL

declare cur_estatusdescargapost cursor for
	SELECT     KAP_CODIGO
	FROM       estatuskap
	ORDER BY KAP_CODIGO
Open cur_estatusdescargapost

	FETCH NEXT FROM cur_estatusdescargapost INTO @kap_codigo
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	exec SP_ESTATUSKARDESPEDwo @kap_codigo

	FETCH NEXT FROM cur_estatusdescargapost INTO @kap_codigo
END
CLOSE cur_estatusdescargapost
DEALLOCATE cur_estatusdescargapost
	exec sp_droptable 'estatuskap'

GO
