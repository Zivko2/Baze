SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[SP_ACTUALIZAARANCELBASETIGIE]   as

SET NOCOUNT ON 
DECLARE @UPDATEEQ CHAR(1)

	ALTER TABLE [ARANCEL] DISABLE TRIGGER [UPDATE_ARANCEL] 


		UPDATE dbo.ARANCEL
		SET     dbo.ARANCEL.AR_ADVDEF= isnull(InTradeGlobal.dbo.ARANCELTIGIE.ART_ADVDEF,-1), 
		              dbo.ARANCEL.AR_FECHAREVISION= isnull(InTradeGlobal.dbo.ARANCELTIGIE.ART_FECHAREVISION, (convert(varchar(10),getdate(),101))),
			dbo.ARANCEL.AR_CAPITULO= InTradeGlobal.dbo.ARANCELTIGIE.ART_CAPITULO, 
			dbo.ARANCEL.AR_DESCCAPITULO= InTradeGlobal.dbo.ARANCELTIGIE.ART_DESCCAPITULO,
			dbo.ARANCEL.AR_PARTIDA= InTradeGlobal.dbo.ARANCELTIGIE.ART_PARTIDA,
			dbo.ARANCEL.AR_DESCPARTIDA= InTradeGlobal.dbo.ARANCELTIGIE.ART_DESCPARTIDA,
			dbo.ARANCEL.AR_IVA= InTradeGlobal.dbo.ARANCELTIGIE.ART_IVA,
			dbo.ARANCEL.AR_IVAFRANJA= InTradeGlobal.dbo.ARANCELTIGIE.ART_IVAFRANJA,
			dbo.ARANCEL.AR_ULTMODIFTIGIE=GETDATE(),
			dbo.ARANCEL.AR_TIPO=InTradeGlobal.dbo.ARANCELTIGIE.ART_TIPO,
			dbo.ARANCEL.AR_OFICIAL=InTradeGlobal.dbo.ARANCELTIGIE.ART_OFICIAL
		FROM          InTradeGlobal.dbo.ARANCELTIGIE 
		INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
		and dbo.ARANCEL.AR_TIPOREG='F' and InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO = dbo.ARANCEL.PA_CODIGO	
		--Yolanda 2009-02-18
		and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo
		--WHERE dbo.ARANCEL.AR_ADVDEF<> isnull(InTradeGlobal.dbo.ARANCELTIGIE.ART_ADVDEF,-1)




		IF EXISTS(SELECT     dbo.ARANCEL.ME_CODIGO
			  FROM InTradeGlobal.dbo.ARANCELTIGIE 
			  INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
			  and (dbo.ARANCEL.ME_CODIGO<>isnull(InTradeGlobal.dbo.ARANCELTIGIE.ME_CODIGO,36) OR dbo.ARANCEL.ME_CODIGO IS NULL) 
                          and dbo.ARANCEL.AR_TIPOREG='F'
			  and InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO = dbo.ARANCEL.PA_CODIGO
			  --Yolanda 2009-02-18
			  and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo)

		  SET @UPDATEEQ='S'
		ELSE
		   SET @UPDATEEQ='N'
		

		UPDATE dbo.ARANCEL
		SET     dbo.ARANCEL.ME_CODIGO= isnull(InTradeGlobal.dbo.ARANCELTIGIE.ME_CODIGO,36), dbo.ARANCEL.ME_CODIGO2= isnull(InTradeGlobal.dbo.ARANCELTIGIE.ME_CODIGO2,0),
			dbo.ARANCEL.AR_ULTMODIFTIGIE=GETDATE()
		FROM         InTradeGlobal.dbo.ARANCELTIGIE 
		INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
			/*and (dbo.ARANCEL.ME_CODIGO= 0 OR dbo.ARANCEL.ME_CODIGO IS NULL) */and dbo.ARANCEL.AR_TIPOREG='F'
		and InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO = dbo.ARANCEL.PA_CODIGO
		--Yolanda 2009-02-18
		and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo



		IF @UPDATEEQ='S'
		EXEC SP_ACTUALIZAEQARANCELALL


/*		UPDATE dbo.ARANCEL
		SET     dbo.ARANCEL.ME_CODIGO= InTradeGlobal.dbo.ARANCELTIGIE.ME_CODIGO, dbo.ARANCEL.ME_CODIGO2= InTradeGlobal.dbo.ARANCELTIGIE.ME_CODIGO2
		FROM         InTradeGlobal.dbo.ARANCELTIGIE INNER JOIN
		                      dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
			and dbo.ARANCEL.ME_CODIGO<> InTradeGlobal.dbo.ARANCELTIGIE.ME_CODIGO and dbo.ARANCEL.AR_TIPOREG='F'
*/

		UPDATE dbo.ARANCEL
		SET     dbo.ARANCEL.AR_OFICIAL= InTradeGlobal.dbo.ARANCELTIGIE.ART_OFICIAL,
			dbo.ARANCEL.AR_ULTMODIFTIGIE=GETDATE()
		FROM         InTradeGlobal.dbo.ARANCELTIGIE INNER JOIN
		                      dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
		WHERE (dbo.ARANCEL.AR_OFICIAL='temp' or dbo.ARANCEL.AR_OFICIAL='.' or dbo.ARANCEL.AR_OFICIAL='temporal' or
		dbo.ARANCEL.AR_OFICIAL= dbo.ARANCEL.AR_USO) and dbo.ARANCEL.AR_TIPOREG='F'
		and InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO = dbo.ARANCEL.PA_CODIGO
		--Yolanda 2009-02-18
		and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo
		and dbo.ARANCEL.AR_OFICIAL<> InTradeGlobal.dbo.ARANCELTIGIE.ART_OFICIAL

		/*UPDATE dbo.PAISARA
		SET     dbo.PAISARA.PAR_BEN= isnull(InTradeGlobal.dbo.PAISARATIGIE.PART_BEN,-1)
		FROM         InTradeGlobal.dbo.PAISARATIGIE INNER JOIN
		                      dbo.PAISARA ON InTradeGlobal.dbo.PAISARATIGIE.ART_CODIGO = dbo.PAISARA.AR_CODIGO AND InTradeGlobal.dbo.PAISARATIGIE.PA_CODIGO = dbo.PAISARA.PA_CODIGO AND 
		                      InTradeGlobal.dbo.PAISARATIGIE.SPI_CODIGO = dbo.PAISARA.SPI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PAISARA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		WHERE dbo.PAISARA.AR_CODIGO IN (SELECT ARANCEL1.AR_CODIGO FROM ARANCEL ARANCEL1 WHERE ARANCEL1.AR_TIPOREG='F'
		and ARANCEL1.PA_CODIGO=ARANCEL.PA_CODIGO)
		and dbo.PAISARA.PAR_BEN<> isnull(InTradeGlobal.dbo.PAISARATIGIE.PART_BEN,-1)

		UPDATE dbo.SECTORARA
		SET     dbo.SECTORARA.SA_PORCENT= isnull(InTradeGlobal.dbo.SECTORARATIGIE.SAT_PORCENT,-1)
		FROM         dbo.SECTORARA INNER JOIN
		                      InTradeGlobal.dbo.SECTORARATIGIE ON dbo.SECTORARA.AR_CODIGO = InTradeGlobal.dbo.SECTORARATIGIE.ART_CODIGO AND 
		                      dbo.SECTORARA.SE_CODIGO = InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.SECTORARA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		WHERE dbo.SECTORARA.AR_CODIGO IN (SELECT ARANCEL1.AR_CODIGO FROM ARANCEL ARANCEL1 WHERE ARANCEL1.AR_TIPOREG='F' and ARANCEL1.PA_CODIGO=ARANCEL.PA_CODIGO)
		and dbo.SECTORARA.SA_PORCENT<> isnull(InTradeGlobal.dbo.SECTORARATIGIE.SAT_PORCENT,-1)
		*/

		delete from paisara where ar_codigo in
		(SELECT     dbo.ARANCEL.AR_CODIGO
		FROM         InTradeGlobal.dbo.ARANCELTIGIE INNER JOIN 
	                    dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
		WHERE  InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154)
		--Yolanda 2009-02-18
		--¿No importa el valor de ar_tipo ?
		--Debe estar agrupada para prevenir si vienen dos registros

		insert into paisara (AR_CODIGO, PA_CODIGO, PAR_BEN, SPI_CODIGO)
		SELECT dbo.ARANCEL.AR_CODIGO, InTradeGlobal.dbo.PAISARATIGIE.PA_CODIGO, InTradeGlobal.dbo.PAISARATIGIE.PART_BEN, InTradeGlobal.dbo.PAISARATIGIE.SPI_CODIGO
		FROM InTradeGlobal.dbo.ARANCELTIGIE 
		INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
		INNER JOIN InTradeGlobal.dbo.PAISARATIGIE ON InTradeGlobal.dbo.ARANCELTIGIE.ART_CODIGO 	= InTradeGlobal.dbo.PAISARATIGIE.ART_CODIGO
		WHERE  InTradeGlobal.dbo.PAISARATIGIE.PART_BEN IS NOT NULL 
		AND InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154
		AND convert(varchar(25),InTradeGlobal.dbo.PAISARATIGIE.PA_CODIGO)+convert(varchar(25),InTradeGlobal.dbo.PAISARATIGIE.SPI_CODIGO)
		 not in (SELECT convert(varchar(25),PA_CODIGO)+convert(varchar(25),SPI_CODIGO) FROM PAISARA WHERE AR_CODIGO =dbo.ARANCEL.AR_CODIGO)
		--Yolanda 2009-02-18
		--¿que pasa cuando una fraccion tiene dos ar_tipo , el sistema trataria de insertar dos registros y eso viola la llave primaria ?
		--Debe estar agrupada para prevenir si vienen dos registros

		-- se agrega Mexico como pais origen con tasa igual que USA
		insert into paisara (AR_CODIGO, PA_CODIGO, PAR_BEN, SPI_CODIGO)
		SELECT AR_CODIGO, 154, PAR_BEN, SPI_CODIGO
		FROM PAISARA WHERE PA_CODIGO=233
		AND convert(varchar(25),154)+convert(varchar(25),SPI_CODIGO) not in
		 (SELECT convert(varchar(25),P1.PA_CODIGO)+convert(varchar(25),P1.SPI_CODIGO) FROM PAISARA P1 WHERE P1.AR_CODIGO =PAISARA.AR_CODIGO)
		--Yolanda 2009-02-18
		--No impporta que existan varios ar_tipo para una fraccion americana

		-->	
		UPDATE dbo.ARANCEL
		SET dbo.ARANCEL.AR_ULTMODIFTIGIE=GETDATE()
		FROM InTradeGlobal.dbo.ARANCELTIGIE 
		INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
		INNER JOIN InTradeGlobal.dbo.PAISARATIGIE ON InTradeGlobal.dbo.ARANCELTIGIE.ART_CODIGO 	= InTradeGlobal.dbo.PAISARATIGIE.ART_CODIGO
		WHERE  InTradeGlobal.dbo.PAISARATIGIE.PART_BEN IS NOT NULL 
		AND InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154
		--Yolanda 2009-02-18
		and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo

		AND convert(varchar(25),InTradeGlobal.dbo.PAISARATIGIE.PA_CODIGO)+convert(varchar(25),InTradeGlobal.dbo.PAISARATIGIE.SPI_CODIGO)
		 not in (SELECT convert(varchar(25),PA_CODIGO)+convert(varchar(25),SPI_CODIGO) FROM PAISARA WHERE AR_CODIGO =dbo.ARANCEL.AR_CODIGO)


		delete from sectorara where ar_codigo in 
		(SELECT dbo.ARANCEL.AR_CODIGO
		FROM InTradeGlobal.dbo.ARANCELTIGIE 
		INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
		WHERE  InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154
		--Yolanda 2009-02-18
		and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo
		)

	
		if (SELECT CF_TIGIESECTORPERM FROM CONFIGURACION)='S'
		begin
			delete from sectorara where SE_CODIGO not 
			in (select se_codigo from vsectorperm)


			insert into sectorara (AR_CODIGO, SE_CODIGO, SA_PORCENT)
			SELECT dbo.ARANCEL.AR_CODIGO, InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO, InTradeGlobal.dbo.SECTORARATIGIE. SAT_PORCENT 
			FROM InTradeGlobal.dbo.ARANCELTIGIE 
			INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
			INNER JOIN InTradeGlobal.dbo.SECTORARATIGIE ON InTradeGlobal.dbo.ARANCELTIGIE.ART_CODIGO =InTradeGlobal.dbo.SECTORARATIGIE.ART_CODIGO
			WHERE  InTradeGlobal.dbo.SECTORARATIGIE. SAT_PORCENT IS NOT NULL 
			AND InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154
			--Yolanda 2009-02-18
			and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo

				and InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO not
				in (SELECT SE_CODIGO FROM SECTORARA WHERE AR_CODIGO =dbo.ARANCEL.AR_CODIGO)
			and InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO in (select se_codigo from vsectorperm)

		end
		else
		begin
			insert into sectorara (AR_CODIGO, SE_CODIGO, SA_PORCENT)
			SELECT dbo.ARANCEL.AR_CODIGO, InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO, InTradeGlobal.dbo.SECTORARATIGIE. SAT_PORCENT 
			FROM InTradeGlobal.dbo.ARANCELTIGIE 
			INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
			INNER JOIN InTradeGlobal.dbo.SECTORARATIGIE ON InTradeGlobal.dbo.ARANCELTIGIE.ART_CODIGO =InTradeGlobal.dbo.SECTORARATIGIE.ART_CODIGO
			WHERE  InTradeGlobal.dbo.SECTORARATIGIE. SAT_PORCENT IS NOT NULL 
			AND InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154
			--Yolanda 2009-02-18
			and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo

				and InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO not
				in (SELECT SE_CODIGO FROM SECTORARA WHERE AR_CODIGO =dbo.ARANCEL.AR_CODIGO)

		end



		UPDATE dbo.ARANCEL
		SET dbo.ARANCEL.AR_ULTMODIFTIGIE=GETDATE()
		FROM InTradeGlobal.dbo.ARANCELTIGIE 
		INNER JOIN dbo.ARANCEL ON InTradeGlobal.dbo.ARANCELTIGIE.ART_FRACCION = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') 
		INNER JOIN InTradeGlobal.dbo.SECTORARATIGIE ON InTradeGlobal.dbo.ARANCELTIGIE.ART_CODIGO =InTradeGlobal.dbo.SECTORARATIGIE.ART_CODIGO
		WHERE  InTradeGlobal.dbo.SECTORARATIGIE. SAT_PORCENT IS NOT NULL 
		AND InTradeGlobal.dbo.ARANCELTIGIE.PA_CODIGO=154
		--Yolanda 2009-02-18
		and InTradeGlobal.dbo.ARANCELTIGIE.art_tipo = dbo.ARANCEL.ar_tipo

			and InTradeGlobal.dbo.SECTORARATIGIE.SE_CODIGO not
			in (SELECT SE_CODIGO FROM SECTORARA WHERE AR_CODIGO =dbo.ARANCEL.AR_CODIGO)



		UPDATE ARANCEL
		SET AR_ADVDEF=-1, AR_ULTMODIFTIGIE=GETDATE()
		WHERE AR_ADVDEF IS NULL		

		DELETE paisara WHERE PAR_BEN IS NULL
		DELETE FROM SECTORARA WHERE SA_PORCENT IS NULL



			ALTER TABLE MAESTRO DISABLE TRIGGER Update_Maestro
	
			EXEC SP_ACTUALIZATASASMAESTROALL
	
			ALTER TABLE MAESTRO ENABLE TRIGGER Update_Maestro



		UPDATE ARANCEL
		SET AR_OBSOLETA='S', AR_ULTMODIFTIGIE=GETDATE()
		WHERE AR_CODIGO IN
		(SELECT     dbo.ARANCEL.AR_CODIGO
		 FROM         dbo.ARANCEL 
		 LEFT OUTER JOIN InTradeGlobal.dbo.ARANCELTIGIE ARANCELTIGIE ON REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') = ARANCELTIGIE.ART_FRACCION
		 WHERE     (ARANCELTIGIE.ART_FRACCION IS NULL))
		--Yolanda 2009-02-18
		--¿No importa el ar_tipo, pa_codigo  ya que tiene que poner obsoleta toda la fraccion y sus tipos?


		UPDATE ARANCEL
		SET AR_OBSOLETA='N', AR_ULTMODIFTIGIE=GETDATE()
		WHERE AR_CODIGO IN
		(SELECT dbo.ARANCEL.AR_CODIGO
		 FROM dbo.ARANCEL 
		 INNER JOIN InTradeGlobal.dbo.ARANCELTIGIE ARANCELTIGIE ON REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '') = ARANCELTIGIE.ART_FRACCION)
		--Yolanda 2009-02-18
		--¿No importa el ar_tipo, pa_codigo  ya que NO tiene que poner obsoleta toda la fraccion y sus tipos que estan en ARANCEL?


		delete from arancelcc where ar_codigo IN (SELECT dbo.ARANCEL.AR_CODIGO	
							  FROM  dbo.ARANCEL 
							  INNER JOIN InTradeGlobal.dbo.ARANCELTIGIE ARANCEL_1 ON dbo.ARANCEL.AR_FRACCION = ARANCEL_1.ART_FRACCION 
							  INNER JOIN InTradeGlobal.dbo.ARANCELTIGIECC ARANCELTIGIECC_2 ON ARANCEL_1.ART_CODIGO = ARANCELTIGIECC_2.ART_CODIGO)
		--Yolanda 2009-02-18
		--¿No importa el ar_tipo, pa_codigo  ya que tiene que borrar toda la fraccion y sus tipos?
--


		insert into arancelcc(ar_codigo, producto, pa_codigo, empresa, cuota, tasa)
		SELECT     dbo.ARANCEL.AR_CODIGO, ARANCELTIGIECC_2.PRODUCTO, ARANCELTIGIECC_2.PA_CODIGO, ARANCELTIGIECC_2.EMPRESA, 
		                      ARANCELTIGIECC_2.CUOTA, ARANCELTIGIECC_2.TASA
		FROM dbo.ARANCEL 
		INNER JOIN InTradeGlobal.dbo.ARANCELTIGIE ARANCEL_1 ON dbo.ARANCEL.AR_FRACCION = ARANCEL_1.ART_FRACCION 
		INNER JOIN InTradeGlobal.dbo.ARANCELTIGIECC ARANCELTIGIECC_2 ON ARANCEL_1.ART_CODIGO = ARANCELTIGIECC_2.ART_CODIGO
		WHERE ARANCEL_1.PA_CODIGO=154
		--Yolanda 2009-02-18
		and ARANCEL_1.art_tipo = dbo.ARANCEL.ar_tipo	
		--¿Importa el ar_tipo? ¿debe insertar los registros por cada ar_tipo de la fraccion ó solo uno por fraccion?

		GROUP BY dbo.ARANCEL.AR_CODIGO, ARANCELTIGIECC_2.PRODUCTO, ARANCELTIGIECC_2.PA_CODIGO, ARANCELTIGIECC_2.EMPRESA, 
		                      ARANCELTIGIECC_2.CUOTA, ARANCELTIGIECC_2.TASA, ARANCELTIGIECC_2.CODIGO
		ORDER BY ARANCELTIGIECC_2.CODIGO


		delete from arancelpermiso where ar_codigo IN (	SELECT dbo.ARANCEL.AR_CODIGO	
							       	FROM dbo.ARANCEL 
								INNER JOIN InTradeGlobal.dbo.ARANCELTIGIE ARANCEL_1 ON dbo.ARANCEL.AR_FRACCION = ARANCEL_1.ART_FRACCION 
								INNER JOIN InTradeGlobal.dbo.ARANCELTIGIEPERMISO ARANCELTIGIEPERMISO_2 ON ARANCEL_1.ART_CODIGO = ARANCELTIGIEPERMISO_2.ART_CODIGO
								--Yolanda 2009-02-18
								--¿Importa el ar_tipo, pa_codigo ?
							       )


		insert into arancelpermiso(AR_CODIGO, ARP_PERMISO)
		SELECT     dbo.ARANCEL.AR_CODIGO, ARANCELTIGIEPERMISO_2.ARP_PERMISO
		FROM dbo.ARANCEL 
		INNER JOIN InTradeGlobal.dbo.ARANCELTIGIE ARANCEL_1 ON dbo.ARANCEL.AR_FRACCION = ARANCEL_1.ART_FRACCION 
		INNER JOIN InTradeGlobal.dbo.ARANCELTIGIEPERMISO ARANCELTIGIEPERMISO_2 ON ARANCEL_1.ART_CODIGO = ARANCELTIGIEPERMISO_2.ART_CODIGO
		WHERE ARANCEL_1.PA_CODIGO=154
		--Yolanda 2009-02-18
		and ARANCEL_1.art_tipo = dbo.ARANCEL.ar_tipo	
		--¿Importa el ar_tipo?	
		GROUP BY dbo.ARANCEL.AR_CODIGO, ARANCELTIGIEPERMISO_2.ARP_PERMISO, ARANCELTIGIEPERMISO_2.ARP_CODIGO
		ORDER BY ARANCELTIGIEPERMISO_2.ARP_CODIGO



	ALTER TABLE [ARANCEL] ENABLE TRIGGER [UPDATE_ARANCEL]


GO
