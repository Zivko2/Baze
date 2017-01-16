SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE VIEW dbo.VPLANTILLATIPODATO
with encryption as
SELECT CB_LOOKUP,CB_LOOKUPENG, PXF_CODIGO from COMBOBOXES
INNER JOIN PLNTEXPFORMULA ON PXF_DATATYPE = CB_KEYFIELD AND CB_TABLA = 282 AND CB_FIELD = 'PXF_DATATYPE'






























GO
