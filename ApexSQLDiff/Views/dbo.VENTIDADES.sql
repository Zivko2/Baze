SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VENTIDADES
with encryption as
select TOP 100 PERCENT AG_CODIGO as CODIGO,AG_NOMBRE as NOMBRE, 'A' AS TIPO from AGENCIA 
union
select cl_codigo, cl_razon, 'C' from cliente
where cl_codigo<>1
union
select ct_codigo, ct_nombre, 'T' from ctranspor


GO
