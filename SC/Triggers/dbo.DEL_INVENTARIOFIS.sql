SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE TRIGGER [DEL_INVENTARIOFIS] ON dbo.INVENTARIOFIS 
FOR DELETE 
AS

declare @ivf_codigo int

	select @ivf_codigo=ivf_codigo from deleted

	if @ivf_codigo is not null and @ivf_codigo>0
	if exists(select * from INVENTARIOFISDET where ivf_codigo=@ivf_codigo)
	delete from INVENTARIOFISDET where ivf_codigo=@ivf_codigo































































GO
