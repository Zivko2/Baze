SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW dbo.vbasedatosI
with encryption as
SELECT     dbo.vbasedatos.tabla, dbo.vbasedatos.columna, dbo.vbasedatos.orden, dbo.vbasedatos.defaultcampo, dbo.vbasedatos.permitenulos, 
                      dbo.vbasedatos.tipocampo, dbo.vbasedatos.tamano, dbo.vllaves.CONSTRAINT_NAME, dbo.vbasedatos.[identity],dbo.vbasedatos.preci,dbo.vbasedatos.escala
FROM         dbo.vbasedatos LEFT OUTER JOIN
                      dbo.vllaves ON dbo.vbasedatos.tabla = dbo.vllaves.TABLE_NAME AND dbo.vbasedatos.columna = dbo.vllaves.COLUMN_NAME










GO
