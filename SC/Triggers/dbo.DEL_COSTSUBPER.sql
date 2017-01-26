SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












































CREATE TRIGGER [DEL_COSTSUBPER] ON dbo.COSTSUBPER 
FOR DELETE AS
BEGIN
  IF EXISTS (SELECT * FROM COSTSUBA, Deleted  WHERE  COSTSUBA.cs_Codigo = Deleted.cs_codigo)
   DELETE FROM COSTSUBA WHERE CS_CODIGO IN (SELECT CS_CODIGO FROM DELETED)

-- los exhibitss

END




















































GO
