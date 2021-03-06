SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[SP_ROWCOUNT] (@AFFECTED INTEGER OUTPUT) AS SELECT     AGENCIAPATENTE.AGT_PATENTE AS Patente, PEDIMP.PI_FOLIO AS Folio, CLAVEPED.CP_CLAVE AS Clave, DATEPART(Year, PEDIMP.PI_FEC_ENT) AS AnoEntrada, 
                      PEDIMP.PI_FEC_ENT AS FechaEntrada, DATEPART(Year, PEDIMP.PI_FEC_PAG) AS AnoPago, PEDIMP.PI_FEC_PAG AS FechaPago, 
                      PEDIMPDET.PID_NOPARTE AS NoParte, SUM(PEDIMPDET.PID_CAN_GEN) AS CantidadGen, SUM(PEDIMPDET.PID_CTOT_DLS) AS ValorDlls, 
                      SUM(PIDescarga.PID_SALDOGEN) AS Saldo, SUM(PIDescarga.PID_SALDOGEN * PEDIMPDET.PID_COS_UNIGEN) AS ValorSaldo, 
                      PEDIMP.PI_RECTIFICA AS FolioOriginal, SUM(PIDescarga.PID_SALDOGEN * PEDIMPDET.PID_PES_UNIKG) AS PesoTotalKg, PEDIMPDET.EQ_IMPMX AS FCUMT
FROM         PEDIMP INNER JOIN
                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO RIGHT OUTER JOIN
                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
                      AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO RIGHT OUTER JOIN
                      PIDescarga ON PEDIMPDET.PI_CODIGO = PIDescarga.PI_CODIGO AND PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED
WHERE     (PEDIMP.PI_MOVIMIENTO = 'e') AND (PEDIMP.PI_RECTESTATUS <> 'R') AND (PEDIMPDET.PID_IMPRIMIR = 'S') AND (NOT (PEDIMPDET.TI_CODIGO IN (9, 18, 19))) AND
                       (NOT (PEDIMP.CP_RECTIFICA IN (26, 1, 58, 15, 113, 3))) OR
                      (PEDIMP.PI_MOVIMIENTO = 'e') AND (PEDIMP.PI_RECTESTATUS <> 'R') AND (PEDIMPDET.PID_IMPRIMIR = 'S') AND (NOT (PEDIMPDET.TI_CODIGO IN (9, 18, 19))) AND
                       (PEDIMP.CP_RECTIFICA IS NULL)
GROUP BY PEDIMP.PI_FOLIO, CLAVEPED.CP_CLAVE, PEDIMP.PI_FEC_ENT, PEDIMP.PI_FEC_PAG, AGENCIAPATENTE.AGT_PATENTE, DATEPART(Year, PEDIMP.PI_FEC_PAG), 
                      DATEPART(Year, PEDIMP.PI_FEC_ENT), PEDIMPDET.PID_NOPARTE, PEDIMP.PI_RECTIFICA, PEDIMPDET.EQ_IMPMX
HAVING      (NOT (CLAVEPED.CP_CLAVE IN ('a1', 'h3', 'bo', 'f4', 'a3', 'af'))) AND (SUM(PIDescarga.PID_SALDOGEN) > '0') OR
                      (NOT (CLAVEPED.CP_CLAVE IN ('a1', 'h3', 'bo', 'f4', 'a3', 'af'))) AND (SUM(PIDescarga.PID_SALDOGEN) > '0')
ORDER BY FechaEntrada
 SET @AFFECTED =@@ROWCOUNT
GO
