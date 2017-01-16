SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.V_BOMMATSUST
with encryption as
SELECT MA_CODIGO, MA_TIP_ENS, TI_CODIGO, 
   MA_NOPARTE
FROM MAESTRO
WHERE TI_CODIGO IN (SELECT TI_CODIGO 
			FROM CONFIGURATIPO WHERE 
			((CFT_TIPO = 'S') OR (CFT_TIPO = 'P')) AND 
   (MA_TIP_ENS = 'P'))






GO
