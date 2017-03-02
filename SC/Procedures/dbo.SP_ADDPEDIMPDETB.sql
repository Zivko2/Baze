SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_ADDPEDIMPDETB (@PI_CODIGO INTEGER)    as

SET NOCOUNT ON 
BEGIN
  BEGIN TRAN DETALLEB
  SAVE TRAN DETALLEB
  DECLARE @ERRORES INT
  SET @ERRORES  = 0

	DELETE FROM PEDIMPDETB WHERE PI_CODIGO = @PI_CODIGO
	IF (@@ERROR <> 0 ) SET @ERRORES = 1
  
	INSERT INTO PEDIMPDETB (PI_CODIGO,PIB_VAL_FAC, PIB_VAL_ADU,PIB_VAL_US,AR_IMPMX)
	SELECT @PI_CODIGO, SUM(PEDIMPDET.PID_CTOT_DLS * PEDIMP.PI_TIP_CAM), SUM(PID_VAL_ADU),SUM(PID_CTOT_DLS),AR_IMPMX
	FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO=PEDIMP.PI_CODIGO
	WHERE PEDIMPDET.PI_CODIGO = @PI_CODIGO GROUP BY AR_IMPMX
	IF (@@ERROR <> 0 ) SET @ERRORES = 1
	
	UPDATE PEDIMPDETB  SET PIB_ESTADO = A.AR_CODIGO FROM PEDIMPDETB AS P,ARANCEL AS A 
	WHERE P.PI_CODIGO = @PI_CODIGO AND A.AR_CODIGO = P.AR_IMPMX
	IF (@@ERROR <> 0 ) SET @ERRORES = 1

 COMMIT TRAN DETALLEB
IF @ERRORES = 0 
 RETURN(0)
ELSE
  BEGIN
    ROLLBACK TRAN DETALLEB
    RETURN(1)
  END
END



























GO