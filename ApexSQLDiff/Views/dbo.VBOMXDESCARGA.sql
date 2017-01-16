SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE VIEW dbo.VBOMXDESCARGA
with encryption as
SELECT     dbo.KARDESPED.KAP_FACTRANS, round(dbo.KARDESPED.KAP_CantTotADescargar / dbo.FACTEXPDET.FED_CANT,6) AS INCORPOR, 
                      'ME_CORTO' = CASE WHEN dbo.MEDIDA.ME_CORTO IS NOT NULL THEN dbo.MEDIDA.ME_CORTO ELSE MEDIDA_1.ME_CORTO END, 
                      dbo.KARDESPED.KAP_INDICED_FACT, dbo.KARDESPED.MA_HIJO
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 LEFT OUTER JOIN
                      dbo.MEDIDA MEDIDA_1 ON MAESTRO_1.ME_COM = MEDIDA_1.ME_CODIGO ON 
                      dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO RIGHT OUTER JOIN
                      dbo.KARDESPED ON dbo.MAESTRO.MA_CODIGO = dbo.KARDESPED.MA_HIJO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED LEFT OUTER JOIN
                      dbo.MEDIDA RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.MEDIDA.ME_CODIGO = dbo.PEDIMPDET.ME_GENERICO ON 
                      dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
WHERE     (dbo.FACTEXPDET.FED_RETRABAJO = 'N' OR
                      dbo.FACTEXPDET.FED_RETRABAJO = 'D') AND (dbo.KARDESPED.KAP_CantTotADescargar / dbo.FACTEXPDET.FED_CANT IS NOT NULL)
GROUP BY dbo.KARDESPED.KAP_FACTRANS, dbo.KARDESPED.KAP_INDICED_FACT, dbo.KARDESPED.KAP_CantTotADescargar, dbo.FACTEXPDET.FED_CANT, 
                      dbo.MEDIDA.ME_CORTO, MEDIDA_1.ME_CORTO, dbo.KARDESPED.MA_HIJO
UNION
SELECT     dbo.KARDESPED.KAP_FACTRANS, round(dbo.KARDESPED.KAP_CantTotADescargar,6) AS INCORPOR, 
                      'ME_CORTO' = CASE WHEN dbo.MEDIDA.ME_CORTO IS NOT NULL THEN dbo.MEDIDA.ME_CORTO ELSE MEDIDA_1.ME_CORTO END, 
                      dbo.KARDESPED.KAP_INDICED_FACT, dbo.KARDESPED.MA_HIJO
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 LEFT OUTER JOIN
                      dbo.MEDIDA MEDIDA_1 ON MAESTRO_1.ME_COM = MEDIDA_1.ME_CODIGO ON 
                      dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO RIGHT OUTER JOIN
                      dbo.KARDESPED ON dbo.MAESTRO.MA_CODIGO = dbo.KARDESPED.MA_HIJO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED LEFT OUTER JOIN
                      dbo.MEDIDA RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.MEDIDA.ME_CODIGO = dbo.PEDIMPDET.ME_GENERICO ON 
                      dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
WHERE     (dbo.FACTEXPDET.FED_RETRABAJO <> 'N' AND dbo.FACTEXPDET.FED_RETRABAJO <> 'D') AND (dbo.KARDESPED.KAP_CantTotADescargar IS NOT NULL)
GROUP BY dbo.KARDESPED.KAP_FACTRANS, dbo.KARDESPED.KAP_INDICED_FACT, dbo.KARDESPED.KAP_CantTotADescargar, dbo.FACTEXPDET.FED_CANT, 
                      dbo.MEDIDA.ME_CORTO, MEDIDA_1.ME_CORTO, dbo.KARDESPED.MA_HIJO








































GO
