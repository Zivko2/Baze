SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
















































CREATE VIEW dbo.VMAESTROVIEW
with encryption as
SELECT MA_CODIGO, MA_NOPARTE, MA_NOMBRE, MA_NAME, 
    TI_CODIGO, MA_INV_GEN, MA_GENERICO
FROM MAESTRO
WHERE (MA_EST_MAT = 'A') AND (MA_OCULTO='N')



































































GO
