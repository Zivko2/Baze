SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.actualizacostousa
AS
SELECT     dbo.MAESTROCOST.MA_NG_USA, dbo.BOM_ARANCEL.BA_COSTO
FROM         dbo.BOM_ARANCEL INNER JOIN
                      dbo.MAESTROCOST ON dbo.BOM_ARANCEL.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO AND 
                      dbo.BOM_ARANCEL.BA_COSTO <> dbo.MAESTROCOST.MA_NG_USA
WHERE     (dbo.BOM_ARANCEL.AR_CODIGO = 420) AND (dbo.BOM_ARANCEL.BA_TIPOCOSTO = '2')
GO
