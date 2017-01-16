SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.VREPEXPNACIONAL
with encryption as
SELECT     dbo.REPEXPUSACA.RUC_CODIGO, dbo.CONFIGURATIPO.CFT_TIPO, MAESTRO_1.MA_NOMBRE, dbo.KARDESPED.KAP_CANTDESC, 
                      dbo.ARANCEL.AR_FRACCION
FROM         dbo.KARDESPED INNER JOIN
                      dbo.REPEXPUSACA INNER JOIN
                      dbo.FACTCONS ON dbo.REPEXPUSACA.RUC_PERINI <= dbo.FACTCONS.FC_FECHA AND 
                      dbo.REPEXPUSACA.RUC_PERFIN >= dbo.FACTCONS.FC_FECHA INNER JOIN
                      dbo.FACTEXP ON dbo.FACTCONS.FC_CODIGO = dbo.FACTEXP.FC_CODIGO ON 
                      dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      dbo.VPEDIMP RIGHT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.PEDIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO ON dbo.VPEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO ON 
                      dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED AND 
                      dbo.REPEXPUSACA.CL_TRANSFIERE = dbo.VPEDIMP.PR_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO1 RIGHT OUTER JOIN
                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.CONFIGURATIPO.TI_CODIGO = MAESTRO_1.TI_CODIGO ON 
                      MAESTRO1.MA_CODIGO = MAESTRO_1.MA_GENERICO ON dbo.KARDESPED.MA_HIJO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.FACTCONS.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO
WHERE     (dbo.CLAVEPED.CP_CLAVE = 'F4')


































































GO
