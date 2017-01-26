SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















CREATE trigger DEL_FACTIMPCARGA on dbo.FACTIMPCARGA  for DELETE as
SET NOCOUNT ON

	UPDATE FACTIMP 
	SET FIG_CODIGO=-1 
	FROM Factimp, Deleted  
	WHERE FactImp.Fig_Codigo = Deleted.Fig_codigo


















GO
