SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
GO

























CREATE VIEW dbo.Prueba_vw
AS
SELECT i.FI_FECHA, i.FI_PI_ENUSO, i.FI_CANCELADO, 
    d.FID_INDICED, d.FI_CODIGO, d.FID_NOMBRE, i.FI_NO_SEM, 
    i.AG_USA, i.AG_MEX
FROM FACTIMP i INNER JOIN
    FACTIMPDET d ON i.FI_CODIGO = d.FI_CODIGO































GO
