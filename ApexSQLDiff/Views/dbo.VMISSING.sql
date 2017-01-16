SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VMISSING
with encryption as
SELECT     TOP 100 PERCENT MI_CODIGO, MI_CLAVE, MI_NOMBRE, MI_NAME
FROM         dbo.MISING
ORDER BY MI_CLAVE






































GO
