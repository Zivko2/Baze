SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE TRIGGER [CUENTA_PIDINSERT] ON dbo.PEDIMPDET 
FOR INSERT
AS


	update pedimp
	set pi_cuentadet=(select count(*) from pedimpdet where pi_codigo in (select pi_codigo from inserted))
	where pi_codigo in (select pi_codigo from inserted)














GO
