SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































































CREATE VIEW dbo.VCERTORIGMPVENCIMIENTO
with encryption as
select ma_noparte,cmp_vfecha, cl_razon, ti_nombre, ma_nombre, cmp_vfecha-(SELECT     CF_DIAS_AVISOTLC   FROM  configuracion) fechavencimiento
from 

(select dbo.maestro.ma_noparte, 
        dbo.cliente.cl_razon, 
        dbo.tipo.ti_nombre, 
        dbo.maestro.ma_nombre,
        max(dbo.certorigmp.cmp_vfecha) cmp_vfecha

from dbo.maestro left outer join dbo.tipo on dbo.maestro.ti_codigo = dbo.tipo.ti_codigo
             left outer join dbo.certorigmpdet on dbo.maestro.ma_codigo = dbo.certorigmpdet.ma_codigo
             left outer join dbo.certorigmp on dbo.certorigmpdet.cmp_codigo = dbo.certorigmp.cmp_codigo
             left outer join dbo.cliente on dbo.certorigmp.pr_codigo = dbo.cliente.cl_codigo

where  dbo.CERTORIGMP.CMP_ESTATUS='V' 
 and dbo.maestro.ma_est_mat = 'A' and dbo.maestro.ma_enuso = 'S'
group by dbo.maestro.ma_noparte, dbo.cliente.cl_razon, dbo.tipo.ti_nombre, dbo.maestro.ma_nombre) a
where a.cmp_vfecha - (SELECT CF_DIAS_AVISOTLC FROM dbo.configuracion) <=   convert(datetime, convert(varchar(11), getdate(),101))



































































GO
