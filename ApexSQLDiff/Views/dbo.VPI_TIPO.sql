SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW dbo.VPI_TIPO
with encryption as
SELECT     CB_KEYFIELD, CB_LOOKUP
FROM         dbo.COMBOBOXES
WHERE     (CB_FIELD = 'PI_TIPO') AND (CB_TABLA = 60)





GO
