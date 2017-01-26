SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_REPPPSIMPDEFMAT ( @DAPCODIGO INT)   as

SET NOCOUNT ON 

DECLARE @IMPDEFINITIVAS decimal(38,6), @IMPDEFINITIVASdlls decimal(38,6)


if exists (select * FROM VREPPPSIMPDEFMAT WHERE     DAP_CODIGO = @DAPCODIGO)
begin
DECLARE CUR_DECANUALPPSTIMPDEFMAT CURSOR FOR

SELECT     SUM(VALOR), SUM(DLLS)
FROM         VREPPPSIMPDEFMAT
WHERE     DAP_CODIGO = @DAPCODIGO
GROUP BY DAP_CODIGO
OPEN CUR_DECANUALPPSTIMPDEFMAT
		
FETCH NEXT FROM CUR_DECANUALPPSTIMPDEFMAT INTO @IMPDEFINITIVAS, @IMPDEFINITIVASdlls

WHILE (@@FETCH_STATUS = 0) 
BEGIN


	UPDATE DECANUALPPS
	SET DAP_IMPDEFINITIVASMAT= floor(round(@IMPDEFINITIVAS, 0)/1000), DAP_IMPDEFINITIVASMATUSD= floor(round(@IMPDEFINITIVASdlls, 0)/1000)
	WHERE DECANUALPPS.DAP_CODIGO = @DAPCODIGO

	FETCH NEXT FROM CUR_DECANUALPPSTIMPDEFMAT INTO @IMPDEFINITIVAS, @IMPDEFINITIVASdlls

END


CLOSE CUR_DECANUALPPSTIMPDEFMAT
DEALLOCATE CUR_DECANUALPPSTIMPDEFMAT
end
else
begin
	UPDATE DECANUALPPS
	SET DAP_IMPDEFINITIVASMAT=0, DAP_IMPDEFINITIVASMATUSD=0
	WHERE DECANUALPPS.DAP_CODIGO = @DAPCODIGO

end



























GO
