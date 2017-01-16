SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE dbo.SP_PARTMASTER   as

SET NOCOUNT ON 
SELECT DISTINCT m.ma_nombre, m.ma_codigo,  m.ma_noparte, m.ti_codigo, t.ti_nombre
FROM MAESTRO m INNER JOIN TIPO t ON m.ti_codigo = t.ti_codigo
WHERE  (m.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('S', 'P')))
ORDER BY  m.ma_noparte,  m.ma_nombre, m.ma_codigo,  t.ti_nombre



























GO
