SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE trigger dbo.Del_FactImpRelEmpaque on dbo.FACTIMPRELEMPAQUE for DELETE as
BEGIN

   IF EXISTS (SELECT * FROM FactImpDet ,deleted WHERE FactImpDet.fid_indiced = deleted.fid_indiced)
      UPDATE FactImpDet SET FID_RELEMP = 'N' FROM FactImpDet ,deleted WHERE FactImpDet.fid_indiced = deleted.fid_indiced


END



































GO
