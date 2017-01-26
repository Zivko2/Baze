SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ImplementaInsertcontrib]     as

SET NOCOUNT ON 

DECLARE @PI_CODIGO int, @CON_CODIGO smallint, @PIT_CONTRIBPOR decimal(38,6), @PIT_CONTRIBAPLICA decimal(38,6),
 @PIT_CONTRIBTOTMN decimal(38,6), @PG_CODIGO smallint, @TTA_CODIGO smallint

DECLARE cur_pedimpinsertcontrib CURSOR FOR
SELECT     dbo.PEDIMP.PI_CODIGO, dbo.IMPLEMENTACONTRIB.CON_CODIGO, dbo.IMPLEMENTACONTRIB.PIT_CONTRIBPOR, 
                      dbo.IMPLEMENTACONTRIB.PIT_CONTRIBAPLICA, dbo.IMPLEMENTACONTRIB.PIT_CONTRIBTOTMN, dbo.IMPLEMENTACONTRIB.PG_CODIGO, 
                      dbo.IMPLEMENTACONTRIB.TTA_CODIGO
FROM         dbo.PEDIMP LEFT OUTER JOIN
                      dbo.IMPLEMENTACONTRIB RIGHT OUTER JOIN
                      dbo.IMPLEMENTAPEDIMP ON dbo.IMPLEMENTACONTRIB.PI_CODIGOIMP = dbo.IMPLEMENTAPEDIMP.PI_CODIGOIMP ON 
                      dbo.PEDIMP.PI_FOLIO = dbo.IMPLEMENTAPEDIMP.PI_FOLIO
WHERE dbo.IMPLEMENTACONTRIB.CON_CODIGO IS NOT NULL
GROUP BY dbo.PEDIMP.PI_CODIGO, dbo.IMPLEMENTACONTRIB.CON_CODIGO, dbo.IMPLEMENTACONTRIB.PIT_CONTRIBPOR, 
                      dbo.IMPLEMENTACONTRIB.PIT_CONTRIBAPLICA, dbo.IMPLEMENTACONTRIB.PIT_CONTRIBTOTMN, dbo.IMPLEMENTACONTRIB.PG_CODIGO, 
                      dbo.IMPLEMENTACONTRIB.TTA_CODIGO

OPEN cur_pedimpinsertcontrib
FETCH NEXT FROM cur_pedimpinsertcontrib INTO @PI_CODIGO, @CON_CODIGO, @PIT_CONTRIBPOR, @PIT_CONTRIBAPLICA, @PIT_CONTRIBTOTMN, @PG_CODIGO, 
@TTA_CODIGO

WHILE (@@FETCH_STATUS = 0) 
BEGIN

	insert into PEDIMPCONTRIBUCION (PI_CODIGO, CON_CODIGO, PIT_CONTRIBPOR, PIT_CONTRIBAPLICA, 
		PIT_CONTRIBTOTMN, PG_CODIGO, TTA_CODIGO)

	Values (@PI_CODIGO, @CON_CODIGO, @PIT_CONTRIBPOR, @PIT_CONTRIBAPLICA, isnull(@PIT_CONTRIBTOTMN,0), isnull(@PG_CODIGO,1), 
	@TTA_CODIGO)

FETCH NEXT FROM cur_pedimpinsertcontrib INTO @PI_CODIGO, @CON_CODIGO, @PIT_CONTRIBPOR, @PIT_CONTRIBAPLICA, @PIT_CONTRIBTOTMN, @PG_CODIGO, 
@TTA_CODIGO


END


CLOSE cur_pedimpinsertcontrib
DEALLOCATE cur_pedimpinsertcontrib






GO
