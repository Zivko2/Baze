SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE dbo.SP_REPANUALMDONACMAT ( @DANCODIGO INT)   as

SET NOCOUNT ON 

DECLARE @MERCADONAC decimal(38,6), @MERCADONACdlls decimal(38,6)


/*if exists (select * 	FROM VREPANUALMDONACMAT WHERE DAN_CODIGO=@DANCODIGO)
begin*/

	
		SELECT @MERCADONAC=SUM(VALOR), @MERCADONACdlls=SUM(PID_CTOT_DLS)
		FROM VREPANUALMDONACMAT
		WHERE DAN_CODIGO=@DANCODIGO
		GROUP BY DAN_CODIGO 


	
		UPDATE DECANUALNVA
		SET DAN_MERCADONACMAT= isnull(floor(round(@MERCADONAC, 0)/1000),0),  DAN_MERCADONACMATUSD= isnull(floor(round(@MERCADONACdlls, 0)/1000),0)
		WHERE DECANUALNVA.DAN_CODIGO = @DANCODIGO
	

/*end
else
begin
	UPDATE DECANUALNVA
	SET DAN_MERCADONACMAT=0,  DAN_MERCADONACMATUSD= 0
	WHERE DECANUALNVA.DAN_CODIGO = @DANCODIGO

end*/






































GO
