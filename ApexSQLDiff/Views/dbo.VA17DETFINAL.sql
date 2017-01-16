SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VA17DETFINAL
with encryption as
SELECT     A17_CODIGO, MIN(MA_GENERICO) AS MA_GENERICO, CL_CODIGO, SUM(A17D_VALORTRANS) AS A17D_VALORTRANS, 
                      SUM(A17D_VALORADQ0) AS A17D_VALORADQ0, SUM(A17D_PROPORCION) AS A17D_PROPORCION
FROM         dbo.A17DET
GROUP BY  A17_CODIGO, CL_CODIGO


GO
