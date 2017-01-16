SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Verifica_R1] AS
SET NOCOUNT ON 
UPDATE    PEDIMP_1
SET       PEDIMP_1.PI_NO_RECT        = PEDIMP.PI_CODIGO, 
          PEDIMP_1.PI_RECTESTATUS  = 'R', 
          PEDIMP_1.PI_ESTATUS            = 'R'
FROM         PEDIMP INNER JOIN
                      PEDIMP PEDIMP_1 ON PEDIMP.PI_RECTIFICA = PEDIMP_1.PI_CODIGO
WHERE     (PEDIMP.CP_CODIGO = 45) AND (PEDIMP.PI_MOVIMIENTO = 'S')
UPDATE PEDIMPRECT
SET   PEDIMPRECT.PI_CODIGO = PEDIMP.PI_RECTIFICA 
FROM         PEDIMP INNER JOIN
                      PEDIMPRECT ON PEDIMP.PI_CODIGO = PEDIMPRECT.PI_NO_RECT
WHERE     (PEDIMP.CP_CODIGO = 45) AND (PEDIMP.PI_MOVIMIENTO = 'S')
UPDATE PEDIMP
SET     PEDIMP.PI_RECTIFICA = PEDIMP_1.PI_CODIGO
FROM         PEDIMP INNER JOIN
                      PEDIMP PEDIMP_1 ON PEDIMP.PI_CODIGO = PEDIMP_1.PI_NO_RECT
WHERE     (PEDIMP.CP_CODIGO = 45) AND (PEDIMP.PI_MOVIMIENTO = 'S')
UPDATE PEDIMPRECT
SET     PEDIMPRECT.PI_NO_RECT = PEDIMP.PI_NO_RECT
FROM         PEDIMP INNER JOIN
                      PEDIMPRECT ON PEDIMP.PI_CODIGO = PEDIMPRECT.PI_CODIGO
WHERE     (PEDIMP.PI_MOVIMIENTO = 'S')
GO
