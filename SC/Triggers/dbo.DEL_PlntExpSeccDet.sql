SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE TRIGGER [DEL_PlntExpSeccDet] ON dbo.PlntExpSeccDet 
FOR DELETE 
AS


  /* Se borra las formulas que pertenescan a la seccion */
  IF EXISTS (SELECT * FROM PlntExpFormula, Deleted  WHERE  PlntExpFormula.Pxf_Codigo = Deleted.Pxf_codigo)
     DELETE PlntExpFormula FROM PlntExpFormula, Deleted  WHERE PlntExpFormula.Pxf_Codigo = Deleted.Pxf_codigo































GO
