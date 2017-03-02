SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_InsertaPckListIncrementables] (@fi_codigo int)  as


		UPDATE FACTIMPINCREMENTA
	SET FII_VALOR= (SELECT SUM(dbo.PCKLISTINCREMENTA.PLI_VALOR) 
			FROM         dbo.PCKLISTINCREMENTA INNER JOIN
			                      dbo.FACTIMPDET ON dbo.PCKLISTINCREMENTA.PL_CODIGO = dbo.FACTIMPDET.PL_CODIGO
			WHERE dbo.PCKLISTINCREMENTA.IC_CODIGO=FACTIMPINCREMENTA.IC_CODIGO 
			AND (dbo.FACTIMPDET.FI_CODIGO = FACTIMPINCREMENTA.FI_CODIGO))
	WHERE FACTIMPINCREMENTA.FI_CODIGO=@fi_codigo

	INSERT INTO FACTIMPINCREMENTA(FI_CODIGO, IC_CODIGO, FII_VALOR)
	SELECT     dbo.FACTIMPDET.FI_CODIGO, dbo.PCKLISTINCREMENTA.IC_CODIGO, SUM(dbo.PCKLISTINCREMENTA.PLI_VALOR) 
	FROM         dbo.PCKLISTINCREMENTA INNER JOIN
	                      dbo.FACTIMPDET ON dbo.PCKLISTINCREMENTA.PL_CODIGO = dbo.FACTIMPDET.PL_CODIGO
	WHERE dbo.PCKLISTINCREMENTA.IC_CODIGO NOT IN (SELECT IC_CODIGO FROM FACTIMPINCREMENTA WHERE FI_CODIGO=@fi_codigo)
	GROUP BY dbo.FACTIMPDET.FI_CODIGO, dbo.PCKLISTINCREMENTA.IC_CODIGO
	HAVING      (dbo.FACTIMPDET.FI_CODIGO = @fi_codigo)


GO