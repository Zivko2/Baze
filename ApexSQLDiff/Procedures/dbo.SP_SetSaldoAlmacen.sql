SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_SetSaldoAlmacen (@ENDINDICED int, @SaldoAlmacen decimal(38,6))   as

SET NOCOUNT ON 
	DECLARE @EnCodigo Int
	select @EnCodigo=en_codigo from entsalalmdet where end_indiced=@endIndiced
	UPDATE ENTSALALMSALDO
	 SET END_USO_SALDO = 'S', 
	END_SALDOALM = @SaldoAlmacen  
	WHERE END_INDICED = @endIndiced
 RETURN
GO
