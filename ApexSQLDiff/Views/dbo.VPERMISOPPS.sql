SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW dbo.VPERMISOPPS
with encryption as
SELECT     dbo.PERMISO.PE_PERMISO, dbo.PERMISODET.AR_IMPMX
FROM         dbo.PERMISO LEFT OUTER JOIN
                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO LEFT OUTER JOIN
                      dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
WHERE     (dbo.IDENTIFICA.IDE_CLAVE = 'PS')






GO
