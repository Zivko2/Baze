SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VInvCantDescGen1
with encryption as
SELECT     round(SUM(KAP_CANTDESC),6) AS KAP_CANTDESC, KAP_PADRESUST
FROM         dbo.KARDESPED
WHERE     (KAP_FACTRANS IN
                          (SELECT     fe_codigo
                            FROM          factexp
                            WHERE      fe_fecha >= '07/01/2002' AND fe_fecha <= '02/28/2003'))
GROUP BY KAP_PADRESUST















































GO
