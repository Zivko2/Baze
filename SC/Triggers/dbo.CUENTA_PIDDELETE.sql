SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [CUENTA_PIDDELETE] ON dbo.PEDIMPDET 
FOR DELETE 
AS
	
	update pedimp
	set pi_cuentadet=(select count(*) from pedimpdet where pi_codigo in (select pi_codigo from deleted))
	where pi_codigo in (select pi_codigo from deleted)














GO
