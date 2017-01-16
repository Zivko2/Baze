SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_CreaVMAESTROCOST1tlc] (@nft_fecha varchar(50))   as

declare @nft_fechavigor varchar(11)

exec sp_droptable 'VMAESTROCOST1tlc', 'V'

select @nft_fechavigor=convert(varchar(11),@nft_fecha,101)

exec('CREATE VIEW dbo.VMAESTROCOST1tlc
with encryption as
SELECT     dbo.MAESTROCOST.MAC_CODIGO, dbo.MAESTROCOST.TCO_CODIGO, dbo.MAESTROCOST.MA_CODIGO, dbo.MAESTROCOST.MA_GRAV_MP, dbo.MAESTROCOST.MA_GRAV_ADD, 
                      dbo.MAESTROCOST.MA_GRAV_EMP, dbo.MAESTROCOST.MA_GRAV_GI, dbo.MAESTROCOST.MA_GRAV_GI_MX, dbo.MAESTROCOST.MA_GRAV_MO, 
                      dbo.MAESTROCOST.MA_NG_MP, dbo.MAESTROCOST.MA_NG_ADD, dbo.MAESTROCOST.MA_NG_EMP, dbo.MAESTROCOST.MA_COSTO, 
                      dbo.MAESTROCOST.MA_GRAVA_VA, dbo.MAESTROCOST.MA_NG_USA, dbo.MAESTROCOST.MA_NG_MX, dbo.MAESTROCOST.TV_CODIGO, 
                      ISNULL(dbo.MAESTRO.MA_NOPARTE,dbo.MAESTROREFER.MA_NOPARTE) AS MA_NOPARTE, ISNULL(dbo.MAESTRO.MA_NOPARTEAUX,
		      dbo.MAESTROREFER.MA_NOPARTEAUX) AS MA_NOPARTEAUX, dbo.MAESTROCOST.SPI_CODIGO, ISNULL(dbo.MAESTRO.EQ_GEN,
		      dbo.MAESTROREFER.EQ_GEN) EQ_GEN
FROM         dbo.MAESTROREFER LEFT OUTER JOIN
                      dbo.CONFIGURATIPO CONFIGURATIPO_1 ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPO_1.TI_CODIGO RIGHT OUTER JOIN
                      dbo.MAESTROCOST ON dbo.MAESTROREFER.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
                      dbo.MAESTRO ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.MAESTRO.TI_CODIGO ON 
                      dbo.MAESTROCOST.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
WHERE     ((((dbo.CONFIGURATIPO.CFT_TIPO <> ''P'' AND dbo.CONFIGURATIPO.CFT_TIPO <> ''S'') OR dbo.MAESTRO.MA_TIP_ENS = ''C'') 
	AND dbo.MAESTROCOST.TCO_CODIGO IN (SELECT TCO_COMPRA FROM CONFIGURACION)) 
	OR
	(((dbo.CONFIGURATIPO.CFT_TIPO = ''P'' OR dbo.CONFIGURATIPO.CFT_TIPO = ''S'') OR (dbo.MAESTRO.MA_TIP_ENS <> ''C'' AND dbo.MAESTRO.MA_TIP_ENS <> ''A'')) 
	AND dbo.MAESTROCOST.TCO_CODIGO IN (SELECT TCO_MANUFACTURA FROM CONFIGURACION))
	OR
	((dbo.MAESTRO.MA_TIP_ENS = ''A'') 
	AND dbo.MAESTROCOST.TCO_CODIGO IN (SELECT TCO_COMPRA FROM CONFIGURACION))) 
	
	AND (ISNULL(dbo.MAESTRO.MA_INV_GEN,''I'') = ''I'') AND (dbo.MAESTROCOST.MA_PERINI <= '''+@nft_fechavigor+''')
	AND (dbo.MAESTROCOST.MA_PERFIN >= '''+@nft_fechavigor+''')')


GO
