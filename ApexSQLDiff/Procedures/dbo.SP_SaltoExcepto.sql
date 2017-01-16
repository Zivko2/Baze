SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* VERIFICA QUE CUMPLE CON ALGUNA DE LAS EXCEPCIONDES DE LAS 3 REGLAS */
CREATE PROCEDURE dbo.SP_SaltoExcepto (@pt int, @nft_codigo INT, @regla smallint=1)   as

SET NOCOUNT ON 
Declare @BST_APLICAREGLA smallint, @fraccionhijo varchar(20), @bsthijo int,
@ARG_CODIGO1 int, @ARG_CODIGO2 int, @ARG_CODIGO3 int, @spi_codigo int


	print 'SP_SaltoExcepto'

	select @spi_codigo=spi_codigo from nafta where nft_codigo=@nft_codigo

/* se sacan los exceptos de la regla 1 del producto en cuestion */
if @regla = 1
SELECT     @ARG_CODIGO1 = dbo.REGLAORIGENDET.ARG_CODIGO
FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
                      dbo.REGLAORIGEN INNER JOIN
                      dbo.MAESTRO INNER JOIN
                      dbo.NAFTA ON dbo.MAESTRO.MA_CODIGO = dbo.NAFTA.MA_CODIGO ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.MAESTRO.AR_IMPFO LEFT OUTER JOIN
                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
WHERE     (dbo.NAFTA.NFT_CODIGO = @nft_codigo) AND (dbo.REGLAORIGENDET.ARR_REGLA = '1')
--Yolanda Avila
--2010-09-20
and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))


/* se sacan los exceptos de la regla 2 del producto en cuestion */
if @regla = 2
SELECT      @ARG_CODIGO2 = dbo.REGLAORIGENDET.ARG_CODIGO
FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
                      dbo.REGLAORIGEN INNER JOIN
                      dbo.MAESTRO INNER JOIN
                      dbo.NAFTA ON dbo.MAESTRO.MA_CODIGO = dbo.NAFTA.MA_CODIGO ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.MAESTRO.AR_IMPFO LEFT OUTER JOIN
                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
WHERE     (dbo.NAFTA.NFT_CODIGO = @nft_codigo) AND (dbo.REGLAORIGENDET.ARR_REGLA = '2')
--Yolanda Avila
--2010-09-20
and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))


/* se sacan los exceptos de la regla 3 del producto en cuestion */
if @regla =3
SELECT     @ARG_CODIGO3 = dbo.REGLAORIGENDET.ARG_CODIGO
FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
                      dbo.REGLAORIGEN INNER JOIN
                      dbo.MAESTRO INNER JOIN
                      dbo.NAFTA ON dbo.MAESTRO.MA_CODIGO = dbo.NAFTA.MA_CODIGO ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.MAESTRO.AR_IMPFO LEFT OUTER JOIN
                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
WHERE     (dbo.NAFTA.NFT_CODIGO = @nft_codigo) AND (dbo.REGLAORIGENDET.ARR_REGLA = '3')
--Yolanda Avila
--2010-09-20
and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))

/*----------------------------------------------------------------*/


	if @ARG_CODIGO1 is not null AND @regla=1
	begin

		update dbo.CLASIFICATLC
		set BST_APLICAREGLA = case when left(replace(dbo.ARANCEL.AR_FRACCION, '.', ''), LEN(ARC_EXCEPTO))  between ARC_EXCEPTO and ARC_EXCEPTOF
					then -1 else isnull(BST_APLICAREGLA,'') end
		FROM  dbo.CLASIFICATLC LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		CROSS JOIN REGLAORIGENEXCEPTO
		where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
		AND (ARG_CODIGO = @ARG_CODIGO1)
		and (SELECT     clas.BST_APLICAREGLA
			FROM         dbo.CLASIFICATLC clas
			WHERE (clas.BST_TIPOORIG ='N')
				and (clas.NFT_CODIGO = dbo.CLASIFICATLC.nft_codigo)  and
				      (clas.BST_HIJO = dbo.CLASIFICATLC.BST_HIJO)
			GROUP BY clas.BST_APLICAREGLA) <> '0'



		update dbo.CLASIFICATLC
		set BST_APLICAREGLA = case when replace(dbo.ARANCEL.AR_FRACCION, '.', '') between left(ARM_PARTIDAMP ,len(replace(dbo.ARANCEL.AR_FRACCION, '.', ''))) and left(ARM_PARTIDAMPF ,len(replace(dbo.ARANCEL.AR_FRACCION, '.', '')))
		then 1 else isnull(BST_APLICAREGLA,'') end
		FROM  dbo.CLASIFICATLC LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		cross join REGLAORIGENMP
		where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
		and (ARG_CODIGO = @ARG_CODIGO1) 
		and
			(SELECT     clas.BST_APLICAREGLA
			FROM         dbo.CLASIFICATLC clas
			WHERE (clas.BST_TIPOORIG ='N')
				and (clas.NFT_CODIGO = dbo.CLASIFICATLC.nft_codigo)  and
				      (clas.BST_HIJO =dbo.CLASIFICATLC.BST_HIJO)
			GROUP BY clas.BST_APLICAREGLA) <>'0'

	end



	if @ARG_CODIGO2 is not null AND @regla=2
	begin

		update dbo.CLASIFICATLC
		set BST_APLICAREGLA = case when left(replace(dbo.ARANCEL.AR_FRACCION, '.', ''), LEN(ARC_EXCEPTO))  between ARC_EXCEPTO and ARC_EXCEPTOF
					then -1 else isnull(BST_APLICAREGLA,'') end
		FROM  dbo.CLASIFICATLC LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		CROSS JOIN REGLAORIGENEXCEPTO
		where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
		AND (ARG_CODIGO = @ARG_CODIGO2)
		and (SELECT     clas.BST_APLICAREGLA
			FROM         dbo.CLASIFICATLC clas
			WHERE (clas.BST_TIPOORIG ='N')
				and (clas.NFT_CODIGO = dbo.CLASIFICATLC.nft_codigo)  and
				      (clas.BST_HIJO = dbo.CLASIFICATLC.BST_HIJO)
			GROUP BY clas.BST_APLICAREGLA) <> '0'



		update dbo.CLASIFICATLC
		set BST_APLICAREGLA = case when replace(dbo.ARANCEL.AR_FRACCION, '.', '') between left(ARM_PARTIDAMP ,len(replace(dbo.ARANCEL.AR_FRACCION, '.', ''))) and left(ARM_PARTIDAMPF ,len(replace(dbo.ARANCEL.AR_FRACCION, '.', '')))
		then 2 else isnull(BST_APLICAREGLA,'') end
		FROM  dbo.CLASIFICATLC LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		cross join REGLAORIGENMP
		where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
		and (ARG_CODIGO = @ARG_CODIGO2) 
		and
			(SELECT     clas.BST_APLICAREGLA
			FROM         dbo.CLASIFICATLC clas
			WHERE (clas.BST_TIPOORIG ='N')
				and (clas.NFT_CODIGO = dbo.CLASIFICATLC.nft_codigo)  and
				      (clas.BST_HIJO =dbo.CLASIFICATLC.BST_HIJO)
			GROUP BY clas.BST_APLICAREGLA) <>'0'

	end



	if @ARG_CODIGO1 is not null AND @regla=3
	begin

		update dbo.CLASIFICATLC
		set BST_APLICAREGLA = case when left(replace(dbo.ARANCEL.AR_FRACCION, '.', ''), LEN(ARC_EXCEPTO))  between ARC_EXCEPTO and ARC_EXCEPTOF
					then -1 else isnull(BST_APLICAREGLA,'') end
		FROM  dbo.CLASIFICATLC LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		CROSS JOIN REGLAORIGENEXCEPTO
		where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
		AND (ARG_CODIGO = @ARG_CODIGO2)
		and (SELECT     clas.BST_APLICAREGLA
			FROM         dbo.CLASIFICATLC clas
			WHERE (clas.BST_TIPOORIG ='N')
				and (clas.NFT_CODIGO = dbo.CLASIFICATLC.nft_codigo)  and
				      (clas.BST_HIJO = dbo.CLASIFICATLC.BST_HIJO)
			GROUP BY clas.BST_APLICAREGLA) <> '0'



		update dbo.CLASIFICATLC
		set BST_APLICAREGLA = case when replace(dbo.ARANCEL.AR_FRACCION, '.', '') between left(ARM_PARTIDAMP ,len(replace(dbo.ARANCEL.AR_FRACCION, '.', ''))) and left(ARM_PARTIDAMPF ,len(replace(dbo.ARANCEL.AR_FRACCION, '.', '')))
		then 3 else isnull(BST_APLICAREGLA,'') end
		FROM  dbo.CLASIFICATLC LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO
		cross join REGLAORIGENMP
		where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
		and (ARG_CODIGO = @ARG_CODIGO3) 
		and
			(SELECT     clas.BST_APLICAREGLA
			FROM         dbo.CLASIFICATLC clas
			WHERE (clas.BST_TIPOORIG ='N')
				and (clas.NFT_CODIGO = dbo.CLASIFICATLC.nft_codigo)  and
				      (clas.BST_HIJO =dbo.CLASIFICATLC.BST_HIJO)
			GROUP BY clas.BST_APLICAREGLA) <>'0'

	end



	-- la vista VTLCCOSTOTOTAL hace la suma de la tabla CLASIFICATLC
	IF (SELECT CF_ANALISISCOSTOMA FROM CONFIGURACION)='S' and @SPI_CODIGO in (select spi_codigo  from spi where (spi_clave='nafta' or spi_clave='mx'))
		UPDATE NAFTA
		SET NFT_COSTOTOTALPT = round((select VTLCCOSTOTOTAL_COSTOMA.COSTOTOTAL FROM VTLCCOSTOTOTAL_COSTOMA where VTLCCOSTOTOTAL_COSTOMA.nft_codigo = NAFTA.NFT_CODIGO),6)
		WHERE NFT_CODIGO=@NFT_CODIGO
	ELSE
		UPDATE NAFTA
		SET NFT_COSTOTOTALPT = round((select VTLCCOSTOTOTAL.COSTOTOTAL FROM VTLCCOSTOTOTAL where VTLCCOSTOTOTAL.nft_codigo = NAFTA.NFT_CODIGO),6)
		WHERE NFT_CODIGO=@NFT_CODIGO
	
	

	UPDATE NAFTA
	SET NFT_MINIMIS = NULL
	WHERE NFT_CODIGO=@NFT_CODIGO


	
	UPDATE NAFTA
	SET NFT_MINIMIS = round(((select vtlcanalisisfrac.COSTO FROM vtlcanalisisfrac where vtlcanalisisfrac.nft_codigo = NAFTA.NFT_CODIGO)*100)
	/NFT_COSTOTOTALPT,2)
	WHERE NFT_CODIGO=@NFT_CODIGO and
	NFT_COSTOTOTALPT > (select vtlcanalisisfrac.COSTO FROM vtlcanalisisfrac where vtlcanalisisfrac.nft_codigo = NAFTA.NFT_CODIGO)



	UPDATE NAFTA
	SET NFT_MINIMIS = 0
	WHERE NFT_CODIGO=@NFT_CODIGO
	and ((NFT_COSTOTOTALPT < (select vtlcanalisisfrac.COSTO FROM vtlcanalisisfrac where vtlcanalisisfrac.nft_codigo = NAFTA.NFT_CODIGO)
	AND NFT_COSTOTOTALPT>0) or
	 NFT_MINIMIS < 0)



GO
