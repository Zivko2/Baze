SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE trigger Del_PcklistDet on dbo.PCKLISTDET for DELETE as
SET NOCOUNT ON 
declare @OrdCompraCant decimal(38,6),  @PckCantst decimal(38,6), @or_codigo int

	 if Exists( select * from PckListCont ,deleted where PckListCont.PLD_indiced = deleted.PLD_indiced)
	   delete PckListCont from PckListCont ,deleted where PckListCont.PLD_indiced = deleted.PLD_indiced

	    /* Se Actualiza el saldo de OrdCompradet */
/*	   IF EXISTS(SELECT * FROM OrdCompraDet, deleted   WHERE OrdCompraDet.or_codigo = deleted.or_codigo 
	        AND OrdCompraDet.ord_indiced = deleted.ord_indiced ) 
	  BEGIN
	  SELECT @OrdCompraCant = OrdCompraDet.ord_cant_st, @PckCantst = Deleted.pld_cant_st FROM OrdCompraDet, deleted  
	    WHERE OrdCompraDet.or_codigo = deleted.or_codigo AND OrdCompraDet.ord_indiced = deleted.ord_indiced
	
	    IF @OrdCompraCant = @PckCantst
	       UPDATE OrdCompraDet SET OrdCompraDet.ord_saldo = OrdCompraDet.ord_cant_st, OrdCompraDet.ord_enuso = 'N'
	       FROM OrdCompraDet, deleted
	       WHERE OrdCompraDet.or_codigo = deleted.or_codigo AND OrdCompraDet.ord_indiced = deleted.ord_indiced
	    ELSE IF @OrdCompraCant > @PckCantst
	       UPDATE OrdCompraDet SET OrdCompraDet.ord_saldo = OrdCompraDet.ord_saldo + deleted.pld_cant_st
	       FROM OrdCompraDet, deleted
	       WHERE OrdCompraDet.or_codigo = deleted.or_codigo AND OrdCompraDet.ord_indiced = deleted.ord_indiced

		select @or_codigo=or_codigo from deleted
		

		exec SP_ACTUALIZAESTATUSORDCOMPRA @or_codigo

	  END*/




































GO
