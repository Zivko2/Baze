SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















































CREATE VIEW dbo.VTRANSFEREP
with encryption as
SELECT     dbo.FACTEXPAGRU.FEA_CODIGO, dbo.FACTEXPAGRU.FEA_FOLIO, dbo.FACTEXPAGRU.FEA_FECHA, dbo.FACTEXPAGRU.FEA_PINICIAL, 
                      dbo.FACTEXPAGRU.FEA_TIPOTRANS, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXPAGRU.CL_DESTINI, dbo.FACTEXPAGRU.DI_DESTINI, 
                      dbo.FACTEXPAGRU.CL_PROD, dbo.FACTEXPAGRU.DI_PROD,  'PI_CODIGO'=CASE WHEN dbo.FACTEXP.PI_RECTIFICA<>-1
THEN dbo.FACTEXP.PI_RECTIFICA ELSE dbo.FACTEXP.PI_CODIGO END
FROM         dbo.FACTEXPAGRU LEFT OUTER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPAGRU.FEA_CODIGO = dbo.FACTEXP.FE_FACTAGRU






























































GO
