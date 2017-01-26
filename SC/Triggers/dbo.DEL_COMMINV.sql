SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















































CREATE TRIGGER DEL_COMMINV ON dbo.COMMINV  FOR DELETE AS
BEGIN
declare @IV_CODIGO int
select @iv_codigo=IV_CODIGO from deleted
	--Borrar CommInvDet  
      if exists(select * from COMMINVDET where IV_CODIGO=@IV_CODIGO)
      DELETE FROM COMMINVDET WHERE IV_CODIGO IN (SELECT IV_CODIGO FROM DELETED)

END
























































GO
