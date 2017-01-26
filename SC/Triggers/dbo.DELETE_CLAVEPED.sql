SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE TRIGGER [DELETE_CLAVEPED] ON dbo.CLAVEPED  
FOR DELETE  
AS 
	 if exists(select * from configuraclaveped where cp_codigo in (select cp_codigo from deleted)) 
	delete from configuraclaveped where cp_codigo in (select cp_codigo from deleted) 
	if exists(select * from RELTFACTCLAPED where cp_codigo in (select cp_codigo from deleted)) 
	delete from RELTFACTCLAPED where cp_codigo in (select cp_codigo from deleted)




































GO
