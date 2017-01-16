SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE dbo.SP_PTSUB_MASTER   as

SET NOCOUNT ON 
SELECT MAESTRO.MA_NOMBRE, MAESTRO.MA_CODIGO, 
    MAESTRO.MA_NOPARTEAUX, MAESTRO.MA_NOPARTE, 
    MAESTRO.TI_CODIGO, MAESTRO.CS_CODIGO,
    UsoFact=case when (select count(ma_codigo) from factexpdet where ma_codigo=maestro.ma_codigo)>0
    then 1 else 0 end,
    ConBom=case when (select count(bst_hijo) from bom_struct where bsu_subensamble=maestro.ma_codigo)>0
then 1 else 0 end
FROM MAESTRO 
WHERE ((MAESTRO.TI_CODIGO IN  (SELECT TI_CODIGO  FROM CONFIGURATIPO  WHERE (CFT_TIPO = 'P') OR (CFT_TIPO = 'S'))) OR
	MAESTRO.CS_CODIGO=2)
	AND (MAESTRO.MA_INV_GEN = 'I')
AND (MAESTRO.MA_OCULTO='N') and (MAESTRO.MA_NOPARTE is not null) and (MAESTRO.MA_NOPARTE<>'')
ORDER BY MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX






























GO
