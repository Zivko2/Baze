SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_GENERABARCODE] (@FI_CODIGO INT, @TIPO CHAR(1))   as

DECLARE @BC_CODIGO INT


--@TIPO E=ENTRADA, S=SALIDA, P=PED IMPORT

	IF @TIPO='E'
	BEGIN
		IF (SELECT ISNULL(BC_CODIGO,0) FROM FACTIMP WHERE FI_CODIGO=@FI_CODIGO) =0 
		BEGIN
			DELETE FROM BARCODE WHERE  --BC_TIPO='F' AND BC_TIPOMOV='E' AND BC_AGRUPACION='I' AND
			BC_NOMBRE IN (SELECT FI_FOLIO FROM FACTIMP WHERE FI_CODIGO=@FI_CODIGO)

			EXEC  SP_GETCONSECUTIVO 'BC', @VALUE = @BC_CODIGO OUTPUT
			
				
			INSERT INTO BARCODE(BC_CODIGO, BC_NOMBRE, BC_TEXTO, BC_DOCTO, BC_TIPO, BC_TIPOMOV, BC_AGRUPACION)
			SELECT @BC_CODIGO, FI_FOLIO, '', 0, 'F', 'E', 'I'
			FROM FACTIMP WHERE FI_CODIGO=@FI_CODIGO
			
			
			UPDATE FACTIMP
			SET BC_CODIGO=@BC_CODIGO
			WHERE FI_CODIGO=@FI_CODIGO
		END
	END

	IF @TIPO='S'
	BEGIN
		IF (SELECT ISNULL(BC_CODIGO,0) FROM FACTEXP WHERE FE_CODIGO=@FI_CODIGO) =0 
		BEGIN
			DELETE FROM BARCODE WHERE  --BC_TIPO='F' AND BC_TIPOMOV='S' AND BC_AGRUPACION='I' AND
			BC_NOMBRE IN (SELECT FE_FOLIO FROM FACTEXP WHERE FE_CODIGO=@FI_CODIGO)

			EXEC  SP_GETCONSECUTIVO 'BC', @VALUE = @BC_CODIGO OUTPUT
			
				
			INSERT INTO BARCODE(BC_CODIGO, BC_NOMBRE, BC_TEXTO, BC_DOCTO, BC_TIPO, BC_TIPOMOV, BC_AGRUPACION)
			SELECT @BC_CODIGO, FE_FOLIO, '', 0, 'F', 'S', 'I'
			FROM FACTEXP WHERE FE_CODIGO=@FI_CODIGO
			
			
			UPDATE FACTEXP
			SET BC_CODIGO=@BC_CODIGO
			WHERE FE_CODIGO=@FI_CODIGO
		END


	END

	IF @TIPO='P'
	BEGIN
		IF (SELECT ISNULL(BC_CODIGO,0) FROM PEDIMP WHERE PI_CODIGO=@FI_CODIGO) =0 
		BEGIN
			DELETE FROM BARCODE WHERE  --BC_TIPO='P' AND BC_TIPOMOV='E' AND BC_AGRUPACION='I' AND
			BC_NOMBRE IN (SELECT dbo.AGENCIAPATENTE.AGT_PATENTE+'-'+dbo.PEDIMP.PI_FOLIO
						FROM         dbo.PEDIMP INNER JOIN
						                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
						WHERE PI_CODIGO=@FI_CODIGO)

			EXEC  SP_GETCONSECUTIVO 'BC', @VALUE = @BC_CODIGO OUTPUT
			
				
			INSERT INTO BARCODE(BC_CODIGO, BC_NOMBRE, BC_TEXTO, BC_DOCTO, BC_TIPO, BC_TIPOMOV, BC_AGRUPACION)
			SELECT @BC_CODIGO, dbo.AGENCIAPATENTE.AGT_PATENTE+'-'+dbo.PEDIMP.PI_FOLIO, '', 0, 'P', 'E', 'I'
			FROM         dbo.PEDIMP INNER JOIN
			                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
			WHERE PI_CODIGO=@FI_CODIGO


			
			
			UPDATE PEDIMP
			SET BC_CODIGO=@BC_CODIGO
			WHERE PI_CODIGO=@FI_CODIGO
		END


	END



	IF @TIPO='X'
	BEGIN
		IF (SELECT ISNULL(BC_CODIGO,0) FROM PEDIMP WHERE PI_CODIGO=@FI_CODIGO) =0 
		BEGIN
			DELETE FROM BARCODE WHERE  --BC_TIPO='P' AND BC_TIPOMOV='S' AND BC_AGRUPACION='I' AND
			BC_NOMBRE IN (SELECT dbo.AGENCIAPATENTE.AGT_PATENTE+'-'+dbo.PEDIMP.PI_FOLIO
						FROM         dbo.PEDIMP INNER JOIN
						                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
						WHERE PI_CODIGO=@FI_CODIGO)

			EXEC  SP_GETCONSECUTIVO 'BC', @VALUE = @BC_CODIGO OUTPUT
			
				
			INSERT INTO BARCODE(BC_CODIGO, BC_NOMBRE, BC_TEXTO, BC_DOCTO, BC_TIPO, BC_TIPOMOV, BC_AGRUPACION)
			SELECT @BC_CODIGO, dbo.AGENCIAPATENTE.AGT_PATENTE+'-'+dbo.PEDIMP.PI_FOLIO, '', 0, 'P', 'S', 'I'
			FROM         dbo.PEDIMP INNER JOIN
			                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
			WHERE PI_CODIGO=@FI_CODIGO
			
			
			UPDATE PEDIMP
			SET BC_CODIGO=@BC_CODIGO
			WHERE PI_CODIGO=@FI_CODIGO
		END


	END



GO
