SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE VIEW dbo.VAGENCIAUS
with encryption as
SELECT AG_CODIGO, AG_NOMBRE, AG_PATENTE
FROM AGENCIA
WHERE AG_TIPO = 'E' or AG_TIPO = 'A'

























GO
