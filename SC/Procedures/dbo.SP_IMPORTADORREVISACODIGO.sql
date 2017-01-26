SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_IMPORTADORREVISACODIGO] (@tabla varchar(150), @ims_codigo int, @ims_cbforma int)   as

declare @enunciado varchar(8000), @RevisaMaestro CHAR(1), @tablename varchar(300), @codigo varchar(10)

	set @codigo = CONVERT(varchar(10),@ims_codigo)

	IF @tabla like 'TempImport1%'
	begin
		declare A cursor for

		SELECT  'INSERT INTO IMPORTLOG(IML_MENSAJE, IML_CBFORMA) SELECT ''No existe '+
			IMPORTFIELDS.IMF_DISPLAYLABEL +':''+ convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+
	 		')+ '' en la tabla '+IMPORTFIELDS.IMF_DISPLAYTABLE+''','+convert(varchar(20),@ims_cbforma)+' FROM '+@tabla+' WHERE Cod_' +
			CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA) +' not in (select '+IMPORTSPECDET.IMD_CAMPOTEXTO+' from '+IMPORTFIELDS.IMF_DISPLAYTABLE +') and '+
			' convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+') <>'''''
 			+' GROUP BY cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
		FROM         IMPORTSPECDET LEFT OUTER JOIN
		     IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
		WHERE     (IMPORTSPECDET.IMS_CODIGO = @ims_codigo) and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) AND (IMPORTSPECDET.IMD_ESCODIGO = 'S') 
	              AND IMPORTFIELDS.IMF_DISPLAYTABLE<>'-1' and IMPORTSPECDET.IMD_CALCULADO='N'
								AND IMPORTSPECDET.IMD_IMPORTAR='S'

		UNION
	
		SELECT  'INSERT INTO IMPORTLOG(IML_MENSAJE, IML_CBFORMA) SELECT ''No existe '+IMPORTFIELDS.IMF_DISPLAYLABEL+':''+ convert(varchar(1000),cod_' + CONVERT(VARCHAR(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+
			')+ '' en la tabla COMBOBOXES'','+convert(varchar(20),@ims_cbforma)+' FROM '+@tabla+' WHERE Cod_'+
			CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+ ' not in (SELECT '+IMPORTSPECDET.IMD_CAMPOTEXTO+' FROM COMBOBOXES WHERE COMBOBOXES.CB_FIELD='''+IMPORTFIELDS.IMF_FIELDNAME+''') and '+
			' convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+') <>'''''
 			+' GROUP BY cod_' + CONVERT(VARCHAR(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
		FROM         IMPORTSPECDET LEFT OUTER JOIN
		                      IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
		WHERE     (IMPORTSPECDET.IMS_CODIGO = @ims_codigo) and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) AND (IMPORTSPECDET.IMD_ESCODIGO = 'S') 
	              AND IMPORTFIELDS.IMF_TYPEOBJET='C' AND IMPORTSPECDET.IMD_CALCULADO='N'
				AND IMPORTSPECDET.IMD_IMPORTAR='S'
			
	end
	else
	begin
		declare A cursor for
		SELECT  'INSERT INTO IMPORTLOG(IML_MENSAJE, IML_CBFORMA) SELECT ''No existe '+
			IMPORTFIELDS.IMF_DISPLAYLABEL +':''+ convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+
	 		')+ '' en la tabla '+IMPORTFIELDS.IMF_DISPLAYTABLE+''','+convert(varchar(20),@ims_cbforma)+' FROM '+@tabla+' WHERE Cod_' +
			CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA) +' not in (select '+IMPORTSPECDET.IMD_CAMPOTEXTO+' from '+IMPORTFIELDS.IMF_DISPLAYTABLE +') and'+
			' convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+') <>'''''
 			+' GROUP BY cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
		FROM         IMPORTSPECDET LEFT OUTER JOIN
		     IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
		WHERE     (IMPORTSPECDET.IMS_CODIGO = @ims_codigo) and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) AND (IMPORTSPECDET.IMD_ESCODIGO = 'S') 
	              AND IMPORTFIELDS.IMF_DISPLAYTABLE<>'-1' and IMPORTSPECDET.IMD_CALCULADO='N'
			AND IMPORTSPECDET.IMD_IMPORTAR='S'

	end



	
	open A
	
	
		FETCH NEXT FROM A INTO @enunciado
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			exec(@enunciado)


		FETCH NEXT FROM A INTO @enunciado
	END
	CLOSE A
	DEALLOCATE A





	set @RevisaMaestro ='S'
	
	/* Se concatena el @ims_codigo al texto de tablas TempImport.. ya que ahora contendra el id del usuario para lo de multiusuario Manuel G. 01-Mar-11 */
	if  @tabla='TempImport162_'+convert(varchar(10),@ims_codigo) /* factura de exportacion */
	begin
		if exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
		                  dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
		WHERE     (dbo.sysobjects.name = N'TempImport162_'+convert(varchar(10),@ims_codigo)) AND (dbo.syscolumns.name = N'FACTEXP'+convert(varchar(10),@ims_codigo)+'#TQ_CODIGO'))
		begin
			-- if (select count(*) from TempImport162 where FACTEXP0#TQ_CODIGO in (select tq_codigo from tembarque where tq_nombre = 'PRODUCTO TERMINADO (CASO ESPECIAL)'))>0
			set @tablename = 'TempImport162_'+convert(varchar(10),@ims_codigo)
			exec ('select * from '+@tablename+' where FACTEXP'+@codigo+'#TQ_CODIGO in (select tq_codigo from tembarque where tq_nombre = ''PRODUCTO TERMINADO (CASO ESPECIAL)'')')
			if @@rowcount > 0
			begin
				set @RevisaMaestro ='N'
	
			end
		end
		else
			set @RevisaMaestro ='S'
	end

	if  @tabla='TempImport160_'+convert(varchar(10),@ims_codigo) /* pedimento unico */
	begin
		set @RevisaMaestro ='S'
	end


	if  @tabla='TempImport144_'+convert(varchar(10),@ims_codigo) /* factura de importacion */
	begin
		if exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
		                  dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
		WHERE     (dbo.sysobjects.name = N'TempImport144_'+convert(varchar(10),@ims_codigo)) AND (dbo.syscolumns.name = N'FACTIMP'+convert(varchar(10),@ims_codigo)+'#TQ_CODIGO'))
		begin
			--if (select count(*) from TempImport144 where FACTIMP0#TQ_CODIGO in (select tq_codigo from tembarque where tq_nombre = 'TODO TIPO MATERIAL Y EQUIPO (CASO ESPECIAL)'))>0
			set @tablename = 'TempImport144_'+convert(varchar(10),@ims_codigo)
			exec ('select * from '+@tablename+' where FACTIMP'+@codigo+'#TQ_CODIGO in (select tq_codigo from tembarque where tq_nombre = ''TODO TIPO MATERIAL Y EQUIPO (CASO ESPECIAL)'')')
			if @@rowCount > 0
			set @RevisaMaestro ='N'
	
		end
		else
			set @RevisaMaestro ='S'
	end


	IF @RevisaMaestro='S'
	begin

		if exists(select ma_codigo from maestrorefer)
		begin
			declare B cursor for
			SELECT  'INSERT INTO IMPORTLOG(IML_MENSAJE, IML_CBFORMA) SELECT ''No existe el '+IMPORTFIELDS.IMF_DISPLAYLABEL+':''+ convert(varchar(1000),cod_' + CONVERT(VARCHAR(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
			 		+')+ '' aux:''+'+tablaaux.aux+'+ '' en la tabla MAESTRO'','+convert(varchar(20),@ims_cbforma)+' FROM '+@tabla+' WHERE Cod_' +
					CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA) +'+'+ tablaaux.aux
				+' not in (select '+IMPORTSPECDET.IMD_CAMPOTEXTO+'+MA_NOPARTEAUX from MAESTRO
					union
					select '+IMPORTSPECDET.IMD_CAMPOTEXTO+'+MA_NOPARTEAUX from MAESTROREFER) and'+
					' convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+') <>'''''
		 			+' GROUP BY cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+','+tablaaux.aux
			FROM         IMPORTSPECDET LEFT OUTER JOIN
			                      IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO cross join
				(select imf_tablename+convert(varchar(10),@ims_codigo)+'#'+imf_fieldname as aux from importfields where imf_fieldname like '%noparteaux' and imt_codigo=@ims_cbforma) tablaaux
			WHERE     (IMPORTSPECDET.IMS_CODIGO = @ims_codigo) and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) AND (IMPORTSPECDET.IMD_ESCODIGO = 'S') AND
			IMPORTFIELDS.IMF_DISPLAYTABLE='-1' and IMPORTSPECDET.IMD_CALCULADO='N'
		end
		else
		begin
			declare B cursor for
			SELECT  'INSERT INTO IMPORTLOG(IML_MENSAJE, IML_CBFORMA) SELECT ''No existe el '+IMPORTFIELDS.IMF_DISPLAYLABEL+':''+ convert(varchar(1000),cod_' + CONVERT(VARCHAR(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
			 		+')+ '' aux:''+'+tablaaux.aux+'+ '' en la tabla MAESTRO'','+convert(varchar(20),@ims_cbforma)+' FROM '+@tabla+' WHERE Cod_' +
					CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA) +'+'+ tablaaux.aux
				+' not in (select '+IMPORTSPECDET.IMD_CAMPOTEXTO+'+MA_NOPARTEAUX from MAESTRO) and'+
					' convert(varchar(1000),cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+') <>'''''
		 			+' GROUP BY cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)+','+tablaaux.aux
			FROM         IMPORTSPECDET LEFT OUTER JOIN
			                      IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO cross join
				(select imf_tablename+convert(varchar(10),@ims_codigo)+'#'+imf_fieldname as aux from importfields where imf_fieldname like '%noparteaux' and imt_codigo=@ims_cbforma) tablaaux
			WHERE     (IMPORTSPECDET.IMS_CODIGO = @ims_codigo) and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) AND (IMPORTSPECDET.IMD_ESCODIGO = 'S') AND
			IMPORTFIELDS.IMF_DISPLAYTABLE='-1' and IMPORTSPECDET.IMD_CALCULADO='N'
		end	

		open B
	
			FETCH NEXT FROM B INTO @enunciado
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
				exec(@enunciado)
	
	
			FETCH NEXT FROM B INTO @enunciado
		END
		CLOSE B
		DEALLOCATE B
	


	end
	else
	begin
		SELECT @enunciado= 'UPDATE '+@tabla+' SET '+IMPORTFIELDS.IMF_TABLENAME+convert(varchar(100),@ims_codigo)+'#'+IMPORTFIELDS.IMF_FIELDNAME+
				' = cod_' + CONVERT(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
		FROM         IMPORTSPECDET LEFT OUTER JOIN
		                      IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
		WHERE     (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)  and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) AND (IMPORTSPECDET.IMD_ESCODIGO = 'S') AND
		IMPORTFIELDS.IMF_DISPLAYTABLE='-1' and IMPORTSPECDET.IMD_CALCULADO='N'

		exec(@enunciado)

	end

GO
