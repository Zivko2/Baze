SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































































CREATE TRIGGER dbo.[DELETE_DECANUALPPS] ON [dbo].[DECANUALPPS] 
FOR DELETE 
AS

	if exists (select * from decanualppsdet where dap_codigo in (select dap_codigo from deleted))
	delete from decanualppsdet where dap_codigo in (select dap_codigo from deleted)






























































GO
