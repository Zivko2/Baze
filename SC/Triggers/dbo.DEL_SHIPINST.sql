SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER DEL_SHIPINST ON dbo.SHIPINST  FOR DELETE AS
declare @si_codigo int

	select @si_codigo=si_codigo from deleted


	update factimp
	set si_codigo=-1
	where si_codigo =@si_codigo

































GO
