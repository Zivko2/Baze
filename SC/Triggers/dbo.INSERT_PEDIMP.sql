SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























































CREATE TRIGGER [INSERT_PEDIMP] ON dbo.PEDIMP 
FOR INSERT
AS
SET NOCOUNT ON
declare @pi_tipo char(1), @pi_codigo int, @pi_ligacorrecta char(1)

	select @pi_ligacorrecta=pi_ligacorrecta, @pi_codigo=pi_codigo, @pi_tipo=pi_tipo from inserted

/*	if (@pi_tipo='A' or @pi_tipo='T')
	begin
		if not exists (select * from pedimpdet where pi_codigo=@pi_codigo)
		update pedimp
		set pi_ligacorrecta='N'
		where pi_codigo=@pi_codigo
	end
*/


















GO
