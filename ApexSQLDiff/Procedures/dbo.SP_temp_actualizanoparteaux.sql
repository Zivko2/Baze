SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_actualizanoparteaux]   as

SET NOCOUNT ON 

print 'actualizando pid_pagacontribucion'
	EXEC SP_ACTUALIZAPI_PAGACONTRIBALL

print 'actualizando factura exportacion'
UPDATE dbo.FACTEXPDET
SET     dbo.FACTEXPDET.FED_NOPARTEAUX= isnull(dbo.MAESTRO.MA_NOPARTEAUX,'')
FROM         dbo.FACTEXPDET INNER JOIN
                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO

print 'actualizando factura importacion'
UPDATE dbo.FACTIMPDET
SET     dbo.FACTIMPDET.FID_NOPARTEAUX= isnull(dbo.MAESTRO.MA_NOPARTEAUX,'')
FROM         dbo.FACTIMPDET INNER JOIN
                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO

print 'actualizando pedimento'
UPDATE dbo.PEDIMPDET
SET     dbo.PEDIMPDET.PID_NOPARTEAUX= isnull(dbo.MAESTRO.MA_NOPARTEAUX,'')
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO

print 'actualizando lista entrada'
UPDATE dbo.PCKLISTDET
SET     dbo.PCKLISTDET.PLD_NOPARTEAUX= isnull(dbo.MAESTRO.MA_NOPARTEAUX,'')
FROM         dbo.PCKLISTDET INNER JOIN
                      dbo.MAESTRO ON dbo.PCKLISTDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO

print 'actualizando lista salida'
UPDATE dbo.LISTAEXPDET
SET     dbo.LISTAEXPDET.LED_NOPARTEAUX= isnull(dbo.MAESTRO.MA_NOPARTEAUX,'')
FROM         dbo.LISTAEXPDET INNER JOIN
                      dbo.MAESTRO ON dbo.LISTAEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO



























GO
