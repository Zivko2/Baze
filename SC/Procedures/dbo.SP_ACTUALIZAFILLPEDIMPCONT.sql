SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZAFILLPEDIMPCONT]    as

SET NOCOUNT ON 

declare @picodigo   int, @fifecha datetime, @pi_fec_pag datetime

declare cur_actualizapedimpcont cursor for
	SELECT     dbo.FACTIMP.PI_CODIGO, MAX(dbo.FACTIMP.FI_FECHA)
	FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.FACTIMPCONT ON dbo.FACTIMPDET.FID_INDICED = dbo.FACTIMPCONT.FID_INDICED INNER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
	WHERE     (dbo.FACTIMPCONT.FIC_MARCA IS NOT NULL) OR
	                      (dbo.FACTIMPCONT.FIC_MODELO IS NOT NULL) OR
	                      (dbo.FACTIMPCONT.FIC_SERIE IS NOT NULL) OR  (dbo.FACTIMPCONT.FIC_EQUIPADOCON IS NOT NULL)
	GROUP BY dbo.FACTIMP.PI_CODIGO
	ORDER BY MAX(dbo.FACTIMP.FI_FECHA)

open cur_actualizapedimpcont
	FETCH NEXT FROM cur_actualizapedimpcont INTO @picodigo, @fifecha

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 

	exec sp_fillpedimpcont @picodigo 


	FETCH NEXT FROM cur_actualizapedimpcont INTO @picodigo, @fifecha

END

CLOSE cur_actualizapedimpcont
DEALLOCATE cur_actualizapedimpcont
















































GO
