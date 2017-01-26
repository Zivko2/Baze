SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE trigger Del_ListaExpDet on dbo.LISTAEXPDET for DELETE as
SET NOCOUNT ON 
declare @AlmDetCant decimal(38,6), @ListaCant  decimal(38,6)


  /* Se borra el contenido del detalle*/
  IF EXISTS (SELECT * FROM ListaExpCont ,deleted WHERE  ListaExpCont.LED_indiced = deleted.LED_indiced)
    DELETE ListaExpCont FROM ListaExpCont ,deleted WHERE  ListaExpCont.LED_indiced = deleted.LED_indiced







GO
