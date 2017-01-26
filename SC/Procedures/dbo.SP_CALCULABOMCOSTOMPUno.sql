SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







/* hace la suma de mp por tipo y lo inserta a la tabla TempBomCosto */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOMPUno] (@spi_codigo int, @uservar varchar(50)='1')   as

SET NOCOUNT ON 

declare @spi_codigovar varchar(50)


	select @spi_codigovar= convert(varchar(50),@spi_codigo)

	/* se insertan el subensamble a la tabla BOMCOSTEMP, para despues actualizarle las columnas de costos*/
	exec('INSERT INTO TempBomCosto (MA_CODIGO, MA_GRAV_MP, MA_GRAV_ADD, 
		MA_GRAV_EMP, MA_GRAV_GI, MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP, MA_NG_ADD, MA_NG_EMP, MA_NG_USA, MA_NG_MX)
	select BST_PERTENECE, 0,0,0,0,0,0,0,0,0,0,0
	from CalculandoCosto'+@uservar+' 
	where BST_PERTENECE not in (select MA_CODIGO from TempBomCosto)
	group by BST_PERTENECE ')


/* en la vista para sacar el costo en la unidad de medida que se se esta usando en el bom
1. costo unit. en um generico = maestro.ma_costo/maestro.eq_gen
2. costo unit. en um bom = costo unit. en um generico * Bom_struct.factconv
*/

	exec SP_CREAVCALCULABOMCOSTOMPUno @uservar

--MA_NG_ADD
exec('exec sp_droptable ''VCALCULABOMCOSTOMPdp'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPdp'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''D'', ''G'', ''P''))
GROUP BY Uno.BSU_SUBENSAMBLE')



--MA_NG_USA
exec('exec sp_droptable ''VCALCULABOMCOSTOMPcd'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPcd'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''D'', ''C''))
GROUP BY Uno.BSU_SUBENSAMBLE')


--MA_NG_MP
exec('exec sp_droptable ''VCALCULABOMCOSTOMPnc'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPnc'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''N'', ''C'', ''Z''))
GROUP BY Uno.BSU_SUBENSAMBLE')


--MA_GRAV_MP
exec('exec sp_droptable ''VCALCULABOMCOSTOMPa'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPa'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''A''))
GROUP BY Uno.BSU_SUBENSAMBLE')



--MA_NG_EMP
exec('exec sp_droptable ''VCALCULABOMCOSTOMPf'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPf'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''F''))
GROUP BY Uno.BSU_SUBENSAMBLE')

--MA_GRAV_ADD
exec('exec sp_droptable ''VCALCULABOMCOSTOMPb'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPb'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''B''))
GROUP BY Uno.BSU_SUBENSAMBLE')


--MA_GRAV_EMP
exec('exec sp_droptable ''VCALCULABOMCOSTOMPe'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPe'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''E'', ''H''))
GROUP BY Uno.BSU_SUBENSAMBLE')


--MA_NG_MX
exec('exec sp_droptable ''VCALCULABOMCOSTOMPmx'+@uservar+'''')

exec('SELECT     ROUND(SUM(Uno.MA_COSTO), 6) as MA_COSTO, Uno.BSU_SUBENSAMBLE
into dbo.VCALCULABOMCOSTOMPmx'+@uservar+'
FROM         dbo.VCALCULABOMCOSTOMP'+@uservar+' Uno 
WHERE     (Uno.BST_TIPOCOSTO IN (''Z'', ''G'', ''H''))
GROUP BY Uno.BSU_SUBENSAMBLE')


/*************************************************************/


	exec('UPDATE TempBomCosto 
	SET MA_GRAV_MP = isnull((SELECT  ROUND(SUM(MA_COSTO),6) FROM VCALCULABOMCOSTOMPa'+@uservar+'
			           WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	        MA_NG_EMP = isnull((SELECT  ROUND(SUM(MA_COSTO),6) FROM VCALCULABOMCOSTOMPf'+@uservar+'
			           WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	         MA_GRAV_ADD = isnull((SELECT  ROUND(SUM(MA_COSTO),6) FROM VCALCULABOMCOSTOMPb'+@uservar+'
			           WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	         MA_GRAV_EMP = isnull((SELECT  ROUND(SUM(MA_COSTO),6) FROM VCALCULABOMCOSTOMPe'+@uservar+'
			           WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	          MA_NG_USA = isnull((SELECT     ROUND(SUM(MA_COSTO),6) FROM VCALCULABOMCOSTOMPcd'+@uservar+'
				WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	           MA_NG_MP =  isnull((SELECT ROUND(SUM(MA_COSTO),6) 	FROM         VCALCULABOMCOSTOMPnc'+@uservar+'
				WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	           MA_NG_ADD =  isnull((SELECT ROUND(SUM(MA_COSTO),6) 	FROM         VCALCULABOMCOSTOMPdp'+@uservar+'
				WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0),
	          MA_NG_MX = isnull((SELECT     ROUND(SUM(MA_COSTO),6) FROM VCALCULABOMCOSTOMPmx'+@uservar+'
					WHERE BSU_SUBENSAMBLE = TempBomCosto.MA_CODIGO),0)
	FROM TempBomCosto INNER JOIN CalculandoCosto'+@uservar+' 
	          ON TempBomCosto.MA_CODIGO=CalculandoCosto'+@uservar+'.BST_PERTENECE
	WHERE TempBomCosto.MA_CODIGO IN (SELECT BSU_SUBENSAMBLE FROM VCALCULABOMCOSTOMP GROUP BY BSU_SUBENSAMBLE)')



exec('exec sp_droptable ''VCALCULABOMCOSTOMPdp'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPcd'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPnc'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPa'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPf'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPb'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPe'+@uservar+'''')
exec('exec sp_droptable ''VCALCULABOMCOSTOMPmx'+@uservar+'''')


-- hace la suma de subensamble y lo inserta a la tabla TempBomCosto   


		exec('INSERT INTO TempBomCosto (MA_CODIGO, MA_GRAV_MP, MA_GRAV_ADD, MA_GRAV_EMP, MA_GRAV_GI,
		MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP, MA_NG_ADD, MA_NG_EMP, MA_NG_USA, MA_NG_MX)

		SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, round(isnull(SUM(VMAESTROCOST.MA_GRAV_MP * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_ADD * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_EMP * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_GI * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_GI_MX * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_GRAV_MO * BOM_STRUCT.BST_INCORPOR),0),6) , 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_MP * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_ADD * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_EMP * BOM_STRUCT.BST_INCORPOR),0),6), 
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_USA * BOM_STRUCT.BST_INCORPOR),0),6),
		                      round(isnull(SUM(VMAESTROCOST.MA_NG_MX * BOM_STRUCT.BST_INCORPOR),0),6)
		FROM         BOM_STRUCT LEFT OUTER JOIN MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN				
		                      VMAESTROCOST ON BOM_STRUCT.BST_HIJO = VMAESTROCOST.MA_CODIGO INNER JOIN
		                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO INNER JOIN CalculandoCosto'+@uservar+'
				ON BOM_STRUCT.BSU_SUBENSAMBLE=CalculandoCosto'+@uservar+'.BST_PERTENECE 
		WHERE     (BOM_STRUCT.BST_PERINI <= CalculandoCosto'+@uservar+'.BST_PERINI) AND (BOM_STRUCT.BST_PERFIN >= CalculandoCosto'+@uservar+'.BST_PERINI)
			   AND VMAESTROCOST.SPI_CODIGO='+@spi_codigovar+'
		/*Yolanda Avila  */ '+
		'/*2010-10-04  */ '+
		'/*Se agrego esta linea para que no incluya en el calculo del costo los componentes que tienen tipo de Adquisicion "FANTASMA"  */'+
		'and BOM_STRUCT.bst_tip_ens <>''P'''+
		'GROUP BY CONFIGURATIPO.CFT_TIPO, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BST_TIP_ENS, 
		                      VMAESTROCOST.TCO_CODIGO,CalculandoCosto'+@uservar+'.BST_PERINI
		HAVING      (CONFIGURATIPO.CFT_TIPO = ''S'' OR
		                      CONFIGURATIPO.CFT_TIPO = ''P'') AND BOM_STRUCT.BST_TIP_ENS<>''C''')





GO
