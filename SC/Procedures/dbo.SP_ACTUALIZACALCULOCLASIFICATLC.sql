SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ACTUALIZACALCULOCLASIFICATLC] (@NFT_CODIGO INT, @regla smallint=1)   as

DECLARE  @tco_manufactura INT, @SPI_CODIGO INT, @MatNoOrig decimal(38,6), @ARG_VTMINIMO VARCHAR(50), @ARG_CNMINIMO VARCHAR(50), @ARR_MINIMIS VARCHAR(50), @spi_analisishtsmex char(1),
@SPI_CLAVE varchar(10), @enunciado varchar(8000), @NFT_CODIGOvar VARCHAR(50)

select  @tco_manufactura=TCO_MANUFACTURA from configuracion

SELECT @SPI_CODIGO=SPI_CODIGO FROM NAFTA WHERE NFT_CODIGO=@NFT_CODIGO
	
	SELECT     @MatNoOrig= round(SUM(BST_MATNOORIG),6) 
	FROM          CLASIFICATLC 
	WHERE     (BST_DISCH = 'S') AND (NFT_CODIGO = @NFT_CODIGO)


	SELECT @SPI_CLAVE=SPI_CLAVE FROM SPI WHERE SPI_CODIGO=@SPI_CODIGO

	set @NFT_CODIGOvar=convert(varchar(50),@NFT_CODIGO)

	-- la vista VTLCCOSTOTOTAL hace la suma de la tabla CLASIFICATLC
	IF (SELECT CF_ANALISISCOSTOMA FROM CONFIGURACION)='S' and @SPI_CODIGO in (select spi_codigo  from spi where (spi_clave='nafta' or spi_clave='mx'))
		UPDATE NAFTA
		SET NFT_COSTO =isnull((select MA_COSTOUNITLC from maestro where MA_CODIGO=NAFTA.MA_CODIGO),0),
		NFT_PRECIO = isnull((select mc_precio from maestrocliente where mc_codigo in
	                                               (select max(mc_codigo) from maestrocliente m2 where m2.mc_vtr='S' and m2.ma_codigo=NAFTA.MA_CODIGO)),0)
		WHERE NFT_CODIGO=@NFT_CODIGO
	ELSE
	BEGIN
		UPDATE NAFTA
		SET NFT_COSTO =isnull((select ma_costo from maestrocost where mac_codigo in 
				(SELECT max(mac_codigo) FROM MAESTROCOST m1
				WHERE m1.SPI_CODIGO = @spi_codigo AND m1.TCO_CODIGO = @tco_manufactura AND m1.MA_PERINI <= CONVERT(varchar(11), nft_fecha, 101)
				AND m1.MA_PERFIN >= CONVERT(varchar(11), nft_fecha, 101) AND m1.MA_CODIGO=NAFTA.MA_CODIGO)),0),
		NFT_PRECIO = isnull((select mc_precio from maestrocliente where mc_codigo in
	                                               (select max(mc_codigo) from maestrocliente m2 where m2.mc_vtr='S' and m2.ma_codigo=NAFTA.MA_CODIGO)),0)
		WHERE NFT_CODIGO=@NFT_CODIGO
	

		-- si no tiene asignado un costo de acuerdo al tratado para el producto, toma el nafta
		if (select isnull(NFT_COSTO,0) from NAFTA where NFT_CODIGO=@NFT_CODIGO)=0
		UPDATE NAFTA
		SET NFT_COSTO =isnull((select ma_costo from maestrocost where mac_codigo in 
				(SELECT max(mac_codigo) FROM MAESTROCOST m1
				WHERE m1.SPI_CODIGO = 22 AND m1.TCO_CODIGO = @tco_manufactura AND m1.MA_PERINI <= CONVERT(varchar(11), nft_fecha, 101)
				AND m1.MA_PERFIN >= CONVERT(varchar(11), nft_fecha, 101) AND m1.MA_CODIGO=NAFTA.MA_CODIGO)),0),
		NFT_PRECIO = isnull((select mc_precio from maestrocliente where mc_codigo in
	                                               (select max(mc_codigo) from maestrocliente m2 where m2.mc_vtr='S' and m2.ma_codigo=NAFTA.MA_CODIGO)),0)
		WHERE NFT_CODIGO=@NFT_CODIGO
	END


	UPDATE NAFTA
	SET NFT_VCRXVT=round(((NFT_PRECIO -  @MatNoOrig) / NFT_PRECIO)* 100,2)
	WHERE NFT_CODIGO=@NFT_CODIGO AND NFT_PRECIO>0

	UPDATE NAFTA
	SET NFT_VCRXVT=0
	WHERE NFT_CODIGO=@NFT_CODIGO AND NFT_PRECIO=0


	UPDATE NAFTA
	SET NFT_VCRXCN=round(((NFT_COSTO - isnull(NFT_COSTOSRESTAR,0)) - @MatNoOrig) / ((NFT_COSTO - isnull(NFT_COSTOSRESTAR,0)) )* 100,2)
	WHERE NFT_CODIGO=@NFT_CODIGO AND (NFT_COSTO - isnull(NFT_COSTOSRESTAR,0))>0

	UPDATE NAFTA
	SET NFT_VCRXCN=0
	WHERE NFT_CODIGO=@NFT_CODIGO AND (NFT_COSTO - isnull(NFT_COSTOSRESTAR,0))=0

	/* ASIGNA CRITERIO */
	
	UPDATE NAFTA
	SET     NAFTA.NFT_NETCOST='1', NFT_OTRASINST='5' , NFT_CRITERIO='1'
	WHERE NFT_CODIGO=@NFT_CODIGO 


	if (select NFT_COSTO from NAFTA WHERE NFT_CODIGO=@NFT_CODIGO) > 0
	begin

		select @spi_analisishtsmex=spi_analisishtsmex from spi where spi_codigo=@spi_codigo

		if @spi_analisishtsmex='S'
		begin
			if @regla=1
			SELECT     @ARG_VTMINIMO= isnull(max(REGLAORIGENDET.ARG_VTMINIMO),1000), @ARG_CNMINIMO=isnull(max(REGLAORIGENDET.ARG_CNMINIMO),1000), 
	                           @ARR_MINIMIS= (case when isnull(max(ARG_USAMINIMIS),'N')<>'S' then -1 else isnull(max(REGLAORIGEN.ARR_MINIMIS),7) end)
			FROM         ARANCELREGLAORIGEN INNER JOIN
			                      REGLAORIGEN INNER JOIN
			                      MAESTRO INNER JOIN
			                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
			                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
			                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPMX LEFT OUTER JOIN
			                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
			WHERE     (REGLAORIGENDET.ARR_REGLA = '1') AND (NAFTA.NFT_CODIGO = @NFT_CODIGO)
			--Yolanda Avila
			--2010-09-20
			and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))

			
			if @regla=2
			SELECT     @ARG_VTMINIMO= isnull(max(REGLAORIGENDET.ARG_VTMINIMO),1000), @ARG_CNMINIMO=isnull(max(REGLAORIGENDET.ARG_CNMINIMO),1000), 
				   @ARR_MINIMIS= (case when isnull(max(ARG_USAMINIMIS),'N')<>'S' then -1 else isnull(max(REGLAORIGEN.ARR_MINIMIS),7) end)
			FROM         ARANCELREGLAORIGEN INNER JOIN
			                      REGLAORIGEN INNER JOIN
			                      MAESTRO INNER JOIN
			                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
			                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
			                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPMX LEFT OUTER JOIN
			                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
			WHERE     (REGLAORIGENDET.ARR_REGLA = '2') AND (NAFTA.NFT_CODIGO = @NFT_CODIGO)
			--Yolanda Avila
			--2010-09-20
			and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))
			
	
	
			if @regla=3
			SELECT     @ARG_VTMINIMO= isnull(max(REGLAORIGENDET.ARG_VTMINIMO),1000), @ARG_CNMINIMO=isnull(max(REGLAORIGENDET.ARG_CNMINIMO),1000), 
				     @ARR_MINIMIS= (case when isnull(max(ARG_USAMINIMIS),'N')<>'S' then -1 else isnull(max(REGLAORIGEN.ARR_MINIMIS),7) end)
			FROM         ARANCELREGLAORIGEN INNER JOIN
			                      REGLAORIGEN INNER JOIN
			                      MAESTRO INNER JOIN
			                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
			                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
			                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPMX LEFT OUTER JOIN
			                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
			WHERE     (REGLAORIGENDET.ARR_REGLA = '3') AND (NAFTA.NFT_CODIGO = @NFT_CODIGO)
			--Yolanda Avila
			--2010-09-20
			and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))

		end
		else
		begin
			if @regla=1
			SELECT     @ARG_VTMINIMO= isnull(max(REGLAORIGENDET.ARG_VTMINIMO),1000), @ARG_CNMINIMO=isnull(max(REGLAORIGENDET.ARG_CNMINIMO),1000), 
	                           @ARR_MINIMIS= (case when isnull(max(ARG_USAMINIMIS),'N')<>'S' then -1 else isnull(max(REGLAORIGEN.ARR_MINIMIS),7) end)
			FROM         ARANCELREGLAORIGEN INNER JOIN
			                      REGLAORIGEN INNER JOIN
			                      MAESTRO INNER JOIN
			                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
			                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
			                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPFO LEFT OUTER JOIN
			                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
			WHERE     (REGLAORIGENDET.ARR_REGLA = '1') AND (NAFTA.NFT_CODIGO = @NFT_CODIGO)
			--Yolanda Avila
			--2010-09-20
			and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))


			
			if @regla=2
			SELECT     @ARG_VTMINIMO= isnull(max(REGLAORIGENDET.ARG_VTMINIMO),1000), @ARG_CNMINIMO=isnull(max(REGLAORIGENDET.ARG_CNMINIMO),1000), 
				   @ARR_MINIMIS= (case when isnull(max(ARG_USAMINIMIS),'N')<>'S' then -1 else isnull(max(REGLAORIGEN.ARR_MINIMIS),7) end)
			FROM         ARANCELREGLAORIGEN INNER JOIN
			                      REGLAORIGEN INNER JOIN
			                      MAESTRO INNER JOIN
			                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
			                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
			                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPFO LEFT OUTER JOIN
			                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
			WHERE     (REGLAORIGENDET.ARR_REGLA = '2') AND (NAFTA.NFT_CODIGO = @NFT_CODIGO)
			--Yolanda Avila
			--2010-09-20
			and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))

	
	
			if @regla=3
			SELECT     @ARG_VTMINIMO= isnull(max(REGLAORIGENDET.ARG_VTMINIMO),1000), @ARG_CNMINIMO=isnull(max(REGLAORIGENDET.ARG_CNMINIMO),1000), 
				     @ARR_MINIMIS= (case when isnull(max(ARG_USAMINIMIS),'N')<>'S' then -1 else isnull(max(REGLAORIGEN.ARR_MINIMIS),7) end)
			FROM         ARANCELREGLAORIGEN INNER JOIN
			                      REGLAORIGEN INNER JOIN
			                      MAESTRO INNER JOIN
			                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
			                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
			                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPFO LEFT OUTER JOIN
			                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
			WHERE     (REGLAORIGENDET.ARR_REGLA = '3') AND (NAFTA.NFT_CODIGO = @NFT_CODIGO)
			--Yolanda Avila
			--2010-09-20
			and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))

		end





		/*-- VALOR DE TRANSACCION
		UPDATE NAFTA
		SET     NAFTA.NFT_NETCOST='2', NFT_OTRASINST='5'
		WHERE NAFTA.NFT_VCRXVT >=@ARG_VTMINIMO 
		AND NFT_CODIGO=@NFT_CODIGO 
		
	
		-- NO APLICA, MINIMIS
		IF (SELECT COUNT(*) FROM CLASIFICATLC WHERE BST_TIPOORIG = 'N' AND BST_APLICAREGLA=-1 AND NFT_CODIGO=@NFT_CODIGO) <>
		    (SELECT COUNT(*) FROM CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO)
		UPDATE NAFTA
		SET     NAFTA.NFT_NETCOST='1', NFT_OTRASINST='1'
		WHERE NAFTA.NFT_MINIMIS <= @ARR_MINIMIS
		AND NFT_CODIGO=@NFT_CODIGO 
			
	
		-- POR COSTO NETO
		UPDATE NAFTA
		SET     NAFTA.NFT_NETCOST='0', NFT_OTRASINST='5'
		WHERE NAFTA.NFT_VCRXCN>=@ARG_CNMINIMO
		AND NFT_CODIGO=@NFT_CODIGO 
	
	
		-- SALTO ARANCELARIO
		IF (SELECT COUNT(*) FROM CLASIFICATLC WHERE BST_TIPOORIG = 'N' AND BST_APLICAREGLA=-1 AND NFT_CODIGO=@NFT_CODIGO)=0
		UPDATE NAFTA
		SET     NAFTA.NFT_NETCOST='4', NFT_OTRASINST='5'
		WHERE NFT_CODIGO=@NFT_CODIGO */



	
	
		exec sp_droptable 'OrderMetodo'
		CREATE TABLE [dbo].[OrderMetodo] (
			[enunciado] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[orden] [int] NOT NULL 
		) ON [PRIMARY]
		
	
		
		insert into OrderMetodo(enunciado,orden)
		SELECT  'UPDATE NAFTA SET NAFTA.NFT_NETCOST=''2'', NFT_OTRASINST=''5'' WHERE NAFTA.NFT_VCRXVT >='+@ARG_VTMINIMO+' AND NFT_CODIGO='+@NFT_CODIGOvar,
			CF_ANAVT
		FROM         CONFIGURACION
	
	
		insert into OrderMetodo(enunciado,orden)
		SELECT 'IF (SELECT COUNT(*) FROM CLASIFICATLC WHERE BST_TIPOORIG = ''N'' AND BST_APLICAREGLA=-1 AND NFT_CODIGO='+@NFT_CODIGOvar+') <>
			    (SELECT COUNT(*) FROM CLASIFICATLC WHERE NFT_CODIGO='+@NFT_CODIGOvar+') UPDATE NAFTA SET NAFTA.NFT_NETCOST=''1'', NFT_OTRASINST=''1''
			WHERE NAFTA.NFT_MINIMIS <= '+@ARR_MINIMIS+' AND NFT_CODIGO='+@NFT_CODIGOvar, CF_ANAMINIMIS
		FROM         CONFIGURACION
		
		insert into OrderMetodo(enunciado,orden)
		SELECT     'UPDATE NAFTA SET NAFTA.NFT_NETCOST=''0'', NFT_OTRASINST=''5'' WHERE NAFTA.NFT_VCRXCN>='+@ARG_CNMINIMO+' AND NFT_CODIGO='+@NFT_CODIGOvar ,
		CF_ANACN
		FROM         CONFIGURACION
		
	
		insert into OrderMetodo(enunciado,orden)
		SELECT     'IF (SELECT COUNT(*) FROM CLASIFICATLC WHERE BST_TIPOORIG = ''N'' AND BST_APLICAREGLA=-1 AND NFT_CODIGO='+@NFT_CODIGOvar+')=0 
			UPDATE NAFTA SET NAFTA.NFT_NETCOST=''4'', NFT_OTRASINST=''5'' WHERE NFT_CODIGO='+@NFT_CODIGOvar ,
		CF_ANASALTOARA
		FROM         CONFIGURACION
		
		
		declare cur_orden cursor for
			select enunciado from OrderMetodo	
			where orden<>0 order by orden desc
		open cur_orden
			FETCH NEXT FROM  cur_orden INTO @enunciado
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				exec(@enunciado)
		
			FETCH NEXT FROM  cur_orden INTO @enunciado
		END
		CLOSE cur_orden
		DEALLOCATE cur_orden
	
	

		 exec sp_droptable 'OrderMetodo'


	end	

	
	UPDATE NAFTA
	SET     NFT_CALIFICO=(CASE WHEN NAFTA.NFT_NETCOST='1' AND NFT_OTRASINST='5' THEN 'N' ELSE 'S' END), 
	NFT_BASIS=(CASE WHEN NFT_NETCOST='1' and NFT_OTRASINST='1'  THEN 'Product qualifies as an originating good under Article 405.1 De Minimis of Rule of Origin because: the value of all non-originating materials used in the production of the good that do not undergo an applicable change in tariff classification set out in Annex 401 is not more than seven percent of the transaction value of the good'
                                              WHEN NFT_NETCOST='4' and NFT_OTRASINST='5'  THEN 'Product qualifies as an originating good under Article 401(b) because: each of the non-originating materials used in the production of the good undergoes an applicable change in tariff classification set out in Annex 401 as a result of production occurring entirely in the territory of one or more of the Parties'
                                              WHEN NFT_NETCOST='0' and NFT_OTRASINST='5'  THEN 'Product qualifies as an originating good because RVC requirement stipulated in Annex 401 is satisfied where Regional Value Content, expressed as a percentage, is computed using the Net Cost method.'
                                              WHEN NFT_NETCOST='2' and NFT_OTRASINST='5'  THEN 'Product qualifies as an originating good because RVC requirement stipulated in Annex 401 is satisfied where Regional Value Content, expressed as a percentage, is computed using the Transaction Value method.'
			     else 'Good failed to qualify for '+@SPI_CLAVE end)
	WHERE NFT_CODIGO=@NFT_CODIGO 




	-- criterio B
	-- los componentes son materias primas y subensambles, hay oroginarios y no originarios
	UPDATE NAFTA
	SET NFT_CRITERIO='1'
	WHERE NFT_CALIFICO='S'
	AND NFT_CODIGO=@NFT_CODIGO

	-- criterio A
	-- los componentes son solo materias primas y todas originarias
	if not exists(select * from clasificatlc where BST_TIPOCOSTO='S' and BST_TRANS='S' and nft_codigo=@nft_codigo)
	update nafta
	set nft_criterio='0'
	where nft_califico='S' and nft_codigo in
		(select nft_codigo
		from clasificatlc
		where nft_codigo=@nft_codigo
		group by nft_codigo
		having sum(bst_MatNoOrig)=0 and sum(bst_MatOrig)>0)


	-- criterio C
	-- los componentes son solo materias primas y subensambles pero todas originarios
	if exists(select * from clasificatlc where BST_TIPOCOSTO='S' and BST_TRANS='S' and nft_codigo=@nft_codigo)
	update nafta
	set nft_criterio='2'
	where nft_califico='S' and nft_codigo in
		(select nft_codigo
		from clasificatlc
		where nft_codigo=@nft_codigo
		group by nft_codigo
		having sum(bst_MatNoOrig)=0 and sum(bst_MatOrig)>0)



	UPDATE NAFTA
	SET     NFT_REGLA=convert(varchar(5), @regla)
	WHERE NFT_CODIGO=@NFT_CODIGO


	UPDATE NAFTA
	SET    NFT_FECHA=GETDATE()
	WHERE NFT_CODIGO=@NFT_CODIGO and NFT_FECHA is null


GO
