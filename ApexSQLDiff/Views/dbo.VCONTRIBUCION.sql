SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































































CREATE VIEW dbo.VCONTRIBUCION
with encryption as
SELECT     CON_CODIGO, CON_ABREVIA, CON_DESC
FROM         dbo.CONTRIBUCION




































































GO
