SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE trigger Del_CTransporPag on dbo.CTRANSPORPAG for DELETE as
begin


   IF EXISTS (SELECT * FROM CTransporPagDet ,deleted WHERE CTransporPagDet.ctp_codigo = deleted.ctp_codigo)
      DELETE CTransporPagDet FROM CTransporPagDet ,deleted WHERE CTransporPagDet.ctp_codigo = deleted.ctp_codigo

   IF EXISTS (SELECT * FROM CTransporPagOtros ,deleted WHERE CTransporPagOtros.ctp_codigo = deleted.ctp_codigo)
      DELETE CTransporPagOtros FROM CTransporPagOtros ,deleted WHERE CTransporPagOtros.ctp_codigo = deleted.ctp_codigo

end

































GO
