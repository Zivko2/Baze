SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE trigger Del_Pcklist on dbo.PCKLIST for DELETE as
SET NOCOUNT ON 
begin
  IF EXISTS (SELECT * FROM PckListDet, Deleted  WHERE  PckListDet.Pl_Codigo = Deleted.Pl_codigo)
     DELETE PckListDet FROM PckListDet, Deleted  WHERE PckListDet.Pl_Codigo = Deleted.Pl_codigo

  IF EXISTS (SELECT * FROM PckListDef, Deleted  WHERE  PckListDef.Pl_Codigo = Deleted.Pl_codigo)
     DELETE PckListDef FROM PckListDef, Deleted  WHERE PckListDef.Pl_Codigo = Deleted.Pl_codigo

end




































GO
