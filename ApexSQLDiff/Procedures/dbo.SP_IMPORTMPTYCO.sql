SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_IMPORTMPTYCO] (@TABLA VARCHAR(150), @USER INT)   as

declare @maximo int

		DELETE FROM REGISTROSIMPORTADOS WHERE RI_CBFORMA=28


                  UPDATE MAESTRO SET MA_ULTIMAMODIF=GETDATE() 
		  WHERE MA_NOPARTE+'-'+MA_NOPARTEAUX IN 
			(SELECT MAESTRO0#MA_NOPARTE+'-'+MAESTRO0#MA_NOPARTEAUX
			FROM TEMPIMPORT141 
			GROUP BY  MAESTRO0#MA_NOPARTE+'-'+MAESTRO0#MA_NOPARTEAUX)


          
          update TempImport141
          set
             MAESTRO0#AR_IMPFOUSA = (select [AR_Codigo]
                                     from   Arancel ar
                                     where  [AR_Fraccion] = (select Arancel.[AR_Fraccion]
                                                             from   Arancel
                                                             where  Arancel.[AR_Codigo] = TempImport141.[MAESTRO0#AR_IMPFO])
                                            and ar.[AR_Tipo] = 'I'
                                            and ar.[PA_Codigo] <> 154)
             , MAESTRO0#AR_EXPFO = (select [AR_Codigo]
                                    from   Arancel ar
                                    where  [AR_Fraccion] = (select Arancel.[AR_Fraccion]
                                                            from   Arancel
                                                            where  Arancel.[AR_Codigo] = TempImport141.[MAESTRO0#AR_EXPFO])
                                           and ar.[AR_Tipo] = 'E'
                                           and ar.[PA_Codigo] <> 154)
             , MAESTRO0#AR_IMPFO = (select [AR_Codigo]
                                    from   Arancel ar
                                    where  [AR_Fraccion] = (select Arancel.[AR_Fraccion]
                                                            from   Arancel
                                                            where  Arancel.[AR_Codigo] = TempImport141.[MAESTRO0#AR_IMPFO])
                                           and ar.[AR_Tipo] = 'I'
                                           and ar.[PA_Codigo] <> 154)
          
          
          UPDATE MAESTRO 
		  SET MA_TIP_ENS=TempImport141.MAESTRO0#MA_TIP_ENS, 
			MA_NOPARTE=TempImport141.MAESTRO0#MA_NOPARTE, 
			TI_CODIGO=TempImport141.MAESTRO0#TI_CODIGO, 
			MA_NAME=TempImport141.MAESTRO0#MA_NAME, 
			MA_NOMBRE=TempImport141.MAESTRO0#MA_NOMBRE, 
			ME_COM=TempImport141.MAESTRO0#ME_COM, 
			PA_ORIGEN=TempImport141.MAESTRO0#PA_ORIGEN, 
			PA_PROCEDE=TempImport141.MAESTRO0#PA_PROCEDE, 
			MA_GENERICO=TempImport141.MAESTRO0#MA_GENERICO, 
			AR_IMPMX=TempImport141.MAESTRO0#AR_IMPMX, 
			AR_EXPMX=TempImport141.MAESTRO0#AR_EXPMX, 

			--2010-11-26
			AR_IMPFOUSA = /*TempImport141.MAESTRO0#AR_IMPFOUSA, */
                   (select ar.[AR_Codigo]
                    from   Arancel ar
                    where  ar.[AR_Fraccion] = (select Arancel.[AR_Fraccion]
                                               from   Arancel
                                               where  Arancel.[AR_Codigo] = TempImport141.[MAESTRO0#AR_IMPFO])
                           and ar.[AR_Tipo] = 'I'
                           and ar.[PA_Codigo] <> 154
                   ),
            AR_EXPFO = /*TempImport141.MAESTRO0#AR_EXPFO, */
                   (select ar.[AR_Codigo]
                    from   Arancel ar
                    where  ar.[AR_Fraccion] = (select Arancel.[AR_Fraccion]
                                               from   Arancel
                                               where  Arancel.[AR_Codigo] = TempImport141.[MAESTRO0#AR_EXPFO])
                           and ar.[AR_Tipo] = 'E'
                           and ar.[PA_Codigo] <> 154
                   ),
            AR_IMPFO = /*TempImport141.MAESTRO0#AR_IMPFO, */
                   (select ar.[AR_Codigo]
                    from   Arancel ar
                    where  ar.[AR_Fraccion] = (select Arancel.[AR_Fraccion]
                                               from   Arancel
                                               where  Arancel.[AR_Codigo] = TempImport141.[MAESTRO0#AR_IMPFO])
                           and ar.[AR_Tipo] = 'I'
                           and ar.[PA_Codigo] <> 154
                   ),
			MA_DEF_TIP=TempImport141.MAESTRO0#MA_DEF_TIP, 
			MA_SEC_IMP=TempImport141.MAESTRO0#MA_SEC_IMP, 
			MA_PESO_LB=TempImport141.MAESTRO0#MA_PESO_LB,
			MA_PESO_KG=TempImport141.MAESTRO0#MA_PESO_KG
 		  FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
                  AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
		  WHERE (MAESTRO.MA_INV_GEN = 'I')

		--2010-11-26
		--agregar actualizar Factores de conversion
		--Fraccion IMP USA
			DECLARE @ma_codigo int, @ar_codigo int
			
			
			DECLARE fracciones_cursor CURSOR FOR
			select ma_codigo, ar_impfo as ar_codigo
			FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
			AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
			WHERE (MAESTRO.MA_INV_GEN = 'I')
			order by maestro.ma_codigo
			
			OPEN fracciones_cursor
			
			FETCH NEXT FROM fracciones_cursor
			INTO @ma_codigo, @ar_codigo
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
			   exec SP_ACTUALIZAEQARANCEL @ar_codigo,  @ma_codigo
			
			   FETCH NEXT FROM fracciones_cursor
			   INTO @ma_codigo, @ar_codigo
			END
			
			CLOSE fracciones_cursor
			DEALLOCATE fracciones_cursor
		
		--Fraccion IMP USA orig
			set @ma_codigo = 0 
			set @ar_codigo = 0
		
			DECLARE fracciones_cursor CURSOR FOR
			select ma_codigo, AR_IMPFOUSA as ar_codigo
			FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
			AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
			WHERE (MAESTRO.MA_INV_GEN = 'I')
			order by maestro.ma_codigo
			
			OPEN fracciones_cursor
			
			FETCH NEXT FROM fracciones_cursor
			INTO @ma_codigo, @ar_codigo
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
			   exec SP_ACTUALIZAEQARANCEL @ar_codigo,  @ma_codigo
			
			   FETCH NEXT FROM fracciones_cursor
			   INTO @ma_codigo, @ar_codigo
			END
			
			CLOSE fracciones_cursor
			DEALLOCATE fracciones_cursor
		
		--Fraccion IMP USA
			DECLARE fracciones_cursor CURSOR FOR
			select ma_codigo, AR_EXPFO as ar_codigo
			FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
			AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
			WHERE (MAESTRO.MA_INV_GEN = 'I')
			order by maestro.ma_codigo
			
			OPEN fracciones_cursor
			
			FETCH NEXT FROM fracciones_cursor
			INTO @ma_codigo, @ar_codigo
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
			   exec SP_ACTUALIZAEQARANCEL @ar_codigo,  @ma_codigo
			
			   FETCH NEXT FROM fracciones_cursor
			   INTO @ma_codigo, @ar_codigo
			END
			
			CLOSE fracciones_cursor
			DEALLOCATE fracciones_cursor
		
		
		
		  select ma_codigo, ar_impfo
 		  FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
                  AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
		  WHERE (MAESTRO.MA_INV_GEN = 'I')

		  select ma_codigo, ar_expfo
 		  FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
                  AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
		  WHERE (MAESTRO.MA_INV_GEN = 'I')

		  select ma_codigo, ar_impfoUSA
 		  FROM MAESTRO INNER JOIN TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE 
                  AND MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
		  WHERE (MAESTRO.MA_INV_GEN = 'I')



	        exec SP_CREATABLALOG 41
	        insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora) 
 	        SELECT     @USER, 2, 'Actualizacion de mp Info. (No. Parte: '+MAESTRO.MA_NOPARTE+')', 41, getdate()
		  FROM MAESTRO INNER JOIN
	                      TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE AND
		MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
	        WHERE (MAESTRO.MA_INV_GEN = 'I')



		-- REGISTROS ACTUALIZADOS
                INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO,RI_TIPO,RI_CBFORMA) 
		SELECT 'MA_NOPARTE = '+CONVERT(varchar(100),MAESTRO0#MA_NOPARTE)+', MA_INV_GEN = I, MA_NOPARTEAUX = '+CONVERT(varchar(100),MAESTRO0#MA_NOPARTEAUX),'A',28
		FROM MAESTRO INNER JOIN
		                    TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE AND
			MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX
		WHERE (MAESTRO.MA_INV_GEN = 'I')


		-- REGISTROS ANEXADOS
                INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO,RI_TIPO,RI_CBFORMA) 
		SELECT 'MA_NOPARTE = '+CONVERT(varchar(100),MAESTRO0#MA_NOPARTE)+', MA_INV_GEN = I, MA_NOPARTEAUX = '+CONVERT(varchar(100),MAESTRO0#MA_NOPARTEAUX),'I',28
		FROM TempImport141
		WHERE MAESTRO0#MA_NOPARTE+'-'+MAESTRO0#MA_NOPARTEAUX NOT IN (SELECT MA_NOPARTE+'-'+MA_NOPARTEAUX FROM MAESTRO WHERE MA_INV_GEN='I')


		exec Sp_GeneraTablaTemp 'MAESTRO'

	       INSERT INTO TempImportMAESTRO (SPI_CODIGO ,MA_INV_GEN ,MA_NOPARTEAUX ,MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,MA_GENERICO ,AR_IMPMX ,AR_EXPMX ,AR_IMPFOUSA ,
				AR_EXPFO ,AR_IMPFO ,MA_DEF_TIP ,MA_SEC_IMP ,MA_PESO_LB ) 

		SELECT
		   22, MAESTRO0#MA_INV_GEN, MAESTRO0#MA_NOPARTEAUX, MAESTRO0#MA_TIP_ENS
		   , MAESTRO0#MA_NOPARTE,MAESTRO0#TI_CODIGO, MAESTRO0#MA_NAME, MAESTRO0#MA_NOMBRE, MAESTRO0#ME_COM, MAESTRO0#PA_ORIGEN
		   , MAESTRO0#PA_PROCEDE,MAESTRO0#MA_GENERICO
		   , MAESTRO0#AR_IMPMX
		   , MAESTRO0#AR_EXPMX
		   , MAESTRO0#AR_IMPFOUSA
		   , MAESTRO0#AR_EXPFO
		   , MAESTRO0#AR_IMPFO
			, MAESTRO0#MA_DEF_TIP, MAESTRO0#MA_SEC_IMP, MAESTRO0#MA_PESO_LB
		FROM TempImport141
		WHERE MAESTRO0#MA_NOPARTE+'-'+MAESTRO0#MA_NOPARTEAUX NOT IN (SELECT MA_NOPARTE+'-'+MA_NOPARTEAUX FROM MAESTRO WHERE MA_INV_GEN='I')


		INSERT INTO MAESTRO(MA_CODIGO, SPI_CODIGO ,MA_INV_GEN ,MA_NOPARTEAUX ,MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,MA_GENERICO ,AR_IMPMX ,AR_EXPMX ,AR_IMPFOUSA ,
				AR_EXPFO ,AR_IMPFO ,MA_DEF_TIP ,MA_SEC_IMP ,MA_PESO_LB, MA_ULTIMAMODIF)

		SELECT MA_CODIGO, SPI_CODIGO ,MA_INV_GEN ,MA_NOPARTEAUX ,MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,MA_GENERICO ,AR_IMPMX ,AR_EXPMX ,AR_IMPFOUSA ,
				AR_EXPFO ,AR_IMPFO ,MA_DEF_TIP ,MA_SEC_IMP ,MA_PESO_LB, GETDATE()
		FROM TempImportMAESTRO

		select @maximo= isnull(max(MA_CODIGO),0) from MAESTRO

		if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@maximo
		select @maximo= isnull(max(MA_CODIGO),0) from MAESTROREFER

		update consecutivo
		set cv_codigo =  @maximo+1
		where cv_tipo = 'MA'




		/* ============ MARESTRODEF ===========*/

		exec Sp_GeneraTablaTemp 'MAESTRODEF'

		UPDATE MAESTRODEF
		SET  MA_DEFTXT1= isnull(TempImport141.MAESTRODEF0#MA_DEFTXT1,''), 
		     MA_DEFTXT2=isnull(TempImport141.MAESTRODEF0#MA_DEFTXT2,''), 
                     MA_DEFTXT3=isnull(TempImport141.MAESTRODEF0#MA_DEFTXT3,''), 
		     MA_DEFBOL1=TempImport141.MAESTRODEF0#MA_DEFBOL1, 
		     MA_DEFBOL2=TempImport141.MAESTRODEF0#MA_DEFBOL2, 
                     MA_DEFDATE1=TempImport141.MAESTRODEF0#MA_DEFDATE1, 
		     MA_DEFDATE2=TempImport141.MAESTRODEF0#MA_DEFDATE2
		FROM         TempImport141 INNER JOIN
		                      MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE AND
			        TempImport141.MAESTRO0#MA_NOPARTEAUX = MAESTRO.MA_NOPARTEAUX INNER JOIN
		                      MAESTRODEF ON MAESTRO.MA_CODIGO = MAESTRODEF.MA_CODIGO



		insert into TempImportMAESTRODEF (MA_CODIGO,MA_DEFTXT1 ,MA_DEFTXT2 ,MA_DEFTXT3 ,MA_DEFBOL1 ,MA_DEFBOL2 ,MA_DEFDATE1 ,MA_DEFDATE2 )
		SELECT MAESTRO.MA_CODIGO, isnull(MAESTRODEF0#MA_DEFTXT1,''), isnull(MAESTRODEF0#MA_DEFTXT2,''), isnull(MAESTRODEF0#MA_DEFTXT3,''), MAESTRODEF0#MA_DEFBOL1 ,MAESTRODEF0#MA_DEFBOL2, MAESTRODEF0#MA_DEFDATE1 ,MAESTRODEF0#MA_DEFDATE2 
		FROM TempImport141 INNER JOIN
		     MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE AND
			TempImport141.MAESTRO0#MA_NOPARTEAUX = MAESTRO.MA_NOPARTEAUX
		WHERE MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTRODEF)

		INSERT INTO MAESTRODEF(MAD_CODIGO, MA_CODIGO,MA_DEFTXT1 ,MA_DEFTXT2 ,MA_DEFTXT3 ,MA_DEFBOL1 ,MA_DEFBOL2 ,MA_DEFDATE1 ,MA_DEFDATE2)
		SELECT MAD_CODIGO, MA_CODIGO,MA_DEFTXT1 ,MA_DEFTXT2 ,MA_DEFTXT3 ,MA_DEFBOL1 ,MA_DEFBOL2 ,MA_DEFDATE1 ,MA_DEFDATE2
		FROM TempImportMAESTRODEF



		update consecutivo
		set cv_codigo =  isnull((select max(MAD_CODIGO) from MAESTRODEF),0) + 1
		where cv_tipo = 'MAD'




		/* ============ MARESTROCATEG ===========*/

		DELETE FROM MAESTROCATEG WHERE MA_CODIGO IN
		(SELECT MAESTRO.MA_CODIGO
		FROM TempImport141 INNER JOIN
		     MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE AND
		    TempImport141.MAESTRO0#MA_NOPARTEAUX = MAESTRO.MA_NOPARTEAUX
		WHERE MAESTROCATEG0#CPE_CODIGO IS NOT NULL
		GROUP BY MAESTRO.MA_CODIGO)


		INSERT INTO MAESTROCATEG (MA_CODIGO,CPE_CODIGO )
		SELECT MAESTRO.MA_CODIGO, MAESTROCATEG0#CPE_CODIGO
		FROM TempImport141 INNER JOIN
		     MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE AND
		     TempImport141.MAESTRO0#MA_NOPARTEAUX = MAESTRO.MA_NOPARTEAUX
		WHERE CONVERT(VARCHAR(150),MAESTRO.MA_CODIGO)+'-'+CONVERT(VARCHAR(150),MAESTROCATEG0#CPE_CODIGO)
		NOT IN (SELECT CONVERT(VARCHAR(150),MA_CODIGO)+'-'+CONVERT(VARCHAR(150),CPE_CODIGO) FROM MAESTROCATEG)


		/* ============ MARESTROCOST ===========*/

/* para que guarde historial, ahorita se importa y solo queda un costo


                  UPDATE MAESTROCOST 
		  SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101) 
		  FROM MAESTRO INNER JOIN MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO 	  	
                  WHERE MAESTRO.MA_NOPARTE IN (SELECT T1.MAESTRO0#MA_NOPARTE FROM TempImport141 T1 GROUP BY T1.MAESTRO0#MA_NOPARTE)
			AND MAESTROCOST.MAC_CODIGO in (SELECT MAESTROCOST.MAC_CODIGO
						FROM TempImport141 INNER JOIN
						                      MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE INNER JOIN
						                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO AND 
						                      TempImport141.MAESTROCOST0#TCO_CODIGO = MAESTROCOST.TCO_CODIGO AND 
						                      MAESTROCOST.SPI_CODIGO = 22
						GROUP BY MAESTROCOST.MAC_CODIGO)


		UPDATE MAESTROCOST
		SET     MAESTROCOST.MA_COSTO= TempImport141.MAESTROCOST0#MA_COSTO
		FROM         MAESTRO INNER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO INNER JOIN
		                      TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE AND 
		                      MAESTROCOST.TCO_CODIGO = TempImport141.MAESTROCOST0#TCO_CODIGO AND 
		                      MAESTROCOST.MA_PERINI = TempImport141.MAESTROCOST0#MA_PERINI AND 
		                      MAESTROCOST.SPI_CODIGO = 22 AND 
		                      MAESTROCOST.MA_COSTO <> TempImport141.MAESTROCOST0#MA_COSTO


                   INSERT INTO MAESTROCOST (MA_CODIGO,SPI_CODIGO ,TCO_CODIGO ,MA_PERINI ,MA_COSTO ) 
		   SELECT MAESTRO.MA_CODIGO, 22, MAESTROCOST0#TCO_CODIGO, MAESTROCOST0#MA_PERINI, MAX(MAESTROCOST0#MA_COSTO)
		   FROM TempImport141 INNER JOIN
		        MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE
		   WHERE convert(varchar(150),MAESTRO.MA_CODIGO)+ convert(varchar(150),22)+convert(varchar(150),MAESTROCOST0#TCO_CODIGO)+convert(varchar(150),MAESTROCOST0#MA_PERINI) not in
			(select convert(varchar(150),maestrocost.MA_CODIGO)+ convert(varchar(150),maestrocost.SPI_CODIGO)+convert(varchar(150),maestrocost.TCO_CODIGO)+convert(varchar(150),maestrocost.MA_PERINI) 
			from maestrocost where maestrocost.ma_codigo=MAESTRO.MA_CODIGO)
		   GROUP BY MAESTRO.MA_CODIGO, MAESTROCOST0#TCO_CODIGO, MAESTROCOST0#MA_PERINI

*/
	        exec SP_CREATABLALOG 41
	        insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora) 
		SELECT     @USER, 2, 'Act. Imp. Datos, No. Parte: '+MAESTRO.MA_NOPARTE+', Costo Unitario: '+convert(varchar(50),MAESTROCOST.MA_COSTO), 41, getdate()
		FROM         MAESTRO INNER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO INNER JOIN
		                      TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE AND 
			         MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX AND 
		                      MAESTROCOST.TCO_CODIGO = TempImport141.MAESTROCOST0#TCO_CODIGO AND 
		                      MAESTROCOST.SPI_CODIGO = 22 AND 
		                      MAESTROCOST.MA_COSTO <> TempImport141.MAESTROCOST0#MA_COSTO


		UPDATE MAESTROCOST
		SET     MAESTROCOST.MA_COSTO= TempImport141.MAESTROCOST0#MA_COSTO
		FROM         MAESTRO INNER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO INNER JOIN
		                      TempImport141 ON MAESTRO.MA_NOPARTE = TempImport141.MAESTRO0#MA_NOPARTE AND 
			         MAESTRO.MA_NOPARTEAUX = TempImport141.MAESTRO0#MA_NOPARTEAUX AND 
		                      MAESTROCOST.TCO_CODIGO = TempImport141.MAESTROCOST0#TCO_CODIGO AND 
		                      MAESTROCOST.SPI_CODIGO = 22 AND 
		                      MAESTROCOST.MA_COSTO <> TempImport141.MAESTROCOST0#MA_COSTO



                   INSERT INTO MAESTROCOST (MA_CODIGO,SPI_CODIGO ,TCO_CODIGO ,MA_PERINI ,MA_COSTO ) 
		   SELECT MAESTRO.MA_CODIGO, 22, MAESTROCOST0#TCO_CODIGO, MIN(MAESTROCOST0#MA_PERINI), MAX(MAESTROCOST0#MA_COSTO)
		   FROM TempImport141 INNER JOIN
		        MAESTRO ON TempImport141.MAESTRO0#MA_NOPARTE = MAESTRO.MA_NOPARTE AND
			TempImport141.MAESTRO0#MA_NOPARTEAUX = MAESTRO.MA_NOPARTEAUX
		   WHERE convert(varchar(150),MAESTRO.MA_CODIGO)+ convert(varchar(150),22)+convert(varchar(150),MAESTROCOST0#TCO_CODIGO) not in
			(select convert(varchar(150),maestrocost.MA_CODIGO)+ convert(varchar(150),maestrocost.SPI_CODIGO)+convert(varchar(150),maestrocost.TCO_CODIGO)
			from maestrocost where maestrocost.ma_codigo=MAESTRO.MA_CODIGO)
		   GROUP BY MAESTRO.MA_CODIGO, MAESTROCOST0#TCO_CODIGO
	-- actualiza a la tasa mas baja
--	exec SP_ACTUALIZATASABAJAMA @USER



		UPDATE MAESTROCOST
		SET     MA_COSTO= ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
		                      MA_NG_ADD + MA_NG_EMP,6)
		FROM         MAESTROCOST
		WHERE TCO_CODIGO=1 AND 
		MA_COSTO<> ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
		                      MA_NG_ADD + MA_NG_EMP,6)


GO
