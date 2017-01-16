SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE trigger dbo.Del_FactExpRelEmpaque on dbo.FACTEXPRELEMPAQUE for DELETE as
BEGIN

   IF EXISTS (SELECT * FROM FactExpDet ,deleted WHERE FactExpDet.fed_indiced = deleted.fed_indiced)
      UPDATE FactExpDet SET FED_RELEMP = 'N' FROM FactExpDet ,deleted WHERE FactExpDet.fed_indiced = deleted.fed_indiced


END




























GO
