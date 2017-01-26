SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE TRIGGER [DEL_PLANTILLAEXP] ON dbo.PlantillaExp 
FOR DELETE 
AS

  IF EXISTS (SELECT * FROM PlntExpSecc, Deleted  WHERE  PlntExpSecc.Pxp_Codigo = Deleted.Pxp_codigo)
     DELETE PlntExpSecc FROM PlntExpSecc, Deleted  WHERE PlntExpSecc.Pxp_Codigo = Deleted.Pxp_codigo


  IF EXISTS (SELECT * FROM PlntExpDet, Deleted  WHERE  PlntExpDet.Pxp_Codigo = Deleted.Pxp_codigo)
     DELETE PlntExpDet FROM PlntExpDet, Deleted  WHERE PlntExpDet.Pxp_Codigo = Deleted.Pxp_codigo



  IF EXISTS (SELECT * FROM PlntExpCnx, Deleted  WHERE  PlntExpCnx.Pxp_Codigo = Deleted.Pxp_codigo)
     DELETE PlntExpCnx FROM PlntExpCnx, Deleted  WHERE PlntExpCnx.Pxp_Codigo = Deleted.Pxp_codigo
































GO
