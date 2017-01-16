SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE VIEW dbo.VTCAMBIOMAX
with encryption as
SELECT     INPCMAX1.PI_CODIGO, INPCMAX1.IN_FECINI, dbo.TCAMBIO.TC_CANTDOF
FROM        (SELECT dbo.VPAGOCONTRIBPERIODO.PI_CODIGO, MAX(dbo.INPC.IN_FECINI) AS IN_FECINI
	FROM  dbo.INPC INNER JOIN
	               dbo.VPAGOCONTRIBPERIODO ON dbo.INPC.IN_FECINI <= DATEADD(mm, -1, dbo.VPAGOCONTRIBPERIODO.KAP_FECHAPEDmax) 
	GROUP BY dbo.VPAGOCONTRIBPERIODO.PI_CODIGO) INPCMAX1 INNER JOIN
     dbo.TCAMBIO ON INPCMAX1.IN_FECINI = dbo.TCAMBIO.TC_FECHA













GO
