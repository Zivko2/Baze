SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



























CREATE TRIGGER [DEL_PlntExpSecc] ON dbo.PlntExpSecc 
FOR DELETE 
AS


  IF EXISTS (SELECT * FROM PlntExpSeccDet, Deleted  WHERE  PlntExpSeccDet.Pxs_Codigo = Deleted.Pxs_codigo)
     DELETE PlntExpSeccDet FROM PlntExpSeccDet, Deleted  WHERE PlntExpSeccDet.Pxs_Codigo = Deleted.Pxs_codigo


  IF EXISTS (SELECT * FROM PlntExpSeccFiltro, Deleted  WHERE  PlntExpSeccFiltro.Pxs_Codigo = Deleted.Pxs_codigo)
     DELETE PlntExpSeccFiltro FROM PlntExpSeccFiltro, Deleted  WHERE PlntExpSeccFiltro.Pxs_Codigo = Deleted.Pxs_codigo

  IF EXISTS (SELECT * FROM PlntExpSeccFiltroFormula, Deleted  WHERE  PlntExpSeccFiltroFormula.Pxs_Codigo = Deleted.Pxs_codigo)
     DELETE PlntExpSeccFiltroFormula FROM PlntExpSeccFiltroFormula, Deleted  WHERE PlntExpSeccFiltroFormula.Pxs_Codigo = Deleted.Pxs_codigo



  IF EXISTS (SELECT * FROM PlntExpSeccPrm, Deleted  WHERE  PlntExpSeccPrm.Pxs_Codigo = Deleted.Pxs_codigo)
     DELETE PlntExpSeccPrm FROM PlntExpSeccPrm, Deleted  WHERE PlntExpSeccPrm.Pxs_Codigo = Deleted.Pxs_codigo



























GO
