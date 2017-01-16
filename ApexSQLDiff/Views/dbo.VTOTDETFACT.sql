SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE VIEW dbo.VTOTDETFACT
with encryption as
SELECT     dbo.ENTRYSUM.ET_CODIGO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.MA_CODIGO, 
                      dbo.FACTEXPDET.TI_CODIGO, (dbo.FACTEXPDET.FED_GRA_MP + dbo.FACTEXPDET.FED_GRA_ADD) 
                      * dbo.FACTEXPDET.FED_CANT AS FED_TOT_MAT_GRA, (dbo.FACTEXPDET.FED_NG_MP + dbo.FACTEXPDET.FED_NG_ADD) 
                      * dbo.FACTEXPDET.FED_CANT AS FED_TOT_MAT_NG, dbo.FACTEXPDET.FED_GRA_EMP * dbo.FACTEXPDET.FED_CANT AS FED_TOT_EMP_GRA, 
                      dbo.FACTEXPDET.FED_NG_EMP * dbo.FACTEXPDET.FED_CANT AS FED_TOT_EMP_NG, 
                      (dbo.FACTEXPDET.FED_GRA_MO+ dbo.FACTEXPDET.FED_GRA_GI_MX) * dbo.FACTEXPDET.FED_CANT AS FED_TOT_VA_GRA 
FROM         dbo.COSTSUBPER INNER JOIN
                      dbo.ENTRYSUM INNER JOIN
                      dbo.FACTEXP ON dbo.ENTRYSUM.ET_CODIGO = dbo.FACTEXP.ET_CODIGO ON 
                      dbo.COSTSUBPER.CS_FECHAINI >= dbo.ENTRYSUM.ET_FEC_ENTRYS AND 
                      dbo.COSTSUBPER.CS_FECHAFIN <= dbo.ENTRYSUM.ET_FEC_ENTRYS LEFT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO










































































GO
