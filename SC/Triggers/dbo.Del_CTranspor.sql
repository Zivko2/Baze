SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE trigger Del_CTranspor on dbo.CTRANSPOR for DELETE as
begin


   IF EXISTS (SELECT * FROM RelCTransporMedioTran ,deleted WHERE RelCTransporMedioTran.ct_codigo = deleted.ct_codigo)
      DELETE RelCTransporMedioTran FROM RelCTransporMedioTran ,deleted WHERE RelCTransporMedioTran.ct_codigo = deleted.ct_codigo


   IF EXISTS (SELECT * FROM CTransporRango ,deleted WHERE CTransporRango.ct_codigo = deleted.ct_codigo)
      DELETE CTransporRango FROM CTransporRango ,deleted WHERE CTransporRango.ct_codigo = deleted.ct_codigo

   IF EXISTS (SELECT * FROM CTransporAdic ,deleted WHERE CTransporAdic.ct_codigo = deleted.ct_codigo)
      DELETE CTransporAdic FROM CTransporAdic ,deleted WHERE CTransporAdic.ct_codigo = deleted.ct_codigo

end


































GO
