SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE trigger DEL_FAST on dbo.FAST  for DELETE as
SET NOCOUNT ON

  IF EXISTS (SELECT * FROM FastDet, Deleted  WHERE  FastDet.Fst_Codigo = Deleted.Fst_codigo)
     DELETE FastDet FROM FastDet, Deleted  WHERE FastDet.Fst_Codigo = Deleted.Fst_codigo

  IF EXISTS (SELECT * FROM FastBarCode, Deleted  WHERE  FastBarCode.Fst_Codigo = Deleted.Fst_codigo)
     DELETE FastBarCode FROM FastBarCode, Deleted  WHERE FastBarCode.Fst_Codigo = Deleted.Fst_codigo
































GO
