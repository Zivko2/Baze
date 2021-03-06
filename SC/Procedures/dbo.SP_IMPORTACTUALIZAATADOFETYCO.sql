SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE PROCEDURE [dbo].[SP_IMPORTACTUALIZAATADOFETYCO] (@TABLA VARCHAR(150), @USER INT)   as



UPDATE FACTEXPDET
SET FACTEXPDET.FED_CANTEMP=1, FACTEXPDET.MA_EMPAQUE=37275
FROM         FACTEXP INNER JOIN
                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
WHERE FACTEXPDET.FED_INDICED IN 
	(SELECT     MIN(FD2.FED_INDICED)
	FROM         FACTEXP F2 INNER JOIN
	                      FACTEXPDET FD2 ON F2.FE_CODIGO = FD2.FE_CODIGO
	WHERE F2.FE_CODIGO=FACTEXPDET.FE_CODIGO
	GROUP BY FD2.FED_OBSERVA, F2.FE_FOLIO)
AND FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I')


Declare @X Int,@POS Varchar(100)

	Select FED_INDICED,FE_CODIGO,FED_RELCAJAS 
	Into dbo.[#TempX] 
	From FACTEXPDET 
	where Not FED_OBSERVA is NULL
	AND FED_CANTEMP=1
	AND FE_CODIGO IN (SELECT FE_CODIGO FROM FACTEXP WHERE FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I'))
	Order by FED_INDICED


	
	SET @X=0
	SET @POS=''
	
	Update #Tempx 
	SET FED_RELCAJAS=@X,@X=CASE WHEN @POS = FE_CODIGO THEN @X+1 ELSE 1 END,@POS=CASE WHEN @POS = FE_CODIGO THEN @POS ELSE FE_CODIGO END
	
	
	Update FACTEXPDET 
	SET FED_RELCAJAS=T.FED_RELCAJAS 
	From #Tempx T inner join FACTEXPDET on T.FED_INDICED=FACTEXPDET.FED_INDICED
	WHERE FACTEXPDET.FE_CODIGO IN (SELECT FE_CODIGO FROM FACTEXP WHERE FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I'))


UPDATE FACTEXP
SET FE_TOTALB=
	ISNULL((SELECT     SUM(FACTEXPDET.FED_CANTEMP)
	FROM         FACTEXPDET
	WHERE FACTEXPDET.FE_CODIGO=FACTEXP.FE_CODIGO),0)
WHERE FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I')




UPDATE FACTEXP
SET     FE_INVOICETYPE=
                          (SELECT     FE_INVOICETYPE
                            FROM          CLIENTE
                            WHERE      CL_EMPRESA = 'S'), 
FE_FOOTER=
                          (SELECT     FE_FOOTER
                            FROM          CLIENTE
                            WHERE      CL_EMPRESA = 'S'), 
FE_HEADER=
                          (SELECT     FE_HEADER
                            FROM          CLIENTE
                            WHERE      CL_EMPRESA = 'S'), 
FE_DESCRIPTION1=
                          (SELECT     CL_DESC_GRAL
                            FROM          CLIENTE
                            WHERE      CL_EMPRESA = 'S'),
FE_DESCRIPTION2=''
FROM         FACTEXP
WHERE FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I')

























GO
