SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























/*Importaciones temporales de materia prima*/
CREATE PROCEDURE dbo.SP_REPANUALIMPTEMPMAT ( @DANCODIGO INT)   as

SET NOCOUNT ON 

DECLARE @TOTIMPTEMP1 decimal(38,6), @TOTIMPTEMP1dlls decimal(38,6)

/*if exists (select * 	FROM VREPANUALIMPTEMPMAT
	WHERE DAN_CODIGO=@DANCODIGO)
begin*/

	
		SELECT @TOTIMPTEMP1=SUM(valor), @TOTIMPTEMP1dlls=SUM(PID_CTOT_DLS)
		FROM VREPANUALIMPTEMPMAT
		WHERE DAN_CODIGO=@DANCODIGO
		GROUP BY DAN_CODIGO 
	
	
		if @TOTIMPTEMP1=0 or @TOTIMPTEMP1 is null
		set @TOTIMPTEMP1=@TOTIMPTEMP1dlls
	
	
		UPDATE DECANUALNVA
		SET DAN_IMPTEMPMAT= isnull(floor(round(@TOTIMPTEMP1, 0)/1000),0),  DAN_IMPTEMPMATUSD= isnull(floor(round(@TOTIMPTEMP1dlls, 0)/1000),0)
		WHERE DECANUALNVA.DAN_CODIGO = @DANCODIGO
	
	

/*end
else
begin
		UPDATE DECANUALNVA
		SET DAN_IMPTEMPMAT=0,  DAN_IMPTEMPMATUSD= 0
		WHERE DECANUALNVA.DAN_CODIGO = @DANCODIGO

end
*/



























GO
