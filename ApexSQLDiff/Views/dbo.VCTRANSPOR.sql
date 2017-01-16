SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VCTRANSPOR
with encryption as
SELECT     TOP 100 PERCENT CT_CODIGO, CT_NOMBRE, CT_RFC, CT_CURP, CT_SCAC
FROM         dbo.CTRANSPOR
ORDER BY CT_NOMBRE




































GO
