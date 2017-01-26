SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_temp_13029]   as


		UPDATE    CERTORIGMP
	SET              CMP_FECHATRANS = CMP_VFECHA
	WHERE     (CMP_FECHATRANS IS NULL)


	UPDATE IMPORTSPECDET
	SET IMD_DEFAULT_CODE = -1
	WHERE IMF_CODIGO = 770






























GO
