SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE trigger DEL_INCREMENTABLE on dbo.INCREMENTABLE  for DELETE as
SET NOCOUNT ON
begin

  IF EXISTS (SELECT * FROM IncrementablexDoc, Deleted  WHERE  IncrementablexDoc.ic_Codigo = Deleted.ic_codigo)
     DELETE IncrementablexDoc FROM IncrementablexDoc, Deleted  WHERE IncrementablexDoc.ic_Codigo = Deleted.ic_codigo

end

























GO
