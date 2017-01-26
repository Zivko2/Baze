SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE TRIGGER [DEL_PlntExpSeccFiltroFormula] ON [dbo].[PlntExpSeccFiltroFormula] 
FOR DELETE 
AS


    IF EXISTS (SELECT * FROM PlntExpSeccFiltroFormula_IN, Deleted  WHERE  PlntExpSeccFiltroFormula_IN.Pxff_Codigo = Deleted.Pxff_codigo)
    DELETE PlntExpSeccFiltroFormula_IN FROM PlntExpSeccFiltroFormula_IN, Deleted  WHERE PlntExpSeccFiltroFormula_IN.Pxff_Codigo = Deleted.Pxff_codigo







































GO
