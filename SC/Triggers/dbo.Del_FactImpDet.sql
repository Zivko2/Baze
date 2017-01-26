SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger Del_FactImpDet on dbo.FACTIMPDET for DELETE as
SET NOCOUNT ON
begin
DECLARE
 @PckListCant decimal(38,6), @FactCantst decimal(38,6), @PckListSaldo decimal(38,6), @OrdCompraCant decimal(38,6), @or_codigo int, @fid_indiced int


   IF EXISTS (SELECT * FROM FactImpCont ,deleted WHERE FactImpCont.fid_indiced = deleted.fid_indiced)
      DELETE FactImpCont FROM FactImpCont ,deleted WHERE FactImpCont.fid_indiced = deleted.fid_indiced

   IF EXISTS (SELECT * FROM FactImpPed ,deleted WHERE FactImpPed.fid_indiced = deleted.fid_indiced)
      DELETE FactImpPed FROM FactImpPed ,deleted WHERE FactImpPed.fid_indiced = deleted.fid_indiced

   IF EXISTS (SELECT * FROM FactImpPerm ,deleted WHERE FactImpPerm.fid_indiced = deleted.fid_indiced)
      DELETE FactImpPerm FROM FactImpPerm ,deleted WHERE FactImpPerm.fid_indiced = deleted.fid_indiced


   IF EXISTS (SELECT * FROM FactImpDetIdentifica ,deleted WHERE FactImpDetIdentifica.fid_indiced = deleted.fid_indiced)
      DELETE FactImpDetIdentifica FROM FactImpDetIdentifica ,deleted WHERE FactImpDetIdentifica.fid_indiced = deleted.fid_indiced


   IF EXISTS (SELECT * FROM FactImpDetDef ,deleted WHERE FactImpDetDef.fid_indiced = deleted.fid_indiced)
      DELETE FactImpDetDef FROM FactImpDetDef ,deleted WHERE FactImpDetDef.fid_indiced = deleted.fid_indiced


--   IF EXISTS (SELECT * FROM FactImpDetCargo ,deleted WHERE FactImpDetCargo.fid_indiced = deleted.fid_indiced)
--      DELETE FactImpDetCargo FROM FactImpDetCargo ,deleted WHERE FactImpDetCargo.fid_indiced = deleted.fid_indiced

    /* Se Actualiza el saldo de ListaExpdet */
   IF EXISTS(   SELECT * FROM PckListdet, deleted   WHERE PckListdet.pl_codigo = deleted.pl_codigo 
        AND PckListdet.pld_indiced = deleted.pld_indiced ) 
  BEGIN
	  SELECT @PckListCant = PckListdet.pld_cant_st, @FactCantst = Deleted.fid_cant_st FROM PckListdet, deleted  
	    WHERE PckListdet.pl_codigo = deleted.pl_codigo AND PckListdet.pld_indiced = deleted.pld_indiced

	    IF @PckListCant = @FactCantst
	       UPDATE PckListdet SET PckListdet.pld_saldo = PckListdet.pld_cant_st, PckListdet.pld_enuso = 'N'
	       FROM PckListdet, deleted
	       WHERE PckListdet.pl_codigo = deleted.pl_codigo AND PckListdet.pld_indiced = deleted.pld_indiced
	    ELSE IF @PckListCant > @FactCantst
	       UPDATE PckListdet SET PckListdet.pld_saldo = PckListdet.pld_saldo + deleted.fid_cant_st
	       FROM PckListdet, deleted
	       WHERE PckListdet.pl_codigo = deleted.pl_codigo AND PckListdet.pld_indiced = deleted.pld_indiced
	
		  /* Se actualiza el estatus de ListaExp */ 
		   IF NOT EXISTS (SELECT * FROM PckListdet, deleted 
		   WHERE PckListdet.pl_codigo = deleted.pl_codigo AND PckListdet.pld_enuso = 'S' ) 
		         UPDATE PckList SET PckList.pl_estatus = 'A'  
		         FROM PckList, deleted  WHERE PckList.pl_codigo = deleted.pl_codigo 
	
		exec SP_CORRIGEPCKLISTSALDOS
  END

	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TempOrdCompAbiertas]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	begin
	   IF EXISTS(   SELECT * FROM TempOrdCompAbiertas, deleted   WHERE TempOrdCompAbiertas.ContractNbr = deleted.FID_ORD_COMP 
	        AND TempOrdCompAbiertas.ContractNbr = deleted.FID_ORD_COMP ) 
	  BEGIN
	   
		UPDATE TempOrdCompAbiertas
		SET     SaldoQty = OutstdQty - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
							       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO<>'V' 
							       AND FACTIMPDET.FID_ORD_COMP = TempOrdCompAbiertas.ContractNbr),0)
		WHERE SaldoQty <> OutstdQty - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
							       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO<>'V' 
                                                                                                    AND FACTIMPDET.FID_ORD_COMP = TempOrdCompAbiertas.ContractNbr),0)
	
		UPDATE TempOrdCompAbiertas
		SET     SaldoQty = OutstdQty
		WHERE TempOrdCompAbiertas.ContractNbr NOT IN (SELECT FID_ORD_COMP FROM FACTIMPDET INNER JOIN FACTIMP ON
							       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO<>'V' AND FID_ORD_COMP IS NOT NULL)
	
	  END
	end

	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TempOrdCompCerradas]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	begin

	   IF EXISTS(   SELECT * FROM TempOrdCompCerradas, deleted   WHERE TempOrdCompCerradas.ORDER_NUMBER = deleted.FID_ORD_COMP 
	        AND TempOrdCompCerradas.ORDER_NUMBER = deleted.FID_ORD_COMP ) 
	  BEGIN
	   
		UPDATE TempOrdCompCerradas
		SET     SaldoQty = QTY_RECVD - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
							       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO='V'
				                                                AND FACTIMPDET.FID_ORD_COMP = TempOrdCompCerradas.ORDER_NUMBER),0)
		WHERE SaldoQty <> QTY_RECVD - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
							       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO='V' 
                                                                                                    AND FACTIMPDET.FID_ORD_COMP = TempOrdCompCerradas.ORDER_NUMBER),0)
	
		UPDATE TempOrdCompCerradas
		SET     SaldoQty = QTY_RECVD
		WHERE TempOrdCompCerradas.ORDER_NUMBER NOT IN (SELECT FID_ORD_COMP FROM FACTIMPDET INNER JOIN FACTIMP ON
							       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO='V' AND FID_ORD_COMP IS NOT NULL)
	
	  END
	end	
	    /* Se Actualiza el saldo de OrdCompradet */
/*	   IF EXISTS(   SELECT * FROM OrdCompraDet, deleted   WHERE OrdCompraDet.or_codigo = deleted.or_codigo 
	        AND OrdCompraDet.ord_indiced = deleted.ord_indiced ) 
	  BEGIN
	  SELECT @OrdCompraCant = OrdCompraDet.ord_cant_st, @FactCantst = Deleted.fid_cant_st FROM OrdCompraDet, deleted  
	    WHERE OrdCompraDet.or_codigo = deleted.or_codigo AND OrdCompraDet.ord_indiced = deleted.ord_indiced
	
	    IF @OrdCompraCant = @FactCantst
	       UPDATE OrdCompraDet SET OrdCompraDet.ord_saldo = OrdCompraDet.ord_cant_st, OrdCompraDet.ord_enuso = 'N'
	       FROM OrdCompraDet, deleted
	       WHERE OrdCompraDet.or_codigo = deleted.or_codigo AND OrdCompraDet.ord_indiced = deleted.ord_indiced
	    ELSE IF @OrdCompraCant > @FactCantst
	       UPDATE OrdCompraDet SET OrdCompraDet.ord_saldo = OrdCompraDet.ord_saldo + deleted.fid_cant_st
	       FROM OrdCompraDet, deleted
	       WHERE OrdCompraDet.or_codigo = deleted.or_codigo AND OrdCompraDet.ord_indiced = deleted.ord_indiced

		select @or_codigo=or_codigo from deleted
		

		exec SP_ACTUALIZAESTATUSORDCOMPRA @or_codigo

	  END*/




end


GO
