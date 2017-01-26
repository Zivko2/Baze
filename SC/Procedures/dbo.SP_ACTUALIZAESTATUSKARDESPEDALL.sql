SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO














CREATE PROCEDURE [SP_ACTUALIZAESTATUSKARDESPEDALL] AS
SET NOCOUNT ON 

declare @kapcodigo int, @fecha datetime

declare cur_actualizaestatuskardesped cursor for
	SELECT     KAP_CODIGO
	FROM         KARDESPED LEFT OUTER JOIN
	FACTEXP ON FACTEXP.FE_CODIGO=KARDESPED.KAP_FACTRANS
	ORDER BY FE_FECHADESCARGA, KAP_CODIGO
open cur_actualizaestatuskardesped


	FETCH NEXT FROM cur_actualizaestatuskardesped INTO @kapcodigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @fecha=fe_fecha from factexp where fe_codigo
	in (select kap_indiced_fact from kardesped where kap_codigo=@kapcodigo)

	print '<==========' + convert(varchar(50), @kapcodigo) + + convert(varchar(50), @fecha) + '==========>' 

	EXEC SP_ESTATUSKARDESPED @kapcodigo


	FETCH NEXT FROM cur_actualizaestatuskardesped INTO @kapcodigo

END

CLOSE cur_actualizaestatuskardesped
DEALLOCATE cur_actualizaestatuskardesped








GO
