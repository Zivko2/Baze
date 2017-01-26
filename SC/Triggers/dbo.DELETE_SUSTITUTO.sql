SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























































CREATE TRIGGER [DELETE_SUSTITUTO] ON [dbo].[SUSTITUTO] 
FOR DELETE 
AS

declare @fe_codigo int

	select @fe_codigo=fetr_codigo from deleted

	if not exists(select * from sustituto where fetr_codigo=@fe_codigo)
	update factexp
	set fe_descsust='N'
	where fe_codigo=@fe_codigo
	and fe_descsust<>'N'




























































GO
