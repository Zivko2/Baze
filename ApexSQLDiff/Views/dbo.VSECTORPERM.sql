SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE VIEW dbo.VSECTORPERM
with encryption as
SELECT     dbo.PERMISODET.SE_CODIGO
FROM         dbo.PERMISO INNER JOIN
                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO INNER JOIN
                      dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
WHERE     (dbo.IDENTIFICA.IDE_CLAVE = 'PS') AND (dbo.PERMISO.PE_APROBADO = 'S')
AND  (dbo.PERMISODET.SE_CODIGO IS NOT NULL) AND (dbo.PERMISODET.SE_CODIGO > 0)
GROUP BY dbo.PERMISODET.SE_CODIGO

































GO
