SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















CREATE PROCEDURE [dbo].[SP_VERIFICACUENTAvsSAAI]   as


		delete from TempAgCuenta where ClavePedimento is null

	Update TempAgCuenta 
	set Aduana=replace(Aduana,'-','')

	INSERT INTO TempAgTotCuenta(PatenteAgente, Pedimento, Aduana, ClavePedimento, 
	FechaPedimento, ValorAduana, PesosMexicanos, IVA, Advalorem, Texto) 
	SELECT Patente, Pedimento, Aduana, CveDocto, FecPagoReal, 
	'-'+ convert(varchar(50),sum(isnull(ValorAduana,0))) as ValorAduana, '-'+ convert(varchar(50),sum(isnull(ValorComercial,0))) as ValorComercial, 
	'-'+convert(varchar(50),sum(isnull(ImporteIVA,0))) as ImporteIVA, 
	'-'+ convert(varchar(50),sum(isnull(ImporteADvalorem,0))) as ImporteADvalorem, 'SAAI' 
	FROM TempAgSaai 
	GROUP BY Patente, Pedimento, Aduana, CveDocto, FecPagoReal 
	
	UPDATE TempAgTotCuenta 
	SET Texto ='NO EXISTE EN AGADUMF' 
	WHERE Aduana+' '+PatenteAgente+' '+Pedimento NOT IN 
	    (SELECT Aduana+' '+PatenteAgente+' '+Pedimento FROM TempAgCuenta 
	     GROUP BY Aduana+' '+PatenteAgente+' '+Pedimento )
	
	INSERT INTO TempAgTotCuenta(PatenteAgente, Pedimento, Aduana, ClavePedimento, 
	FechaPedimento, ValorAduana, PesosMexicanos, IVA, Advalorem, Texto) 
	SELECT PatenteAgente, Pedimento, Aduana, ClavePedimento, FechaPedimento, SUM(isnull(ValorAduana,0)) AS ValorAduana, 
	SUM(isnull(PesosMexicanos,0)) AS PesosMexicanos, SUM(isnull(IVA,0)) AS IVA, SUM(isnull(Advalorem,0)) AS Advalorem, 
	'AGADUMF' 
	FROM TempAgCuenta 
	GROUP BY Pedimento, PatenteAgente, Aduana, ClavePedimento, FechaPedimento 
	
	UPDATE TempAgTotCuenta 
	SET Texto ='NO EXISTE EN AGADUMF' 
	WHERE Texto = 'AGADUMF' and Aduana+' '+PatenteAgente+' '+Pedimento NOT IN 
	    (SELECT Aduana+' '+Patente+' '+Pedimento FROM TempAgSaai GROUP BY 
	     Aduana+' '+Patente+' '+Pedimento)
	
	
	INSERT INTO TempAgTotCuenta(ValorAduana, Advalorem, IVA, 
	PesosMexicanos, Aduana, PatenteAgente, Pedimento, Texto) 
	SELECT round(SUM(ValorAduana),6) AS ValorAduana, round(SUM(Advalorem),6) AS Advalorem, round(SUM(IVA),6) AS IVA, 
	round(SUM(PesosMexicanos),6) AS PesosMexicanos, Aduana, PatenteAgente, Pedimento, 'DIFERENCIA' 
	FROM TempAgTotCuenta 
	WHERE (Texto ='SAAI') OR (Texto ='AGADUMF') 
	GROUP BY Aduana, PatenteAgente, Pedimento

GO
