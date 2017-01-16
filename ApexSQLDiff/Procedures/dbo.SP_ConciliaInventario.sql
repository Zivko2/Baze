SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



























CREATE PROCEDURE [dbo].[SP_ConciliaInventario] (@fechaini datetime, @fechafin datetime)   as

-- para poder correr este procedimiento se deberan tener antes descargadas las facturas de exportacion del periodo y haber corrido el proceso de sp_calculainventarios


	--respalda la tabla pidescarga
	SELECT     PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
	                      PI_DEFINITIVO, DI_DEST_ORIGEN
	INTO       dbo.PIDESCARGARespaldo
	FROM         PIDescarga

	EXEC SP_DROPTABLE 'PIDESCARGA'

	-- genera la tabla pidescarga
	exec sp_CreaPIDescarga

	-- llena la tabla PIDESCARGA solo con las cantidades que debe de descargar
	INSERT INTO PIDESCARGA(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
	                      PI_DEFINITIVO, DI_DEST_ORIGEN)
	
	SELECT     TOP 100 PERCENT PIDESCARGARespaldo.PI_CODIGO, PIDESCARGARespaldo.PID_INDICED, TEMP_INVENTARIOS.FED_SALDOGEN, PIDESCARGARespaldo.MA_CODIGO, PIDESCARGARespaldo.MA_GENERICO, 
	                      PIDESCARGARespaldo.PI_FEC_ENT, PIDESCARGARespaldo.pid_fechavence, PIDESCARGARespaldo.PI_ACTIVOFIJO, 
	                      PIDESCARGARespaldo.PI_DEFINITIVO, DI_DEST_ORIGEN
	FROM         TEMP_INVENTARIOS INNER JOIN
	                      PIDESCARGARespaldo ON TEMP_INVENTARIOS.PID_INDICED = PIDESCARGARespaldo.PID_INDICED
	WHERE      (TEMP_INVENTARIOS.FED_SALDOGEN > 0)
	ORDER BY PIDESCARGARespaldo.MA_GENERICO


	-- descarga las facturas sin descargar por grupo generico, solamente tomando en cuenta el inventario de lo que se debe de descargar
	exec sp_DescargaFactExpPeriodo  @fechaini, @fechafin, 1, 'S'


	 exec SP_AJUSTAVENCE1 @fechaini, @fechafin

	INSERT INTO PIDESCARGA(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
	                      PI_DEFINITIVO, DI_DEST_ORIGEN)
	
	SELECT     PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
	                      PI_DEFINITIVO, DI_DEST_ORIGEN
	FROM         PIDESCARGARespaldo
	WHERE     PID_INDICED NOT IN (SELECT pid_indiced FROM pidescarga)

	-- regresa los saldos y actualiza los estatus
	exec sp_reestructuradescargas 1

	exec sp_reestructuradescargas 1

	exec sp_droptable 'PIDESCARGARespaldo'



























GO
