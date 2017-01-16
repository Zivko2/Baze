SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



create view dbo.VTotalDescPedSinTasaImpMx with encryption
as
select
   PI_Codigo,
   sum(CantidadDescargada) as CantidadDescargada
from
   (select
       PedImpDetB.PIB_Can_Gen as CantidadDescargada,
       PedImpDetB.PI_Codigo
    from
       VDatosPedExpDesc_TasaCero inner join PedImpDetB
          on VDatosPedExpDesc_TasaCero.pib_Indiceb = PedImpDetB.PIB_IndiceB
    where
       not (VDatosPedExpDesc_TasaCero.kap_Indiced_ped is null)
       and VDatosPedExpDesc_TasaCero.kap_cantdesc > 0
    group by
       PedImpDetB.PI_Codigo,
       PedImpDetB.PIB_IndiceB,
       PedImpDetB.PIB_Can_Gen) as PedImpDescarga
group by
   PI_Codigo
GO
