SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* VERIFICA QUE CUMPLE CON ALGUNA DE LAS 3 REGLAS PARA SALTO ARANCELARIO 
la fraccion arancelaria (ar_impfo) del pt se toma del cat. maestro */
CREATE PROCEDURE dbo.SP_SaltoArancelario (@pt int, @nft_codigo int, @regla smallint=1)   as

--SET NOCOUNT ON 

-- asigna fraccion del componente segun tratado
UPDATE CLASIFICATLC
SET     CLASIFICATLC.AR_CODIGO=(CASE WHEN NAFTA.SPI_CODIGO in (select spi_codigo from spi where SPI_ANALISISHTSMEX='S') then MAESTRO.AR_IMPMX else MAESTRO.AR_IMPFO end)
FROM         CLASIFICATLC INNER JOIN
                      NAFTA ON CLASIFICATLC.NFT_CODIGO = NAFTA.NFT_CODIGO INNER JOIN
                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO
WHERE     (NAFTA.NFT_CODIGO = @nft_codigo)


/*----------------------------------------------------------------*/

	update dbo.CLASIFICATLC
	set BST_APLICAREGLA =-1
	where dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



		
		if @regla=1
		begin

			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla01'  AND  type = 'U')
			begin
				drop table ##regla01
			end
		
		
			CREATE TABLE [##regla01] (
				[salto1] varchar(10) null,
				[saltoF1] varchar(10) null,
				[len1] int null,
				[ARR_OTRAPARTIDA1] char(1) null,
				[fraccionPt] varchar(800) null
			) ON [PRIMARY]




			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla1'  AND  type = 'U')
			begin
				drop table ##regla1
			end

	
			CREATE TABLE [##regla1] (
				[clt_codigo] int null,
				[fraccionhijo] varchar(10) null,
				[bsthijo] int null,
				[salto1] varchar(10) null,
				[saltoF1] varchar(10) null,
				[len1] int null,
				[ARR_OTRAPARTIDA1] char(1) null,
				[fraccionPt] varchar(800) null
			) ON [PRIMARY]




				insert into ##regla01(salto1, saltoF1, len1, ARR_OTRAPARTIDA1, fraccionPt)
				SELECT     dbo.REGLAORIGENDET.ARR_PARTIDASALTO, dbo.REGLAORIGENDET.ARR_PARTIDASALTOF, LEN(dbo.REGLAORIGENDET.ARR_PARTIDASALTO), 
				                      ISNULL(dbo.REGLAORIGENDET.ARR_OTRAPARTIDA, 'N'), REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
				FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
				                      dbo.REGLAORIGEN INNER JOIN
				                      dbo.NAFTA ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
				                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
				                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.NAFTA.AR_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.NAFTA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
				WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '1')
				and dbo.REGLAORIGENDET.ARR_PARTIDASALTO is not null
				--Yolanda Avila
				--2010-09-20
				and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
				     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))
		


				insert into ##regla1(fraccionhijo, bsthijo, salto1, saltoF1, len1, ARR_OTRAPARTIDA1, fraccionPt, CLT_CODIGO)
				SELECT     REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''), dbo.CLASIFICATLC.BST_HIJO, 
				salto1, saltoF1, len1, ARR_OTRAPARTIDA1, fraccionPt, dbo.CLASIFICATLC.CLT_CODIGO				
				FROM          dbo.ARANCEL  RIGHT OUTER JOIN dbo.CLASIFICATLC ON
				 dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO CROSS JOIN ##regla01 R1
				WHERE (BST_TIPOORIG ='N')
				AND (dbo.CLASIFICATLC.NFT_CODIGO = @nft_codigo)
				GROUP BY REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''),
					       dbo.CLASIFICATLC.BST_HIJO, dbo.CLASIFICATLC.BST_APLICAREGLA, dbo.ARANCEL.AR_CAPITULO,
					salto1, saltoF1, len1, ARR_OTRAPARTIDA1, fraccionPt, dbo.CLASIFICATLC.CLT_CODIGO
				ORDER BY REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
				



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla01'  AND  type = 'U')
			begin
				drop table ##regla01
			end
		


				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when left(fraccionhijo, len1) not between salto1 and saltoF1
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where ARR_OTRAPARTIDA1='T' and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO


				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 4) <> left(salto1,4))  or  (left(fraccionhijo, 4) = left( salto1,4))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='H') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO




				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 6) <> left(salto1,6))  or  (left(fraccionhijo, 6) = left( salto1,6))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='S') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 4) = left( salto1, 4))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='D') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 6) = left( salto1, 6))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='E') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 4) <> left(salto1,4))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='A') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 6) <> left(salto1,6))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='B') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO




				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 2) <> left(salto1,2))
								then 1 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla1 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA1='C') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla1'  AND  type = 'U')
			begin
				drop table ##regla1
			end
		



/*CB_KEYFIELD	CB_LOOKUP
--C	DE CUALQUIER OTRO CAPITULO
--H	DE CUALQUIER OTRA PARTIDA (INCLUYENDO LA PARTIDA DENTRO DEL GRUPO)
--S	DE CUALQUIER OTRA SUBPARTIDA (INCLUYENDO LA SUBPARTIDA DENTRO DEL GRUPO)
--T	DE CUALQUIER OTRA FRACCION
--A	DE CUALQUIER OTRA PARTIDA FUERA DEL GRUPO
--B	DE CUALQUIER OTRA SUBPARTIDA FUERA DEL GRUPO
--N	NO APLICA
--D	DE CUALQUIER OTRA PARTIDA DENTRO DEL GRUPO
--E	DE CUALQUIER OTRA SUBPARTIDA DENTRO DEL GRUPO*/
	


		end
		else
		if @regla=2
		begin
/*--- REGLA 2 -------------*/			

			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla02'  AND  type = 'U')
			begin
				drop table ##regla02
			end
		
		
			CREATE TABLE [##regla02] (
				[salto2] varchar(10) null,
				[saltoF2]	varchar(10) null,
				[len2] int null,
				[ARR_OTRAPARTIDA2] char(1) null,
				[fraccionPt]	varchar(800) null
			) ON [PRIMARY]




			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla2'  AND  type = 'U')
			begin
				drop table ##regla2
			end

	
			CREATE TABLE [##regla2] (
				[clt_codigo] int null,
				[fraccionhijo] varchar(10) null,
				[bsthijo] int null,
				[salto2] varchar(10) null,
				[saltoF2]	varchar(10) null,
				[len2] int null,
				[ARR_OTRAPARTIDA2] char(1) null,
				[fraccionPt]	varchar(800) null
			) ON [PRIMARY]




				insert into ##regla02(salto2, saltoF2, len2, ARR_OTRAPARTIDA2, fraccionPt)
				SELECT     dbo.REGLAORIGENDET.ARR_PARTIDASALTO, dbo.REGLAORIGENDET.ARR_PARTIDASALTOF, LEN(dbo.REGLAORIGENDET.ARR_PARTIDASALTO), 
				                      ISNULL(dbo.REGLAORIGENDET.ARR_OTRAPARTIDA, 'N'), REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
				FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
				                      dbo.REGLAORIGEN INNER JOIN
				                      dbo.NAFTA ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
				                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
				                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.NAFTA.AR_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.NAFTA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
				WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '2')
				and dbo.REGLAORIGENDET.ARR_PARTIDASALTO is not null
				--Yolanda Avila
				--2010-09-20
				and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
				     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))



				insert into ##regla2(fraccionhijo, bsthijo, salto2, saltoF2, len2, ARR_OTRAPARTIDA2, fraccionPt, CLT_CODIGO)
				SELECT     REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''), dbo.CLASIFICATLC.BST_HIJO, 
				salto2, saltoF2, len2, ARR_OTRAPARTIDA2, fraccionPt, dbo.CLASIFICATLC.CLT_CODIGO				
				FROM          dbo.ARANCEL  RIGHT OUTER JOIN dbo.CLASIFICATLC ON
				 dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO CROSS JOIN ##regla02 R1
				WHERE (BST_TIPOORIG ='N')
				AND (dbo.CLASIFICATLC.NFT_CODIGO = @nft_codigo)
				GROUP BY REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''),
					       dbo.CLASIFICATLC.BST_HIJO, dbo.CLASIFICATLC.BST_APLICAREGLA, dbo.ARANCEL.AR_CAPITULO,
					salto2, saltoF2, len2, ARR_OTRAPARTIDA2, fraccionPt, dbo.CLASIFICATLC.CLT_CODIGO
				ORDER BY REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
				



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla02'  AND  type = 'U')
			begin
				drop table ##regla02
			end
		


				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when left(fraccionhijo, len2) not between salto2 and saltoF2
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where ARR_OTRAPARTIDA2='T' and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO


				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 4) <> left(salto2,4))  or  (left(fraccionhijo, 4) = left( salto2,4))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='H') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO




				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 6) <> left(salto2,6))  or  (left(fraccionhijo, 6) = left( salto2,6))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='S') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 4) = left( salto2, 4))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='D') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 6) = left( salto2, 6))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='E') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 4) <> left(salto2,4))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='A') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 6) <> left(salto2,6))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='B') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO




				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 2) <> left(salto2,2))
								then 2 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla2 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA2='C') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla2'  AND  type = 'U')
			begin
				drop table ##regla2
			end
		




		end
		else
		if @regla=3
		begin
/*--- REGLA 3 -------------*/			



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla03'  AND  type = 'U')
			begin
				drop table ##regla03
			end
		
		
			CREATE TABLE [##regla03] (
				[salto3] varchar(10) null,
				[saltoF3]	varchar(10) null,
				[len3] int null,
				[ARR_OTRAPARTIDA3] char(1) null,
				[fraccionPt]	varchar(800) null
			) ON [PRIMARY]




			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla3'  AND  type = 'U')
			begin
				drop table ##regla3
			end

	
			CREATE TABLE [##regla3] (
				[clt_codigo] int null,
				[fraccionhijo] varchar(10) null,
				[bsthijo] int null,
				[salto3] varchar(10) null,
				[saltoF3]	varchar(10) null,
				[len3] int null,
				[ARR_OTRAPARTIDA3] char(1) null,
				[fraccionPt]	varchar(800) null
			) ON [PRIMARY]




				insert into ##regla03(salto3, saltoF3, len3, ARR_OTRAPARTIDA3, fraccionPt)
				SELECT     dbo.REGLAORIGENDET.ARR_PARTIDASALTO, dbo.REGLAORIGENDET.ARR_PARTIDASALTOF, LEN(dbo.REGLAORIGENDET.ARR_PARTIDASALTO), 
				                      ISNULL(dbo.REGLAORIGENDET.ARR_OTRAPARTIDA, 'N'), REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
				FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
				                      dbo.REGLAORIGEN INNER JOIN
				                      dbo.NAFTA ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
				                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
				                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.NAFTA.AR_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.NAFTA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
				WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '3')
				and dbo.REGLAORIGENDET.ARR_PARTIDASALTO is not null
				--Yolanda Avila
				--2010-09-20
				and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
				     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))



				insert into ##regla3(fraccionhijo, bsthijo, salto3, saltoF3, len3, ARR_OTRAPARTIDA3, fraccionPt, CLT_CODIGO)
				SELECT     REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''), dbo.CLASIFICATLC.BST_HIJO, 
				salto3, saltoF3, len3, ARR_OTRAPARTIDA3, fraccionPt, dbo.CLASIFICATLC.CLT_CODIGO				
				FROM          dbo.ARANCEL  RIGHT OUTER JOIN dbo.CLASIFICATLC ON
				 dbo.CLASIFICATLC.AR_CODIGO = dbo.ARANCEL.AR_CODIGO CROSS JOIN ##regla03 R1
				WHERE (BST_TIPOORIG ='N')
				AND (dbo.CLASIFICATLC.NFT_CODIGO = @nft_codigo)
				GROUP BY REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''),
					       dbo.CLASIFICATLC.BST_HIJO, dbo.CLASIFICATLC.BST_APLICAREGLA, dbo.ARANCEL.AR_CAPITULO,
					salto3, saltoF3, len3, ARR_OTRAPARTIDA3, fraccionPt, dbo.CLASIFICATLC.CLT_CODIGO
				ORDER BY REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
				



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla03'  AND  type = 'U')
			begin
				drop table ##regla03
			end
		


				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when left(fraccionhijo, len3) not between salto3 and saltoF3
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where ARR_OTRAPARTIDA3='T' and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO


				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 4) <> left(salto3,4))  or  (left(fraccionhijo, 4) = left( salto3,4))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='H') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO




				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 6) <> left(salto3,6))  or  (left(fraccionhijo, 6) = left( salto3,6))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='S') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 4) = left( salto3, 4))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='D') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 6) = left( salto3, 6))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='E') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when (left(fraccionhijo, 4) <> left(salto3,4))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='A') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO



				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 6) <> left(salto3,6))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='B') and dbo.CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO




				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = (case when  (left(fraccionhijo, 2) <> left(salto3,2))
								then 3 else isnull(BST_APLICAREGLA,'') end)
				from dbo.CLASIFICATLC INNER JOIN ##regla3 r1 on r1.clt_codigo=dbo.CLASIFICATLC.CLT_CODIGO
				where (ARR_OTRAPARTIDA3='C') and dbo.CLASIFICATLC.NFT_CODIGO = NFT_CODIGO



			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##regla3'  AND  type = 'U')
			begin
				drop table ##regla3
			end
		




		end


GO
