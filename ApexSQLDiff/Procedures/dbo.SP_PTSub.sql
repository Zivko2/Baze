SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PTSub] (@user int)   as

declare @userstr varchar(50)

set @userstr= Convert(varchar(50),@user)

exec ('exec sp_droptable ''TempBomPTSub'+@userstr+'''')


exec ('SELECT MAESTRO.MA_NOMBRE, MAESTRO.MA_CODIGO, 
    MAESTRO.MA_NOPARTEAUX, MAESTRO.MA_NOPARTE, 
    MAESTRO.TI_CODIGO,   0 as UsoFact, 
    0 as ConBom, TI_NOMBRE 
into dbo.TempBomPTSub'+@userstr+' FROM MAESTRO LEFT OUTER JOIN TIPO ON MAESTRO.TI_CODIGO = TIPO.TI_CODIGO 
WHERE ((MAESTRO.TI_CODIGO IN  (SELECT TI_CODIGO  FROM CONFIGURATIPO  WHERE (CFT_TIPO = ''P'') OR (CFT_TIPO = ''S''))) OR 
	MAESTRO.CS_CODIGO=2) AND (MAESTRO.MA_INV_GEN = ''I'') 
AND (MAESTRO.MA_OCULTO=''N'') and (MAESTRO.MA_NOPARTE is not null) and (MAESTRO.MA_NOPARTE<>'''') ')
--ORDER BY MAESTRO.MA_NOPARTE ASC, MAESTRO.MA_NOPARTEAUX


exec('update TempBomPTSub'+@userstr+' set UsoFact = 1 where
(select count(ma_codigo) from factexpdet where ma_codigo=TempBomPTSub'+@userstr+'.ma_codigo and fed_retrabajo=''N'')>0')

exec('update TempBomPTSub'+@userstr+' set ConBom = 1 where
(select count(bst_hijo) from bom_struct where bst_perini<=getdate() and bst_Perfin>=getdate() and bsu_subensamble=TempBomPTSub'+@userstr+'.ma_codigo)>0')


/*

exec ('SELECT MAESTRO.MA_NOMBRE, MAESTRO.MA_CODIGO, 
    MAESTRO.MA_NOPARTEAUX, MAESTRO.MA_NOPARTE, 
    MAESTRO.TI_CODIGO, MAESTRO.CS_CODIGO, 
    UsoFact=case when (select count(ma_codigo) from factexpdet where ma_codigo=maestro.ma_codigo and fed_retrabajo=''N'')>0 
    then 1 else 0 end, 
    ConBom=case when (select count(bst_hijo) from bom_struct where bsu_subensamble=maestro.ma_codigo)>0 
then 1 else 0 end, TI_NOMBRE 
into dbo.TempBomPTSub'+@userstr+' FROM MAESTRO LEFT OUTER JOIN TIPO ON MAESTRO.TI_CODIGO = TIPO.TI_CODIGO 
WHERE ((MAESTRO.TI_CODIGO IN  (SELECT TI_CODIGO  FROM CONFIGURATIPO  WHERE (CFT_TIPO = ''P'') OR (CFT_TIPO = ''S''))) OR 
	MAESTRO.CS_CODIGO=2) AND (MAESTRO.MA_INV_GEN = ''I'') 
AND (MAESTRO.MA_OCULTO=''N'') and (MAESTRO.MA_NOPARTE is not null) and (MAESTRO.MA_NOPARTE<>'''') 
ORDER BY MAESTRO.MA_NOPARTE ASC, MAESTRO.MA_NOPARTEAUX')*/






















GO
