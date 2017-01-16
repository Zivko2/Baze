SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VInvCantDebeDescGen
with encryption as
SELECT     SUM(FED_SALDOGEN) AS FED_SALDOGEN, MA_GENERICO
FROM         dbo.TEMP_INVENTARIOS 
WHERE PID_INDICED IS NOT NULL
GROUP BY MA_GENERICO
HAVING SUM(FED_SALDOGEN) >0













































GO
