SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE TRIGGER [INSERT_PCKLIST] ON dbo.PCKLIST 
FOR INSERT
AS
SET NOCOUNT ON 

	UPDATE PCKLIST
	SET PL_FOLIO=UPPER(RTRIM(PL_FOLIO))
	WHERE PL_CODIGO IN (SELECT PL_CODIGO FROM INSERTED)






































GO
