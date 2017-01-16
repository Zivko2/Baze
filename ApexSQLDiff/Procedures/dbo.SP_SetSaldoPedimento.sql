SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_SetSaldoPedimento (@nPidIndiced Int, @fSaldoPedimento decimal(38,6))   as

SET NOCOUNT ON 

	DECLARE @nPiCodigo Int

	select @nPiCodigo=pi_codigo from pedimpdet where pid_indiced=@nPidIndiced


	UPDATE PEDIMP 
	SET PI_AFECTADO = 'S' 
	WHERE PI_CODIGO = @nPiCodigo
	and PI_AFECTADO <> 'S'


	UPDATE PIDESCARGA
	SET PID_SALDOGEN=@fSaldoPedimento
	WHERE PID_INDICED=@nPidIndiced








GO
