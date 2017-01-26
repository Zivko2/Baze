SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ESTATUSKARDESPEDPostAll](@fechaini varchar(10)='01/01/1900', @fechafin varchar(10)='01/01/9999')   as

SET NOCOUNT ON 
declare @kap_codigo int
	if @fechaini='01/01/1900'
	select @fechaini= convert(varchar(11),min(fe_fecha),101) from factexp where fe_codigo in (select kap_factrans from kardesped group by kap_factrans)
	if @fechafin='01/01/9999'
	select @fechafin= convert(varchar(11),max(fe_fecha),101) from factexp where fe_codigo in (select kap_factrans from kardesped group by kap_factrans)
	exec sp_droptable 'estatuskap'
	SELECT     dbo.KARDESPED.KAP_CODIGO
	into dbo.estatuskap
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.KARDESPED ON dbo.FACTEXP.FE_CODIGO = dbo.KARDESPED.KAP_FACTRANS
	WHERE     dbo.FACTEXP.FE_FECHA >= @fechaini AND dbo.FACTEXP.FE_FECHA <= @fechafin
declare cur_estatusdescargapost cursor for
	SELECT     KAP_CODIGO
	FROM        estatuskap
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
