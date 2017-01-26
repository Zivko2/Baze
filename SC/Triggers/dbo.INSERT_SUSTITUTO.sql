SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























































CREATE TRIGGER [INSERT_SUSTITUTO] ON [dbo].[SUSTITUTO] 
FOR INSERT
AS
declare @fe_codigo int

	select @fe_codigo=fetr_codigo from inserted

	update factexp
	set fe_descsust='S'
	where fe_codigo=@fe_codigo
	and fe_descsust<>'S'



























































GO
