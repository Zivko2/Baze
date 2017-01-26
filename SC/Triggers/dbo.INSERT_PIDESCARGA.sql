SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE TRIGGER [INSERT_PIDESCARGA] ON dbo.PIDescarga 
FOR INSERT, UPDATE
AS

declare @pi_codigo int, @pi_tipo char(1), @cp_codigo int 


	if update(pid_saldogen)
	begin
		select @cp_codigo=cp_codigo, @pi_codigo=pi_codigo  from pedimp where pi_codigo in
		(select pi_codigo from inserted)
		exec SP_ACTUALIZAESTATUSPEDIMP @pi_codigo, @cp_codigo
	end


























GO
