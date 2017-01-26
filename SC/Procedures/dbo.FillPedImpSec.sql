SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- este proceso genera solo la secuencia de los detalles, sin generar la agrupacion saai
CREATE PROCEDURE dbo.[FillPedImpSec] (@picodigo int, @user int)   as
    set nocount on

-- en versión 2.0.0.33 se hacía la actualización en base a la secuencia definida en la agrupación SAAI
/*
   if (select PICF_AGRUPASAAISEC from PEDIMPSAAICONFIG WHERE PI_CODIGO = @picodigo) = 'N'
   begin
      UPDATE dbo.PEDIMPDET
      SET
         dbo.PEDIMPDET.PID_SECUENCIA = dbo.PEDIMPDETB.PIB_SECUENCIA
      FROM
         PEDIMPDETB INNER JOIN PEDIMPDET
            ON PEDIMPDETB.PIB_INDICEB = PEDIMPDET.PIB_INDICEB 
      WHERE
         dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
         AND  (PEDIMPDETB.PI_CODIGO = @picodigo) 
   end
   else
   begin
      UPDATE dbo.PEDIMPDET
      SET
         dbo.PEDIMPDET.PID_SECUENCIA = dbo.PEDIMPDETB.PIB_SECUENCIA
      FROM
         dbo.PEDIMPDET, dbo.PEDIMPDETB 
      WHERE
         dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO
         AND dbo.PEDIMPDETB.PI_CODIGO = @picodigo
         and dbo.PEDIMPDET.PID_SECUENCIA = dbo.PEDIMPDETB.PIB_SECUENCIA
         AND dbo.PEDIMPDET.PID_IMPRIMIR = 'S'
   end
*/

   declare @X int
   
   set @X = 0
   
   update PedImpDet
   set PID_Secuencia = @X, @X = @X + 1
   where PI_Codigo = @picodigo

GO
