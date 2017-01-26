SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE [dbo].[SP_temp_13023]   as


		-- EN CASO DE QUE EXISTAN REPEDIDAS CON DIFERENTE TIPO
	/*------------------*/
	IF EXISTS(select fc_codigo from factcons 
	where FC_FOLIO + CONVERT(varchar(10), AGT_CODIGO)
	in (SELECT FC_FOLIO + CONVERT(varchar(10), AGT_CODIGO) 
 	    FROM FACTCONS GROUP BY FC_FOLIO + CONVERT(varchar(10), AGT_CODIGO)
 	    HAVING COUNT(*) > 1))
	BEGIN
		INSERT INTO AGENCIA (AG_TIPO, AG_NOMBRE)
		SELECT 'M', 'TEMPORAL INTRADE'
	
	
		INSERT INTO AGENCIAPATENTE(AGT_CODIGO, AG_CODIGO, AGT_NOMBRE, AGT_RFC, AGT_CURP, AGT_PATENTE, AGT_DEFAULT)
		SELECT     AG_CODIGO, AG_CODIGO,'', '', '',  AG_PATENTE, 'S'
		FROM         AGENCIA
		WHERE AG_NOMBRE ='TEMPORAL INTRADE'
	END
	/*------------------*/	

	/* ACTUALIZA LOS REGISTROS REPETIDOS CON EL REGISTRO TEMPORAL DE AGENCIA */
	update factcons
	set agt_codigo=(SELECT AG_CODIGO FROM AGENCIA WHERE AG_NOMBRE ='TEMPORAL INTRADE')
	where fc_codigo in
	(select fc_codigo from factcons 
	where FC_FOLIO + CONVERT(varchar(10), AGT_CODIGO)
	in (SELECT FC_FOLIO + CONVERT(varchar(10), AGT_CODIGO) 
 	    FROM FACTCONS GROUP BY FC_FOLIO + CONVERT(varchar(10), AGT_CODIGO)
 	    HAVING COUNT(*) > 1))
	and fc_codigo not in 
	(select min(A.fc_codigo) from factcons A
	where A.FC_FOLIO + CONVERT(varchar(10), A.AGT_CODIGO) in
		(SELECT B.FC_FOLIO + CONVERT(varchar(10), B.AGT_CODIGO)
		FROM FACTCONS B
		GROUP BY B.FC_FOLIO + CONVERT(varchar(10), B.AGT_CODIGO)
		HAVING COUNT(*) > 1)
		group by A.FC_FOLIO + CONVERT(varchar(10), A.AGT_CODIGO))


	UPDATE PEDIMPDET
	SET PEDIMPDET.PID_SECUENCIA= PEDIMPDETB.PIB_SECUENCIA 
             FROM PEDIMPDETB INNER JOIN PEDIMPDET ON PEDIMPDETB.PIB_INDICEB = PEDIMPDET.PIB_INDICEB 
	WHERE PEDIMPDET.PID_SECUENCIA IS NULL


	delete from pidescarga where pi_codigo not in (select pi_codigo from vpedimp)
	delete from pidescarga where pid_indiced not in (select pid_indiced from vpedimp inner join pedimpdet on vpedimp.pi_codigo=pedimpdet.pi_codigo)

	UPDATE FACTEXP
	SET FE_DESCMANUAL='S' 
	WHERE tf_codigo in (select tf_codigo from configuratfact where cff_tipodescarga='M')

	/*UPDATE PIDescarga
	SET     PIDescarga.PA_ORIGEN= ISNULL(PEDIMPDET.PA_ORIGEN,233)
	FROM         PIDescarga INNER JOIN
	                      PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED
	WHERE PIDescarga.PA_ORIGEN IS NULL

	*/

























GO
