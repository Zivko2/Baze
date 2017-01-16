SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VTLCANALISISFRAC
with encryption as
-- Esta consulta se comento ya que la parte donde usa el vmaestrocost no deberia realizarlo
-- ya que solo es para cuando sean no originarios y sin salto arancelario. 06-Nov-09 Manuel G.
/*SELECT     dbo.MAESTRO.MA_CODIGO AS BST_PT,  NAFTA.NFT_CODIGO, 'COSTO'=CASE WHEN 
isnull((SELECT     SUM(BST_MATNOORIG)
                              FROM         CLASIFICATLC 
                              WHERE    NFT_CODIGO=NAFTA.NFT_CODIGO AND
			(BST_APLICAREGLA = -1) AND (BST_TIPOORIG = 'N')),0)<=0
THEN 
isnull((SELECT MA_COSTO FROM VMAESTROCOST WHERE MA_CODIGO=MAESTRO.MA_CODIGO AND TCO_CODIGO IN (SELECT TCO_MANUFACTURA FROM dbo.CONFIGURACION)),0)
WHEN 
isnull((SELECT     SUM(BST_MATNOORIG)
                              FROM         CLASIFICATLC 
                              WHERE    NFT_CODIGO=NAFTA.NFT_CODIGO
			AND (BST_APLICAREGLA =-1) AND (BST_TIPOORIG = 'N')),0)>0
THEN 
(SELECT     SUM(BST_MATNOORIG)
                              FROM         CLASIFICATLC 
                              WHERE    NFT_CODIGO=NAFTA.NFT_CODIGO
			AND (dbo.CLASIFICATLC.BST_APLICAREGLA =-1) AND (dbo.CLASIFICATLC.BST_TIPOORIG = 'N'))
END, NAFTA.SPI_CODIGO
FROM         dbo.MAESTRO inner join nafta on maestro.ma_codigo=nafta.ma_codigo
WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P' OR CFT_TIPO='S')*/


SELECT     dbo.MAESTRO.MA_CODIGO AS BST_PT,  NAFTA.NFT_CODIGO,
isnull((SELECT     SUM(BST_MATNOORIG)
                              FROM         CLASIFICATLC 
                              WHERE    NFT_CODIGO=NAFTA.NFT_CODIGO
			AND (BST_APLICAREGLA =-1) AND (BST_TIPOORIG = 'N')),0) COSTO, NAFTA.SPI_CODIGO
FROM         dbo.MAESTRO inner join nafta on maestro.ma_codigo=nafta.ma_codigo
WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P' OR CFT_TIPO='S')








































GO
