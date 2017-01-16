SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VFE_DESTINO
with encryption as
SELECT     CB_FIELD, CB_KEYFIELD, CB_LOOKUP, CB_LOOKUPENG
FROM         dbo.COMBOBOXES
WHERE     (CB_FIELD = 'FE_DESTINO') AND (CB_TABLA = 62)





































GO
