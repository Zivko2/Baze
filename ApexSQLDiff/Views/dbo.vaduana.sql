SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.vaduana
with encryption as
SELECT     AD_CODIGO, AD_CLAVE collate database_default + '-' + AD_SECCION collate database_default AS [CLAVE-SECCION], AD_NOMBRE, AD_CLAVE, AD_SECCION
FROM         dbo.ADUANA

GO
