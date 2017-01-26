SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER DEL_FACTEXPAGRU ON dbo.FACTEXPAGRU 
FOR DELETE 
AS

BEGIN

	-- Actualizar la Factura de Exportaci>n Individual para indicar que ya no pertenece a ninguna Factura Agrupada
	   IF EXISTS (SELECT * FROM FactExp ,deleted WHERE FactExp.fe_FactAgru = deleted.fea_codigo)
	      UPDATE FactExp SET Fe_FactAgru=-1 FROM FactExp ,deleted WHERE FactExp.fe_FactAgru = deleted.fea_codigo


	-- Borrar los Commercial Invoices pertenecientes a esta factura
	   IF EXISTS (SELECT * FROM COMMINV ,deleted WHERE COMMINV.fe_codigo = deleted.fea_codigo)
 	      DELETE COMMINV  FROM COMMINV ,deleted WHERE COMMINV.fe_codigo = deleted.fea_codigo AND IV_TIPOFACT = 'A'


	-- Borrar los Canada Custom Invoices pertenecientes a esta factura
	IF EXISTS (SELECT * FROM CANADACINV ,deleted WHERE CANADACINV.fe_codigo = deleted.fea_codigo)
	      DELETE CANADACINV  FROM CANADACINV ,deleted WHERE CANADACINV.fe_codigo = deleted.fea_codigo AND CD_TIPOFACT = 'A'


END


















































GO
