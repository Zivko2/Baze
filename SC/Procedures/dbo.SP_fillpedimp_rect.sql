SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_fillpedimp_rect] (@picodigo int, @user int)   as

SET NOCOUNT ON 
DECLARE @CF_MAN_EMPAQUE CHAR(1), @CF_EMPDESPIMP CHAR(1),@pi_movimiento CHAR(1), @ccp_tipo VARCHAR(5), @ccp_tipo2 VARCHAR(5), @pi_rectifica INT, @numfacturas INT,
@totalpartidas INT, @semana INT, @iniciosem DATETIME, @inisem INT, @finsem INT, @mes VARCHAR(15), @year INT, @pi_observa VARCHAR(1100), @peso DECIMAL(38,6)

SELECT 
	@CF_MAN_EMPAQUE= CF_MAN_EMPAQUE, @CF_EMPDESPIMP=CF_EMPDESPIMP
FROM CONFIGURACION

SELECT 
	@ccp_tipo=ccp_tipo 
FROM configuraclaveped 
WHERE cp_codigo IN (SELECT cp_codigo FROM pedimp WHERE pi_codigo=@picodigo)

SELECT 
	@pi_movimiento=pi_movimiento,@pi_rectifica=pi_rectifica,@totalpartidas=pi_cuentadet 
FROM pedimp 
WHERE pi_codigo=@picodigo

SELECT 
	@ccp_tipo2=ccp_tipo 
FROM configuraclaveped 
WHERE cp_codigo IN (SELECT cp_codigo FROM pedimp WHERE pi_codigo=@pi_rectifica)

if @pi_movimiento='E' AND ((@ccp_tipo2<>'CN' AND @ccp_tipo2<>'RP' AND @ccp_tipo2<>'RG') 
	OR (@ccp_tipo2='RG'  AND (SELECT PI_DESP_EQUIPO FROM pedimp WHERE pi_codigo=@pi_rectifica)='N'))
	BEGIN
		
		SELECT 
			@numfacturas=COUNT(fi_numvehiculos) 
		FROM factimp WHERE pi_rectifica=@picodigo
	
		SELECT 
			@peso=CASE WHEN ISNULL(SUM(FID_PES_BRU),0)> 0 THEN ISNULL(SUM(FID_PES_BRU),0) ELSE ISNULL(SUM(FID_PES_NET),0) END
		FROM  dbo.FACTIMPDET 
		INNER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO=FACTIMP.FI_CODIGO
		WHERE (FACTIMP.PI_RECTIFICA = @picodigo)
	
		UPDATE pedimp
		SET pi_numvehiculos=ISNULL(@numfacturas,1), pi_bulto=(SELECT ISNULL(SUM(fi_totalb),0) FROM factimp WHERE pi_rectifica=@picodigo),pi_peso=@peso
		WHERE pi_codigo=@picodigo

		SELECT @PI_OBSERVA=PI_OBSERVA FROM PEDIMP WHERE PI_CODIGO=@picodigo

		IF @numfacturas>1 AND (@pi_observa NOT LIKE '**PEDIMENTOS CONSOLIDADOS DTA POR %' OR @pi_observa IS NULL)
		BEGIN
			UPDATE pedimp
			SET pi_observa='**PEDIMENTOS CONSOLIDADOS DTA POR '+CONVERT(VARCHAR(5),@numfacturas)+' VEHICULOS DE CONFORMIDAD CON EL ART. 49 INCISO III DE LA LEY FEDERAL DE DERECHOS, EN BASE AL ART. 37 DE LA LEY ADUANERA VIGENTE Y 58 DEL REGLAMENTO.** '
			WHERE pi_codigo=@picodigo		
	
			UPDATE pedimp
			SET pi_sem=DATEPART(wk, PI_FEC_ENT)-1
			WHERE pi_codigo=@picodigo
	
			SELECT @semana=pi_sem FROM PEDIMP WHERE PI_CODIGO = @picodigo

			IF (@ccp_tipo2='VT' or @ccp_tipo2='IV') 
				BEGIN
		
					SELECT 
						@mes=mes, @year=[year]
					FROM VPEDIMPPERIODO
					GROUP BY mes, [year], PI_CODIGO
					HAVING (PI_CODIGO = @picodigo)	
		
					UPDATE pedimp
					SET pi_observa=ISNULL(pi_observa,'')+'SEMANA: '+CONVERT(VARCHAR(3),@semana)+' PERIODO: '+@mes +' DEL ' +CONVERT(VARCHAR(10), @year)
					WHERE pi_codigo=@picodigo
				END
				ELSE
				BEGIN
					SELECT 
						@mes=MONTH(pi_fec_ent),@year=YEAR(pi_fec_ent)
					FROM PEDIMP
					WHERE(PI_CODIGO = @picodigo)	
		
					SELECT @iniciosem=CASE WHEN DATEPART(dw, PI_FEC_ENT-7)=4 THEN PI_FEC_ENT-9 WHEN DATEPART(dw, PI_FEC_ENT-7)=3 THEN PI_FEC_ENT-8 WHEN DATEPART(dw, PI_FEC_ENT-7)=2 THEN 
					PI_FEC_ENT-7 END FROM PEDIMP WHERE PI_CODIGO = 215
		
					SET @inisem=(SELECT DAY(@iniciosem))
					SET @finsem=(select DAY(@inisem+5))
		
					UPDATE pedimp
					SET pi_observa=ISNULL(pi_observa,'')+'SEMANA: '+CONVERT(varchar(3),@semana)+' DEL '+convert(varchar(10),@inisem)+' AL '+convert(varchar(10),@finsem)+' DEL MES '+convert(varchar(10),@mes)+' DEL '+convert(varchar(10), @year)
					WHERE pi_codigo=@picodigo
		
				END
		END

		IF EXISTS(SELECT * FROM factimpdet WHERE fi_codigo IN (SELECT fi_codigo FROM factimp WHERE pi_codigo=@pi_rectifica) AND (pid_indicedliga=-1 OR pid_indicedliga IS NULL))
			EXEC sp_fillpedimp @pi_rectifica, @user

		EXEC sp_fillpedimpdet @picodigo, @ccp_tipo, @user /* inserta detalle del pedimento */

		SELECT 
			@totalpartidas=COUNT(*) 
		FROM pedimpdet 
		WHERE pi_codigo=@picodigo 
		AND (pid_imprimir = 'S')

		IF (SELECT pi_llenapedimpdetb FROM configurapedimento)='S' AND @totalpartidas>0
		BEGIN
			EXEC sp_fillpedimpdetB @picodigo,@user	
		END

		EXEC fillpedimpcont_rect @picodigo, @user	/*inserta contenido del pedimento */
	
		EXEC fillpedimpidentifica @picodigo /* inserta  permisos a los identificadores a nivel pedimento */
	
		EXEC sp_fillpedimpincrementa @picodigo, @user  /* inserta incrementables de la factura a la tabla pedimpincrementa*/
	
		/* llena la columna de fecha vence */
		EXEC sp_actualizapedimpvencimiento @picodigo, @user
		/* falta insertar los contenedores */
	END
	ELSE
	BEGIN
		
		SELECT 
			@numfacturas=COUNT(fe_codigo) 
		FROM factexp 
		WHERE pi_rectifica=@picodigo
	
		SELECT 
			@peso = CASE WHEN ISNULL(SUM(FED_PES_BRU),0)> 0 THEN ISNULL(SUM(FED_PES_BRU),0) ELSE ISNULL(SUM(FED_PES_NET),0) END
		FROM dbo.FACTEXPDET 
		INNER JOIN FACTEXP ON FACTEXPDET.FE_CODIGO=FACTEXP.FE_CODIGO
		WHERE (FACTEXP.PI_RECTIFICA = @picodigo)
	
		UPDATE pedimp
		SET pi_numvehiculos=isnull(@numfacturas,1), pi_bulto=(SELECT isnull(sum(fe_totalb),0) FROM factexp WHERE pi_rectifica=@picodigo),pi_peso=@peso
		WHERE pi_codigo=@picodigo

		IF EXISTS(SELECT * FROM factexpdet WHERE fe_codigo IN (SELECT fe_codigo FROM factexp WHERE pi_codigo=@pi_rectifica) AND (pid_indicedliga=-1 OR pid_indicedliga IS NULL))
			EXEC sp_fillpedexp @pi_rectifica, @user

		IF @ccp_tipo2='CN' OR @ccp_tipo2='RP' OR (@ccp_tipo2='RG' AND (SELECT PI_DESP_EQUIPO FROM pedimp WHERE pi_codigo=@pi_rectifica)='S')
		BEGIN
			PRINT 'sp_fillpedimpdetReg'
			EXEC sp_fillpedimpdetReg @picodigo, @user
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT * FROM factexp where pi_codigo=@picodigo OR pi_rectifica=@picodigo
			AND tq_codigo IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D'))
	  			EXEC sp_fillpedexpdetdesp @picodigo, @ccp_tipo, @user		/*inserta detalle y contenido del pedimento cuando existesn facturas que son de desperdicio*/
			ELSE
				EXEC sp_fillpedexpdet @picodigo, @ccp_tipo, @user		/*inserta detalle y contenido del pedimento */
		END

		SELECT 
			@totalpartidas=count(*) 
		FROM pedimpdet 
		WHERE pi_codigo=@picodigo 
		AND (pid_imprimir = 'S')


		IF @totalpartidas>0
		BEGIN
			EXEC sp_fillpedimpdetB @picodigo, @user 	--inserta detalle B del pedimento 
			EXEC sp_fillpedExpDetBArt303 @picodigo
		END

		EXEC fillpedexpcont_rect @picodigo, @user	/*inserta contenido del pedimento */
		EXEC sp_fillpedexpincrementa @picodigo, @user /* inserta incrementables de la factura a la tabla pedimpincrementa*/
	END
	
-- =============================================================================================================================
	/*
		* Descripción: Modificación para actualizar la observación y el número de bultos a nivel carátula del pedimento R1, 
		* en base al pedimento original.
		* Fecha: 03 Marzo 2012
	*/
-- =============================================================================================================================		 
	-- Actualizar observaciones
	UPDATE pedImp 
	SET 
		pedImp.pi_observa = pedimpRectificado.pi_observa,
		pedImp.pi_bulto = pedimpRectificado.pi_bulto
	FROM pedImp
	INNER JOIN pedImp pedimpRectificado ON pedImp.pi_rectifica = pedimpRectificado.pi_codigo
	WHERE pedImp.pi_codigo = @piCodigo
		
-- =============================================================================================================================
/*
	* Descripción: Modificación para actualizar las C. Transportistas nivel carátula del pedimento R1, 
	* en base al pedimento original.
	* Fecha: 05 Marzo 2012
*/
-- =============================================================================================================================
	-- Declaración de variable que contiene el código del pedimento original
	DECLARE @pedimentoOriginal AS INT
	
	-- Obtener el código del pedimento original
	SELECT 
		@pedimentoOriginal = pedimpRectificado.pi_codigo
	FROM pedImp
	INNER JOIN pedImp pedimpRectificado ON pedImp.pi_rectifica = pedimpRectificado.pi_codigo
	WHERE pedImp.pi_codigo = @piCodigo

	-- Eliminar los registros actuales referentes a C. Transportista del pedimento R1
	DELETE FROM pedImpCtranspor WHERE pi_codigo = @piCodigo
	
	-- Insertar los nuevos registros referentes a C. Transportista al pedimento R1
	INSERT INTO pedImpCtranspor(pi_codigo,ct_codigo,pa_cTranpor,pi_identmTransp,pi_numeroCandado)
	SELECT @piCodigo,ct_codigo,pa_cTranpor,pi_identmTransp,pi_numeroCandado
	FROM pedImpCtranspor
	WHERE pi_codigo = @pedimentoOriginal
	
-- =============================================================================================================================
/*
	* Descripción: Modificación para actualizar los identificadores a nivel carátula del pedimento R1, 
	* en base al pedimento original.
	* Fecha: 09 Marzo 2012
*/
-- =============================================================================================================================
	-- Declaración de variables
	DECLARE @tableTempPI TABLE(ID INT IDENTITY(1,1),pi_codigo INT,ide_codigo INT,ided_codigo INT,pii_desc VARCHAR(40),pii_desc2 VARCHAR(40),ided_codigo2 INT,pii_desc3 VARCHAR(40),ided_codigo3 INT)

	-- Almacenar temporalmente en una variable tipo tabla los identificadores
	INSERT INTO @tableTempPI
	SELECT 
		pi_codigo,ide_codigo,ided_codigo,pii_desc,pii_desc2,ided_codigo2,pii_desc3,ided_codigo3
	FROM pedImpIdentifica
	WHERE 
		pi_codigo = @pedimentoOriginal

	-- Eliminar los registros actuales referentes a identificadores del pedimento R1
	DELETE FROM pedImpIdentifica WHERE pi_codigo = @piCodigo

	-- Inserción de registros
	INSERT INTO pedImpIdentifica (pii_codigo,pi_codigo,ide_codigo,ided_codigo,pii_desc,pii_desc2,ided_codigo2,pii_desc3,ided_codigo3)
	SELECT 
		(SELECT (cv_codigo-1+ID) FROM consecutivo WHERE cv_tabla = 'pedImpIdentifica' AND cv_campo = 'pii_codigo') ,@piCodigo,ide_codigo,ided_codigo,pii_desc,pii_desc2,ided_codigo2,pii_desc3,ided_codigo3
	FROM @tableTempPI

	-- Actualizar el id siguiente de la tabla de consecutivo
	UPDATE consecutivo
	SET cv_codigo = (SELECT MAX(pii_codigo)+1 
					FROM pedImpIdentifica) 
	FROM consecutivo  
	WHERE cv_tabla = 'pedImpIdentifica' 
	AND cv_campo = 'pii_codigo'
	
-- =============================================================================================================================
	/*
		* Descripción: Modificación para actualizar los identificadores a nivel partida del pedimento R1, 
		* en base al pedimento original.
		* Fecha: 12 Marzo 2012
	*/
-- =============================================================================================================================
	-- Declaración de variables 
	DECLARE @qtyRowsOrg INT,@qtyRowsR1 INT,@qtyRowsDetOrg INT,@qtyRowsDetR1 INT,@clavePedimento VARCHAR(5)
	DECLARE @tableP VARCHAR(7),@tableDet VARCHAR(10),@tableDetColumn VARCHAR(9)
	
	-- Asignación de valores a las variables
	-- Detalles
	SET @qtyRowsDetR1 = (SELECT COUNT(*) FROM pedImpDet WHERE pi_codigo = @piCodigo)
	SET @qtyRowsDetOrg = (SELECT COUNT(*) FROM pedImpDet WHERE pi_codigo = @pedimentoOriginal)
	-- Agrupación SAAI
	SET @qtyRowsR1 = (SELECT COUNT(*) FROM pedImpDetB WHERE pi_codigo = @piCodigo)
	SET @qtyRowsOrg = (SELECT COUNT(*) FROM pedImpDetB WHERE pi_codigo = @pedimentoOriginal) 
	SET @clavePedimento = (SELECT clavePed.cp_clave FROM pedImp INNER JOIN clavePed ON pedImp.cp_codigo = clavePed.cp_codigo WHERE pi_codigo = @pedimentoOriginal)

	-- Insertar registros
	IF((@qtyRowsR1 = @qtyRowsOrg AND @qtyRowsDetOrg = @qtyRowsDetR1) AND @qtyRowsOrg>0)
	BEGIN

		-- Validar la relación pedimento-factura
		IF(@clavePedimento = 'F4')
		BEGIN
			SET @tableP = 'factExp'
			SET @tableDet = 'FactExpDet'
			SET @tableDetColumn = 'fe_codigo'
		END
		ELSE
		BEGIN
			SET @tableP = 'factImp'
			SET @tableDet = 'factImpDet'
			SET @tableDetColumn = 'fi_codigo'
		END
		
		-- Eliminar los registros actuales referentes a identificadores del pedimento R1
		DELETE FROM pedImpDetIdentifica
		FROM pedImpDetIdentifica
		INNER JOIN pedImpDetB ON pedImpDetIdentifica.pib_indiceB = pedImpDetB.pib_indiceB
		INNER JOIN pedImp ON pedImpDetB.pi_codigo = pedImp.pi_codigo
		WHERE 
			pedImp.pi_codigo = @piCodigo
		
		-- Desactivar el trigger de actualización
		ALTER TABLE [PedImpDetIdentifica] DISABLE TRIGGER [UPDATE_PEDIMPDETIDENTIFICA]
		
		-- Inserción de registros referentes a indetificadores a nivel partida
		EXEC('
				-- Declaración de variable tipo tabla para almacenar la consulta con un identity
				DECLARE @tempTable TABLE(ID INT IDENTITY(1,1),pib_indiceB INT,ide_codigo INT,ided_codigo INT,piid_desc VARCHAR(40),piid_desc2 VARCHAR(40),piid_tipo CHAR(1),ided_codigo2 INT,ided_codigo3 INT,piid_desc3 VARCHAR(40))
			
				INSERT INTO @tempTable(pib_indiceB,ide_codigo,ided_codigo,piid_desc,piid_desc2,piid_tipo,ided_codigo2,ided_codigo3,piid_desc3)
				SELECT 
					pedDetR1.pib_indiceB,pedimpdetidentifica.ide_codigo,pedimpdetidentifica.ided_codigo,
					pedimpdetidentifica.piid_desc,pedimpdetidentifica.piid_desc2,pedimpdetidentifica.piid_tipo,
					pedimpdetidentifica.ided_codigo2,pedimpdetidentifica.ided_codigo3,pedimpdetidentifica.piid_desc3
				FROM '+@tableDet+'
				INNER JOIN '+@tableP+' ON '+@tableDet+'.'+@tableDetColumn+' = '+@tableP+'.'+@tableDetColumn+'
				INNER JOIN pedImpDet ON '+@tableDet+'.pid_indicedLiga = pedImpDet.pid_indiced
				INNER JOIN pedImpDetB ON pedImpDet.pib_indiceB = pedImpDetB.pib_indiceB
				INNER JOIN pedImpDetIdentifica ON pedImpDetB.pib_indiceB = pedImpDetIdentifica.pib_indiceB
				INNER JOIN pedImpDet pedDetR1 ON factImpDet.pid_indicedLigaR1 = pedDetR1.pid_indiced
				WHERE 
					pedImpDet.pi_codigo = '+@pedimentoOriginal+'
				GROUP BY 
					pedDetR1.pib_indiceB,pedImpDetIdentifica.piid_codigo,pedimpdetidentifica.pib_indiceb,pedimpdetidentifica.ide_codigo,
					pedimpdetidentifica.ided_codigo,pedimpdetidentifica.piid_desc,pedimpdetidentifica.piid_desc2,
					pedimpdetidentifica.piid_tipo,pedimpdetidentifica.ided_codigo2,pedimpdetidentifica.ided_codigo3,
					pedimpdetidentifica.piid_desc3
				ORDER BY 
					pedDetR1.pib_indiceB
					
				-- Inserción de registros
				INSERT INTO pedImpDetIdentifica(piid_codigo,pib_indiceB,ide_codigo,ided_codigo,piid_desc,piid_desc2,piid_tipo,ided_codigo2,ided_codigo3,piid_desc3)	
				SELECT 
					(SELECT (cv_codigo-1+ID) FROM consecutivo WHERE cv_tabla = ''pedImpDetIdentifica'' AND cv_campo = ''piid_codigo''),
					pib_indiceB,ide_codigo,ided_codigo,piid_desc,piid_desc2,piid_tipo,ided_codigo2,ided_codigo3,piid_desc3
				FROM @tempTable
				
				-- Actualizar el id de la tabla
				UPDATE consecutivo
				SET cv_codigo = (SELECT MAX(piid_codigo)+1 FROM pedImpDetIdentifica) 
				WHERE cv_tabla = ''pedImpDetIdentifica''
				AND cv_campo = ''piid_codigo''
				'
			)
			
			-- Activar el trigger de actualización
			ALTER TABLE [PedImpDetIdentifica] ENABLE TRIGGER [UPDATE_PEDIMPDETIDENTIFICA]		
	END

GO
