SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














































CREATE VIEW dbo.VDOCFACTCOM
with encryption as
SELECT     dbo.COMMINV.IV_CODIGO, dbo.COMMINV.IV_FOLIO, dbo.COMMINV.IV_FECHA, dbo.COMMINV.IV_TIPOFACT, dbo.COMMINV.CL_CODIGO, 
                      dbo.COMMINV.ET_CODIGO, dbo.COMMINV.FE_CODIGO, dbo.CLIENTE.CL_RAZON, InTradeGlobal.dbo.sysusrlst.sysusrlst_id
FROM         dbo.COMMINV INNER JOIN
                      InTradeGlobal.dbo.sysusrlst ON dbo.COMMINV.IV_FECHA >= GETDATE() - InTradeGlobal.dbo.sysusrlst.cf_aniossys * 365 LEFT OUTER JOIN
                      dbo.FACTEXP ON dbo.COMMINV.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      dbo.CLIENTE ON dbo.COMMINV.CL_CODIGO = dbo.CLIENTE.CL_CODIGO
WHERE     (dbo.FACTEXP.FE_TIPO = 'F')














































GO
