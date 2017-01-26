SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE trigger DEL_FASTDET on dbo.FASTDET  for DELETE as
SET NOCOUNT ON


  IF EXISTS (SELECT * FROM FastBarCode, Deleted  WHERE  FastBarCode.Fst_Codigo = Deleted.Fst_codigo and FastBarCode.et_codigo = Deleted.et_codigo)
     DELETE FastBarCode FROM FastBarCode, Deleted  WHERE FastBarCode.Fst_Codigo = Deleted.Fst_codigo and FastBarCode.et_codigo = Deleted.et_codigo


































GO
