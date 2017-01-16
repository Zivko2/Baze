SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



























CREATE PROCEDURE dbo.[temp_actualizadecimal]   as




UPDATE MAESTROCOST
SET     MAESTROCOST.MA_COSTO= 
                      MAESTROCOST.MA_GRAV_MP + MAESTROCOST.MA_GRAV_ADD + MAESTROCOST.MA_GRAV_EMP + MAESTROCOST.MA_GRAV_GI + MAESTROCOST.MA_GRAV_GI_MX
                       + MAESTROCOST.MA_GRAV_MO + MAESTROCOST.MA_NG_MP + MAESTROCOST.MA_NG_ADD + MAESTROCOST.MA_NG_EMP
FROM         MAESTRO INNER JOIN
                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
WHERE     (MAESTRO.TI_CODIGO = 14) OR
                      (MAESTRO.TI_CODIGO = 16)



























GO
