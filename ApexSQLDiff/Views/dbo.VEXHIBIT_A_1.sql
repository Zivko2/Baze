SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







/* materia prima y empaque no gravable y gravable*/
CREATE VIEW dbo.VEXHIBIT_A_1
with encryption as
SELECT     dbo.COSTSUBPER.CS_CODIGO, dbo.VEXHIBIT_A_1a.CSA_EMP_FO, dbo.VEXHIBIT_A_1a.CSA_GRAV_MAT, dbo.VEXHIBIT_A_1b.CSA_EMP_US, 
                      dbo.VEXHIBIT_A_1b.CSA_NG_MAT
FROM         dbo.COSTSUBPER LEFT OUTER JOIN
                      dbo.VEXHIBIT_A_1b ON dbo.COSTSUBPER.CS_CODIGO = dbo.VEXHIBIT_A_1b.CS_CODIGO LEFT OUTER JOIN
                      dbo.VEXHIBIT_A_1a ON dbo.COSTSUBPER.CS_CODIGO = dbo.VEXHIBIT_A_1a.CS_CODIGO
GROUP BY dbo.COSTSUBPER.CS_CODIGO, dbo.VEXHIBIT_A_1a.CSA_EMP_FO, dbo.VEXHIBIT_A_1a.CSA_GRAV_MAT, dbo.VEXHIBIT_A_1b.CSA_EMP_US, 
                      dbo.VEXHIBIT_A_1b.CSA_NG_MAT




GO
