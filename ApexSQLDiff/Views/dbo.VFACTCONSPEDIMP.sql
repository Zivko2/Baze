SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VFACTCONSPEDIMP
with encryption as
SELECT     F.FC_CODIGO, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + F.FC_FOLIO collate database_default AS agencia_folio, F.FC_SEM, F.CP_CODIGO, F.FC_INI, F.FC_FIN, F.FC_TIPO, 
                      C.CP_CLAVE
FROM         dbo.FACTCONS F LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON F.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.VPEDIMP ON F.FC_CODIGO = dbo.VPEDIMP.FC_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED C ON F.CP_CODIGO = C.CP_CODIGO
WHERE     (F.FC_TIPO = 'E') AND (dbo.VPEDIMP.FC_CODIGO IS NULL)





































































GO
