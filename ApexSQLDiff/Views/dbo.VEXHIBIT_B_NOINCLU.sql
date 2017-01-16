SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VEXHIBIT_B_NOINCLU
with encryption as
SELECT     dbo.COSTSUBPER.CS_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TENVIO.TN_DESCRIP, dbo.ENTRYSUM.ET_ENTRY_NO, 
                      dbo.FACTEXP.FE_CODIGO, dbo.CLIENTE.CL_RAZON, dbo.FACTEXP.CL_DESTINI, dbo.ENTRYSUM.ET_FEC_ENTRYS
FROM         dbo.CLIENTE RIGHT OUTER JOIN
                      dbo.ENTRYSUM INNER JOIN
                      dbo.COSTSUBPER INNER JOIN
                      dbo.FACTEXP ON dbo.COSTSUBPER.CS_FECHAINI <= dbo.FACTEXP.FE_FECHA AND dbo.COSTSUBPER.CS_FECHAFIN >= dbo.FACTEXP.FE_FECHA ON 
                      dbo.ENTRYSUM.ET_CODIGO = dbo.FACTEXP.ET_CODIGO ON dbo.CLIENTE.CL_CODIGO = dbo.FACTEXP.DI_DESTINI LEFT OUTER JOIN
                      dbo.TENVIO ON dbo.FACTEXP.TN_CODIGO = dbo.TENVIO.TN_CODIGO
WHERE     (dbo.FACTEXP.FE_CANCELADO = 'N')
GROUP BY dbo.COSTSUBPER.CS_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TENVIO.TN_DESCRIP, dbo.ENTRYSUM.ET_ENTRY_NO, 
                      dbo.FACTEXP.FE_CODIGO, dbo.CLIENTE.CL_RAZON, dbo.FACTEXP.CL_DESTINI, dbo.ENTRYSUM.ET_FEC_ENTRYS
HAVING      (NOT (dbo.FACTEXP.FE_FOLIO IN
                          (SELECT     fe_folio
                            FROM          COSTSUBB_247
                            WHERE      cs_codigo = costsubper.cs_codigo)))



GO
