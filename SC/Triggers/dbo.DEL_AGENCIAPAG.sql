SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER [DEL_AGENCIAPAG] ON dbo.AGENCIAPAG
FOR DELETE 
AS
declare @agp_codigo int

	select @agp_codigo=agp_codigo from deleted

	if exists(select * from agenciapagdet where agp_codigo=@agp_codigo)
	delete  from agenciapagdet where agp_codigo=@agp_codigo

































GO
