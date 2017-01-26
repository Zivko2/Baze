SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















CREATE trigger DEL_FACTEXP on dbo.FACTEXP  for DELETE as
SET NOCOUNT ON
begin
 /*Se borra info de Contenido*/
  IF EXISTS (SELECT * FROM FactExpCont, Deleted  WHERE  FactExpCont.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpCont FROM FactExpCont, Deleted  WHERE FactExpCont.Fe_Codigo = Deleted.Fe_codigo

  /* Se borra el detalle de la factura */

  IF EXISTS (SELECT * FROM FactExpDet, Deleted  WHERE  FactExpDet.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpDet FROM FactExpDet, Deleted  WHERE FactExpDet.Fe_Codigo = Deleted.Fe_codigo

  /* Se borra el definibles de la factura */
  IF EXISTS (SELECT * FROM FactExpDef, Deleted  WHERE  FactExpDef.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpDef FROM FactExpDef, Deleted  WHERE FactExpDef.Fe_Codigo = Deleted.Fe_codigo

  /* Se borra el desperdicio de la factura */
  IF EXISTS (SELECT * FROM FactExpDesp, Deleted  WHERE  FactExpDesp.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpDesp FROM FactExpDesp, Deleted  WHERE FactExpDesp.Fe_Codigo = Deleted.Fe_codigo

  /* Se borra el empaque de la factura */
  IF EXISTS (SELECT * FROM FactExpEmpaque ,  Deleted where  FactExpEmpaque.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpEmpaque FROM FactExpEmpaque,  Deleted WHERE  FactExpEmpaque.Fe_Codigo = Deleted.Fe_codigo

  /* Se borra el empaque adicional de la factura */
  IF EXISTS (SELECT * FROM FactExpEmpaqueadicional ,  Deleted where  FactExpEmpaqueadicional.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpEmpaqueadicional FROM FactExpEmpaqueadicional,  Deleted WHERE  FactExpEmpaqueadicional.Fe_Codigo = Deleted.Fe_codigo

  /* Se borra la relacion del empaque con el detalle */
  IF EXISTS (SELECT * FROM FactExpRelEmpaque, Deleted  WHERE FactExpRelEmpaque.Fe_Codigo =   Deleted.fe_codigo)
    DELETE FactExpRelEmpaque FROM FactExpRelEmpaque, Deleted WHERE FactExpRelEmpaque.Fe_codigo = Deleted.fe_codigo

  IF EXISTS (SELECT * FROM FactExpIdentifica, Deleted  WHERE FactExpIdentifica.Fe_Codigo =   Deleted.fe_codigo)
    DELETE FactExpIdentifica FROM FactExpIdentifica, Deleted WHERE FactExpIdentifica.Fe_codigo = Deleted.fe_codigo

  IF EXISTS (SELECT * FROM FactExpIncrementa, Deleted  WHERE  FactExpIncrementa.Fe_Codigo = Deleted.Fe_codigo)
     DELETE FactExpIncrementa FROM FactExpIncrementa, Deleted  WHERE FactExpIncrementa.Fe_Codigo = Deleted.Fe_codigo

	-- Borrar los Commercial Invoices pertenecientes a esta factura
  IF EXISTS (SELECT * FROM COMMINV, Deleted  WHERE COMMINV.FE_Codigo =   Deleted.fe_codigo)
    DELETE COMMINV FROM COMMINV, Deleted WHERE COMMINV.Fe_codigo = Deleted.fe_codigo AND  IV_TIPOFACT = 'I'

	-- Borrar los Canada Custom Invoices pertenecientes a esta factura
  IF EXISTS (SELECT * FROM CANADACINV, Deleted  WHERE CANADACINV.FE_Codigo =   Deleted.fe_codigo)
    DELETE CANADACINV FROM CANADACINV, Deleted WHERE CANADACINV.Fe_codigo = Deleted.fe_codigo AND  CD_TIPOFACT = 'I'


-- Borrar los Entry Summaries perteneceientes a esta factura
     IF EXISTS (SELECT * FROM ENTRYSUM, Deleted  WHERE ENTRYSUM.et_Codigo =   Deleted.et_codigo) 
     if not exists(select fe_codigo from factexp where et_codigo in (select et_codigo from deleted))
    DELETE ENTRYSUM FROM ENTRYSUM, Deleted WHERE ENTRYSUM.et_codigo = Deleted.et_codigo


	declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(FE_CODIGO),0)+1 FROM FACTEXP

	update consecutivo
	set cv_codigo = isnull(@consecutivo,0)
	where cv_tipo ='FE'


	--exec SP_CORRIGELISTAEXPSALDOS


  IF EXISTS (SELECT * FROM CongelaSub, Deleted  WHERE  CongelaSub.Fe_Codigo = Deleted.Fe_codigo)
     DELETE CongelaSub FROM CongelaSub, Deleted  WHERE CongelaSub.Fe_Codigo = Deleted.Fe_codigo


END















GO
