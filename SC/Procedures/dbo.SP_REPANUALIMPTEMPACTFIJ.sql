SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























/*Importaciones temporales de activo fijo*/
CREATE PROCEDURE dbo.SP_REPANUALIMPTEMPACTFIJ ( @DANCODIGO INT)   as

SET NOCOUNT ON 

DECLARE @TOTIMPTEMP1 decimal(38,6), @TOTIMPTEMP1dlls decimal(38,6)

/*if exists (select * 	FROM VREPANUALIMPTEMPACTFIJ
	WHERE DAN_CODIGO=@DANCODIGO)
begin*/

	
		SELECT @TOTIMPTEMP1= SUM(valor), @TOTIMPTEMP1dlls=SUM(PID_CTOT_DLS)
		FROM VREPANUALIMPTEMPACTFIJ
		WHERE DAN_CODIGO=@DANCODIGO
		GROUP BY DAN_CODIGO 

	
		if @TOTIMPTEMP1=0 or @TOTIMPTEMP1 is null
		set @TOTIMPTEMP1=@TOTIMPTEMP1dlls
	
	
		UPDATE DECANUALNVA
		SET DAN_IMPTEMPACTFIJ = isnull(floor(round(@TOTIMPTEMP1, 0)/1000),0),  DAN_IMPTEMPACTFIJUSD= isnull(floor(round(@TOTIMPTEMP1dlls, 0)/1000),0)
		WHERE DECANUALNVA.DAN_CODIGO = @DANCODIGO
	

/*end
else
begin
		UPDATE DECANUALNVA
		SET DAN_IMPTEMPACTFIJ=0,  DAN_IMPTEMPACTFIJUSD= 0
		WHERE DECANUALNVA.DAN_CODIGO = @DANCODIGO

end
*/



























GO
