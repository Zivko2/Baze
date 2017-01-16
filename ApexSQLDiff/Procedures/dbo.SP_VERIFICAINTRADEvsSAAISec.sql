SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_VERIFICAINTRADEvsSAAISec] (@FechaIni VARCHAR(11), @FechaFin VARCHAR(11), @FILTROCLAVE CHAR(1) ='N', @TIPOMOV CHAR(1)='E')   as


   -- se insertan todos los registros de TempAgSaai a TempAgTotSaai agrupados
	if @FILTROCLAVE='N'
	begin
 		IF @TIPOMOV='E'
		BEGIN
		           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed,
			Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
			SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
			PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
			'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
			'SAAI' , Sec
			FROM TempAgSaai 
			WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
			AND rtrim(ltrim(TOper))='1'
			AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
						FROM PEDIMP INNER JOIN
						     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
						     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
						WHERE PEDIMP.PI_TIPO <> 'C')
		END
		ELSE
 		IF @TIPOMOV='S'
		BEGIN
		           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
			Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
			SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
			PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
			'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
			'SAAI' , Sec
			FROM TempAgSaai 
			WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
			AND rtrim(ltrim(TOper))='2'
		END
		ELSE
		BEGIN
		           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
			Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
			SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
			PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
			'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
			'SAAI' , Sec
			FROM TempAgSaai 
			WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
			AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
						FROM PEDIMP INNER JOIN
						     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
						     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
						WHERE PEDIMP.PI_TIPO <> 'C')

		END


	end
	else
	if @FILTROCLAVE='S'
	begin
			delete from ##TEMPCLAVE WHERE CLAVE='LL'
	
	 		IF @TIPOMOV='E'
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				AND rtrim(ltrim(TOper))='1' AND CveDocto in(select CLAVE from ##TEMPCLAVE)
				AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
							FROM PEDIMP INNER JOIN
							     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
							     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
							WHERE PEDIMP.PI_TIPO <> 'C')


			END
			ELSE
	 		IF @TIPOMOV='S'
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				AND rtrim(ltrim(TOper))='2' AND CveDocto in(select CLAVE from ##TEMPCLAVE)
			END
			ELSE
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				and CveDocto in(select CLAVE from ##TEMPCLAVE)
				AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
							FROM PEDIMP INNER JOIN
							     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
							     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
							WHERE PEDIMP.PI_TIPO <> 'C')

			END
	
	end
	else
	if @FILTROCLAVE='Z'
	begin
			delete from ##TEMPCLAVE2 WHERE CLAVE='LL'
	
	 		IF @TIPOMOV='E'
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				AND rtrim(ltrim(TOper))='1' AND CveDocto not in(select CLAVE from ##TEMPCLAVE2)
				AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
							FROM PEDIMP INNER JOIN
							     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
							     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
							WHERE PEDIMP.PI_TIPO <> 'C')

			END
			ELSE
	 		IF @TIPOMOV='S'
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				AND rtrim(ltrim(TOper))='2' AND CveDocto not in(select CLAVE from ##TEMPCLAVE2)
			END
			ELSE
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed,
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				and CveDocto not in(select CLAVE from ##TEMPCLAVE2)
				AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
							FROM PEDIMP INNER JOIN
							     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
							     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
							WHERE PEDIMP.PI_TIPO <> 'C')

			END


	end
	else
	if @FILTROCLAVE='A'
	begin
			delete from ##TEMPCLAVE WHERE CLAVE='LL'
			delete from ##TEMPCLAVE2 WHERE CLAVE='LL'
	
	 		IF @TIPOMOV='E'
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed,
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),isnull(ValorAduana,0)), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				AND rtrim(ltrim(TOper))='1' AND CveDocto in(select CLAVE from ##TEMPCLAVE)
				AND CveDocto not in(select CLAVE from ##TEMPCLAVE2)
				AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
							FROM PEDIMP INNER JOIN
							     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
							     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
							WHERE PEDIMP.PI_TIPO <> 'C')

			END
			ELSE
	 		IF @TIPOMOV='S'
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed,
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),sum(isnull(ValorAduana,0))), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				AND rtrim(ltrim(TOper))='2' AND CveDocto in(select CLAVE from ##TEMPCLAVE)
				AND CveDocto not in(select CLAVE from ##TEMPCLAVE2)

			END
			ELSE
			BEGIN
			           INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, TipoPed, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				SELECT Patente, Pedimento, Aduana, TOper, CveDocto, left(FecPagoReal,11), TipoPed, REPLACE(Fraccion,'.',''), 
				PaisOD, PaisCV, '-'+ convert(varchar(50),sum(isnull(ValorAduana,0))), '-'+ convert(varchar(50),isnull(ValorComercial,0)), 
				'-'+ convert(varchar(50),isnull(CantidadUMT,0)), '-'+convert(varchar(50),isnull(ImporteIVA,0)), '-'+ convert(varchar(50),isnull(ImporteADvalorem,0)), 
				'SAAI' , Sec
				FROM TempAgSaai 
				WHERE convert(datetime,left(FecPagoReal,11))>=@FechaIni and convert(datetime,left(FecPagoReal,11))<=@FechaFin
				and CveDocto in(select CLAVE from ##TEMPCLAVE) and CveDocto not in(select CLAVE from ##TEMPCLAVE2)
				AND Aduana+'-'+ Patente+'-'+Pedimento NOT IN (SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + '-' + AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO 
							FROM PEDIMP INNER JOIN
							     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
							     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO
							WHERE PEDIMP.PI_TIPO <> 'C')

			END

	end
	

	UPDATE TempAgTotSaai 
	SET Texto = 'RECTIFICADO' 
	WHERE Aduana+' '+Patente+' '+Pedimento in 
	         (SELECT ADUANA.AD_CLAVE+ADUANA.AD_SECCION+' '+AGENCIAPATENTE.AGT_PATENTE+' '+PEDIMP.PI_FOLIO
	          FROM PEDIMP INNER JOIN ADUANA ON PEDIMP.AD_DES =ADUANA.AD_CODIGO INNER JOIN 
	               AGENCIAPATENTE ON PEDIMP.AGT_CODIGO =AGENCIAPATENTE.AGT_CODIGO 
	               WHERE PEDIMP.PI_ESTATUS ='R' 
	          GROUP BY ADUANA.AD_CLAVE+ADUANA.AD_SECCION+' '+AGENCIAPATENTE.AGT_PATENTE+' '+PEDIMP.PI_FOLIO) 

	OR Aduana+' '+Patente+' '+Pedimento in 
		(SELECT     ADUANA.AD_CLAVE+ ADUANA.AD_SECCION+' '+ AGENCIAPATENTE.AGT_PATENTE+' '+ PEDIMPR1HIST.R1H_PEDIMENTOR1ANT
		FROM         ADUANA RIGHT OUTER JOIN
		                      PEDIMPR1HIST ON ADUANA.AD_CODIGO = PEDIMPR1HIST.AD_CODIGOANT LEFT OUTER JOIN
		                      AGENCIAPATENTE ON PEDIMPR1HIST.AGT_R1ANT = AGENCIAPATENTE.AGT_CODIGO)



  -- se insertan todos los de intrade que cubren el periodo
	if @FILTROCLAVE='N'
	begin
 		IF @TIPOMOV='E'
		BEGIN
			INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
			Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
			

			SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
				 'TOper'=CASE WHEN PEDIMP.PI_MOVIMIENTO='E' THEN '1' ELSE '2' END, CLAVEPED.CP_CLAVE, 
				CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END
				          , left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, PEDIMPDETB.PIB_VAL_ADU, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR,
				 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
				         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
				              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
				              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
				         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
				               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
				isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
				        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
				             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
				             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
				        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
				             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
			FROM  PEDIMP INNER JOIN 
			     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
			     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
			     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
			     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
			     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
			     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
			     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
			 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
			AND PEDIMP.PI_MOVIMIENTO='E' AND PEDIMP.PI_TIPO = 'C'
		END
		ELSE
 		IF @TIPOMOV='S'
		BEGIN
			INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
			Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
			
			SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
				 'TOper'=CASE WHEN PEDIMP.PI_MOVIMIENTO='E' THEN '1' ELSE '2' END, CLAVEPED.CP_CLAVE, 
				          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END
				, left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, /*PIB_VAL_ADU*/0, PIB_VAL_FAC, PIB_CAN_AR,

				 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
				         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
				              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
				              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
				         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB 
				               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
				isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
				        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
				             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
				             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
				        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
				             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
			FROM  PEDIMP INNER JOIN 
			     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
			     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
			     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
			     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
			     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
			     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
			     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
			 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
			AND PEDIMP.PI_MOVIMIENTO='S' AND PEDIMP.PI_TIPO = 'C'
		END
		ELSE		
		BEGIN
			INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
			Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
			
			SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
				 'TOper'=CASE WHEN PEDIMP.PI_MOVIMIENTO='E' THEN '1' ELSE '2' END, CLAVEPED.CP_CLAVE, 
				          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
					 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, case when PEDIMP.PI_MOVIMIENTO='E' THEN PEDIMPDETB.PIB_VAL_ADU ELSE 0 END, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
				 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
				         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
				              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
				              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
				         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
				               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
				isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
				        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
				             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
				             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
				        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
				             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
			FROM  PEDIMP INNER JOIN 
			     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
			     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
			     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
			     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
			     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
			     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
			     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
			 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
			 AND PEDIMP.PI_TIPO = 'C'
		END
	end
	else
	begin


		IF @FILTROCLAVE='S'
		begin
	 		IF @TIPOMOV='E'
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					  '1' AS 'TOper', CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END
						, left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, PEDIMPDETB.PIB_VAL_ADU, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				AND PEDIMP.PI_MOVIMIENTO='E' AND CLAVEPED.CP_CLAVE in(select CLAVE from ##TEMPCLAVE)
				AND PEDIMP.PI_TIPO = 'C'
			END
			ELSE
	 		IF @TIPOMOV='S'
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					 '2' AS 'TOper', CLAVEPED.CP_CLAVE, 
					CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END					          
					, left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, /*PEDIMPDETB.PIB_VAL_ADU*/0, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				AND PEDIMP.PI_MOVIMIENTO='S' AND CLAVEPED.CP_CLAVE in(select CLAVE from ##TEMPCLAVE)
				AND PEDIMP.PI_TIPO = 'C'
			END
			ELSE		
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					 'TOper'=CASE WHEN PEDIMP.PI_MOVIMIENTO='E' THEN '1' ELSE '2' END, CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
						 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, case when PEDIMP.PI_MOVIMIENTO='E' THEN PEDIMPDETB.PIB_VAL_ADU ELSE 0 END,
						 PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				and CLAVEPED.CP_CLAVE in(select CLAVE from ##TEMPCLAVE)
				AND PEDIMP.PI_TIPO = 'C'
			END
		end
		else
		IF @FILTROCLAVE='Z'
		begin

	 		IF @TIPOMOV='E'
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					  '1' AS 'TOper', CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END
						, left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, PEDIMPDETB.PIB_VAL_ADU, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PI_CODIGO= PEDIMP.PI_CODIGO  AND PEDIMPDETB3.AR_IMPMX=PEDIMPDETB.AR_IMPMX AND 
					               PEDIMPDETB3.PA_ORIGEN=PEDIMPDETB.PA_ORIGEN AND PEDIMPDETB3.PA_PROCEDE=PEDIMPDETB.PA_PROCEDE 
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				AND PEDIMP.PI_MOVIMIENTO='E' AND CLAVEPED.CP_CLAVE not in(select CLAVE from ##TEMPCLAVE2)
				AND PEDIMP.PI_TIPO = 'C'
			END
			ELSE
	 		IF @TIPOMOV='S'
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					 '2' AS 'TOper', CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
						 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, /*PEDIMPDETB.PIB_VAL_ADU*/0, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				AND PEDIMP.PI_MOVIMIENTO='S' AND CLAVEPED.CP_CLAVE not in(select CLAVE from ##TEMPCLAVE2)
				AND PEDIMP.PI_TIPO = 'C'
			END
			ELSE		
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					 'TOper'=CASE WHEN PEDIMP.PI_MOVIMIENTO='E' THEN '1' ELSE '2' END, CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
						 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, case when PEDIMP.PI_MOVIMIENTO='E' THEN PEDIMPDETB.PIB_VAL_ADU ELSE 0 END,
					 PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				and CLAVEPED.CP_CLAVE not in(select CLAVE from ##TEMPCLAVE2)
				AND PEDIMP.PI_TIPO = 'C'
			END

		end	
		else
		begin


	 		IF @TIPOMOV='E'
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					  '1' AS 'TOper', CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
						 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, PEDIMPDETB.PIB_VAL_ADU, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				AND PEDIMP.PI_MOVIMIENTO='E' AND CLAVEPED.CP_CLAVE in(select CLAVE from ##TEMPCLAVE)
				AND CLAVEPED.CP_CLAVE not in(select CLAVE from ##TEMPCLAVE2)
				AND PEDIMP.PI_TIPO = 'C'
			END
			ELSE
	 		IF @TIPOMOV='S'
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					 '2' AS 'TOper', CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
						 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, /*PEDIMPDETB.PIB_VAL_ADU*/0, PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				AND PEDIMP.PI_MOVIMIENTO='S' AND CLAVEPED.CP_CLAVE in(select CLAVE from ##TEMPCLAVE)
				AND CLAVEPED.CP_CLAVE not in(select CLAVE from ##TEMPCLAVE2)
				AND PEDIMP.PI_TIPO = 'C'
			END
			ELSE		
			BEGIN
				INSERT INTO TempAgTotSaai(Patente, Pedimento, Aduana, TOper, CveDocto, FecPagoReal, 
				Fraccion, PaisOD, PaisCV, ValorAduana, ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 
				
				SELECT     left(AGENCIAPATENTE.AGT_PATENTE,4), left(PEDIMP.PI_FOLIO,10), left(ADUANA.AD_CLAVE+ADUANA.AD_SECCION,5), 
					 'TOper'=CASE WHEN PEDIMP.PI_MOVIMIENTO='E' THEN '1' ELSE '2' END, CLAVEPED.CP_CLAVE, 
					          CASE WHEN CLAVEPED.CP_CLAVE='R1' THEN convert(varchar(11),PEDIMP.PI_FEC_PAGR1,101) ELSE convert(varchar(11),PEDIMP.PI_FEC_PAG,101) END,
					 left(ARANCEL.AR_FRACCION,8), PAIS.PA_SAAIM3, PAIS_1.PA_SAAIM3, case when PEDIMP.PI_MOVIMIENTO='E' THEN PEDIMPDETB.PIB_VAL_ADU ELSE 0 END, 
					PEDIMPDETB.PIB_VAL_FAC, PEDIMPDETB.PIB_CAN_AR, 
					 isnull(round((SELECT SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					         FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					              PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					              CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					         WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					               AND CONTRIBUCION.CON_CLAVE = '3'),6),0) AS IMPORTEIVAMN, 
					isnull(round((SELECT     SUM(PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN) 
					        FROM PEDIMPDETB PEDIMPDETB3 INNER JOIN 
					             PEDIMPDETBCONTRIBUCION ON PEDIMPDETB3.PIB_INDICEB = PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN 
					             CONTRIBUCION ON PEDIMPDETBCONTRIBUCION.CON_CODIGO = CONTRIBUCION.CON_CODIGO 
					        WHERE PEDIMPDETB3.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
					             AND CONTRIBUCION.CON_CLAVE = '6'),6),0) AS IMPORTEIADVMN, 'INTRADE' , PEDIMPDETB.PIB_SECUENCIA
				FROM  PEDIMP INNER JOIN 
				     ADUANA ON PEDIMP.AD_DES = ADUANA.AD_CODIGO INNER JOIN 
				     AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO INNER JOIN 
				     PEDIMPDETB ON PEDIMP.PI_CODIGO = PEDIMPDETB.PI_CODIGO INNER JOIN 
				     ARANCEL ON PEDIMPDETB.AR_IMPMX = ARANCEL.AR_CODIGO INNER JOIN 
				     PAIS ON PEDIMPDETB.PA_ORIGEN = PAIS.PA_CODIGO INNER JOIN 
				     PAIS PAIS_1 ON PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO INNER JOIN 
				     CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
				 WHERE PEDIMP.PI_ESTATUS <>'R' AND PEDIMP.PI_FEC_PAG >= @FechaIni AND PEDIMP.PI_FEC_PAG <= @FechaFin 
				and CLAVEPED.CP_CLAVE in(select CLAVE from ##TEMPCLAVE) and CLAVEPED.CP_CLAVE not in(select CLAVE from ##TEMPCLAVE2)
				AND PEDIMP.PI_TIPO = 'C'
			END
		end


	end	





	UPDATE TempAgTotSaai 
	SET Texto = 'NO EXISTE EN INTRADE' 
	WHERE Texto='SAAI' and 
	      Aduana+' '+Patente+' '+Pedimento not in 
	       (SELECT Aduana+' '+Patente+' '+Pedimento  
                      FROM TempAgTotSaai 
	        WHERE Texto='INTRADE' or Texto = 'RELACION FRACCION-PAIS-PEDIMENTO NO EXISTE EN SAAI' 
	       GROUP BY Aduana+' '+Patente+' '+Pedimento) and 
	      Aduana+' '+Patente+' '+Pedimento not in
		(SELECT ADUANA.AD_CLAVE + ADUANA.AD_SECCION + ' ' + AGENCIAPATENTE.AGT_PATENTE + ' ' + PEDIMPR1HIST.R1H_PEDIMENTOR1ANT
		 FROM   PEDIMPR1HIST INNER JOIN
                      AGENCIAPATENTE ON PEDIMPR1HIST.AGT_R1ANT = AGENCIAPATENTE.AGT_CODIGO INNER JOIN
                      ADUANA ON PEDIMPR1HIST.AD_CODIGOANT = ADUANA.AD_CODIGO)
		

	UPDATE TempAgTotSaai 
	SET Texto = 'NO EXISTE EN SAAI' 
	WHERE (Texto='INTRADE' OR Texto = 'RELACION FRACCION-PAIS-PEDIMENTO NO EXISTE EN SAAI' ) and 
	      Aduana+' '+Patente+' '+Pedimento not in 
	       (SELECT Aduana+' '+Patente+' '+Pedimento  
                      FROM TempAgSaai GROUP BY Aduana+' '+Patente+' '+Pedimento) 


	UPDATE TempAgTotSaai 
	SET Texto = 'PEDIMENTO FUERA DE PERIODO EN INTRADE' 
	WHERE Texto = 'NO EXISTE EN INTRADE'  AND Aduana+' '+Patente+' '+Pedimento in 
	         (SELECT ADUANA.AD_CLAVE+ADUANA.AD_SECCION+' '+AGENCIAPATENTE.AGT_PATENTE+' '+PEDIMP.PI_FOLIO
	          FROM PEDIMP INNER JOIN ADUANA ON PEDIMP.AD_DES =ADUANA.AD_CODIGO INNER JOIN 
	               AGENCIAPATENTE ON PEDIMP.AGT_CODIGO =AGENCIAPATENTE.AGT_CODIGO 
	          GROUP BY ADUANA.AD_CLAVE+ADUANA.AD_SECCION+' '+AGENCIAPATENTE.AGT_PATENTE+' '+PEDIMP.PI_FOLIO) 


	UPDATE TempAgTotSaai 
	SET Texto = Texto+' (R1)' 
	WHERE Texto <> 'INTRADE'  AND Texto <> 'SAAI' AND Texto <> 'DIFERENCIA' AND Aduana+' '+Patente+' '+Pedimento in 
	(SELECT ADUANA+' '+PATENTE+' '+PEDIMENTO 
	FROM GLOSASAAI
	WHERE TIPOPED='2' 
	GROUP BY ADUANA+' '+PATENTE+' '+PEDIMENTO) and Texto not like '%(R1)'


-- se actualiza el texto de los que se insertaron de intrade y no existen en saai
            -- se calcula la diferencia de los valores
	insert into TempAgTotSaai(Aduana, Patente, Pedimento, CveDocto, ValorAduana, 
	ValorComercial, CantidadUMT, ImporteIVA, ImporteADvalorem, Texto, Sec) 

	SELECT     Aduana, Patente, Pedimento, max(CveDocto), round(SUM(ISNULL(ValorAduana, 0)),6) AS ValorAduana, 
	round(SUM(ISNULL(ValorComercial, 0)),6) AS ValorComercial, round(SUM(ISNULL(CantidadUMT, 0)),6) AS CantidadUMT, 
	round(SUM(ISNULL(ImporteIVA, 0)),6) AS ImporteIVA, round(SUM(ISNULL(ImporteADvalorem, 0)),6) AS ImporteADvalorem, 'DIFERENCIA' , Sec
	FROM  TempAgTotSaai 
	WHERE (Texto ='RECTIFICADO (R1)') OR (Texto ='SAAI') OR (Texto ='INTRADE') 
	GROUP BY Aduana, Patente, Pedimento, Sec



	UPDATE TempAgTotSaai
	SET Fraccion='DIF'
	WHERE Texto='DIFERENCIA' AND
	CONVERT(VARCHAR(5),Aduana)+ CONVERT(VARCHAR(5),Patente)+ CONVERT(VARCHAR(10),Pedimento)+CONVERT(VARCHAR(5),Sec) IN 
 	(SELECT CONVERT(VARCHAR(5),SAAI.Aduana)+ CONVERT(VARCHAR(5),SAAI.Patente)+ CONVERT(VARCHAR(10),SAAI.Pedimento)+CONVERT(VARCHAR(5),SAAI.Sec) FROM
		(SELECT Aduana, Patente, Pedimento, Sec, Fraccion FROM TempAgTotSaai WHERE (Texto ='RECTIFICADO (R1)') OR Texto='SAAI') SAAI,
	            (SELECT Aduana, Patente, Pedimento, Sec, Fraccion FROM TempAgTotSaai WHERE Texto='INTRADE') INTRADE
	WHERE SAAI.Aduana = INTRADE.Aduana AND  SAAI.Patente=INTRADE.Patente AND SAAI.Pedimento = INTRADE.Pedimento
	AND SAAI.Sec = INTRADE.Sec and SAAI.Fraccion <> INTRADE.Fraccion)



	UPDATE TempAgTotSaai
	SET PaisOD='DIF'
	WHERE Texto='DIFERENCIA' AND
	CONVERT(VARCHAR(5),Aduana)+ CONVERT(VARCHAR(5),Patente)+ CONVERT(VARCHAR(10),Pedimento)+CONVERT(VARCHAR(5),Sec) IN 
 	(SELECT CONVERT(VARCHAR(5),SAAI.Aduana)+ CONVERT(VARCHAR(5),SAAI.Patente)+ CONVERT(VARCHAR(10),SAAI.Pedimento)+CONVERT(VARCHAR(5),SAAI.Sec) FROM
		(SELECT Aduana, Patente, Pedimento, Sec, PaisOD FROM TempAgTotSaai WHERE (Texto ='RECTIFICADO (R1)') OR Texto='SAAI') SAAI,
	            (SELECT Aduana, Patente, Pedimento, Sec, PaisOD FROM TempAgTotSaai WHERE Texto='INTRADE') INTRADE
	WHERE SAAI.Aduana = INTRADE.Aduana AND  SAAI.Patente=INTRADE.Patente AND SAAI.Pedimento = INTRADE.Pedimento
	AND SAAI.Sec = INTRADE.Sec and SAAI.PaisOD <> INTRADE.PaisOD)


GO
