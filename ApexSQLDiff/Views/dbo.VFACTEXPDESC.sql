SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















































CREATE VIEW dbo.VFACTEXPDESC
with encryption as
SELECT     FE_FECHA, FE_FOLIO, FE_CODIGO AS KAP_FACTRANS, FE_TIPO, TQ_CODIGO, TF_CODIGO, FE_ESTATUS, FE_FECHADESCARGA
FROM         dbo.FACTEXP
WHERE     (FE_FECHADESCARGA IS NOT NULL)






































GO
