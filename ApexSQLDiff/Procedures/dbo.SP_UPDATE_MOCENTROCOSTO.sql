SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_UPDATE_MOCENTROCOSTO(@NEWCOST decimal(38,6),  @TAFFECT INTEGER, @OLDCOST decimal(38,6) ,@AFFECTED INTEGER OUTPUT)   as

SET NOCOUNT ON 
BEGIN
	-- AFFECT ALL
	IF @TAFFECT = 1
	BEGIN
		UPDATE CENTROCOSTO SET CC_MO = @NEWCOST
	END
	SET @AFFECTED = ISNULL(@@ROWCOUNT,0)
	
	-- AFECT ONLY WITH 0
	IF @TAFFECT = 2
	BEGIN
		UPDATE CENTROCOSTO SET CC_MO = @NEWCOST WHERE CC_MO = 0
	END
	SET @AFFECTED = ISNULL(@@ROWCOUNT,0)
	
	-- AFECT WITH CUSTOM VALUE
	IF @TAFFECT = 3
	BEGIN
		UPDATE CENTROCOSTO SET CC_MO = @NEWCOST WHERE CC_MO = @OLDCOST
	END
	SET @AFFECTED = ISNULL(@@ROWCOUNT,0)



		UPDATE MAESTROCOST
		SET     MA_COSTO= ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
		                      MA_NG_ADD + MA_NG_EMP,6)
		FROM         MAESTROCOST
		WHERE TCO_CODIGO=1 AND MA_PERINI <=GETDATE() and MA_PERFIN>= GETDATE() AND
		MA_COSTO<> ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
		                      MA_NG_ADD + MA_NG_EMP,6)
END





















GO
