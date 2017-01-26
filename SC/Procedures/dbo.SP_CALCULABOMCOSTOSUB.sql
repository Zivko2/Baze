SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* actualiza los costos sumando los de la tabla TempBomCosto y los costos de sus subensambles */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOSUB]  (@GuardaHist char(1), @spi_codigo int, @uservar varchar(50)='1')   as

SET NOCOUNT ON 
DECLARE @MA_CODIGO INT, @MA_GRAV_MP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_EMP decimal(38,6),
@cft_tipo char(1), @tco_codigo int, @MA_NG_USA decimal(38,6), @tco_manufactura int


		select  @tco_manufactura=TCO_MANUFACTURA from configuracion
	
		TRUNCATE TABLE TempBomCosto 
		

		exec SP_CALCULABOMCOSTOMP @spi_codigo

		delete from maestrocost where ma_perfin < ma_perini		

			if @GuardaHist='S' 
			begin
					/*
					UPDATE MAESTROCOST
					SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
					FROM MAESTROCOST INNER JOIN CalculandoCosto ON 
					MAESTROCOST.MA_CODIGO=CalculandoCosto.BST_PERTENECE
					WHERE MAESTROCOST.MAC_CODIGO not in
						(SELECT MAX(MAC_CODIGO)
						FROM MAESTROCOST
						WHERE SPI_CODIGO = @spi_codigo AND TCO_CODIGO = @tco_manufactura AND MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
						GROUP BY MA_CODIGO)
					and TCO_CODIGO = @tco_manufactura 
					*/

					--Yolanda Avila
					--2010-04-21
					--Vence solo el ultimo de los costos siempre y cuando sean del mismo tipo de costo. Excluyendo el que se esta dando de alta en ese momento
				begin tran
					UPDATE MAESTROCOST
					SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
					FROM MAESTROCOST 
					INNER JOIN CalculandoCosto ON MAESTROCOST.MA_CODIGO=CalculandoCosto.BST_PERTENECE
					where maestrocost.mac_codigo in (
									select max(mc.mac_codigo)
									FROM MAESTROCOST mc
									INNER JOIN CalculandoCosto cc ON mc.MA_CODIGO=Cc.BST_PERTENECE
									where mc.mac_codigo not in 
										(SELECT MAX(m.MAC_CODIGO)
										FROM MAESTROCOST m
										WHERE m.SPI_CODIGO = @spi_codigo AND m.TCO_CODIGO = @tco_manufactura AND m.MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
										GROUP BY m.MA_CODIGO) 
									and mc.TCO_CODIGO =@tco_manufactura
									group by mc.ma_codigo
								       )

				commit tran
				

				begin tran
					INSERT INTO MAESTROCOST(TCO_CODIGO, MA_CODIGO, MA_GRAV_MP, MA_GRAV_ADD, MA_GRAV_EMP, MA_GRAV_GI, MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP, 
					                      MA_NG_ADD, MA_NG_EMP, MA_COSTO, MA_NG_USA, MA_NG_MX, SPI_CODIGO, MA_PERINI, MA_PERFIN)
	
					SELECT @tco_manufactura, BST_PERTENECE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, @spi_codigo, convert(varchar(11),getdate(),101), '01/01/9999'
					FROM CalculandoCosto
					WHERE BST_PERTENECE NOT IN (select MA_CODIGO FROM MAESTROCOST WHERE MA_PERINI=convert(varchar(11),getdate(),101)
										AND SPI_CODIGO=@spi_codigo AND TCO_CODIGO=@tco_manufactura)
					GROUP BY BST_PERTENECE
				commit tran

				-- al calcular el material en base al bom jala la mano de obra del ultimo registro				
				begin tran
					UPDATE MAESTROCOST 
					SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) ,
					MA_NG_MX =  isnull((select round(SUM(MA_NG_MX),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) ,
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
					FROM MAESTROCOST INNER JOIN CalculandoCosto ON MAESTROCOST.MA_CODIGO=CalculandoCosto.BST_PERTENECE
					WHERE  MAESTROCOST.tco_codigo =@tco_manufactura and MAESTROCOST.MA_PERINI=convert(varchar(11),getdate(),101)
					AND MAESTROCOST.SPI_CODIGO=@spi_codigo and MA_GRAV_MO=0
				commit tran

				begin tran				
					UPDATE MAESTROCOST 
					SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) ,
					MA_NG_MX =  isnull((select round(SUM(MA_NG_MX),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) ,
					MA_GRAV_GI = isnull((select m2.MA_GRAV_GI FROM MAESTROCOST m2 WHERE 
							 m2.mac_codigo in (select max(m1.mac_codigo) from maestrocost  m1 where m1.MA_PERINI<convert(varchar(11),getdate(),101)
												and m1.SPI_CODIGO=MAESTROCOST.SPI_CODIGO and m1.TCO_CODIGO=MAESTROCOST.tco_codigo
												and m1.ma_codigo= MAESTROCOST.ma_codigo)),0),
					MA_GRAV_GI_MX = isnull((select m3.MA_GRAV_GI_MX FROM MAESTROCOST m3 WHERE 
							 m3.mac_codigo in (select max(m4.mac_codigo) from maestrocost  m4 where m4.MA_PERINI<convert(varchar(11),getdate(),101)
												AND m4.SPI_CODIGO=MAESTROCOST.SPI_CODIGO AND m4.TCO_CODIGO=MAESTROCOST.tco_codigo
												and m4.ma_codigo= MAESTROCOST.ma_codigo)),0)
					FROM MAESTROCOST INNER JOIN CalculandoCosto ON MAESTROCOST.MA_CODIGO=CalculandoCosto.BST_PERTENECE
					WHERE  MAESTROCOST.tco_codigo =@tco_manufactura and MAESTROCOST.MA_PERINI=convert(varchar(11),getdate(),101)
					AND MAESTROCOST.SPI_CODIGO=@spi_codigo and MA_GRAV_MO>0						
				commit tran
			end
			else
			begin
				begin tran
					UPDATE MAESTROCOST 
					SET MA_GRAV_MP = isnull((select round(SUM(MA_GRAV_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_EMP =  isnull((select round(SUM(MA_NG_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_GRAV_ADD= isnull((select round(SUM(MA_GRAV_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_MP =  isnull((select round(SUM(MA_NG_MP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_ADD =  isnull((select round(SUM(MA_NG_ADD),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_GRAV_EMP =  isnull((select round(SUM(MA_GRAV_EMP),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_USA =  isnull((select round(SUM(MA_NG_USA),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0), 
					MA_NG_MX =  isnull((select round(SUM(MA_NG_MX),6) from TempBomCosto where TempBomCosto.ma_codigo=MAESTROCOST.MA_CODIGO),0) 
					FROM MAESTROCOST INNER JOIN CalculandoCosto ON MAESTROCOST.MA_CODIGO=CalculandoCosto.BST_PERTENECE
					WHERE  MAESTROCOST.tco_codigo =@tco_manufactura AND MAESTROCOST.SPI_CODIGO=@spi_codigo
					and MAESTROCOST.MA_PERINI<=getdate() and MAESTROCOST.MA_PERFIN>=getdate()
				commit tran	

				begin tran
					INSERT INTO MAESTROCOST(MA_GRAV_MP, MA_NG_EMP,  MA_GRAV_ADD, MA_NG_MP, 
					MA_NG_ADD, MA_GRAV_EMP, MA_CODIGO, tco_codigo, MA_NG_USA, MA_NG_MX, SPI_CODIGO, MA_PERINI, MA_PERFIN)
		
					SELECT    round(SUM(isnull(MA_GRAV_MP,0)),6), round(SUM(isnull(MA_NG_EMP,0)),6), 
				             	         round(SUM(isnull(MA_GRAV_ADD,0)),6) , round(SUM(isnull(MA_NG_MP,0)),6), 
					         round(SUM(isnull(MA_NG_ADD,0)),6), round(SUM(isnull(MA_GRAV_EMP,0)),6), 
				             	 TempBomCosto.MA_CODIGO, @tco_manufactura, round(SUM(isnull(MA_NG_USA,0)),6), round(SUM(isnull(MA_NG_MX,0)),6),
					@spi_codigo, convert(varchar(11),getdate(),101), '01/01/9999'
					FROM TempBomCosto INNER JOIN CalculandoCosto ON
						TempBomCosto.MA_CODIGO=CalculandoCosto.BST_PERTENECE
					WHERE TempBomCosto.MA_CODIGO NOT IN
					(SELECT MA_CODIGO FROM MAESTROCOST WHERE TCO_CODIGO =@tco_manufactura
					and MAESTROCOST.MA_PERINI<=getdate() and MAESTROCOST.MA_PERFIN>=getdate() and SPI_CODIGO=@spi_codigo)
					GROUP BY TempBomCosto.MA_CODIGO
				commit tran	
			end
			
		
			




			IF (SELECT CF_USACLASSCOSTO FROM CONFIGURACION)='N'	
			begin
				begin tran

					insert into MAESTROCOST (MA_GRAV_MP, MA_NG_EMP,  MA_GRAV_ADD, MA_NG_MP, MA_NG_ADD, MA_GRAV_EMP, MA_CODIGO,
					tco_codigo)
					SELECT 0, 0, 0, 0,0, 0, BST_PERTENECE, (select TCO_MANUFACTURA from configuracion)
					FROM CalculandoCosto
					WHERE BST_PERTENECE NOT IN (select MA_CODIGO from TempBomCosto)
					AND BST_PERTENECE NOT IN
					(SELECT MA_CODIGO FROM MAESTROCOST WHERE TCO_CODIGO IN(select  TCO_MANUFACTURA from configuracion))
	
				commit tran	
			end



		begin tran		
		UPDATE MAESTROCOST
		SET MA_COSTO = round( isnull(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX 
		+ MA_GRAV_MO + MA_NG_MP + MA_NG_ADD + MA_NG_EMP,0),6)
		WHERE MA_CODIGO in (select BST_PERTENECE from CalculandoCosto) and mac_codigo in 
					(SELECT MAX(MAC_CODIGO)
					FROM MAESTROCOST
					WHERE SPI_CODIGO = @spi_codigo AND TCO_CODIGO = @tco_manufactura 
					GROUP BY MA_CODIGO)
		commit tran















GO
