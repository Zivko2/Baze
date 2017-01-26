SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [DEL_REVORIGEN] ON [dbo].[REVORIGEN] 
FOR DELETE 
AS


	if exists(select * from revorigencontrib where fi_codigo in (select fi_codigo from deleted))
	delete from revorigencontrib where fi_codigo in (select fi_codigo from deleted)






























































GO
