SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* actualiza los costos sumando los de la tabla TempBomCosto y los costos de sus subensambles */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOSUBUno]  (@GuardaHist char(1), @bst_pt int, @spi_codigo int, @uservar varchar(50)='1', @tco_codigovar varchar(50)='1')   as

SET NOCOUNT ON 
DECLARE @MA_CODIGO INT, @MA_GRAV_MP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_EMP decimal(38,6),
@cft_tipo char(1), @tco_codigo int, @MA_NG_USA decimal(38,6), @tco_manufactura int, @tco_manufacturavar varchar(5), @spi_codigovar varchar(50)


		select  @tco_manufactura=TCO_MANUFACTURA from configuracion
	
		TRUNCATE TABLE TempBomCosto 
		

		select @spi_codigovar= convert(varchar(50), @spi_codigo), @tco_manufacturavar= convert(varchar(5), @tco_manufactura)

		exec SP_CALCULABOMCOSTOMPUno @spi_codigo, @uservar

		delete from maestrocost where ma_perfin < ma_perini		

			if @GuardaHist='S' 
			begin
				-- Actualiza el ultimo registro del costo
				/*
				exec('UPDATE MAESTROCOST
				SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
				FROM MAESTROCOST INNER JOIN CalculandoCosto'+@uservar+' ON 
					MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE MAESTROCOST.MAC_CODIGO not in
					(SELECT MAX(MAC_CODIGO)
					FROM MAESTROCOST
					WHERE SPI_CODIGO = '+@spi_codigovar+' AND TCO_CODIGO = '+@tco_codigovar+' AND MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
					GROUP BY MA_CODIGO) and TCO_CODIGO ='+@tco_codigovar)
				*/
				/*
				exec(	'UPDATE MAESTROCOST
				SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
				FROM MAESTROCOST 
				INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				where maestrocost.mac_codigo = (
								select max(mac_codigo)
								FROM MAESTROCOST 
								INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
								where maestrocost.mac_codigo not in 
									(SELECT MAX(MAC_CODIGO)
									FROM MAESTROCOST
									WHERE SPI_CODIGO = '+@spi_codigovar+' AND TCO_CODIGO = '+@tco_codigovar+' AND MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
									GROUP BY MA_CODIGO) and TCO_CODIGO ='+@tco_codigovar+
								')'
				)

				*/
				--Yolanda Avila
				--2010-04-21
				--Vence solo el ultimo de los costos siempre y cuando sean del mismo tipo de costo. Excluyendo el que se esta dando de alta en ese momento
				exec(	'UPDATE MAESTROCOST
				SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
				FROM MAESTROCOST 
				INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				where maestrocost.mac_codigo in (
								select max(mc.mac_codigo)
								FROM MAESTROCOST mc
								INNER JOIN CalculandoCosto'+@uservar+' ON mc.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
								where mc.mac_codigo not in 
									(SELECT MAX(MAC_CODIGO)
									FROM MAESTROCOST
									WHERE SPI_CODIGO = '+@spi_codigovar+' AND TCO_CODIGO = '+@tco_codigovar+' AND MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
									GROUP BY MA_CODIGO) and TCO_CODIGO ='+@tco_codigovar+
								' group by mc.ma_codigo
								)'
				)



				exec('INSERT INTO MAESTROCOST(TCO_CODIGO, MA_CODIGO, MA_GRAV_MP, MA_GRAV_ADD, MA_GRAV_EMP, MA_GRAV_GI, MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP, 
				                      MA_NG_ADD, MA_NG_EMP, MA_COSTO, MA_NG_USA, SPI_CODIGO, MA_PERINI, MA_PERFIN)

				SELECT '+@tco_codigovar+', BST_PERTENECE, 	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '+@spi_codigovar+', convert(varchar(11),getdate(),101), ''01/01/9999''
				FROM CalculandoCosto'+@uservar+' 
				WHERE BST_PERTENECE NOT IN (select MA_CODIGO FROM MAESTROCOST WHERE MA_PERINI=convert(varchar(11),getdate(),101)
									AND SPI_CODIGO='+@spi_codigovar+' AND TCO_CODIGO='+@tco_codigovar+')
					and BST_PERTENECE<>'+@bst_pt+' 
				GROUP BY BST_PERTENECE')



				exec('INSERT INTO MAESTROCOST(TCO_CODIGO, MA_CODIGO, MA_GRAV_MP, MA_GRAV_ADD, MA_GRAV_EMP, MA_GRAV_GI, MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP, 
				                      MA_NG_ADD, MA_NG_EMP, MA_COSTO, MA_NG_USA, SPI_CODIGO, MA_PERINI, MA_PERFIN)

				SELECT '+@tco_codigovar+', BST_PERTENECE, 	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '+@spi_codigovar+', convert(varchar(11),getdate(),101), ''01/01/9999''
				FROM CalculandoCosto'+@uservar+' 
				WHERE BST_PERTENECE NOT IN (select MA_CODIGO FROM MAESTROCOST WHERE MA_PERINI=convert(varchar(11),getdate(),101)
									AND SPI_CODIGO='+@spi_codigovar+' AND TCO_CODIGO='+@tco_codigovar+')
					and BST_PERTENECE='+@bst_pt+' 
				GROUP BY BST_PERTENECE')



				-- al calcular el material en base al bom jala la mano de obra del ultimo registro				
				exec('UPDATE MAESTROCOST 
				SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) ,
				MA_GRAV_GI = isnull((select m2.MA_GRAV_GI FROM MAESTROCOST m2 WHERE 
						 m2.mac_codigo in (select max(m1.mac_codigo) from maestrocost  m1 where m1.MA_PERINI<convert(varchar(11),getdate(),101)
											and m1.SPI_CODIGO=MAESTROCOST.SPI_CODIGO and m1.TCO_CODIGO=MAESTROCOST.tco_codigo
											and m1.ma_codigo= MAESTROCOST.ma_codigo)),0),
				MA_GRAV_GI_MX = isnull((select m3.MA_GRAV_GI_MX FROM MAESTROCOST m3 WHERE 
						 m3.mac_codigo in (select max(m4.mac_codigo) from maestrocost  m4 where m4.MA_PERINI<convert(varchar(11),getdate(),101)
											AND m4.SPI_CODIGO=MAESTROCOST.SPI_CODIGO AND m4.TCO_CODIGO=MAESTROCOST.tco_codigo
											and m4.ma_codigo= MAESTROCOST.ma_codigo)),0),
				MA_GRAV_MO = isnull((select m5.MA_GRAV_MO FROM MAESTROCOST m5 WHERE 
						 m5.mac_codigo in (select max(m6.mac_codigo) from maestrocost  m6 where m6.SPI_CODIGO=MAESTROCOST.SPI_CODIGO AND m6.TCO_CODIGO=MAESTROCOST.tco_codigo
										and m6.ma_codigo= MAESTROCOST.ma_codigo and m6.MA_PERINI in
										 (select max(m7.ma_perini) from maestrocost  m7 where m7.MA_PERINI<convert(varchar(11),getdate(),101)
											AND m7.SPI_CODIGO=MAESTROCOST.SPI_CODIGO AND m7.TCO_CODIGO=MAESTROCOST.tco_codigo
											and m7.ma_codigo= MAESTROCOST.ma_codigo))),0)
				FROM MAESTROCOST INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE  MAESTROCOST.tco_codigo ='+@tco_codigovar+' and MAESTROCOST.MA_PERINI=convert(varchar(11),getdate(),101)
				AND MAESTROCOST.SPI_CODIGO='+@spi_codigovar+' and MA_GRAV_MO=0')


				exec ('UPDATE MAESTROCOST 
				SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) ,
				MA_GRAV_GI = isnull((select m2.MA_GRAV_GI FROM MAESTROCOST m2 WHERE 
						 m2.mac_codigo in (select max(m1.mac_codigo) from maestrocost  m1 where m1.MA_PERINI<convert(varchar(11),getdate(),101)
											and m1.SPI_CODIGO=MAESTROCOST.SPI_CODIGO and m1.TCO_CODIGO=MAESTROCOST.tco_codigo
											and m1.ma_codigo= MAESTROCOST.ma_codigo)),0),
				MA_GRAV_GI_MX = isnull((select m3.MA_GRAV_GI_MX FROM MAESTROCOST m3 WHERE 
						 m3.mac_codigo in (select max(m4.mac_codigo) from maestrocost  m4 where m4.MA_PERINI<convert(varchar(11),getdate(),101)
											AND m4.SPI_CODIGO=MAESTROCOST.SPI_CODIGO AND m4.TCO_CODIGO=MAESTROCOST.tco_codigo
											and m4.ma_codigo= MAESTROCOST.ma_codigo)),0)
				FROM MAESTROCOST INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE  MAESTROCOST.tco_codigo ='+@tco_codigovar+' and MAESTROCOST.MA_PERINI=convert(varchar(11),getdate(),101)
				and CalculandoCosto'+@uservar+'.BST_PERTENECE='+@bst_pt+' 
				AND MAESTROCOST.SPI_CODIGO='+@spi_codigovar+' and MA_GRAV_MO>0	')

			end
			else
			begin
				-- los diferentes al producto que se esta calculando
				exec('UPDATE MAESTROCOST 
				SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) 
				FROM MAESTROCOST INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE  MAESTROCOST.tco_codigo ='+@tco_codigovar+' AND MAESTROCOST.SPI_CODIGO='+@spi_codigovar+'
				and CalculandoCosto'+@uservar+'.BST_PERTENECE<>'+@bst_pt+' 
				and MAESTROCOST.MA_PERINI<=getdate() and MAESTROCOST.MA_PERFIN>=getdate()')


				exec('INSERT INTO MAESTROCOST(MA_GRAV_MP, MA_NG_EMP,  MA_GRAV_ADD, MA_NG_MP, 
				MA_NG_ADD, MA_GRAV_EMP, MA_CODIGO, tco_codigo, MA_NG_USA, SPI_CODIGO, MA_PERINI, MA_PERFIN)
	
				SELECT    round(SUM(isnull(MA_GRAV_MP,0)),6), round(SUM(isnull(MA_NG_EMP,0)),6), 
			             	         round(SUM(isnull(MA_GRAV_ADD,0)),6) , round(SUM(isnull(MA_NG_MP,0)),6), 
				         round(SUM(isnull(MA_NG_ADD,0)),6), round(SUM(isnull(MA_GRAV_EMP,0)),6), 
			             	 TempBomCosto.MA_CODIGO, '+@tco_codigovar+', round(SUM(isnull(MA_NG_USA,0)),6),
				'+@spi_codigovar+', convert(varchar(11),getdate(),101), ''01/01/9999''
				FROM TempBomCosto INNER JOIN CalculandoCosto'+@uservar+' ON
					TempBomCosto.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE TempBomCosto.MA_CODIGO NOT IN
				(SELECT MA_CODIGO FROM MAESTROCOST WHERE TCO_CODIGO ='+@tco_codigovar+'
				and MAESTROCOST.MA_PERINI<=getdate() and MAESTROCOST.MA_PERFIN>=getdate() and SPI_CODIGO='+@spi_codigovar+')
				and CalculandoCosto'+@uservar+'.BST_PERTENECE<>'+@bst_pt+' 
				GROUP BY TempBomCosto.MA_CODIGO')


				-- el pt

				exec('UPDATE MAESTROCOST 
				SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
				MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) 
				FROM MAESTROCOST INNER JOIN CalculandoCosto'+@uservar+' ON MAESTROCOST.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE  MAESTROCOST.tco_codigo ='+@tco_codigovar+' AND MAESTROCOST.SPI_CODIGO='+@spi_codigovar+'
				and CalculandoCosto'+@uservar+'.BST_PERTENECE='+@bst_pt+' 
				and MAESTROCOST.MA_PERINI<=getdate() and MAESTROCOST.MA_PERFIN>=getdate()')


				exec('INSERT INTO MAESTROCOST(MA_GRAV_MP, MA_NG_EMP,  MA_GRAV_ADD, MA_NG_MP, 
				MA_NG_ADD, MA_GRAV_EMP, MA_CODIGO, tco_codigo, MA_NG_USA, SPI_CODIGO, MA_PERINI, MA_PERFIN)
	
				SELECT    round(SUM(isnull(MA_GRAV_MP,0)),6), round(SUM(isnull(MA_NG_EMP,0)),6), 
			             	         round(SUM(isnull(MA_GRAV_ADD,0)),6) , round(SUM(isnull(MA_NG_MP,0)),6), 
				         round(SUM(isnull(MA_NG_ADD,0)),6), round(SUM(isnull(MA_GRAV_EMP,0)),6), 
			             	 TempBomCosto.MA_CODIGO, '+@tco_codigovar+', round(SUM(isnull(MA_NG_USA,0)),6),
				'+@spi_codigovar+', convert(varchar(11),getdate(),101), ''01/01/9999''
				FROM TempBomCosto INNER JOIN CalculandoCosto'+@uservar+' ON
					TempBomCosto.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
				WHERE TempBomCosto.MA_CODIGO NOT IN
				(SELECT MA_CODIGO FROM MAESTROCOST WHERE TCO_CODIGO ='+@tco_codigovar+'
				and MAESTROCOST.MA_PERINI<=getdate() and MAESTROCOST.MA_PERFIN>=getdate() and SPI_CODIGO='+@spi_codigovar+')
				and CalculandoCosto'+@uservar+'.BST_PERTENECE='+@bst_pt+' 
				GROUP BY TempBomCosto.MA_CODIGO')


			end
			
		
			




			IF (SELECT CF_USACLASSCOSTO FROM CONFIGURACION)<>'N'
			begin
	

				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0)
				where ba_tipocosto='1'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)
				select ma_codigo,  '1', round(SUM(MA_GRAV_MP),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='1')
				group by ma_codigo
				having SUM(MA_GRAV_MP)>0



				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0)
				where ba_tipocosto='3'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)
				select ma_codigo,  '3', round(SUM(MA_NG_EMP),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='3')
				group by ma_codigo
				having SUM(MA_NG_EMP)>0
			

				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0) 
				where ba_tipocosto='6'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)
				select ma_codigo, '6', round(SUM(MA_GRAV_ADD),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='6')
				group by ma_codigo
				having SUM(MA_GRAV_ADD)>0
			
		

				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0)
				where ba_tipocosto='2'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)
				select ma_codigo,  '2', round(SUM(MA_NG_MP),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='2')
				group by ma_codigo
				having SUM(MA_NG_MP)>0



				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0)
				where ba_tipocosto='7'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)
				select ma_codigo,  '7', round(SUM(MA_NG_ADD),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='7')
				group by ma_codigo
				having SUM(MA_NG_ADD)>0
		


				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0)
				where ba_tipocosto='8'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)
				select ma_codigo,  '8', round(SUM(MA_GRAV_EMP),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='8')
				group by ma_codigo
				having SUM(MA_GRAV_EMP)>0



				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0) 
				where ba_tipocosto='N'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)				select ma_codigo,  'N', round(SUM(MA_NG_USA),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='N')
				group by ma_codigo
				having SUM(MA_NG_USA)>0


				update bom_arancel
				set ba_costo= isnull((select round(SUM(MA_NG_MX),6) from TempBomCosto where TempBomCosto.ma_codigo=bom_arancel.MA_CODIGO),0) 
				where ba_tipocosto='Z'

				insert into bom_arancel(ma_codigo, ba_tipocosto, ba_costo, ar_codigo)				select ma_codigo,  'Z', round(SUM(MA_NG_MX),6), 0 
				from TempBomCosto
				where ma_codigo not in (select ma_codigo from bom_arancel where ba_tipocosto='Z')
				group by ma_codigo
				having SUM(MA_NG_MX)>0

	
			end
			else			
	
			begin
				exec('insert into MAESTROCOST (MA_GRAV_MP, MA_NG_EMP,  MA_GRAV_ADD, MA_NG_MP, MA_NG_ADD, MA_GRAV_EMP, MA_CODIGO,
				tco_codigo)
				SELECT 0, 0, 0, 0,0, 0, BST_PERTENECE, '+@tco_codigovar+'
				FROM CalculandoCosto'+@uservar+'
				WHERE BST_PERTENECE NOT IN (select MA_CODIGO from TempBomCosto)
				AND BST_PERTENECE NOT IN
				(SELECT MA_CODIGO FROM MAESTROCOST WHERE TCO_CODIGO ='+@tco_codigovar+')')


			end
					

		
		exec('UPDATE MAESTROCOST
		SET MA_COSTO = round( isnull(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX 
		+ MA_GRAV_MO + MA_NG_MP + MA_NG_ADD + MA_NG_EMP,0),6)
		WHERE MA_CODIGO in (select BST_PERTENECE from CalculandoCosto'+@uservar+') and mac_codigo in 
					(SELECT MAX(MAC_CODIGO)
					FROM MAESTROCOST
					WHERE SPI_CODIGO = '+@spi_codigovar+' AND TCO_CODIGO = '+@tco_codigovar+' 
					GROUP BY MA_CODIGO)')





GO
