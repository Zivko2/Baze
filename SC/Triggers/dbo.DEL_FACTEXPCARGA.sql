SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















CREATE trigger DEL_FACTEXPCARGA on dbo.FACTEXPCARGA  for DELETE as
SET NOCOUNT ON

	UPDATE FACTEXP SET FEG_CODIGO=-1 
	FROM FactExp, Deleted  
	WHERE FactExp.Feg_Codigo = Deleted.Feg_codigo


















GO
