SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE TRIGGER DEL_MAESTRO ON dbo.MAESTRO FOR  DELETE 
AS
SET NOCOUNT ON 

  IF EXISTS (SELECT * FROM MaestroCost, Deleted  WHERE  MaestroCost.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroCost FROM MaestroCost, Deleted  WHERE MaestroCost.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroCliente, Deleted  WHERE  MaestroCliente.Ma_Codigo = Deleted.Ma_codigo)
	     DELETE MaestroCliente FROM MaestroCliente, Deleted  WHERE MaestroCliente.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroProvee, Deleted  WHERE  MaestroProvee.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroProvee FROM MaestroProvee, Deleted  WHERE MaestroProvee.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroSust, Deleted  WHERE  MaestroSust.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroSust FROM MaestroSust, Deleted  WHERE MaestroSust.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroDef, Deleted  WHERE  MaestroDef.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroDef FROM MaestroDef, Deleted  WHERE MaestroDef.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM Nafta, Deleted  WHERE  Nafta.Ma_Codigo = Deleted.Ma_codigo)
     DELETE Nafta FROM Nafta, Deleted  WHERE Nafta.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroAlm, Deleted  WHERE  MaestroAlm.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroAlm FROM MaestroAlm, Deleted  WHERE MaestroAlm.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroAlmDet, Deleted  WHERE  MaestroAlmDet.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroAlmDet FROM MaestroAlmDet, Deleted  WHERE MaestroAlmDet.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroCara, Deleted  WHERE  MaestroCara.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroCara FROM MaestroCara, Deleted  WHERE MaestroCara.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM MaestroUbicacion, Deleted  WHERE  MaestroUbicacion.Ma_Codigo = Deleted.Ma_codigo)
     DELETE MaestroUbicacion FROM MaestroUbicacion, Deleted  WHERE MaestroUbicacion.Ma_Codigo = Deleted.Ma_codigo


  IF EXISTS (SELECT * FROM CertOrigMPDet, Deleted  WHERE  CertOrigMPDet.Ma_Codigo = Deleted.Ma_codigo)
     DELETE CertOrigMPDet FROM CertOrigMPDet, Deleted  WHERE CertOrigMPDet.Ma_Codigo = Deleted.Ma_codigo



	declare @consecutivo int

	select @consecutivo= max(isnull(MA_CODIGO,0))+1 from MAESTRO
	

	if exists(select * from maestrorefer) and (select max(isnull(ma_codigo,0)) from maestrorefer)>@consecutivo
	select @consecutivo= max(isnull(MA_CODIGO,0))+1 from MAESTROREFER

	update consecutivo
	set cv_codigo = @consecutivo
	where cv_tipo ='MA'






















GO
