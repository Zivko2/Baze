SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VCOT_TIPO
with encryption as
SELECT     CB_KEYFIELD, CB_LOOKUP
FROM         dbo.COMBOBOXES
WHERE     (CB_FIELD = 'cot_tipo') AND (CB_TABLA = 272)
























































GO
