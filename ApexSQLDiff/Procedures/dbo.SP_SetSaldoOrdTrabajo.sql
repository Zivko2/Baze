SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_SetSaldoOrdTrabajo (@OtdIndiced Int, @SaldoOrden decimal(38,6), @OTDP_INDICEP int)   as

SET NOCOUNT ON 
	DECLARE @OtCodigo Int, @cantdescargada decimal(38,6)

	select @OtCodigo=ot_codigo from OrdTrabajodet where otd_indiced=@OtdIndiced

	if @OTDP_INDICEP=0
	begin
		UPDATE ORDTRABAJODET
		 SET OTD_ENUSO = 'S', 
		OTD_SALDO = @SaldoOrden
		WHERE OTD_INDICED = @OtdIndiced
	end
	else
	begin
		SELECT     @cantdescargada=SUM(LIP_CANTDESC)
		FROM         PRODUCLIGA
		WHERE     (OTD_INDICED = @OtdIndiced)


		UPDATE ORDTRABAJODET
		 SET OTD_ENUSO = 'S', 
		OTD_SALDO = OTD_SIZELOTE-@cantdescargada
		WHERE OTD_INDICED = @OtdIndiced


		UPDATE ORDTRABAJODETENTPARCIAL
		 SET OTDP_ENUSO = 'S', 
		OTDP_SALDO = @SaldoOrden
		WHERE OTDP_INDICEP = @OTDP_INDICEP

	end

 RETURN









GO
