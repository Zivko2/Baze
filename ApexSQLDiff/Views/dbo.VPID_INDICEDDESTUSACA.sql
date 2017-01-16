SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.VPID_INDICEDDESTUSACA
with encryption as
SELECT     dbo.PEDIMPDET.PID_INDICED
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.KARDESPED ON dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_PED INNER JOIN
                      dbo.VFACTEXPDETliga ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.VFACTEXPDETliga.FED_INDICED INNER JOIN
                      dbo.PEDIMPDET PEDIMPDET_1 ON dbo.VFACTEXPDETliga.PID_INDICEDLIGA = PEDIMPDET_1.PID_INDICED
WHERE     (PEDIMPDET_1.PA_ORIGEN = 233) OR
                      (PEDIMPDET_1.PA_ORIGEN = 35)
GROUP BY dbo.PEDIMPDET.PID_INDICED

































GO
