SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW dbo.VOT_ESTATUS
with encryption as
SELECT     CB_KEYFIELD, CB_LOOKUP
FROM         dbo.COMBOBOXES
WHERE     (CB_FIELD = 'ot_estatus') AND (CB_TABLA = 249)











GO
