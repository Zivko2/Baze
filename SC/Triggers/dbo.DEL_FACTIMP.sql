SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















CREATE trigger DEL_FACTIMP on dbo.FACTIMP  for DELETE as
SET NOCOUNT ON
Declare @fi_codigo int
begin

	select @fi_codigo=fi_codigo from deleted
 /*Se borra info de Contenido*/
  IF EXISTS (SELECT * FROM FactImpCont, Deleted  WHERE  FactImpCont.Fi_Codigo = Deleted.Fi_codigo)
     DELETE FactImpCont FROM FactImpCont, Deleted  WHERE FactImpCont.Fi_Codigo = Deleted.Fi_codigo


  /* Se borra el detalle de la factura */
  IF EXISTS (SELECT * FROM FactImpDet, Deleted  WHERE  FactImpDet.Fi_Codigo = Deleted.Fi_codigo)
     DELETE FactImpDet FROM FactImpDet, Deleted  WHERE FactImpDet.Fi_Codigo = Deleted.Fi_codigo

  /* Se borra los definibles de la factura */
  IF EXISTS (SELECT * FROM FactImpDef, Deleted  WHERE  FactImpDef.Fi_Codigo = Deleted.Fi_codigo)
     DELETE FactImpDef FROM FactImpDef, Deleted  WHERE FactImpDef.Fi_Codigo = Deleted.Fi_codigo

  /* Se borra el empaque de la factura */
  IF EXISTS (SELECT * FROM FactImpEmpaque ,  Deleted where  FactImpEmpaque.Fi_Codigo = Deleted.Fi_codigo)
     DELETE FactImpEmpaque FROM FactImpEmpaque,  Deleted WHERE  FactImpEmpaque.Fi_Codigo = Deleted.Fi_codigo

  /* Se borra la relacion del empaque con el detalle */
  IF EXISTS (SELECT * FROM FactImpRelEmpaque, Deleted  WHERE FactImpRelEmpaque.Fi_Codigo =   Deleted.fi_codigo)
    DELETE FactImpRelEmpaque FROM FactImpRelEmpaque, Deleted WHERE FactImpRelEmpaque.Fi_codigo = Deleted.fi_codigo

  IF EXISTS (SELECT * FROM FactImpIdentifica, Deleted  WHERE FactImpIdentifica.Fi_Codigo =   Deleted.fi_codigo)
    DELETE FactImpIdentifica FROM FactImpIdentifica, Deleted WHERE FactImpIdentifica.Fi_codigo = Deleted.fi_codigo


  IF EXISTS (SELECT * FROM FactImpIncrementa, Deleted  WHERE  FactImpIncrementa.Fi_Codigo = Deleted.Fi_codigo)
     DELETE FactImpIncrementa FROM FactImpIncrementa, Deleted  WHERE FactImpIncrementa.Fi_Codigo = Deleted.Fi_codigo

  IF EXISTS (SELECT * FROM FactImpEmpaqueAdicional, Deleted  WHERE  FactImpEmpaqueAdicional.Fi_Codigo = Deleted.Fi_codigo)
     DELETE FactImpEmpaqueAdicional FROM FactImpEmpaqueAdicional, Deleted  WHERE FactImpEmpaqueAdicional.Fi_Codigo = Deleted.Fi_codigo


	--   exec SP_CORRIGEPCKLISTSALDOS

  IF EXISTS (SELECT * FROM DesCongelaSub, Deleted  WHERE  DesCongelaSub.Fi_Codigo = Deleted.Fi_codigo)
     DELETE DesCongelaSub FROM DesCongelaSub, Deleted  WHERE DesCongelaSub.Fi_Codigo = Deleted.Fi_codigo


	declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(FI_CODIGO),0)+1 FROM FACTIMP

	update consecutivo
	set cv_codigo = isnull(@consecutivo,0)
	where cv_tipo ='FI'


	exec sp_DescargaCancelaPermiso @fi_codigo

END















GO
