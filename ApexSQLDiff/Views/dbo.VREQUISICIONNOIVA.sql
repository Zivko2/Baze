SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VREQUISICIONNOIVA
with encryption as
SELECT     SUM(ISNULL(REQC_CONTRIBTOTUS, 0)) AS ORC_CONTRIBTOTUS, REQ_CODIGO
FROM         dbo.REQUISICIONCONTRIB
WHERE     (CON_CODIGO not in(select con_codigo from contribucion where con_clave='3'))
GROUP BY REQ_CODIGO






GO
