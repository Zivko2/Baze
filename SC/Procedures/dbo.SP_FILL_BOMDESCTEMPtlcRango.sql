SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_FILL_BOMDESCTEMPtlcRango] (@noparteini varchar(30), @nopartefin varchar(30), @spi_codigo int, @FechaEntVigor Datetime, @IncluyeSub char(1), @Tabla char(1)='N', @CL_CODIGO int=0, @FechaEntVencimiento Datetime, @FechaAnalisis Datetime)   as

declare @BST_PT int, @NFT_CODIGO int, @spi_clave varchar(20), @AR_CODIGOPT INT, @spi_analisishtsmex char(1)
DECLARE @existe INT, @nivel INT, @fechaactual varchar(11), @CODIGO_PADRE INT, @CODIGO_HIJO INT, @tieneEstructura char(1)


	--Yolanda Avila
	--2011-11-24
	--Metodo de Tracevalue
	--exec SP_FILL_temporal
	--select * from TempRangoTlc_Original
	--2012-01-18
	--Se eliminan los datos de la tabla temporal para que únicamente tenga el listado que se va a procesar
	if exists(select * from sysobjects where name = 'TempRangoTlc_Original' and xtype = 'U')
	begin
		delete from TempRangoTlc_Original	
		--Se agrego las columnas de AM_NoParteAux y NFT_TraceValue Manuel G. 10-Dic-2011
		insert into TempRangoTlc_Original (ma_noparte, ma_noparteaux, nft_tracevalue)
		select ma_noparte, MA_NoParteAux, NFT_TraceValue
		from TempRangoTlc
	end
	
	
	--2012-01-18
	--Esta tabla ya no se utiliza en la nueva version, solo se uso cuando se hacia una parte manual del proceso
	/*
	if exists(select * from sysobjects where name = 'TempRangoTlc_Listado' and xtype = 'U')
	begin
		update TempRangoTlc_Original
		set nft_tracevalue = 'S'
		where ma_noparte +'-'+ma_noparteaux  IN (select ma_noparte +'-'+ma_noparteaux from TempRangoTlc_Listado)
	end
	*/	
	

        set @tieneEstructura = 'S'

	select @spi_clave=spi_clave from spi where spi_codigo =@spi_codigo
	select @spi_analisishtsmex=spi_analisishtsmex from spi where spi_codigo=@spi_codigo


	--Yolanda Avila
	--2010-09-14
	--Aqui debe asignar la fecha Analisis que recibe como parametro el procedimiento
	--select @fechaactual=convert(varchar(11),getdate(),101)
	set @fechaactual = @FechaAnalisis




	delete from IMPORTLOG where IML_CBFORMA=-88

	--declare @macodigo table (MA_CODIGO int, NFT_CODIGO int)


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##MACODIGO'  AND  type = 'U')
	begin
		drop table ##MACODIGO
	end

		--Yolanda Avila
		--2011-11-22
		--Metodo de TraceValue
		CREATE TABLE [##MACODIGO] (
			[MA_CODIGO] [int] NULL ,
			[NFT_CODIGO] [int] NULL ,
			[PROCESADO] char(1) NULL ,
			[NFT_TRACEVALUE] char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_##MACODIGO_NFT_TRACEVALUE] DEFAULT ('N')
		) ON [PRIMARY]


	-- Nueva logica para el manejo o no, de subensambles ya se en rango o por tabla, con cliente o sin cliente.
	-- 26-oct-09 Manuel G.
	if @CL_CODIGO > 0 --Con cliente
	begin
		if @Tabla = 'S'    -- con tabla y con cliente
		begin
			if @IncluyeSub = 'S' -- con subensamble, con tabla y con cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la validacion para que tome el no.parte y el auxiliar ya que NO lo estaba considerando
				--Se agrego la parte de TRACEVALUE
				insert into ##macodigo(ma_codigo, procesado, nft_tracevalue)
				SELECT MA_CODIGO, 'N', (select NFT_TRACEVALUE from TempRangoTlc_Original where TempRangoTlc_Original.ma_noparte+'-'+TempRangoTlc_Original.ma_noparteaux = maestro.MA_NOPARTE+'-'+maestro.ma_noparteaux ) 
				FROM MAESTRO		
				--WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
				WHERE MA_NOPARTE+'-'+ma_noparteaux in (select ma_noparte+'-'+ma_noparteaux from TempRangoTlc_Original)
				AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
			end
			else -- sin subensamble, con tabla y con cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la validacion para que tome el no.parte y el auxiliar ya que NO lo estaba considerando
				--Se agrego la parte de TRACEVALUE
				insert into ##macodigo(ma_codigo, procesado, nft_tracevalue)
				SELECT MA_CODIGO, 'N', (select NFT_TRACEVALUE from TempRangoTlc_Original where TempRangoTlc_Original.ma_noparte+'-'+TempRangoTlc_Original.ma_noparteaux = maestro.MA_NOPARTE+'-'+maestro.ma_noparteaux ) 
				FROM MAESTRO
				--WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
				WHERE MA_NOPARTE+'-'+ma_noparteaux in (select ma_noparte+'-'+ma_noparteaux from TempRangoTlc_Original)
				AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
			end
		end
		else -- sin tabla y con cliente
		begin
			if @IncluyeSub = 'S' -- con subensamble, sin tabla y con cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la parte de TRACEVALUE
				--Debido a que esta opción SOLO permite indicar un rango de No.Parte no se puede indicar si UTILIZAN TRACEVALUE o no.
				--Esta opción NO podrá ser utilizada con el metodo de TRACE VALUE por sus caracteristicas, el valor por default para este metodo es "N"
				insert into ##macodigo(ma_codigo, procesado, nft_tracevalue)
				SELECT MA_CODIGO, 'N', 'N'
				FROM MAESTRO
				WHERE MA_NOPARTE >=@noparteini 
				AND MA_NOPARTE <=@nopartefin
				AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
			end
			else -- Sin subensamble, sin tabla y con cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la parte de TRACEVALUE
				--Debido a que esta opción SOLO permite indicar un rango de No.Parte no se puede indicar si UTILIZAN TRACEVALUE o no.
				--Esta opción NO podrá ser utilizada con el metodo de TRACE VALUE por sus caracteristicas, el valor por default para este metodo es "N"
				insert into ##macodigo(ma_codigo, procesado,nft_tracevalue)
				SELECT MA_CODIGO, 'N', 'N'
				FROM MAESTRO
				WHERE MA_NOPARTE >=@noparteini 
				AND MA_NOPARTE <=@nopartefin
				AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
			end
		end		
	end
	else -- sin cliente
		if @Tabla = 'S'    -- con tabla y sin cliente
		begin
			if @IncluyeSub = 'S' -- con subensamble, con tabla y sin cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la validacion para que tome el no.parte y el auxiliar ya que NO lo estaba considerando
				--Se agrego la parte de TRACEVALUE
				insert into ##macodigo(ma_codigo, procesado, nft_tracevalue)
				SELECT MA_CODIGO, 'N',(select NFT_TRACEVALUE from TempRangoTlc_Original where TempRangoTlc_Original.ma_noparte+'-'+TempRangoTlc_Original.ma_noparteaux = maestro.MA_NOPARTE+'-'+maestro.ma_noparteaux ) 
				FROM MAESTRO
				--WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
				WHERE MA_NOPARTE+'-'+ma_noparteaux in (select ma_noparte+'-'+ma_noparteaux from TempRangoTlc_Original)
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
			end
			else -- sin subensamble, con tabla y sin cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la validacion para que tome el no.parte y el auxiliar ya que NO lo estaba considerando
				--Se agrego la parte de TRACEVALUE
				insert into ##macodigo(ma_codigo, procesado,nft_tracevalue)
				SELECT MA_CODIGO, 'N', (select NFT_TRACEVALUE from TempRangoTlc_Original where TempRangoTlc_Original.ma_noparte+'-'+TempRangoTlc_Original.ma_noparteaux = maestro.MA_NOPARTE+'-'+maestro.ma_noparteaux ) 
				FROM MAESTRO
				--WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
				WHERE MA_NOPARTE+'-'+ma_noparteaux in (select ma_noparte+'-'+ma_noparteaux from TempRangoTlc_Original)
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
			end
		end
		else -- sin tabla y sin cliente
		begin
			if @IncluyeSub = 'S' -- con subensamble, sin tabla y sin cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la parte de TRACEVALUE
				--Debido a que esta opción SOLO permite indicar un rango de No.Parte no se puede indicar si UTILIZAN TRACEVALUE o no.
				--Esta opción NO podrá ser utilizada con el metodo de TRACE VALUE por sus caracteristicas, el valor por default para este metodo es "N"
				insert into ##macodigo(ma_codigo, procesado, nft_tracevalue)
				SELECT MA_CODIGO, 'N','N'
				FROM MAESTRO
				WHERE MA_NOPARTE >=@noparteini 
				AND MA_NOPARTE <=@nopartefin
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
			end
			else -- Sin subensamble, sin tabla y sin cliente
			begin
				--Yolanda Avila
				--2011-11-22
				--Se agrego la parte de TRACEVALUE
				--Debido a que esta opción SOLO permite indicar un rango de No.Parte no se puede indicar si UTILIZAN TRACEVALUE o no.
				--Esta opción NO podrá ser utilizada con el metodo de TRACE VALUE por sus caracteristicas, el valor por default para este metodo es "N"
				insert into ##macodigo(ma_codigo, procesado, nft_tracevalue)
				SELECT MA_CODIGO, 'N', 'N'
				FROM MAESTRO
				WHERE MA_NOPARTE >=@noparteini 
				AND MA_NOPARTE <=@nopartefin
				AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
			end
		end		
	


	-- Esta sección de código se cambio ya que no funcionaba correctamente cuando se queria o no manejar el subensamble,
	-- y fue cambiado por la lógica anterior.
	-- 29-oct-09 Manuel G.
	/*if @CL_CODIGO>0
	begin
		if @Tabla='S' 
		begin


			insert into ##macodigo(ma_codigo, procesado)
		
			SELECT MA_CODIGO, 'N'
			FROM MAESTRO
			WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
			AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		if @IncluyeSub='S' 
		begin
			insert into ##macodigo(ma_codigo, procesado)
			
			SELECT MA_CODIGO, 'N'
			FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		begin
			insert into ##macodigo(ma_codigo, procesado)
			
			SELECT MA_CODIGO, 'N'
			FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
		end
	end
	else  -- sin cliente
	begin
		if @Tabla='S' 
		begin
			insert into ##macodigo(ma_codigo, procesado)
		
			SELECT MA_CODIGO, 'N'
			FROM MAESTRO
			WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		if @IncluyeSub='S' 
		begin
			insert into ##macodigo(ma_codigo, procesado)
			
			SELECT MA_CODIGO, 'N'
			FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		begin
			insert into ##macodigo(ma_codigo, procesado)
			SELECT MA_CODIGO, 'N'
			FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
		end

	end*/


			
			UPDATE NAFTA
			SET NFT_PERFIN=@FechaEntVigor-1
			WHERE NFT_PERFIN>=@FechaEntVigor
			 AND NFT_CODIGO IN (SELECT MAX(NF1.NFT_CODIGO) FROM NAFTA NF1 WHERE NF1.ma_codigo=nafta.ma_codigo and NF1.spi_codigo=@spi_codigo 
				AND NF1.NFT_PERFIN IN (SELECT MAX(NF2.NFT_PERFIN) FROM NAFTA NF2 WHERE NF2.ma_codigo=nafta.ma_codigo and NF2.spi_codigo=@spi_codigo))
			--Yolanda Avila
			--2010-09-17
			--Se asigno un alias a la tabla de nafta del subquery ya que no tomaba bien la informacion sin este alias
			--and not exists(select * from nafta where ma_codigo=nafta.ma_codigo and spi_codigo=@spi_codigo and nft_perini=@FechaEntVigor and nft_perfin=@FechaEntVencimiento)
			and not exists(select * from nafta na where na.ma_codigo=nafta.ma_codigo and na.spi_codigo=@spi_codigo and na.nft_perini=@FechaEntVigor and na.nft_perfin=@FechaEntVencimiento)
			and ma_codigo in (select ma_codigo from ##macodigo)
			and nft_codigo not in (select na2.nft_codigo from nafta na2 where na2.NFT_PERINI=@FechaEntVigor and na2.NFT_PERFIN=@FechaEntVencimiento and na2.spi_codigo=@spi_codigo)
			AND NFT_PERFIN<>@FechaEntVigor-1

			exec Sp_GeneraTablaTemp 'NAFTA'

			truncate table TempImportNAFTA

			--Yolanda Avila
			--2011-11-22
			--Se agrego la parte de TRACEVALUE
			--INSERT INTO TempImportNAFTA(MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA)
			--select ma_codigo, @spi_codigo, '1', '0', '1', '1', '5', @FechaEntVigor, @FechaEntVencimiento, 'N', @spi_clave+'('+Replace(convert(varchar(11),@FechaEntVigor,101),'/','')+')', ma_noparte, ma_noparteaux, @fechaactual
			INSERT INTO TempImportNAFTA(MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA, nft_tracevalue)
			select ma_codigo, @spi_codigo, '1', '0', '1', '1', '5', @FechaEntVigor, @FechaEntVencimiento, 'N', @spi_clave+'('+Replace(convert(varchar(11),@FechaEntVigor,101),'/','')+')', ma_noparte, ma_noparteaux, @fechaactual, (select ##macodigo.nft_tracevalue from ##macodigo where ##macodigo.ma_codigo = maestro.ma_codigo)
			from maestro
			where ma_codigo in (select ma_codigo from ##macodigo)
			and ma_codigo not in (select ma_codigo from nafta where NFT_PERINI=@FechaEntVigor and NFT_PERFIN=@FechaEntVencimiento and spi_codigo=@spi_codigo)


			--Yolanda Avila
			--2011-11-22
			--Se agrego la parte de TRACEVALUE
			--insert into nafta(NFT_CODIGO, MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA)
			--select NFT_CODIGO+ISNULL((SELECT MAX(NFT_CODIGO) FROM NAFTA),0), MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA
			insert into nafta(NFT_CODIGO, MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA, nft_tracevalue)
			select NFT_CODIGO+ISNULL((SELECT MAX(NFT_CODIGO) FROM NAFTA),0), MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA, nft_tracevalue
			from TempImportNAFTA
			where ma_codigo in (select ma_codigo from ##macodigo)

                        -- Una vez que inserta en nafta, actualizar consecutivo según tabla nafta 10-Nov-09 Manuel G.
                        exec sp_ActualizaConsecutivoTabla 'NFT'

			update ##macodigo
			set nft_codigo=nafta.nft_codigo
			from ##macodigo ma inner join nafta on nafta.ma_codigo=ma.ma_codigo 
			where spi_codigo=@spi_codigo and nft_perini=@FechaEntVigor and nft_perfin=@FechaEntVencimiento
			

			UPDATE NAFTA			
			set	AR_CODIGO=case when ma_codigo>0 then
				(case when (select spi_analisishtsmex from spi where spi_codigo=nafta.spi_codigo)='S' then
					(select isnull(ar_impmx,0) from maestro where ma_codigo=nafta.ma_codigo)
					else
					(select isnull(ar_impfo,0) from maestro where ma_codigo=nafta.ma_codigo)
				end)
				else
				(case when (select spi_analisishtsmex from spi where spi_codigo=nafta.spi_codigo)='S' then
					(select isnull(max(ar_expmx),0) from factexpdet where fed_noparte=nafta.nft_noparte and fed_noparteaux=nafta.nft_noparteaux)
					else
					(select isnull(max(ar_impfo),0) from factexpdet where fed_noparte=nafta.nft_noparte  and fed_noparteaux=nafta.nft_noparteaux)
				end)
				end 
			from nafta
			where nft_codigo in (select nft_codigo from ##macodigo)


			UPDATE NAFTA
			SET NFT_FECHA=@fechaactual
			where nft_codigo in (select nft_codigo from ##macodigo)


			-- verifica la informacion de los productos

			if (select CF_ANALISISCOSTOMA from configuracion)='S' AND @spi_codigo in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta'))
			begin

				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 			
				select  'NO. PARTE PT: ' +ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', -88, ma_codigo
				from maestro
				where ma_codigo in (select ma_codigo from ##macodigo) AND
				(SELECT ISNULL(m1.MA_COSTOUNITLC,0) FROM MAESTRO m1 WHERE m1.MA_CODIGO =maestro.ma_codigo)=0
			end	
			else
			begin
				if @spi_codigo in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta'))
				begin

					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					select  'NO. PARTE PT: ' +ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', -88, ma_codigo
					from maestro
					where ma_codigo in (select ma_codigo from ##macodigo)
						and 
						(select count(*) AS CUENTA from maestrocost where mac_codigo in (SELECT max(mac_codigo) FROM MAESTROCOST m1 
						       WHERE m1.SPI_CODIGO in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta')) AND m1.TCO_CODIGO in (select TCO_MANUFACTURA from configuracion) AND m1.MA_PERINI <= @fechaactual 
						        AND m1.MA_PERFIN >= @fechaactual AND m1.MA_CODIGO=maestro.ma_codigo))=0 
					
	
				end
				else
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					select  'NO. PARTE PT: ' +ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', -88, ma_codigo
					from maestro
					where ma_codigo in (select ma_codigo from ##macodigo)
						and
						(select count(*) AS CUENTA from maestrocost where mac_codigo in (SELECT max(mac_codigo) FROM MAESTROCOST m1 
						       WHERE m1.SPI_CODIGO = @spi_codigo AND m1.TCO_CODIGO in (select TCO_MANUFACTURA from configuracion) AND m1.MA_PERINI <= @fechaactual 
						        AND m1.MA_PERFIN >= @fechaactual AND m1.MA_CODIGO=maestro.ma_codigo))=0 
			end


			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
			select 'NO. PARTE PT: ' +ma_noparte +' NO TIENE ASIGNADA FRACCION ARANCELARIA', -88, maestro.ma_codigo
			from maestro inner join nafta on maestro.ma_codigo=nafta.ma_codigo
			where nft_codigo in (select nft_codigo from ##macodigo) and isnull(ar_codigo,0)=0




			if @spi_analisishtsmex='S'
			begin

				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
				select 'LA FRACCION ARANCELARIA DEL NO. PARTE PT: ' +ma_noparte +' NO TIENE ASIGNADA LA REGLA DE ORIGEN', -88, maestro.ma_codigo
				from maestro inner join nafta on maestro.ma_codigo=nafta.ma_codigo
				where nft_codigo in (select nft_codigo from ##macodigo) and isnull(ar_codigo,0)>0
				and (SELECT     count(*)
				FROM         ARANCELREGLAORIGEN INNER JOIN
				                      REGLAORIGEN INNER JOIN
				                      MAESTRO m1 INNER JOIN
				                      NAFTA nft ON m1.MA_CODIGO = nft.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = nft.SPI_CODIGO ON 
				                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
				                      ARANCELREGLAORIGEN.AR_CODIGO = m1.AR_IMPMX INNER JOIN
				                      ARANCEL ON m1.AR_IMPMX = ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
				WHERE     (nft.NFT_CODIGO = nafta.nft_codigo)
					--Yolanda Avila
					--2010-09-20
					and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = nafta.nft_codigo), 101)
					     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = nafta.nft_codigo), 101))				
					) = 0
			end
			else
			begin

				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
				select 'LA FRACCION ARANCELARIA DEL NO. PARTE PT: ' +ma_noparte +' NO TIENE ASIGNADA LA REGLA DE ORIGEN', -88, maestro.ma_codigo
				from maestro inner join nafta on maestro.ma_codigo=nafta.ma_codigo
				where nft_codigo in (select nft_codigo from ##macodigo) and isnull(ar_codigo,0)>0
				and (SELECT     count(*)
				FROM         ARANCELREGLAORIGEN INNER JOIN
				                      REGLAORIGEN INNER JOIN
				                      MAESTRO m1 INNER JOIN
				                      NAFTA nft ON m1.MA_CODIGO = nft.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = nft.SPI_CODIGO ON 
				                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
				                      ARANCELREGLAORIGEN.AR_CODIGO = m1.AR_IMPFO INNER JOIN
				                      ARANCEL ON m1.AR_IMPFO = ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
				WHERE     (nft.NFT_CODIGO = nafta.nft_codigo)
					--Yolanda Avila
					--2010-09-20
					and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = nafta.nft_codigo), 101)
					     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = nafta.nft_codigo), 101))				

					) = 0

			end
	
	


	-- estructuras cicladas =================================================================

		exec SP_NAFTACICLO
	

	-- Inserta los componentes ============================================================
	
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##SUBENSAMBLE'  AND  type = 'U')
		begin
			drop table ##SUBENSAMBLE
		end
	
	
		CREATE TABLE [##SUBENSAMBLE] (
			[NFT_CODIGO] [int] NULL ,
			[CODIGOPADRE] [int] NULL ,
			[CODIGOPERTENECE] [int] NULL ,
			[CODIGOHIJO] [int] NULL ,
			[NIVEL] [int] NULL ,
			[INCORPORACION] [decimal] (38,6) NULL 
		) ON [PRIMARY]
	
	
	
			insert into ##SUBENSAMBLE(NFT_CODIGO, CODIGOPADRE, CODIGOPERTENECE, CODIGOHIJO, NIVEL, INCORPORACION)
			SELECT NFT_CODIGO, MA_CODIGO, MA_CODIGO, MA_CODIGO, 0, 1
			FROM ##MACODIGO
		
		
			insert into ##SUBENSAMBLE(NFT_CODIGO, CODIGOPADRE, CODIGOPERTENECE, CODIGOHIJO, NIVEL, INCORPORACION)
			SELECT     TablaTemp.NFT_CODIGO, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.BOM_STRUCT.BST_HIJO, 1, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR
			FROM         dbo.BOM_STRUCT INNER JOIN ##MACODIGO TablaTemp  ON TablaTemp.MA_CODIGO = dbo.BOM_STRUCT.BSU_SUBENSAMBLE
					LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN dbo.MAESTROREFER ON 
				         dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO CONFIGURATIPOA ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPOA.TI_CODIGO
			WHERE     (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) = 'S') 
				AND (dbo.BOM_STRUCT.BST_TIP_ENS = 'F' OR dbo.BOM_STRUCT.BST_TIP_ENS IS NULL) AND (dbo.BOM_STRUCT.BST_TRANS<>'S' OR dbo.BOM_STRUCT.BST_TRANS IS NULL)
				and dbo.BOM_STRUCT.BSU_SUBENSAMBLE IN (SELECT MA_CODIGO FROM ##MACODIGO)
				AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND dbo.BOM_STRUCT.BST_INCORPOR >0 
				-- Se cambio @FechaEntVigor por @FechaActual 28-Oct-09 Manuel G.
				AND (dbo.BOM_STRUCT.BST_PERINI <=  @FechaActual and dbo.BOM_STRUCT.BST_PERFIN>=  @FechaActual)
				AND dbo.BOM_STRUCT.BSU_SUBENSAMBLE<> dbo.BOM_STRUCT.BST_HIJO
				AND dbo.BOM_STRUCT.BST_INCORPOR >0
				and dbo.BOM_STRUCT.BST_HIJO not in (select distinct(bst_pt) from BOMCICLO where bst_pt<>0)
			GROUP BY TablaTemp.NFT_CODIGO, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI
		

		
		SET @nivel=2
		
		
		inicio:
				insert into ##SUBENSAMBLE(NFT_CODIGO, CODIGOPADRE,  NIVEL, CODIGOPERTENECE, CODIGOHIJO, INCORPORACION)
				-- Esta linea se comento por la multiplicación SUM(dbo.BOM_STRUCT.BST_INCORPOR)*SUM(TablaTemp.INCORPORACION), la cual estaba mal, ya que TablaTemp.INCORPORACION
				-- no debe ser la suma es simplemente la multiplicación de cada nivel. 06-Nov-09 Manuel G.
				--SELECT TablaTemp.NFT_CODIGO, TablaTemp.CODIGOPADRE, @nivel, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR)*SUM(TablaTemp.INCORPORACION)
             			SELECT TablaTemp.NFT_CODIGO, TablaTemp.CODIGOPADRE, @nivel, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR)*TablaTemp.INCORPORACION
				FROM  BOM_STRUCT INNER JOIN ##SUBENSAMBLE TablaTemp
				      ON TablaTemp.CODIGOHIJO=BOM_STRUCT.BSU_SUBENSAMBLE LEFT OUTER JOIN MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO 
				WHERE TablaTemp.NIVEL=@nivel-1 AND dbo.BOM_STRUCT.BST_INCORPOR >0
				AND (CONFIGURATIPO.CFT_TIPO = 'P' OR CONFIGURATIPO.CFT_TIPO = 'S') 
				AND (BOM_STRUCT.BST_TIP_ENS = 'F' OR BOM_STRUCT.BST_TIP_ENS IS NULL) AND (BOM_STRUCT.BST_TRANS<>'S' OR BOM_STRUCT.BST_TRANS IS NULL)
				-- Se cambio @FechaEntVigor por @FechaActual 28-Oct-09 Manuel G.
				AND (BOM_STRUCT.BST_PERINI <=  @FechaActual and BOM_STRUCT.BST_PERFIN>=  @FechaActual)
				and BOM_STRUCT.BST_HIJO not in (select distinct(bst_pt) from BOMCICLO where bst_pt<>0)

				GROUP BY TablaTemp.NFT_CODIGO, BOM_STRUCT.BST_HIJO, TablaTemp.CODIGOPADRE, BOM_STRUCT.BSU_SUBENSAMBLE, TablaTemp.INCORPORACION
				ORDER BY BOM_STRUCT.BST_HIJO
	
	
				SET @nivel=@nivel+1
		
				if EXISTS(SELECT BOM_STRUCT.BST_HIJO
				FROM  BOM_STRUCT INNER JOIN ##SUBENSAMBLE TablaTemp
				      ON TablaTemp.CODIGOHIJO=BOM_STRUCT.BSU_SUBENSAMBLE LEFT OUTER JOIN MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO 
				WHERE TablaTemp.NIVEL=@nivel-1 AND dbo.BOM_STRUCT.BST_INCORPOR >0
				AND (CONFIGURATIPO.CFT_TIPO = 'P' OR CONFIGURATIPO.CFT_TIPO = 'S') 
				AND BOM_STRUCT.BST_HIJO <> TablaTemp.CODIGOPERTENECE
				AND (BOM_STRUCT.BST_TIP_ENS = 'F' OR BOM_STRUCT.BST_TIP_ENS IS NULL) AND (BOM_STRUCT.BST_TRANS<>'S' OR BOM_STRUCT.BST_TRANS IS NULL)
                                -- Se cambio @FechaEntVigor por @FechaActual 28-Oct-09 Manuel G.
				AND (BOM_STRUCT.BST_PERINI <=  @FechaActual and BOM_STRUCT.BST_PERFIN>=  @FechaActual)
				and dbo.BOM_STRUCT.BST_HIJO not in (select distinct(bst_pt) from BOMCICLO where bst_pt<>0))
		
				set @existe=1
				else
				set @existe=0
		
		
			while (@existe>0)
			goto inicio

         	-- Verifica si tiene estructura
		Declare cur_estructura Cursor For
                        Select CODIGOPADRE, CODIGOHIJO from ##SUBENSAMBLE
                Open cur_estructura
		FETCH NEXT FROM cur_estructura INTO @CODIGO_PADRE, @CODIGO_HIJO
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA)
			SELECT 'NO. PARTE : ' +MA_NOPARTE+' NO TIENE ASIGNADA ESTRUCTURA (BOM)', -88,  @CODIGO_PADRE
			FROM MAESTRO WHERE MA_CODIGO=@CODIGO_HIJO AND
			MA_CODIGO NOT IN (SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT WHERE 
			BST_PERINI <=  @FechaActual and BST_PERFIN>=  @FechaActual)
    	        	FETCH NEXT FROM cur_estructura INTO @CODIGO_PADRE, @CODIGO_HIJO
		END
		CLOSE cur_estructura
		DEALLOCATE cur_estructura

	
			DELETE FROM CLASIFICATLC WHERE NFT_CODIGO IN
			(SELECT DISTINCT(NFT_CODIGO) FROM ##SUBENSAMBLE)
		
			DECLARE cur_nivel CURSOR FOR
				SELECT     DISTINCT(NIVEL)
				FROM ##SUBENSAMBLE
				order by NIVEL
			OPEN cur_nivel
			
			FETCH NEXT FROM cur_nivel INTO @NIVEL
			
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		
					insert into CLASIFICATLC(BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
					    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
					    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, BST_PERTENECE,
		 			PA_CODIGO, AR_CODIGO, NFT_CODIGO)
		
		
		
					SELECT     TablaTemp.CODIGOPADRE, @FechaEntVigor, dbo.BOM_STRUCT.BST_HIJO, sum(TablaTemp.INCORPORACION*(BOM_STRUCT.BST_INCORPOR+(CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and
							isnull(MAESTRO.MA_POR_DESP,0)<>0 then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) 
							         else 0 end))) AS BST_INCORPOR, 
							'BST_DISCH'=CASE WHEN (dbo.BOM_STRUCT.BST_TIP_ENS='A') OR 
							((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='P' or ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='S') AND dbo.BOM_STRUCT.BST_TRANS='S') THEN 'S' ELSE dbo.BOM_STRUCT.BST_DISCH END, 
					                      ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO), dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
					                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
					                      CASE WHEN dbo.BOM_STRUCT.BST_TIP_ENS='A' THEN 'C' ELSE dbo.BOM_STRUCT.BST_TIP_ENS END, 1, TablaTemp.CODIGOPADRE,
							dbo.MAESTRO.PA_ORIGEN, 'AR_CODIGO'=CASE WHEN @spi_codigo in (select spi_codigo from spi where SPI_ANALISISHTSMEX='S') then MAX(dbo.MAESTRO.AR_IMPMX) else MAX(dbo.MAESTRO.AR_IMPFO) end, TablaTemp.NFT_CODIGO
					FROM         dbo.BOM_STRUCT INNER JOIN ##SUBENSAMBLE TablaTemp  ON TablaTemp.CODIGOHIJO = dbo.BOM_STRUCT.BSU_SUBENSAMBLE
								LEFT OUTER JOIN
					                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
					                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO  LEFT OUTER JOIN dbo.MAESTROREFER ON 
						         dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
					                      dbo.CONFIGURATIPO CONFIGURATIPOA ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPOA.TI_CODIGO
		
					WHERE (((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)<>'P' and ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)<>'S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS is null))
					or ((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='P' or ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS='A' or dbo.BOM_STRUCT.BST_TIP_ENS='E' 
						or dbo.BOM_STRUCT.BST_TIP_ENS='O' or dbo.BOM_STRUCT.BST_TRANS='S'))) and
						dbo.MAESTRO.MA_USO_ENANALISIS='S'
                                        -- Se cambio @FechaEntVigor por @FechaActual 28-Oct-09 Manuel G.
					AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @FechaActual and dbo.BOM_STRUCT.BST_PERFIN>= @FechaActual)
					AND dbo.BOM_STRUCT.BST_INCORPOR >0 
					and NIVEL= @NIVEL
					GROUP BY TablaTemp.CODIGOPADRE, TablaTemp.NFT_CODIGO, dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO), dbo.BOM_STRUCT.ME_CODIGO, 
					                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
					                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
					                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.PA_ORIGEN
					ORDER BY dbo.BOM_STRUCT.BST_HIJO
		
			
		
			FETCH NEXT FROM cur_nivel INTO @NIVEL
			
			END
			
			CLOSE cur_nivel
			DEALLOCATE cur_nivel
		

			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##SUBENSAMBLE'  AND  type = 'U')
			begin
				 drop table ##SUBENSAMBLE
			end
	
	
	
	
	
		
		-- verifica informacion  componentes ======================================================
	
			exec SP_ACTUALIZATIPOCOSTOCLASIFICATLCRango @spi_codigo
	
	
			exec SP_ACTUALIZATIPOMATORIGRango @fechaactual, @spi_codigo
	
	
	
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
	
			SELECT 'EL NO. PARTE SUB: ' +MA_NOPARTE+' NO TIENE ASIGNADO ANALISIS NAFTA (SE INCLUYE EN ACUMULACION DEL P.T.'+ma_noparte+')', -88, CLASIFICATLC.BST_PT
			FROM         CLASIFICATLC INNER JOIN
			                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE NFT_CODIGO in (select nft_codigo from ##macodigo)  AND CLASIFICATLC.BST_TIPOCOSTO='S' and CLASIFICATLC.BST_TRANS='S'
			AND MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM NAFTA WHERE SPI_CODIGO=@SPI_CODIGO)


			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
			SELECT     'NO. PARTE : ' +MAESTRO.MA_NOPARTE+' NO TIENE ASIGNADO COSTO VIGENTE', -88, CLASIFICATLC.BST_PT
			FROM         CLASIFICATLC INNER JOIN
			                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE     (isnull(CLASIFICATLC.BST_COS_UNI,0)= 0) AND (CLASIFICATLC.NFT_CODIGO in (select nft_codigo from ##macodigo) )
	
	
	
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
			SELECT     'NO. PARTE : ' +MAESTRO.MA_NOPARTE+' NO TIENE ASIGNADA FRACCION ARANCELARIA', -88, CLASIFICATLC.BST_PT
			FROM         CLASIFICATLC INNER JOIN
			                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      ARANCEL ON CLASIFICATLC.AR_CODIGO = ARANCEL.AR_CODIGO
			WHERE     (ARANCEL.AR_FRACCION IS NULL OR
			                      ARANCEL.AR_FRACCION = '' OR
			                      ARANCEL.AR_FRACCION = 'SINFRACCION' OR
			                      ARANCEL.AR_FRACCION = 'SIN FRACCION') AND (CLASIFICATLC.NFT_CODIGO in (select nft_codigo from ##macodigo) )
	
	
			-- genera el calculo ================================================================
			DECLARE Cur_tlcRango CURSOR FOR
				SELECT     MA_CODIGO
				FROM ##macodigo
				order by MA_CODIGO
			OPEN Cur_tlcRango
			
			FETCH NEXT FROM Cur_tlcRango INTO @BST_PT
			
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		
		
		
				select @NFT_CODIGO=NFT_CODIGO from nafta where ma_codigo=@BST_PT and spi_codigo=@spi_codigo and nft_perini=@FechaEntVigor and nft_perfin=@FechaEntVencimiento
		
		
		
		
				exec SP_FILL_BOMDESCTEMPtlc @BST_PT, @NFT_CODIGO, 'N'
		
				update ##macodigo
				set procesado='S'
				where MA_CODIGO=@BST_PT
		
			
			FETCH NEXT FROM Cur_tlcRango INTO @BST_PT
			
			END
			
			CLOSE Cur_tlcRango
			DEALLOCATE Cur_tlcRango
		
		
		
		
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
				SELECT     'CALIFICO: '+REPLACE(REPLACE(NFT_CALIFICO,'N','NO'),'S','SI')+CHAR(9)+ +' NO. PARTE: '+ISNULL(NAFTA.NFT_NOPARTE, MAESTRO.MA_NOPARTE) +CHAR(9)++' PAIS: '+ PAIS.PA_ISO+CHAR(9)+ 
				+'CRITERIO: '+(case when NFT_CALIFICO='N' then '' else
				(case when NFT_CRITERIO='0' then 'A'
				when NFT_CRITERIO='1' then 'B'
				when NFT_CRITERIO='2' then 'C'
				when NFT_CRITERIO='3' then 'D'
				when NFT_CRITERIO='4' then 'E'
				when NFT_CRITERIO='5' then 'F' end) end) +CHAR(9)+ 
				+'MET. UTILIZADO: '+(case when NFT_CALIFICO='N' then '' else (case when NFT_NETCOST='0' then 'NET COST'
				when NFT_NETCOST='1' then 'NO APLICA'
				when NFT_NETCOST='2' then 'VT (VALOR TRANS.)'
				when NFT_NETCOST='3' then 'PROMEDIOS ART. 4-04(7)'
				when NFT_NETCOST='4' then 'SALTO ARANCELARIO' end) end)+CHAR(9)+
				+'OTRAS INSTANCIAS: '+(case when NFT_CALIFICO='N' then '' else (case when NFT_OTRASINST='1' then 'DMI (DE MINIMIS)'
				when NFT_OTRASINST='2' then 'MAI (MATERIALES INTERMEDIOS)'
				when NFT_OTRASINST='3' then 'ACU (ACUMULACION..)'
				when NFT_OTRASINST='4' then 'BMF (BIENES Y MATERIALES FUNGIBLES)'
				when NFT_OTRASINST='5' then 'NO APLICA' end) end), -88, @BST_PT
				FROM         NAFTA LEFT OUTER JOIN
				                      PAIS ON NAFTA.PA_CLASE = PAIS.PA_CODIGO LEFT OUTER JOIN
				                      MAESTRO ON NAFTA.MA_CODIGO = MAESTRO.MA_CODIGO
				WHERE ISNULL(NFT_BASIS,'')<>'' AND NFT_CODIGO in (select nft_codigo from ##macodigo) and   
				NAFTA.MA_CODIGO NOT IN (SELECT IML_REFERENCIA FROM IMPORTLOG WHERE IML_CBFORMA=-88 AND IML_REFERENCIA= NAFTA.MA_CODIGO )
		
		
		
			truncate table TempRangoTlc
			--Yolanda Avila
			--2012-01-18
			--Esta tabla ya no se utiliza en la nueva version, solo se uso cuando se hacia una parte manual del proceso
			--truncate table TempRangoTlc_Listado

			-- Cursor agregado para verificar si a algun no. parte le falto información
			-- y asi eliminarlo y no calificarlo. 28-Oct-2009 Manuel G.
			DECLARE Cur_tlcRango CURSOR FOR
				SELECT     MA_CODIGO
				FROM ##macodigo
				order by MA_CODIGO
			OPEN Cur_tlcRango
			FETCH NEXT FROM Cur_tlcRango INTO @BST_PT
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
                                select @NFT_CODIGO=NFT_CODIGO from nafta where ma_codigo=@BST_PT and spi_codigo=@spi_codigo and nft_perini=@FechaEntVigor and nft_perfin=@FechaEntVencimiento
				if exists(select * from CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO and (isnull(ar_codigo,0)=0 or isnull(bst_cos_uni,0)=0))
				or exists(select * from importlog where IML_CBFORMA=-88 and IML_REFERENCIA=@BST_PT AND IML_MENSAJE like '%NO TIENE%')
	                          begin
		 			-- Se agrego que eliminara la clasificación ya que le falto alguna información
					-- 28-Oct-2009 Manuel G.
		                        DELETE FROM CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO
					update nafta
					set nft_califico='N', NFT_BASIS='', NFT_CLASE='1', NFT_FABRICA='0', NFT_CRITERIO='1', NFT_NETCOST='1', NFT_OTRASINST='5'
					where nft_codigo=@NFT_CODIGO
	                          end
			         FETCH NEXT FROM Cur_tlcRango INTO @BST_PT
			END
			CLOSE Cur_tlcRango
			DEALLOCATE Cur_tlcRango
	


			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##MACODIGO'  AND  type = 'U')
			begin
				drop table ##MACODIGO
			end	
                      
GO
