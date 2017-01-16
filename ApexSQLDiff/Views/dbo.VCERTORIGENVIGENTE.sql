SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE VIEW dbo.VCERTORIGENVIGENTE
with encryption as
SELECT     dbo.CERTORIGMPDET.PA_CLASE, dbo.CERTORIGMPDET.CMP_FABRICA, dbo.CERTORIGMPDET.CMP_CRITERIO, 
                      dbo.CERTORIGMPDET.CMP_NETCOST, dbo.CERTORIGMPDET.CMP_OTRASINST, dbo.CERTORIGMP.CMP_FOLIO, dbo.CERTORIGMP.CMP_IFECHA, 
                      dbo.CERTORIGMP.CMP_VFECHA, dbo.CERTORIGMP.SPI_CODIGO, dbo.CERTORIGMP.CMP_CODIGO, dbo.CERTORIGMPDET.MA_CODIGO
FROM         dbo.CERTORIGMP INNER JOIN
                      dbo.CERTORIGMPDET ON dbo.CERTORIGMP.CMP_CODIGO = dbo.CERTORIGMPDET.CMP_CODIGO
WHERE     (dbo.CERTORIGMP.SPI_CODIGO IN
                          (SELECT     spi_codigo
                            FROM          spi
                            WHERE      spi_clave = 'nafta')) AND (dbo.CERTORIGMP.CMP_IFECHA <= GETDATE()) AND (dbo.CERTORIGMP.CMP_VFECHA >= GETDATE()) AND 
                      (dbo.CERTORIGMP.CMP_IFECHA IN
                          (SELECT     MAX(CERTORIGMP1.CMP_IFECHA)
                            FROM          CERTORIGMP CERTORIGMP1 INNER JOIN
                                                   CERTORIGMPDET CERTORIGMPDET1 ON CERTORIGMP1.CMP_CODIGO = CERTORIGMPDET1.CMP_CODIGO
                            WHERE      CERTORIGMPDET1.MA_CODIGO = CERTORIGMPDET.MA_CODIGO))
AND dbo.CERTORIGMP.CMP_ESTATUS='V' 

































GO
