SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VPAGOCONTRIBPERIODO
with encryption as
SELECT     PI_CODIGO, min(PI_FEC_PAG + 60) AS KAP_FECHAPEDmin, ISNULL(MAX(PI_FECHAPAGO), (convert(varchar(10),getdate(),101))) as KAP_FECHAPEDmax
FROM dbo.PEDIMP PEDIMP_2
GROUP BY PI_CODIGO

/*CONVERT(DATETIME, DATEDIFF(dd, datepart(dd,dbo.PEDIMP.PI_FEC_PAG + 60)-1, dbo.PEDIMP.PI_FEC_PAG + 60)) 1er dia*/




















GO
