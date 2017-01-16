SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VPAGOCONTRIBUCIONESFC
with encryption as
SELECT     PI_CODIGO, isnull(SUM(TOTALPT),0) AS totalpt, isnull(SUM(TOTALPTMN),0) AS totalptmn
FROM         dbo.VPAGOCONTRIBUCION
GROUP BY PI_CODIGO


GO
