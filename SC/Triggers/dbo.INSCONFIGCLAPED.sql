SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE TRIGGER [INSCONFIGCLAPED] ON dbo.CLAVEPED  
FOR INSERT 
AS 
BEGIN 
Declare @cpcodigo int 
	select @cpcodigo = CP_CODIGO FROM INSERTED 
	where CP_CODIGO NOT IN (SELECT CP_CODIGO FROM CONFIGURACLAVEPED) and cp_codigo is not null
 
	if @cpcodigo is not null	if not exists (select * from configuraclaveped where cp_codigo in (select cp_codigo from inserted)) 
	INSERT INTO CONFIGURACLAVEPED (CP_CODIGO, CCP_TIPO) 
	VALUES (@cpcodigo, '' ) 
 
END




































GO
