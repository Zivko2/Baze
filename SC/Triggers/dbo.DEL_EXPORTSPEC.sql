SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























































CREATE TRIGGER [DEL_EXPORTSPEC] ON [dbo].[EXPORTSPEC] 
FOR DELETE 
AS

  IF EXISTS (SELECT * FROM EXPORTSPECPRM, Deleted  WHERE  EXPORTSPECPRM.ems_Codigo = Deleted.ems_codigo)
     DELETE EXPORTSPECPRM FROM EXPORTSPECPRM, Deleted  WHERE EXPORTSPECPRM.ems_Codigo = Deleted.ems_codigo

  IF EXISTS (SELECT * FROM EXPORTSPECPRMVAL, Deleted  WHERE  EXPORTSPECPRMVAL.ems_Codigo = Deleted.ems_codigo)
     DELETE EXPORTSPECPRMVAL FROM EXPORTSPECPRMVAL, Deleted  WHERE EXPORTSPECPRMVAL.ems_Codigo = Deleted.ems_codigo


  IF EXISTS (SELECT * FROM EXPORTSPECFIXVAL, Deleted  WHERE  EXPORTSPECFIXVAL.ems_Codigo = Deleted.ems_codigo)
     DELETE EXPORTSPECFIXVAL FROM EXPORTSPECFIXVAL, Deleted  WHERE EXPORTSPECFIXVAL.ems_Codigo = Deleted.ems_codigo


  IF EXISTS (SELECT * FROM EXPORTSPECFILES, Deleted  WHERE  EXPORTSPECFILES.ems_Codigo = Deleted.ems_codigo)
     DELETE EXPORTSPECFILES FROM EXPORTSPECFILES, Deleted  WHERE EXPORTSPECFILES.ems_Codigo = Deleted.ems_codigo








































GO
