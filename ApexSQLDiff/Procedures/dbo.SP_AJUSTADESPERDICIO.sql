SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  dbo.SP_AJUSTADESPERDICIO (@BorraAntes char(1), @FechaIniFact VARCHAR(11), @FechaFinFact VARCHAR(11), @porFamiliaDesp char(1)='S')   as

--exec sp_generaTempConciliaDesp @FechaIniPed, @FechaFinPed

	exec sp_droptable 'TEMP_RETRABAJO'
	exec sp_droptable 'TEMP_RETRABAJO1'
	exec SP_GENERATEMP_RETRABAJO


	select * from tempConciliaDesp
	--toma en cuenta solo las facturas de desperdicio que se encuentran en el periodo asignado

	if @porFamiliaDesp='S'
	begin
		-- en este caso solo incluye en la estructura dinamica los que pertenecen a la misma familia de desperdicio

		INSERT INTO TEMP_RETRABAJO (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					        TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)
		
		SELECT     'F', FACTEXPDET.FE_CODIGO, FACTEXPDET.FED_INDICED, tempConciliaDesp.MA_CODIGO, tempConciliaDesp.MA_NOPARTE, 
			(SELECT MA_NOMBRE FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT MA_NAME FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO),
			dbo.trunc((FACTEXPDET.FED_CANT/ (SELECT sum(FACTEXPDET.FED_CANT) 
							FROM FACTEXP INNER JOIN FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO INNER JOIN
	     		             				CONFIGURATEMBARQUE ON FACTEXP.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
						              tempConciliaDesp tempConciliaDesp1 ON FACTEXP.FE_FECHA >= tempConciliaDesp1.PI_FEC_ENT AND FACTEXP.FE_FECHA >= tempConciliaDesp1.pid_fechavence
							WHERE FACTEXP.FE_DESCARGADA='N' AND FACTEXP.FE_CANCELADO='N' AND CONFIGURATEMBARQUE.CFQ_TIPO = 'D' AND tempConciliaDesp1.PID_INDICED = tempConciliaDesp.PID_INDICED
							GROUP BY tempConciliaDesp1.PID_INDICED)* tempConciliaDesp.FED_SALDOGEN)/FACTEXPDET.FED_CANT,6), 
			(SELECT TI_CODIGO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO IN(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO)),
			(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO IN(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO)),
			1, 1, 'N', (SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT PA_ORIGEN FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO)
		FROM         FACTEXP INNER JOIN
		                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO INNER JOIN
		                      CONFIGURATEMBARQUE ON FACTEXP.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
		                      tempConciliaDesp ON FACTEXP.FE_FECHA >= tempConciliaDesp.PI_FEC_ENT AND FACTEXP.FE_FECHA >= tempConciliaDesp.pid_fechavence
		WHERE     FACTEXP.FE_DESCARGADA='N' AND FACTEXP.FE_CANCELADO='N'  AND CONFIGURATEMBARQUE.CFQ_TIPO = 'D' and
			     FACTEXP.FE_FECHA >=@FechaIniFact  and FACTEXP.FE_FECHA <= @FechaFinFact
		AND FACTEXPDET.FED_CANT>0 and tempConciliaDesp.MA_CODIGO IN 
		(SELECT M2.MA_CODIGO FROM MAESTRO M2 WHERE M2.MA_FAMILIAMP IN 
			(SELECT M1.MA_FAMILIAMP FROM MAESTRO M1 WHERE M1.MA_CODIGO=FACTEXPDET.MA_CODIGO))


	end
	else
	begin

		INSERT INTO TEMP_RETRABAJO (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					        TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)
		
		SELECT     'F', FACTEXPDET.FE_CODIGO, FACTEXPDET.FED_INDICED, tempConciliaDesp.MA_CODIGO, tempConciliaDesp.MA_NOPARTE, 
			(SELECT MA_NOMBRE FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT MA_NAME FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO),
			dbo.trunc((FACTEXPDET.FED_CANT/ (SELECT sum(FACTEXPDET.FED_CANT) 
							FROM FACTEXP INNER JOIN FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO INNER JOIN
	     		             				CONFIGURATEMBARQUE ON FACTEXP.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
						              tempConciliaDesp tempConciliaDesp1 ON FACTEXP.FE_FECHA >= tempConciliaDesp1.PI_FEC_ENT AND FACTEXP.FE_FECHA >= tempConciliaDesp1.pid_fechavence
							WHERE FACTEXP.FE_DESCARGADA='N' AND FACTEXP.FE_CANCELADO='N' AND CONFIGURATEMBARQUE.CFQ_TIPO = 'D' AND tempConciliaDesp1.PID_INDICED = tempConciliaDesp.PID_INDICED
							GROUP BY tempConciliaDesp1.PID_INDICED)* tempConciliaDesp.FED_SALDOGEN)/FACTEXPDET.FED_CANT,6), 
			(SELECT TI_CODIGO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO IN(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO)),
			(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO IN(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO)),
			1, 1, 'N', (SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO), (SELECT PA_ORIGEN FROM MAESTRO WHERE MA_CODIGO=tempConciliaDesp.MA_CODIGO)
		FROM         FACTEXP INNER JOIN
		                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO INNER JOIN
		                      CONFIGURATEMBARQUE ON FACTEXP.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
		                      tempConciliaDesp ON FACTEXP.FE_FECHA >= tempConciliaDesp.PI_FEC_ENT AND FACTEXP.FE_FECHA >= tempConciliaDesp.pid_fechavence
		WHERE     FACTEXP.FE_DESCARGADA='N' AND FACTEXP.FE_CANCELADO='N'  AND CONFIGURATEMBARQUE.CFQ_TIPO = 'D' and
			     FACTEXP.FE_FECHA >=@FechaIniFact  and FACTEXP.FE_FECHA <= @FechaFinFact
		AND FACTEXPDET.FED_CANT>0
	end

	exec sp_droptable 'FactExpAfectaDesp'
	SELECT FE_FOLIO, FE_FECHA
	INTO dbo.FactExpAfectaDesp
	FROM FACTEXP 
	WHERE FE_CODIGO IN (SELECT FETR_CODIGO FROM TEMP_RETRABAJO GROUP BY FETR_CODIGO)

	
	if @BorraAntes='S'
	begin
		-- los borra de la tabla de retrabajo
		DELETE FROM RETRABAJO WHERE (FETR_INDICED IN
		                          (SELECT     FETR_INDICED
		                            FROM          TEMP_RETRABAJO))
	end

	-- inserta a la tabla de temp_retrabajo lo que ya existe en retrabajo con el fin de hacer una agrupacion y no se repita la llave primaria
	INSERT INTO TEMP_RETRABAJO(TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, 
	                      RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)

	SELECT     TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR, TI_HIJO, 
	                      ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN
	FROM         RETRABAJO


	TRUNCATE TABLE RETRABAJO

	-- nada mas se inserta a la tabla TEMP_RETRABAJO1 para reiniciar el RE_INDICER

	INSERT INTO TEMP_RETRABAJO1(TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, 
	                      RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)


	SELECT    TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, MAX(RE_NOPARTE), MAX(RE_NOMBRE), MAX(RE_NAME), 
	                      SUM(RE_INCORPOR), MAX(TI_HIJO), MAX(ME_CODIGO), MAX(MA_GENERICO), MAX(ME_GEN), SUM(RE_INCORPORGEN), MAX(FACTCONV), 
	                      FETR_RETRABAJODES, MAX(FETR_NAFTA), MAX(PA_ORIGEN)
	FROM         TEMP_RETRABAJO	
	GROUP BY TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, FETR_RETRABAJODES


	-- los inserta pero ya agrupados
	INSERT INTO RETRABAJO(RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, 
	                      RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)
	
	SELECT     MAX(RE_INDICER), TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, MAX(RE_NOPARTE), MAX(RE_NOMBRE), MAX(RE_NAME), 
	                      SUM(RE_INCORPOR), MAX(TI_HIJO), MAX(ME_CODIGO), MAX(MA_GENERICO), MAX(ME_GEN), SUM(RE_INCORPORGEN), MAX(FACTCONV), 
	                      FETR_RETRABAJODES,MAX(FETR_NAFTA), MAX(PA_ORIGEN)
	FROM         TEMP_RETRABAJO1 
	GROUP BY TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, FETR_RETRABAJODES


	UPDATE dbo.FACTEXPDET
	SET FED_RETRABAJO='D'
	WHERE     FED_INDICED IN (SELECT FETR_INDICED FROM TEMP_RETRABAJO WHERE TIPO_FACTRANS = 'F')


	exec sp_droptable 'TempConciliaDespFacturas'

	SELECT     MAX(RE_INDICER) as RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, MAX(RE_NOPARTE) as RE_NOPARTE, MAX(RE_NOMBRE) as RE_NOMBRE, MAX(RE_NAME) as RE_NAME, 
	                      SUM(RE_INCORPOR) as RE_INCORPOR, MAX(TI_HIJO) as TI_HIJO, MAX(ME_CODIGO) as ME_CODIGO, MAX(MA_GENERICO) as MA_GENERICO, MAX(ME_GEN) as ME_GEN, SUM(RE_INCORPORGEN) as RE_INCORPORGEN, MAX(FACTCONV) as FACTCONV, 
	                      FETR_RETRABAJODES, MAX(FETR_NAFTA) as FETR_NAFTA, MAX(PA_ORIGEN) AS PA_ORIGEN
	INTO dbo.TempConciliaDespFacturas
	FROM         TEMP_RETRABAJO1 
	GROUP BY TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, FETR_RETRABAJODES


	exec sp_droptable 'TEMP_RETRABAJO1'
	exec sp_droptable 'TEMP_RETRABAJO'
	exec sp_droptable 'tempConciliaDesp'


GO
