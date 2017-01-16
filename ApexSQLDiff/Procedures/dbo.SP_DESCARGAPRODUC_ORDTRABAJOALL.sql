SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_DESCARGAPRODUC_ORDTRABAJOALL] (@pro_codigo int)   as

SET NOCOUNT ON 

declare @PRO_CODIGO1 int

	if exists (select * from PRODUCDET where PROD_CANTPEND > 0 and PRO_CODIGO=@pro_codigo)
	exec SP_DESCARGAPRODUC_ORDTRABAJO @PRO_CODIGO

	DECLARE curDescOrdTrabajo CURSOR FOR
		SELECT     dbo.PRODUC.PRO_CODIGO
		FROM         dbo.PRODUC LEFT OUTER JOIN
		                      dbo.PRODUCDET ON dbo.PRODUC.PRO_CODIGO = dbo.PRODUCDET.PRO_CODIGO
		WHERE     (dbo.PRODUCDET.PROD_CANTPEND > 0)
		GROUP BY dbo.PRODUC.PRO_CODIGO, dbo.PRODUC.PRO_FECHA
		ORDER BY dbo.PRODUC.PRO_FECHA
	OPEN curDescOrdTrabajo
	FETCH NEXT FROM curDescOrdTrabajo INTO @PRO_CODIGO1
		WHILE (@@fetch_status <> -1)
		BEGIN  --1

			exec SP_DESCARGAPRODUC_ORDTRABAJO @PRO_CODIGO1

	FETCH NEXT FROM curDescOrdTrabajo INTO @PRO_CODIGO1
	end


	CLOSE curDescOrdTrabajo
	DEALLOCATE curDescOrdTrabajo








































GO
