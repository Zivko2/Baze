SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE trigger DEL_ENTRYCONS on dbo.ENTRYCONS  for DELETE as
SET NOCOUNT ON

declare @etc_codigo int


	select @etc_codigo=etc_codigo from deleted

	update factexp
	set etc_codigo=-1
	where etc_codigo=@etc_codigo
































GO
