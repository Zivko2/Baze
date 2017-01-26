SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- Descarga de Facturas de Exportaci>n NUEVA
CREATE PROCEDURE dbo.SP_DescargaFactExpInv (@CodigoFactura Int, @MetodoDescarga Varchar(4), @user int)    as

SET NOCOUNT ON 

  DECLARE @FechaActual varchar(10), @CodigoMexico Int, @TEmbarque char(1), @CountPT Int, @bst_hijo int, @DesperdicioConfig CHAR(1), @FE_TIPO CHAR(1),
@CF_DESCDESPERDICIO char(1), @CF_DESCARGASBUS char(1), @CF_DESCSENCILLAS char(1), @cuentamaq int, @consecutivo int, @fe_fecha datetime,
@fe_folio varchar(25), @hora varchar(15), @em_codigo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO),0)+1 FROM KARDESPED 

	
	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS


	select @fe_fecha=fe_fecha, @fe_folio=fe_folio from factexp where fe_codigo=@CodigoFactura

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	   -- Aqui la factura a Procesarse manualmente en caso de haber encontrado que alguno de los detalles era de tipo descarga manual
	   -- en este caso checamos para todos aquellos cuyo tipo sea de Herramienta que por el momento es el unico tipo que se descarga manualmente

SET @FechaActual = convert(varchar(10), getdate(),101)


	if exists (select * from bom_desctemp where fe_codigo=@CodigoFactura)
	begin

	
		/* Con este procedimiento se sacan todos lo no. de parte a descargar y se insertan en la tabla BOM_DESCTEMP
		pero se comenta porque ya esta en codigo la explosion*/
	
	--	EXEC SP_DescExplosionFactExp @CodigoFactura, @user

		UPDATE FACTEXP 
		SET FE_FECHADESCARGA=GETDATE(), FE_DESCARGADA='S'
		WHERE FE_CODIGO=@CodigoFactura



		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Descargando, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Discharge, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)


		print '<========= Descargando ' + convert(varchar(50), @CodigoFactura) + + convert(varchar(11), @fe_fecha) +', '+@hora+ '=========>' 


		Exec sp_descargaMainInv  @CodigoFactura, @MetodoDescarga, 'N'


		IF @COUNTPT>0  --si hay productos terminados o subensambles
	
			begin
			
		/*	Aqui Insertamos aquellos que no tienen bom!!!!!*/
				if exists( SELECT   * FROM         dbo.BOM_STRUCT RIGHT OUTER JOIN
				                      dbo.FACTEXPDET ON dbo.BOM_STRUCT.BST_PERFIN >= dbo.FACTEXPDET.FED_FECHA_STRUCT AND 
				                      dbo.BOM_STRUCT.BST_PERINI <= dbo.FACTEXPDET.FED_FECHA_STRUCT AND 
				                      dbo.BOM_STRUCT.BSU_SUBENSAMBLE = dbo.FACTEXPDET.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.FACTEXPDET.FED_TIP_ENS = 'F')
				GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, 
				                      dbo.FACTEXPDET.FED_RETRABAJO
				HAVING      (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
				                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE IS NULL) AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND 
				                      (dbo.FACTEXPDET.FED_RETRABAJO = 'N'))
	
				INSERT INTO KARDESPEDtemp(KAP_FACTRANS, KAP_INDICED_FACT, KAP_ESTATUS)
	
				SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED,'B'
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
	

	
	
	
		if exists(select * from BOM_DESCTEMP WHERE FE_CODIGO = @CodigoFactura)
		DELETE FROM BOM_DESCTEMP WHERE FE_CODIGO = @CodigoFactura



		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Descargando, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Discharge, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)


		print '<========= Descargando ' + convert(varchar(50), @CodigoFactura) + + convert(varchar(11), @fe_fecha) +', '+@hora+ '=========>' 
	
		exec SP_ACTUALIZAESTATUSFACTEXP @CodigoFactura
	
	
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


		UPDATE FACTEXP
		SET FE_DESCITALICA='S'
		WHERE FE_CODIGO NOT IN (SELECT     KAP_FACTRANS AS FE_CODIGO FROM KARDESPED WHERE (KAP_INDICED_PED IS NOT NULL)
					         GROUP BY KAP_FACTRANS)
		AND FE_CODIGO=@CodigoFactura


		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Termino Proceso de Descarga, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Discharge Finish Process, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)


		delete from bom_desctemp where fe_codigo=@CodigoFactura

	end
	else
	begin


			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	
			insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
			values (@user,1, 'No se pudo Descargar (No existe informacion en la tabla bom_desctemp), Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Couldnot be discharge, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @FechaActual, @hora, @em_codigo)
	
	
			print '<========= No se pudo Descargar no existe informacion en la tabla bom_desctemp ' + convert(varchar(50), @CodigoFactura) + + convert(varchar(11), @fe_fecha) +', '+@hora+ '=========>' 


	end
	



	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0



























GO
