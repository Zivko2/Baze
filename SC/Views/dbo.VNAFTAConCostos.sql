SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

create view VNAFTAConCostos
as
select
   dbo.NAFTA.[NFT_Codigo]
   , dbo.NAFTA.[MA_Codigo]
   , dbo.NAFTA.[SPI_Codigo]
   , dbo.NAFTA.[NFT_Califico]
   --, dbo.NAFTA.[NFT_Costo]
   , (select sum(dbo.ClasificaTLC.[BST_Empaque])
      from   dbo.ClasificaTLC
      where  dbo.ClasificaTLC.[NFT_Codigo] = NAFTA.[NFT_Codigo]
             and dbo.ClasificaTLC.[BST_Empaque] > 0
             and dbo.ClasificaTLC.[BST_MatOrig] = 0
             and dbo.ClasificaTLC.[BST_MatNoOrig] = 0) as [NAFTAEmpaque]
   , (select top 1
             dbo.MaestroCost.[MA_Grav_GI] + dbo.MaestroCost.[MA_Grav_GI_Mx]
      from   dbo.MaestroCost
      where  dbo.MaestroCost.[MA_Codigo] = dbo.NAFTA.[MA_Codigo]
             and dbo.MaestroCost.[SPI_Codigo] = dbo.NAFTA.[SPI_Codigo]
             and dbo.MaestroCost.[MA_PerIni] <= dbo.NAFTA.[NFT_Fecha]
             and dbo.MaestroCost.[MA_PerFin] >= dbo.NAFTA.[NFT_Fecha]
             -- costo de manufactura
             and dbo.MaestroCost.[TCO_Codigo] = 1
      order by
             dbo.MaestroCost.[MA_PerIni] desc
             ,dbo.MaestroCost.[MA_PerFin] desc) as [ValorAgregadoIndirecto]
   , (select top 1
             dbo.MaestroCost.[MA_Grav_MO]
      from   dbo.MaestroCost
      where  dbo.MaestroCost.[MA_Codigo] = dbo.NAFTA.[MA_Codigo]
             and dbo.MaestroCost.[SPI_Codigo] = dbo.NAFTA.[SPI_Codigo]
             and dbo.MaestroCost.[MA_PerIni] <= dbo.NAFTA.[NFT_Fecha]
             and dbo.MaestroCost.[MA_PerFin] >= dbo.NAFTA.[NFT_Fecha]
             -- costo de manufactura
             and dbo.MaestroCost.[TCO_Codigo] = 1
      order by
             dbo.MaestroCost.[MA_PerIni] desc
             ,dbo.MaestroCost.[MA_PerFin] desc) as [ManoObra]
from
   dbo.NAFTA
--where
--   dbo.NAFTA.[NFT_PerIni] <= getdate()
--   and dbo.NAFTA.[NFT_PerFin] >= getdate()
--group by
--   dbo.NAFTA.[MA_Codigo]
--   , dbo.NAFTA.[SPI_Codigo]
--   , dbo.NAFTA.[NFT_Califico]
--   , dbo.NAFTA.[NFT_Costo]
GO
