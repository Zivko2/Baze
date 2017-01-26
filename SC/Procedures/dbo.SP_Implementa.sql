SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



/* Inserta en la tabla Implementa lo generado por la explosion de facturas sin afectar pedimentos */
CREATE PROCEDURE [dbo].[SP_Implementa] (@fechaini varchar(10), @fechafin varchar(10))   as

SET NOCOUNT ON 

declare @BST_HIJO INT, @PID_CANT_ST decimal(38,6), @FE_FECHA DATETIME, @ME_CODIGO INT, @Factconv decimal(28,14), @MA_COSTO decimal(38,6)

 TRUNCATE TABLE BOM_DESCTEMP


	EXEC sp_ExplosionaFactExpPeriodo @fechaini, @fechafin



	TRUNCATE TABLE implementa


	INSERT INTO IMPLEMENTA(BST_HIJO, PID_CANT_ST, FE_FECHA, ME_CODIGO, FACTCONV, MA_COSTO, ORIGENREG)
	SELECT     dbo.BOM_DESCTEMP.BST_HIJO, SUM(dbo.BOM_DESCTEMP.BST_INCORPOR * dbo.BOM_DESCTEMP.FED_CANT * dbo.BOM_DESCTEMP.FACTCONV) 
	                      AS PID_CANT_ST, dbo.FACTEXP.FE_FECHA, isnull(MIN(dbo.BOM_DESCTEMP.ME_GEN), 19),  dbo.BOM_DESCTEMP.FACTCONV, 
	                      MIN(VMAESTROCOST.MA_COSTO) , 'E'
	FROM         dbo.BOM_DESCTEMP LEFT OUTER JOIN
	                      VMAESTROCOST ON dbo.BOM_DESCTEMP.BST_HIJO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
	                      dbo.FACTEXP ON dbo.BOM_DESCTEMP.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
	WHERE     (dbo.BOM_DESCTEMP.BST_DISCH = 'S') AND 
	                      (dbo.BOM_DESCTEMP.BST_INCORPOR * dbo.BOM_DESCTEMP.FED_CANT * dbo.BOM_DESCTEMP.FACTCONV IS NOT NULL) 
	GROUP BY dbo.BOM_DESCTEMP.BST_HIJO, dbo.FACTEXP.FE_FECHA, dbo.BOM_DESCTEMP.FACTCONV
	HAVING      (SUM(dbo.BOM_DESCTEMP.BST_INCORPOR * dbo.BOM_DESCTEMP.FED_CANT * dbo.BOM_DESCTEMP.FACTCONV) > 0) AND 
		(dbo.BOM_DESCTEMP.BST_HIJO) IS NOT NULL



	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP






GO
