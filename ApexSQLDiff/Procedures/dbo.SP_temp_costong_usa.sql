SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_costong_usa]   as

SET NOCOUNT ON 

	UPDATE MAESTROCOST
	SET MA_NG_USA=MA_NG_MP + MA_NG_ADD
	WHERE MA_NG_USA = 0 OR MA_NG_USA IS NULL
	and ma_codigo  IN (select  ma_codigo
		from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
	and tco_codigo in (select tco_manufactura from configuracion)

	update maestrocost
	set ma_costo = isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
	isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0) 
	WHERE ma_codigo  IN (select  ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))
	and tco_codigo in (select tco_manufactura from configuracion) and
	ma_costo <> (isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
	isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0))


	UPDATE FACTEXPDET
	SET FED_NG_USA=FED_NG_MP + FED_NG_ADD
	WHERE FED_NG_USA = 0 OR FED_NG_USA IS NULL
	and ma_codigo  IN (select  ma_codigo
	from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))


	UPDATE dbo.BOM_COSTO
	SET     dbo.BOM_COSTO.BST_NG_USA = dbo.VMAESTROCOST.MA_NG_USA
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.BOM_COSTO ON dbo.BOM_STRUCT.BST_CODIGO = dbo.BOM_COSTO.BST_CODIGO INNER JOIN
	                      dbo.VMAESTROCOST ON dbo.BOM_STRUCT.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO
	WHERE     dbo.BOM_STRUCT.BST_HIJO IN (select  ma_codigo
	from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S'))


	UPDATE dbo.BOM_COSTO
	SET     dbo.BOM_COSTO.BST_COSTO= dbo.BOM_COSTO.BST_GRAV_MP+ dbo.BOM_COSTO.BST_GRAV_ADD+ dbo.BOM_COSTO.BST_GRAV_EMP+ 
	                      dbo.BOM_COSTO.BST_GRAV_GI+ dbo.BOM_COSTO.BST_GRAV_GI_MX + dbo.BOM_COSTO.BST_GRAV_MO + dbo.BOM_COSTO.BST_NG_MP +
	                      dbo.BOM_COSTO.BST_NG_ADD+ dbo.BOM_COSTO.BST_NG_EMP
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.BOM_COSTO ON dbo.BOM_STRUCT.BST_CODIGO = dbo.BOM_COSTO.BST_CODIGO
	WHERE     (dbo.BOM_STRUCT.BST_HIJO IN
                          (SELECT     ma_codigo
                            FROM          maestro
                            WHERE      ti_codigo IN
                                                       (SELECT     ti_codigo
                                                         FROM          configuratipo
                                                         WHERE      cft_tipo = 'P' OR
                                                                                cft_tipo = 'S')))




	/*UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.BST_PESO_KG= dbo.MAESTRO.MA_PESO_KG
	FROM         dbo.BOM_STRUCT INNER JOIN
             dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO AND dbo.BOM_STRUCT.ME_CODIGO = dbo.MAESTRO.ME_COM
	WHERE  dbo.MAESTRO.MA_PESO_KG>0*/



























GO
