SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















































CREATE PROCEDURE [dbo].[SP_IMPLEMENTAEXCEL]   as

SET NOCOUNT ON 
declare @BST_HIJO int, @PID_CANT_ST decimal(38,6),@FE_FECHA datetime, @ME_CODIGO int, @Factconv decimal(28,14), 
                      @MA_COSTO decimal(38,6)

/* se pasa la informacion de implementa a implementatemp para poder hacer la sumatoria
de de lo que esta en excel (inventario) y lo de implementa*/ 

INSERT INTO IMPLEMENTATEMP(BST_HIJO, PID_CANT_ST, FE_FECHA, ME_CODIGO, FACTCONV, MA_COSTO)

SELECT     BST_HIJO, PID_CANT_ST, FE_FECHA, ME_CODIGO, FACTCONV, MA_COSTO
FROM         dbo.IMPLEMENTA

TRUNCATE TABLE IMPLEMENTA



-- los que estan en los dos
declare cur_losdos cursor for
SELECT     dbo.IMPLEMENTATEMP.BST_HIJO, SUM(dbo.IMPLEMENTATEMP.PID_CANT_ST + dbo.IMPLEMENTAEXCEL.PID_CANT_ST), 
                      dbo.IMPLEMENTAEXCEL.FE_FECHA, MAX(dbo.IMPLEMENTAEXCEL.ME_CODIGO), MAX(dbo.IMPLEMENTAEXCEL.FACTCONV), 
		MAX(dbo.IMPLEMENTAEXCEL.MA_COSTO)
FROM         dbo.IMPLEMENTATEMP INNER JOIN
                      dbo.IMPLEMENTAEXCEL ON dbo.IMPLEMENTATEMP.BST_HIJO = dbo.IMPLEMENTAEXCEL.BST_HIJO AND 
                      dbo.IMPLEMENTATEMP.FE_FECHA = dbo.IMPLEMENTAEXCEL.FE_FECHA
GROUP BY dbo.IMPLEMENTATEMP.BST_HIJO, dbo.IMPLEMENTAEXCEL.FE_FECHA
open cur_losdos


	FETCH NEXT FROM cur_losdos INTO @BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	insert into implementa (BST_HIJO, PID_CANT_ST, FE_FECHA, ME_CODIGO, FACTCONV, 
                      MA_COSTO)
		
	values (@BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO)



	FETCH NEXT FROM cur_losdos INTO @BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO


END

CLOSE cur_losdos
DEALLOCATE cur_losdos





-- LOS QUE ESTAN EN IMPLEMENTA Y NO EN EXCEL

declare cur_implementa cursor for
SELECT     dbo.IMPLEMENTATEMP.BST_HIJO, SUM(dbo.IMPLEMENTATEMP.PID_CANT_ST), dbo.IMPLEMENTATEMP.FE_FECHA, 
                      MAX(dbo.IMPLEMENTATEMP.ME_CODIGO), MAX(dbo.IMPLEMENTATEMP.ME_CODIGO), MAX(dbo.IMPLEMENTATEMP.MA_COSTO)
FROM         dbo.IMPLEMENTATEMP LEFT OUTER JOIN
                      dbo.IMPLEMENTAEXCEL ON dbo.IMPLEMENTATEMP.BST_HIJO = dbo.IMPLEMENTAEXCEL.BST_HIJO AND 
                      dbo.IMPLEMENTATEMP.FE_FECHA = dbo.IMPLEMENTAEXCEL.FE_FECHA
WHERE     (dbo.IMPLEMENTAEXCEL.BST_HIJO IS NULL)
GROUP BY dbo.IMPLEMENTATEMP.BST_HIJO, dbo.IMPLEMENTATEMP.FE_FECHA
open cur_implementa


	FETCH NEXT FROM cur_implementa INTO @BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	insert into implementa (BST_HIJO, PID_CANT_ST, FE_FECHA, ME_CODIGO, FACTCONV, 
                      MA_COSTO)
		
	values (@BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO)



	FETCH NEXT FROM cur_implementa INTO @BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO


END

CLOSE cur_implementa
DEALLOCATE cur_implementa




-- LOS QUE ESTAN EN EXCEL Y NO EN IMPLEMENTA
declare cur_excel cursor for
SELECT     dbo.IMPLEMENTAEXCEL.BST_HIJO, SUM(dbo.IMPLEMENTAEXCEL.PID_CANT_ST), dbo.IMPLEMENTAEXCEL.FE_FECHA, 
                      MAX(dbo.IMPLEMENTAEXCEL.ME_CODIGO), MAX(dbo.IMPLEMENTAEXCEL.FACTCONV), MAX(dbo.IMPLEMENTAEXCEL.MA_COSTO)
FROM         dbo.IMPLEMENTATEMP RIGHT OUTER JOIN
                      dbo.IMPLEMENTAEXCEL ON dbo.IMPLEMENTATEMP.BST_HIJO = dbo.IMPLEMENTAEXCEL.BST_HIJO AND 
                      dbo.IMPLEMENTATEMP.FE_FECHA = dbo.IMPLEMENTAEXCEL.FE_FECHA
WHERE     (dbo.IMPLEMENTATEMP.BST_HIJO IS NULL)
GROUP BY dbo.IMPLEMENTAEXCEL.BST_HIJO, dbo.IMPLEMENTAEXCEL.FE_FECHA
open cur_excel


	FETCH NEXT FROM cur_excel INTO @BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	insert into implementa (BST_HIJO, PID_CANT_ST, FE_FECHA, ME_CODIGO, FACTCONV, 
                      MA_COSTO)
		
	values (@BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO)



	FETCH NEXT FROM cur_excel INTO @BST_HIJO, @PID_CANT_ST,@FE_FECHA, @ME_CODIGO, @FACTCONV, 
                      @MA_COSTO


END

CLOSE cur_excel
DEALLOCATE cur_excel
















































GO
