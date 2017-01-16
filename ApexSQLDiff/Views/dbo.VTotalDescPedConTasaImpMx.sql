SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




create view dbo.VTotalDescPedConTasaImpMx with encryption
as
select
   PI_Codigo,
   sum(CantidadDescargada) as CantidadDescargada
from
   (select
       PedImpDetB.PIB_Can_Gen as CantidadDescargada,
       PedImpDetB.PI_Codigo
    from
       PedImpDetB inner join KarDatosPedExpDesc
          on PedImpDetB.PIB_IndiceB = KarDatosPedExpDesc.PIB_IndiceB
    where
       KarDatosPedExpDesc.PID_Por_Def > 0
       and KarDatosPedExpDesc.KAP_CantDesc > 0
       and not (KarDatosPedExpDesc.KAP_IndiceD_Ped is null)
    group by
       PedImpDetB.PI_Codigo,
       PedImpDetB.PIB_IndiceB,
       PedImpDetB.PIB_Can_Gen) as PedImpConSumDescarga
group by
   PI_Codigo
GO
