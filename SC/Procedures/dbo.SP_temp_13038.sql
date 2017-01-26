SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE PROCEDURE [dbo].[SP_temp_13038]   as



UPDATE PEDIMP
SET PI_MOVIMIENTO='E'
WHERE CP_CODIGO IN
(SELECT CP_CODIGO FROM CLAVEPED WHERE CP_CLAVE IN ('F4', 'F5'))

























GO
