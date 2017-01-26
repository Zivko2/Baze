SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ESTATUSKARDESPEDFACT](@fe_codigo int)   as

SET NOCOUNT ON 
declare @kap_codigo int
declare cur_estatusdescarga cursor for
	SELECT     kap_codigo
	FROM         kardespedtemp
	where kap_factrans=@fe_codigo
	order by kap_codigo
open cur_estatusdescarga

	FETCH NEXT FROM cur_estatusdescarga INTO @kap_codigo
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	exec sp_estatuskardesped @kap_codigo

	FETCH NEXT FROM cur_estatusdescarga INTO @kap_codigo
END
CLOSE cur_estatusdescarga
DEALLOCATE cur_estatusdescarga
GO
