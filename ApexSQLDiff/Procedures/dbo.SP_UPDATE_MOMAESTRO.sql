SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* Actualiza el campo de mano de obra en el catalogo maestro */
CREATE PROCEDURE dbo.SP_UPDATE_MOMAESTRO(@NEWCOST decimal(38,6), @TAFFECT INTEGER, @OLDCOST decimal(38,6), @PTSUB VARCHAR(1), @AFFECTED INTEGER OUTPUT)  as

SET NOCOUNT ON 
BEGIN

declare @NEWCOST1 decimal(38,6), @OLDCOST1 decimal(38,6), @TCO_MANUFACTURA INT

	set @NEWCOST1= round(@NEWCOST,6)
	set @OLDCOST1= round(@OLDCOST,6)


	SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA FROM dbo.CONFIGURACION

-- AFFECT ALL
IF @TAFFECT = 1
BEGIN
	IF @PTSUB = 'P' 
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE CFT_TIPO = 'P'))
		AND TCO_CODIGO=@TCO_MANUFACTURA

	ELSE
	IF @PTSUB = 'S' 
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE CFT_TIPO = 'S'))
		AND TCO_CODIGO=@TCO_MANUFACTURA
	ELSE
       	IF @PTSUB = 'A' 
		UPDATE MAESTROCOSTCOST SET MA_GRAV_MO = @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE (CFT_TIPO = 'P') AND (CFT_TIPO = 'S')))
		AND TCO_CODIGO=@TCO_MANUFACTURA


	SET @AFFECTED = isnull(@@ROWCOUNT,0)
END
ELSE
-- AFECT ONLY WITH 0
IF @TAFFECT = 2
BEGIN

	IF @PTSUB = 'P' 
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE CFT_TIPO = 'P'))
		AND (MA_GRAV_MO = 0) AND TCO_CODIGO=@TCO_MANUFACTURA
	ELSE
       	IF @PTSUB = 'S' 
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE CFT_TIPO = 'S'))
		AND (MA_GRAV_MO = 0) AND TCO_CODIGO=@TCO_MANUFACTURA
	ELSE
        	IF @PTSUB = 'A'
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE (CFT_TIPO = 'P') AND (CFT_TIPO = 'S')))
		AND (MA_GRAV_MO = 0) AND TCO_CODIGO=@TCO_MANUFACTURA

	 SET @AFFECTED = isnull(@@ROWCOUNT,0)
END
ELSE
-- AFECT WITH CUSTOM VALUE
IF @TAFFECT = 3
BEGIN

	IF @PTSUB = 'P'
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE CFT_TIPO = 'P'))
		AND (MA_GRAV_MO = @OLDCOST1) AND TCO_CODIGO=@TCO_MANUFACTURA
	ELSE
       	IF @PTSUB = 'S' 
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE CFT_TIPO = 'S'))
		AND (MA_GRAV_MO = @OLDCOST1) AND TCO_CODIGO=@TCO_MANUFACTURA
	ELSE
        	IF @PTSUB = 'A'
		UPDATE MAESTROCOST SET MA_GRAV_MO= @NEWCOST1 FROM MAESTROCOST
		WHERE MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTRO WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM  CONFIGURATIPO WHERE (CFT_TIPO = 'P') AND (CFT_TIPO = 'S')))
		AND (MA_GRAV_MO = @OLDCOST1) AND TCO_CODIGO=@TCO_MANUFACTURA

	SET @AFFECTED = isnull(@@ROWCOUNT ,0)


END

	IF @PTSUB = 'P'			
	update maestrocost
	set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
	isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
	where tco_codigo=@tco_manufactura and ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P')) 


	IF @PTSUB = 'S'			
	update maestrocost
	set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
	isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
	where tco_codigo=@tco_manufactura and ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='S')) 
  
	IF @PTSUB = 'A'			
	update maestrocost
	set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
	isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
	where tco_codigo=@tco_manufactura and ma_codigo in (select ma_codigo from maestro where ti_codigo in (select ti_codigo from configuratipo where cft_tipo='S' or cft_tipo='P')) 

END




GO
