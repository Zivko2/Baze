SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VR1ANTERIOR
with encryption as
SELECT     PI_CODIGO, MAX(R1H_FECHAPAGO) AS R1H_FECHAPAGO,
                          (SELECT     VR1ANTERIOR1A.CP_CODIGO
                            FROM          VR1ANTERIOR1 VR1ANTERIOR1A
                            WHERE      VR1ANTERIOR1A.PI_CODIGO = VR1ANTERIOR1.PI_CODIGO AND 
                                                   VR1ANTERIOR1A.R1H_FECHAPAGO = MAX(VR1ANTERIOR1.R1H_FECHAPAGO)) AS CP_CODIGO,
                          (SELECT     VR1ANTERIOR1B.R1H_PEDIMENTOR1ANT
                            FROM          VR1ANTERIOR1 VR1ANTERIOR1B
                            WHERE      VR1ANTERIOR1B.PI_CODIGO = VR1ANTERIOR1.PI_CODIGO AND 
                                                   VR1ANTERIOR1B.R1H_FECHAPAGO = MAX(VR1ANTERIOR1.R1H_FECHAPAGO)) AS R1H_PEDIMENTOR1ANT,
                          (SELECT     VR1ANTERIOR1C.AGT_PATENTE
                            FROM          VR1ANTERIOR1 VR1ANTERIOR1C
                            WHERE      VR1ANTERIOR1C.PI_CODIGO = VR1ANTERIOR1.PI_CODIGO AND 
                                                   VR1ANTERIOR1C.R1H_FECHAPAGO = MAX(VR1ANTERIOR1.R1H_FECHAPAGO)) AS AGT_PATENTE
FROM         VR1ANTERIOR1
GROUP BY PI_CODIGO














GO
