SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VIEW1
with encryption as
SELECT     CONVERT(varchar(2), RIGHT(YEAR(PEDIMP_1.PI_FEC_PAG), 2)) 
                      + ' ' + + dbo.ADUANA.AD_CLAVE collate database_default + ' ' + dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + ' ' + PEDIMP_1.PI_FOLIO collate database_default AS PEDIMENTOANT, PEDIMP_1.PI_FEC_PAG, 
                      dbo.PEDIMP.PI_CODIGO, dbo.CLAVEPED.CP_CLAVE
FROM         dbo.PEDIMP INNER JOIN
                      dbo.PEDIMP PEDIMP_1 ON dbo.PEDIMP.PI_RECTIFICA = PEDIMP_1.PI_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED ON PEDIMP_1.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON PEDIMP_1.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.ADUANA ON PEDIMP_1.AD_DES = dbo.ADUANA.AD_CODIGO



GO
