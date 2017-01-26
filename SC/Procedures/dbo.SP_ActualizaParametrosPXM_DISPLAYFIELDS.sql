SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_ActualizaParametrosPXM_DISPLAYFIELDS]    as

--Cambio hecho el 09-Nov-09  Version DB 1.3.0.20a
--Este query es para Actualiza el campo de pxm_displayfields porque cambio el parametro de la seccion principal en las plantillas, 
--ahora debe indicar la tabla y el campo y antes solo indicaba el campo y no la tabla.



UPDATE plntexpseccprm
SET plntexpseccprm.pxm_displayfields=
importfields.IMF_TABLENAME+'.'+plntexpseccprm.pxm_displayfields
FROM         PlantillaExp INNER JOIN
                      PlntExpSecc ON PlantillaExp.PXP_CODIGO = PlntExpSecc.PXP_CODIGO INNER JOIN
                      PlntExpSeccPrm ON PlntExpSecc.PXS_CODIGO = PlntExpSeccPrm.PXS_CODIGO INNER JOIN
                      IMPORTFIELDS ON PlntExpSeccPrm.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
where 
plntexpsecc.pxs_esprincipal='S' and
CHARINDEX('.',plntexpseccprm.pxm_displayfields)=0


UPDATE EXPORTSPECPRM
SET EXPORTSPECPRM.PXM_DISPLAYFIELDS=
     IMPORTFIELDS.IMF_TABLENAME+'.'+EXPORTSPECPRM.PXM_DISPLAYFIELDS 
FROM         EXPORTSPECPRM INNER JOIN
                      IMPORTFIELDS ON EXPORTSPECPRM.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO RIGHT OUTER JOIN
                      EXPORTSPEC ON EXPORTSPECPRM.EMS_CODIGO = EXPORTSPEC.EMS_CODIGO
WHERE     (CHARINDEX('.', EXPORTSPECPRM.PXM_DISPLAYFIELDS) = 0)



























GO
