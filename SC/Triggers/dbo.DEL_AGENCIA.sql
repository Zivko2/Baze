SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE TRIGGER [DEL_AGENCIA] ON dbo.AGENCIA 
FOR DELETE 
AS

	if not exists (select * from agenciadel where ag_codigo in (select ag_codigo from deleted))
	INSERT INTO AGENCIADEL (AG_CODIGO, AG_NOMBRE)
	SELECT AG_CODIGO, AG_NOMBRE FROM DELETED


	  IF EXISTS (SELECT * FROM AgenciaPatente, Deleted  WHERE  AgenciaPatente.ag_codigo = Deleted.ag_codigo)
	     DELETE AgenciaPatente FROM AgenciaPatente, Deleted  WHERE AgenciaPatente.ag_codigo = Deleted.ag_codigo


	  IF EXISTS (SELECT * FROM AgenciaHonorario, Deleted  WHERE  AgenciaHonorario.ag_codigo = Deleted.ag_codigo)
	     DELETE AgenciaHonorario FROM AgenciaHonorario, Deleted  WHERE AgenciaHonorario.ag_codigo = Deleted.ag_codigo




























































GO
