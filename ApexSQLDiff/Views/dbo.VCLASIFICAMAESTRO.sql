SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































































CREATE VIEW dbo.VCLASIFICAMAESTRO
with encryption as
SELECT CS_CODIGO, CS_DESC, CS_TRAT
FROM CLASIFICA
WHERE (CS_TRAT = 'M')









































































GO
