SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_temp_13032]   as

		/* borrado de tipos de factura definitivos de activo fijo */

	if (select tf_nombre from tfactura where tf_codigo=15)='IMPORTACION DEFINITIVA DE ACTIVO FIJO'
	begin

		UPDATE FACTIMP
		SET TF_CODIGO=4
		WHERE TF_CODIGO=15

		UPDATE PCKLIST
		SET TF_CODIGO=4
		WHERE TF_CODIGO=15

	
		delete from tfactura where tf_codigo =15
	end


	if (select tf_nombre from tfactura where tf_codigo=14)='EXPORTACION DEFINITIVA DE ACTIVO FIJO'
	begin
		UPDATE FACTEXP
		SET TF_CODIGO=2
		WHERE TF_CODIGO=14

		UPDATE LISTAEXP
		SET TF_CODIGO=2
		WHERE TF_CODIGO=14


		delete from tfactura where tf_codigo =14
	end






























GO
