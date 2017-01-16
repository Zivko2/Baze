SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[LlenaPIDescargaNoDescInicial] (@fe_fecha varchar(11)='01/01/1900')   as


		if exists (select * from dbo.sysobjects where name='PIDescargaNoDescargables')
	begin
		ALTER TABLE PIDESCARGA DISABLE TRIGGER [INSERT_PIDESCARGA]
	
			-- REGRESA LOS REGISTROS SIN SALDO A LA TABLA PIDESCARGA
			INSERT INTO PIDESCARGA (PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
			                      PID_SALDOINCORRECTO, PI_DEFINITIVO, DI_DEST_ORIGEN)
			SELECT     PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
			                      PID_SALDOINCORRECTO, PI_DEFINITIVO, DI_DEST_ORIGEN
			FROM PIDescargaNoDescargables
			WHERE     PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDESCARGA)
	
		ALTER TABLE PIDESCARGA ENABLE TRIGGER [INSERT_PIDESCARGA]
	
		exec sp_droptable 'PIDescargaNoDescargables'
	end




		SELECT     PI_CODIGO, PID_INDICED, ISNULL(PID_SALDOGEN,0) AS PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_ACTIVOFIJO, 
		                      PID_SALDOINCORRECTO, PI_DEFINITIVO, DI_DEST_ORIGEN
		INTO dbo.PIDescargaNoDescargables
		FROM         PIDescarga
		WHERE PID_SALDOGEN = 0 OR PID_SALDOGEN IS NULL


		delete from PIDESCARGA where PID_SALDOGEN = 0 OR PID_SALDOGEN IS NULL

		
	
	-- saldo incompleto, esto para saber si los saldos en cero estan borrados
	update configuracion
	set cf_pedsaldoinc='S'

		
	

GO
