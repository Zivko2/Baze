SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE trigger Del_CTransporPagDet on dbo.CTRANSPORPAGDET for DELETE as
begin


   IF EXISTS (SELECT * FROM CTransporPagOtros ,deleted WHERE CTransporPagOtros.ctpd_indiced = deleted.ctpd_indiced)
      DELETE CTransporPagOtros FROM CTransporPagOtros ,deleted WHERE CTransporPagOtros.ctpd_indiced = deleted.ctpd_indiced

end



































GO
