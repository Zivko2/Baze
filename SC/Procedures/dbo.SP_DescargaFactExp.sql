SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- Descarga de Facturas de Exportaci>n NUEVA
CREATE PROCEDURE dbo.SP_DescargaFactExp (@CodigoFactura Int, @MetodoDescarga Varchar(4), @user int, @Concilia char(1)='N')   as

SET NOCOUNT ON 

  DECLARE @FechaActual varchar(10), @CodigoMexico Int, @TEmbarque char(1), @CountPT Int, @bst_hijo int, @DesperdicioConfig CHAR(1), @FE_TIPO CHAR(1),
@CF_DESCDESPERDICIO char(1), @CF_DESCARGASBUS char(1), @CF_DESCSENCILLAS char(1), @cuentamanual int, @consecutivo int, @fe_fecha varchar(11),
@fe_folio varchar(25), @hora varchar(15), @em_codigo int, @cuentaeq int, @tipo char(1)

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO),0)+1 FROM KARDESPED 

	
	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS


	select @fe_fecha=convert(varchar(11),fe_fecha,101), @fe_folio=fe_folio from factexp where fe_codigo=@CodigoFactura

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	   -- Aqui la factura a Procesarse manualmente en caso de haber encontrado que alguno de los detalles era de tipo descarga manual
	   -- en este caso checamos para todos aquellos cuyo tipo sea de Herramienta que por el momento es el unico tipo que se descarga manualmente
	

	SELECT  @cuentamanual=count(*) from factexp where (tf_codigo in (select tf_codigo from configuratfact where (cff_tipodescarga='M')) or
	tq_codigo in (select tq_codigo from tembarque where (tq_ti_desc='M'))) and 
	(dbo.FACTEXP.FE_CODIGO = @CodigoFactura )


	--  IF @@ROWCOUNT > 0
	if @cuentamanual >0
	    RETURN 99001



	SELECT  @cuentaeq=count(*) from factexpdet where FE_CODIGO = @CodigoFactura and ti_codigo in 
	  (select ti_codigo from configuratipo where cft_tipo in ('C', 'H', 'Q', 'X'))


/*	if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' and (select count(*) from factexp where fe_codigo=@CodigoFactura and cp_codigo in
		(select cp_codigo from claveped where cp_clave in ('A1', 'T1', 'C1', 'I1')))>0
	  	 set @tipo= 'D'
	else
	begin*/
		if @cuentamanual =0 and @cuentaeq >0
	  	 set @tipo= 'F'
		else
	  	 set @tipo= 'M'
--	end


SET @FechaActual = convert(varchar(10), getdate(),101)


--	exec LlenaPIDescargaNoDescInicial
	if exists(select * from FACTEXP WHERE fe_codigo = @CodigoFactura
	and tq_codigo in (SELECT TQ_CODIGO FROM TEMBARQUE WHERE TQ_NOMBRE='EMPAQUE REUTILIZABLE'))
	begin
		UPDATE FACTEXP 
		SET FE_FECHADESCARGA=GETDATE(), FE_DESCARGADA='S'
		WHERE FE_CODIGO=@CodigoFactura
	end

	-- If modificado Manuel G. tunning descargas Feb 2010
	if (select count(*) from bom_desctemp where fe_codigo=@CodigoFactura)>0 
	begin


		SELECT     @COUNTPT = COUNT(*)
		FROM         dbo.FACTEXPDET LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR dbo.CONFIGURATIPO.CFT_TIPO = 'S') 
			    AND (dbo.FACTEXPDET.FED_TIP_ENS<>'C')
		GROUP BY dbo.FACTEXPDET.FE_CODIGO
		HAVING      (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)
	
	
		SELECT     @TEmbarque = dbo.CONFIGURATEMBARQUE.CFQ_TIPO, @FE_TIPO = dbo.FACTEXP.FE_TIPO
		FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO
		GROUP BY dbo.CONFIGURATEMBARQUE.CFQ_TIPO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_TIPO
		HAVING      (dbo.FACTEXP.FE_CODIGO = @CodigoFactura)
	
	
		SELECT @DesperdicioConfig = CF_DESPERDICIO_BOM, @CF_DESCDESPERDICIO =CF_DESCDESPERDICIO
		FROM CONFIGURACION
	
	
	
		/* Con este procedimiento se sacan todos lo no. de parte a descargar y se insertan en la tabla BOM_DESCTEMP
		pero se comenta porque ya esta en codigo la explosion*/
	
	--	EXEC SP_DescExplosionFactExp @CodigoFactura, @user

		UPDATE FACTEXP 
		SET FE_FECHADESCARGA=GETDATE(), FE_DESCARGADA='S'
		WHERE FE_CODIGO=@CodigoFactura



	--		Aqui Insertamos el desperdicio en almacen de desperdicio de acuerdo al bom !!!!!
		if @TEmbarque<>'D'	
		begin
			IF @DesperdicioConfig = 'S' 
				--si en configura dice que captura cantidad de desperdicio en bom
	
			BEGIN
	
				if exists (select * from ALMACENDESP where FETR_CODIGO=@CodigoFactura)
				delete from ALMACENDESP where FETR_CODIGO=@CodigoFactura
	
				INSERT INTO  ALMACENDESP (FETR_CODIGO, FETR_INDICED, FETR_TIPO, MA_PADRE, MA_HIJO, TI_CODIGO,
					ADE_CANT,  ME_CODIGO, ADE_SALDO, ADE_ENUSO, ADE_GENERADOPOR, TIPO_ENT_SAL, PI_CODIGO, PID_INDICED,
					ADE_CANTKG, ADE_PESO_UNIKG, MA_GENERICO)
	
				/*SELECT     dbo.FACTEXP.FE_CODIGO, dbo.BOM_DESCTEMP.FED_INDICED, dbo.FACTEXP.FE_TIPO, dbo.FACTEXPDET.MA_CODIGO, 
	     				         dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.TI_CODIGO, 
						--Modificacion Manuel G. 02-JUNIO-2010
						--sum(dbo.BOM_DESCTEMP.FED_CANT * (ABS(dbo.MAESTRO.MA_POR_DESP)/dbo.BOM_DESCTEMP.BST_INCORPOR)) AS ADE_CANT, 
						SUM(dbo.BOM_DESCTEMP.FED_CANT * ABS(dbo.MAESTRO.MA_POR_DESP/100)) AS ade_cant,
	             			         dbo.BOM_DESCTEMP.ME_CODIGO, sum(dbo.BOM_DESCTEMP.FED_CANT * (ABS(dbo.MAESTRO.MA_POR_DESP)/dbo.BOM_DESCTEMP.BST_INCORPOR)*dbo.BOM_DESCTEMP.BST_PESO_KG) AS ADE_SALDO, 'N',  'B' , 'S', 0, 0,
				          sum(dbo.BOM_DESCTEMP.FED_CANT * (ABS(dbo.MAESTRO.MA_POR_DESP)/dbo.BOM_DESCTEMP.BST_INCORPOR)*dbo.BOM_DESCTEMP.BST_PESO_KG) , max(dbo.BOM_DESCTEMP.BST_PESO_KG), MAESTRO.MA_GENERICO
				FROM         dbo.BOM_DESCTEMP LEFT OUTER JOIN
				         dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.BOM_DESCTEMP.FED_INDICED = dbo.FACTEXPDET.FED_INDICED RIGHT OUTER JOIN
	     				         dbo.FACTEXP ON dbo.BOM_DESCTEMP.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE dbo.MAESTRO.MA_POR_DESP IS NOT NULL AND ABS(dbo.MAESTRO.MA_POR_DESP) >0
				GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.BOM_DESCTEMP.FED_INDICED, dbo.FACTEXPDET.MA_CODIGO, 
			                     dbo.BOM_DESCTEMP.BST_HIJO, dbo.BOM_DESCTEMP.TI_CODIGO, 
	     				         dbo.FACTEXPDET.FED_RETRABAJO, dbo.FACTEXP.FE_TIPO, dbo.MAESTRO.TI_CODIGO, dbo.BOM_DESCTEMP.ME_CODIGO, 
	     				         dbo.BOM_DESCTEMP.BST_DISCH,MAESTRO.MA_GENERICO
				HAVING      (dbo.FACTEXPDET.FED_RETRABAJO = 'N') AND (dbo.FACTEXP.FE_CODIGO = @CodigoFactura) 
					--AND sum (dbo.BOM_DESCTEMP.FED_CANT * (ABS(dbo.MAESTRO.MA_POR_DESP)/dbo.BOM_DESCTEMP.BST_INCORPOR))>0 
					AND SUM(dbo.BOM_DESCTEMP.FED_CANT * ABS(dbo.MAESTRO.MA_POR_DESP/100)) > 0
					AND (dbo.BOM_DESCTEMP.BST_DISCH = 'S')
				*/
				SELECT     dbo.FACTEXP.FE_CODIGO, dbo.BOM_DESCTEMP.FED_INDICED, dbo.FACTEXP.FE_TIPO, dbo.FACTEXPDET.MA_CODIGO, 
	     				         dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.TI_CODIGO, 
					sum(dbo.BOM_DESCTEMP.FED_CANT * (ABS(dbo.MAESTRO.MA_POR_DESP)/dbo.BOM_DESCTEMP.BST_INCORPOR)) AS ADE_CANT, 
	             			         dbo.BOM_DESCTEMP.ME_CODIGO, 
					  sum(dbo.BOM_DESCTEMP.FED_CANT * ((ABS(dbo.MAESTRO.MA_POR_DESP)*dbo.BOM_DESCTEMP.BST_INCORPOR)/100)*dbo.BOM_DESCTEMP.BST_PESO_KG) AS ADE_SALDO, 
					  'N',  'B' , 'S', 0, 0,
				          sum(dbo.BOM_DESCTEMP.FED_CANT * ((ABS(dbo.MAESTRO.MA_POR_DESP)*dbo.BOM_DESCTEMP.BST_INCORPOR)/100)*dbo.BOM_DESCTEMP.BST_PESO_KG) ,
					  max(dbo.BOM_DESCTEMP.BST_PESO_KG), MAESTRO.MA_GENERICO
				FROM  dbo.BOM_DESCTEMP 
				LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO 
				LEFT OUTER JOIN dbo.FACTEXPDET ON dbo.BOM_DESCTEMP.FED_INDICED = dbo.FACTEXPDET.FED_INDICED 
				RIGHT OUTER JOIN dbo.FACTEXP ON dbo.BOM_DESCTEMP.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE dbo.MAESTRO.MA_POR_DESP IS NOT NULL AND ABS(dbo.MAESTRO.MA_POR_DESP) >0
				and (dbo.FACTEXP.FE_CODIGO = @CodigoFactura)
				and (dbo.FACTEXPDET.FED_RETRABAJO = 'N') 
				and (dbo.BOM_DESCTEMP.BST_DISCH = 'S')
				GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.BOM_DESCTEMP.FED_INDICED, dbo.FACTEXPDET.MA_CODIGO, 
			                     dbo.BOM_DESCTEMP.BST_HIJO, dbo.BOM_DESCTEMP.TI_CODIGO, 
	     				         dbo.FACTEXPDET.FED_RETRABAJO, dbo.FACTEXP.FE_TIPO, dbo.MAESTRO.TI_CODIGO, dbo.BOM_DESCTEMP.ME_CODIGO, 
	     				         dbo.BOM_DESCTEMP.BST_DISCH,MAESTRO.MA_GENERICO
				HAVING   sum (dbo.BOM_DESCTEMP.FED_CANT * ((ABS(dbo.MAESTRO.MA_POR_DESP)*dbo.BOM_DESCTEMP.BST_INCORPOR)/100))>0 



				EXEC SP_ACTUALIZAEQGENALMDESP @CodigoFactura

			END

		end	


		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Descargando, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Discharge, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)


		print '<========= Descargando ' + convert(varchar(50), @CodigoFactura) + + convert(varchar(11), @fe_fecha) +', '+@hora+ '=========>' 


		if @TEmbarque='D'
			Exec sp_descargaMain  @CodigoFactura, @MetodoDescarga, 'D', @Concilia, @tipo
		else
		begin
			IF @COUNTPT>0  --si hay productos terminados o subensambles
			begin
				Exec sp_descargaMain  @CodigoFactura, @MetodoDescarga, 'NM', @Concilia, @tipo
		end
			else
				Exec sp_descargaMain  @CodigoFactura, @MetodoDescarga, 'N', @Concilia, @tipo
		end


		IF @COUNTPT>0  --si hay productos terminados o subensambles
	
		begin
			
		--	Aqui Insertamos aquellos que no tienen bom!!!!!

				INSERT INTO KARDESPEDtemp(KAP_FACTRANS, KAP_INDICED_FACT, KAP_ESTATUS, KAP_CANTDESC, KAP_CantTotADescargar, KAP_Saldo_FED)
	
				SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED,'B', 0, 0, 0
				FROM         dbo.BOM_STRUCT RIGHT OUTER JOIN
				                      dbo.FACTEXPDET ON dbo.BOM_STRUCT.BST_PERFIN >= dbo.FACTEXPDET.FED_FECHA_STRUCT AND 
				                      dbo.BOM_STRUCT.BST_PERINI <= dbo.FACTEXPDET.FED_FECHA_STRUCT AND 
				                      dbo.BOM_STRUCT.BSU_SUBENSAMBLE = dbo.FACTEXPDET.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.FACTEXPDET.FED_TIP_ENS = 'F')
				GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, 
				                      dbo.FACTEXPDET.FED_RETRABAJO
				HAVING      (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
				                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE IS NULL) AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND 
				                      (dbo.FACTEXPDET.FED_RETRABAJO = 'N')
				ORDER BY dbo.FACTEXPDET.FE_CODIGO
	
				UPDATE dbo.FACTEXPDET
				SET dbo.FACTEXPDET.FED_DESCARGADO='S'
				FROM         dbo.BOM_STRUCT RIGHT OUTER JOIN
				                      dbo.FACTEXPDET ON dbo.BOM_STRUCT.BST_PERFIN >= dbo.FACTEXPDET.FED_FECHA_STRUCT AND 
				                      dbo.BOM_STRUCT.BST_PERINI <= dbo.FACTEXPDET.FED_FECHA_STRUCT AND 
				                      dbo.BOM_STRUCT.BSU_SUBENSAMBLE = dbo.FACTEXPDET.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE dbo.FACTEXPDET.FED_TIP_ENS='F'
				AND     (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
				                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE IS NULL) AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND 
				                      (dbo.FACTEXPDET.FED_RETRABAJO = 'N') 

	
		end
	
	
	
	
	
			IF @TEmbarque ='T'  or @TEmbarque = 'D' /*pedimentos con los que entraron el retorno y desperdicio que no se declararon en ningun pedimento
									de importacion -- por eso no se descargan -- ej. el deperdicio generado por retrabajo*/
	
				begin
					INSERT INTO KARDESPEDtemp(KAP_FACTRANS, KAP_INDICED_FACT, 
					    MA_HIJO, KAP_ESTATUS, KAP_TIPO_DESC, KAP_CANTDESC, KAP_CANTTOTADESCARGAR)
	
					SELECT FACTEXP.FE_CODIGO, FACTEXPDET.FED_INDICED, 
					    FACTEXPDET.MA_CODIGO AS MA_HIJO, 
					    'T' AS KAP_ESTATUS, 
					    ALMACENDESP.MA_GENERA_EMP AS KAP_TIPO_DESC, FACTEXPDET.FED_CANT, FACTEXPDET.FED_CANT
					FROM ALMACENDESP LEFT OUTER JOIN
					    PEDIMP ON 
					    ALMACENDESP.PI_CODIGO = PEDIMP.PI_CODIGO RIGHT OUTER
					     JOIN
					    MAESTRO RIGHT OUTER JOIN
					    FACTEXPDET ON 
					    MAESTRO.MA_CODIGO = FACTEXPDET.MA_CODIGO ON 
					    ALMACENDESP.ADE_CODIGO = FACTEXPDET.ADE_CODIGO RIGHT
					     OUTER JOIN
					    FACTEXP ON 
					    FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
					WHERE (ALMACENDESP.PI_CODIGO IS NOT NULL and ALMACENDESP.PI_CODIGO<>0) AND 
					    (FACTEXP.FE_CODIGO = @CodigoFactura) and (ADE_GENERADOPOR='R')
				end
	
	
		if (select CF_DESCUPDATECOSTFE from configuracion)='S' and @TEmbarque<>'D' and (SELECT ISNULL(FE_INICIOCRUCE,'N') FROM FACTEXP WHERE FE_CODIGO=@CodigoFactura)='N'
		Exec sp_DescValorTransaccion  @CodigoFactura
	

		if (SELECT CF_CAMBIOTASASEC FROM CONFIGURACION)='S'
		exec sp_actualizaTasaSectorPT @CodigoFactura

	

		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Descargando, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Discharge, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)


		print '<========= Descargando ' + convert(varchar(50), @CodigoFactura) + + convert(varchar(11), @fe_fecha) +', '+@hora+ '=========>' 
	
		exec SP_ACTUALIZAESTATUSFACTEXP @CodigoFactura
	
		--Actualiza los saldos de control de retrabajo
		declare @CR_Codigo int, @CRS_CantidadDescargada decimal(38,6)
		declare @SALDORETRABAJO table(CR_Codigo int not null,
                          CRS_CantidadDescargada decimal(38, 6) not null)
		
		insert into @SALDORETRABAJO
		select crs.CR_Codigo, crs.CRS_CantidadDescargada
		from ControlRetrabajo cr
			inner join ControlRetrabajoSaldo crs on cr.CR_Codigo = crs.CR_Codigo
			inner join factexpdet on crs.Fed_Indiced = factexpdet.fed_indiced
		where factexpdet.fe_codigo = @codigoFactura
		declare SaldoR cursor for
			select CR_Codigo, CRS_CantidadDescargada from @SALDORETRABAJO
		open SaldoR
		FETCH NEXT FROM SaldoR INTO @CR_Codigo, @CRS_CantidadDescargada
		WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				update ControlRetrabajo set CR_Saldo = CR_Saldo - @CRS_CantidadDescargada
				where CR_Codigo = @CR_Codigo
				FETCH NEXT FROM SaldoR INTO @CR_Codigo, @CRS_CantidadDescargada
			END
		Close SaldoR
		deallocate SaldoR
			

	
		RETURN 0
	
	
		/*Posibles Estatus (KARDESPED.KAP_ESTATUS)
		 'D' = 'Descargado'
		 'P' = 'Parcialmente Descargado' 
		 'N' = 'No se Encuentra en Pedimento'
		 'B' = 'Sin BOM' 
		 'T' ='No se Descarga' */
	
	
		/* Posibles Tipos Desc (dbo.KARDESPED.KAP_TIPO_DESC)
		 'N' = 'Normal'
		'NS' = 'Normal Equivalente'
		'M' = 'Merma' 
		'MS' = 'Merma Equivalente'
	              'MN' = 'Manual Normal'
		'D' = 'Desperdicio'
		'DS'= 'Desperdicio Equivalente'
			*/

		-- se vulve a correr aqui para que inserto los que no tienen bom
		if exists (select * from kardespedtemp)
		EXEC SP_FILL_KARDESPED	


		begin tran
			UPDATE FACTEXP
			SET FE_DESCITALICA='S'
			WHERE FE_CODIGO NOT IN (SELECT     KAP_FACTRANS AS FE_CODIGO FROM KARDESPED WHERE (KAP_INDICED_PED IS NOT NULL)
						         GROUP BY KAP_FACTRANS)
			AND FE_CODIGO=@CodigoFactura
		commit tran


		EXEC SP_ACTUALIZAESTATUSPEDIMPDesc @CodigoFactura
		
		

		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Termino Proceso de Descarga, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Discharge Finish Process, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)


		if exists(select * from BOM_DESCTEMP WHERE FE_CODIGO = @CodigoFactura)
		DELETE FROM BOM_DESCTEMP WHERE FE_CODIGO = @CodigoFactura

	end
	else
	begin


			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	
			insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
			values (@user,1, 'No se pudo Descargar (No existe informacion en la tabla bom_desctemp), Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Couldnot be discharge, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)
	
	
			print '<========= No se pudo Descargar no existe informacion en la tabla bom_desctemp ' + convert(varchar(50), @CodigoFactura) + + convert(varchar(11), @fe_fecha) +', '+@hora+ '=========>' 


	end

--	exec LlenaPIDescargaNoDescFinal	

	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0


--              exec LlenaPIDescargaNoDescFinal

GO
