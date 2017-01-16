SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE VIEW dbo.VARANCELPEDIMP
with encryption as
SELECT AR_CODIGO, AR_FRACCION, PA_CODIGO
FROM ARANCEL
WHERE (dbo.ARANCEL.AR_TIPOREG<>'C')


























GO
