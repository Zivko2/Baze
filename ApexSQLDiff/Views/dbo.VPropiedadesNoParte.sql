SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE VIEW dbo.VPropiedadesNoParte
with encryption as
SELECT     dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE collate database_default + dbo.MAESTRO.MA_NOPARTEAUX collate database_default AS NoParte, dbo.MAESTRO.MA_NOMBRE, 
                      dbo.MAESTRO.MA_NAME, dbo.TIPO.TI_NOMBRE AS TipoMaterial, 
                      'TipoAdquisicion' = CASE dbo.MAESTRO.MA_TIP_ENS WHEN 'F' THEN 'Fisico' WHEN 'P' THEN 'Fantasma' WHEN 'C' THEN 'Comprado' 
	        WHEN 'E' THEN 'Subensamble Exportado' WHEN 'A' THEN 'Comprado - Fisico'  END, 
                      PAIS_2.PA_CORTO AS PaisOrigen, dbo.MEDIDA.ME_CORTO, 
                      'Individualidad' = CASE dbo.MAESTRO.MA_INV_GEN WHEN 'G' THEN 'Grupo Generico' WHEN 'I' THEN 'No. Parte Individual' END, 
                      PAIS_1.PA_CORTO AS PaisProcede, ARANCEL_1.AR_FRACCION AS fraccionImpMx, ARANCEL_1.AR_FRACCION AS fraccionImpFo, 
                      MAESTRO_1.MA_NOPARTE collate database_default + MAESTRO_1.MA_NOPARTEAUX collate database_default AS GrupoGenerico, VMAESTROCOST.MA_COSTO, 
                      'Estatus' = CASE dbo.MAESTRO.MA_EST_MAT WHEN 'A' THEN 'ACTIVO' WHEN 'O' THEN 'OBSOLETO' END, dbo.MAESTRO.MA_PESO_KG, 
                      'Virtual' = CASE dbo.MAESTRO.MA_CONSTA WHEN 'S' THEN 'PROVIENE P. VIRTUAL' WHEN 'N' THEN 'PROVIENE P. NORMAL' END, 
                      'Descarga' = CASE dbo.MAESTRO.MA_DISCHARGE WHEN 'S' THEN 'SE DESCARGA' WHEN 'N' THEN 'NO SE DESCARGA' END
FROM         dbo.TIPO RIGHT OUTER JOIN
                      dbo.MEDIDA RIGHT OUTER JOIN
                      dbo.ARANCEL ARANCEL_1 RIGHT OUTER JOIN
                      dbo.MAESTRO LEFT OUTER JOIN
                      dbo.ARANCEL ARANCEL_2 ON dbo.MAESTRO.AR_IMPMX = ARANCEL_2.AR_CODIGO ON 
                      ARANCEL_1.AR_CODIGO = dbo.MAESTRO.AR_IMPFO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO ON 
                      dbo.MEDIDA.ME_CODIGO = dbo.MAESTRO.ME_COM LEFT OUTER JOIN
                      dbo.PAIS PAIS_1 ON dbo.MAESTRO.PA_PROCEDE = PAIS_1.PA_CODIGO LEFT OUTER JOIN
                      dbo.PAIS PAIS_2 ON dbo.MAESTRO.PA_ORIGEN = PAIS_2.PA_CODIGO ON dbo.TIPO.TI_CODIGO = dbo.MAESTRO.TI_CODIGO LEFT OUTER JOIN
	         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO

























































































































GO
