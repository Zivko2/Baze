SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW dbo.VPERMISOMATERIALES
with encryption as
SELECT     dbo.MAESTROCATEG.MA_CODIGO, dbo.MAESTROCATEG.CPE_CODIGO
FROM         dbo.PERMISO INNER JOIN
                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO INNER JOIN
                      dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO INNER JOIN
                      dbo.MAESTROCATEG ON dbo.PERMISODET.MA_GENERICO = dbo.MAESTROCATEG.CPE_CODIGO
GROUP BY dbo.IDENTIFICA.IDE_CLAVE, dbo.MAESTROCATEG.MA_CODIGO, dbo.MAESTROCATEG.CPE_CODIGO
HAVING      (dbo.IDENTIFICA.IDE_CLAVE = 'MQ' OR
                      dbo.IDENTIFICA.IDE_CLAVE = 'PX')





GO
