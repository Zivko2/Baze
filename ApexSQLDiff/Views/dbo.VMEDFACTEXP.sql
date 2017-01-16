SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
















































CREATE VIEW dbo.VMEDFACTEXP
with encryption as
SELECT ME_CODIGO,  FED_INDICED
FROM FACTEXPDET
union
SELECT     ME_COM, 0
FROM         dbo.MAESTRO
union
SELECT     ME_KILOGRAMOS, 0
FROM         dbo.CONFIGURACION































































GO
