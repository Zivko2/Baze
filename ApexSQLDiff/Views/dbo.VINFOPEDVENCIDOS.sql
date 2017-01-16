SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VINFOPEDVENCIDOS
with encryption as
SELECT     dbo.PEDIMP.PI_CODIGO, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_FOLIO, MIN(dbo.CLAVEPED.CP_CLAVE) 
                      AS CP_CLAVE
FROM         dbo.PIDescarga RIGHT OUTER JOIN
                      dbo.PEDIMP ON dbo.PIDescarga.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
WHERE     (dbo.PIDescarga.pid_fechavence IS NOT NULL) AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND (dbo.PIDescarga.PID_SALDOGEN > 0) AND 
                      (dbo.PEDIMP.PI_ESTATUS <> 'R')
GROUP BY dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default, dbo.PEDIMP.PI_CODIGO
HAVING      (MIN(dbo.PIDescarga.pid_fechavence) <= convert(datetime, convert(varchar(11), getdate()-ISNULL ((SELECT     CF_DIAS_AVISO 
  FROM         configuracion), 0)),101))













GO
