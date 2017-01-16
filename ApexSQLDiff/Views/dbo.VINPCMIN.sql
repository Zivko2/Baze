SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VINPCMIN
with encryption as
SELECT     INPCMIN1.IN_FECINI, INPCMIN1.PI_CODIGO, MAX(dbo.INPC.IN_CANT) AS IN_CANT, dbo.INPC.IN_MES
FROM         (SELECT dbo.VPAGOCONTRIBPERIODO.PI_CODIGO, MAX(dbo.INPC.IN_FECINI) AS IN_FECINI
FROM  dbo.INPC INNER JOIN
               dbo.VPAGOCONTRIBPERIODO ON dbo.INPC.IN_FECINI <= DATEADD(mm, -1, dbo.VPAGOCONTRIBPERIODO.KAP_FECHAPEDmin)  
GROUP BY dbo.VPAGOCONTRIBPERIODO.PI_CODIGO) INPCMIN1 INNER JOIN
                      dbo.INPC ON INPCMIN1.IN_FECINI = dbo.INPC.IN_FECINI
GROUP BY INPCMIN1.IN_FECINI, INPCMIN1.PI_CODIGO, dbo.INPC.IN_MES














GO
