SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.vINVENTARIO_NOPARTE
with encryption as
SELECT     MA_CODIGO, NOPARTE, END_SALDOGEN
FROM         dbo.TEMP_INVENTARIOS
GROUP BY MA_CODIGO, NOPARTE, END_SALDOGEN

GO
