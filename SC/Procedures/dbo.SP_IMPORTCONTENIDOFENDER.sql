SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE SP_IMPORTCONTENIDOFENDER(@TABLA VARCHAR(150), @USER INT)   AS

exec('
DECLARE @Col_7 float,@FACTEXPDET#FED_COS_TOT float,@FACTEXPDET#FED_PES_BRU float,@FACTEXPDET#FED_PES_BRULB float,
		@FACTEXPDET#FED_PES_NET float,@FACTEXPDET#FED_PES_NETLB float,@FACTEXPDET#FED_NOMBRE varchar(8000),
		@FACTEXPDET#FED_NAME varchar(8000),@FACTEXPDET#FED_COS_UNI float,@FACTEXPDET#FED_GRA_EMP float,@FACTEXPDET#FED_NG_EMP float,
		@FACTEXPDET#FED_GRA_GI_MX float,@FACTEXPDET#FED_GRA_GI float,@FACTEXPDET#FED_GRA_MO float,@FACTEXPDET#FED_GRA_MP float,
		@FACTEXPDET#FED_NG_MP float,@FACTEXP#FE_TIPO char,@FACTEXP#TQ_CODIGO smallint,@FACTEXP#TF_CODIGO smallint,
		@FACTEXPDET#FED_NOPARTEAUX varchar(8000),@FACTEXP#FE_FOLIO varchar(8000),@FACTEXPDET#FED_CANTEMP float,
		@FACTEXPDET#FED_NOPARTE varchar(8000),@FACTEXPDET#MA_EMPAQUE int,@FACTEXPDET#FED_CANT float,
		@FACTEXPCONT#FEC_SERIE varchar(8000),@Cod_3 varchar(8000),@Cod_5 varchar(8000)
DECLARE @ACTUALIZA bit,@ANEXA bit,@CONSECUTIVO int,@CONSDET int,@CONSANEX int,@CONSCONT int
DECLARE @CAMPOSMASTER varchar(255),@temp_str varchar(20)
SELECT @ACTUALIZA=0
SELECT @ANEXA=1
DELETE FROM REGISTROSIMPORTADOS where RI_USERID = 1
-- Variables para campos de caratula
           DECLARE @FACTEXP#FE_DESCRIPTION1 varchar(8000)
           DECLARE @FACTEXP#FE_HEADER varchar(8000)
           DECLARE @FACTEXP#FE_FOOTER varchar(8000)
           DECLARE @FACTEXP#FE_FECHA datetime
           DECLARE @FACTEXP#AG_MX int
           DECLARE @FACTEXP#AG_US int
           DECLARE @FACTEXP#CL_PROD int
           DECLARE @FACTEXP#DI_PROD int
           DECLARE @FACTEXP#CL_COMP int
           DECLARE @FACTEXP#DI_COMP int
           DECLARE @FACTEXP#CL_COMPFIN int
           DECLARE @FACTEXP#DI_COMPFIN int
           DECLARE @FACTEXP#CL_EXP int
           DECLARE @FACTEXP#DI_EXP int
           DECLARE @FACTEXP#CL_EXPFIN int
           DECLARE @FACTEXP#DI_EXPFIN int
           DECLARE @FACTEXP#CL_DESTINI int
           DECLARE @FACTEXP#DI_DESTINI int
           DECLARE @FACTEXP#CL_DESTFIN int
           DECLARE @FACTEXP#DI_DESTFIN int
           DECLARE @FACTEXP#CL_VEND int
           DECLARE @FACTEXP#DI_VEND int
           DECLARE @FACTEXP#CL_IMP int
           DECLARE @FACTEXP#DI_IMP int
           DECLARE @FACTEXP#PU_CARGA int
           DECLARE @FACTEXP#PU_SALIDA int
           DECLARE @FACTEXP#PU_ENTRADA int
           DECLARE @FACTEXP#PU_DESTINO int
           DECLARE @FACTEXP#CT_COMPANY1 int
           DECLARE @FACTEXP#CT_COMPANY2 int
           DECLARE @FACTEXP#IT_COMPANY1 smallint
           DECLARE @FACTEXP#MT_COMPANY1 smallint
           DECLARE @FACTEXP#IT_COMPANY2 smallint
           DECLARE @FACTEXP#MT_COMPANY2 smallint
           DECLARE @FACTEXP#FE_TIPOCAMBIO decimal(38,14)
           DECLARE @FACTEXP#MO_CODIGO int
           DECLARE @FACTEXP#FE_PINICIAL datetime
           DECLARE @FACTEXP#FE_PFINAL datetime
           DECLARE @FACTEXP#AGT_CODIGO int

-- Variables para campos de detalle
           DECLARE @FACTEXPDET#FED_PARTTYPE char
           DECLARE @FACTEXPDET#MA_STRUCT int
           DECLARE @FACTEXPDET#SE_CODIGO smallint
           DECLARE @FACTEXPDET#FED_FECHA_STRUCT datetime
           DECLARE @FACTEXPDET#FED_RETRABAJO char
           DECLARE @FACTEXPDET#TI_CODIGO smallint
           DECLARE @FACTEXPDET#TCO_CODIGO smallint
           DECLARE @FACTEXPDET#SPI_CODIGO smallint
           DECLARE @FACTEXPDET#PA_CODIGO int
           DECLARE @FACTEXPDET#ME_CODIGO int
           DECLARE @FACTEXPDET#ME_AREXPMX int
           DECLARE @FACTEXPDET#MA_GENERICO int
           DECLARE @FACTEXPDET#MA_CODIGO int
           DECLARE @FACTEXPDET#FED_TIP_ENS char
           DECLARE @FACTEXPDET#FED_SEC_IMP smallint
           DECLARE @FACTEXPDET#AR_EXPMX int
           DECLARE @FACTEXPDET#FED_POR_DEF decimal(38,14)
           DECLARE @FACTEXPDET#FED_PES_UNILB decimal(38,14)
           DECLARE @FACTEXPDET#FED_PES_UNI decimal(38,14)
           DECLARE @FACTEXPDET#FED_NG_USA decimal(38,14)
           DECLARE @FACTEXPDET#FED_NG_ADD decimal(38,14)
           DECLARE @FACTEXPDET#FED_NAFTA char
           DECLARE @FACTEXPDET#FED_GRA_ADD decimal(38,14)
           DECLARE @FACTEXPDET#FED_DISCHARGE char
           DECLARE @FACTEXPDET#FED_DEF_TIP char
           DECLARE @FACTEXPDET#EQ_IMPFO decimal(38,14)
           DECLARE @FACTEXPDET#EQ_GEN decimal(38,14)
           DECLARE @FACTEXPDET#EQ_EXPMX decimal(38,14)
           DECLARE @FACTEXPDET#CS_CODIGO smallint
           DECLARE @FACTEXPDET#CL_CODIGO int
           DECLARE @FACTEXPDET#AR_IMPMX int
           DECLARE @FACTEXPDET#AR_IMPFO int
           DECLARE @FACTEXPDET#AR_ORIG int
           DECLARE @FACTEXPDET#AR_NG_EMP int
           DECLARE @FACTEXPDET#FED_RATEIMPFO decimal(38,14)
           DECLARE @FACTEXPDET#ME_GENERICO int
DECLARE CUR_TEMPIMPORT162_1 CURSOR FOR
SELECT Col_7,Cod_3,Cod_5,FACTEXP'+@USER+'#FE_TIPO,FACTEXP'+@USER+'#TQ_CODIGO,FACTEXP'+@USER+'#TF_CODIGO,FACTEXP'+@USER+'#FE_FOLIO FROM '+@TABLA+' WHERE FACTEXP'+@USER+'#FE_FOLIO NOT IN (select factexp.fe_folio from factexp WHERE factexp.fe_estatus in (''A'', ''C'', ''P'', ''L'', ''S'') or fe_iniciocruce=''S'')
OPEN CUR_TEMPIMPORT162_1
FETCH NEXT FROM CUR_TEMPIMPORT162_1 INTO @Col_7 ,@Cod_3 ,@Cod_5 ,@FACTEXP#FE_TIPO ,@FACTEXP#TQ_CODIGO ,@FACTEXP#TF_CODIGO ,@FACTEXP#FE_FOLIO 
WHILE (@@FETCH_STATUS = 0)
BEGIN
  IF (select count(factexpdet.FE_CODIGO) from factexp left outer join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo where FE_FOLIO=@FACTEXP#FE_FOLIO AND FE_TIPO=@FACTEXP#FE_TIPO AND TQ_CODIGO=@FACTEXP#TQ_CODIGO) = 0
  IF @ANEXA=1
  BEGIN
		select @CONSECUTIVO = fe_codigo from factexp where FE_FOLIO=@FACTEXP#FE_FOLIO AND FE_TIPO=@FACTEXP#FE_TIPO AND TQ_CODIGO=@FACTEXP#TQ_CODIGO
        DECLARE CUR_TEMPIMPORT162_1DET CURSOR FOR
        SELECT Col_7,Cod_3,Cod_5,FACTEXPDET'+@USER+'#FED_COS_TOT,FACTEXPDET'+@USER+'#FED_PES_BRU,FACTEXPDET'+@USER+'#FED_PES_BRULB,FACTEXPDET'+@USER+'#FED_PES_NET,FACTEXPDET'+@USER+'#FED_PES_NETLB,FACTEXPDET'+@USER+'#FED_NOMBRE,FACTEXPDET'+@USER+'#FED_NAME,FACTEXPDET'+@USER+'#FED_COS_UNI,FACTEXPDET'+@USER+'#FED_GRA_EMP,FACTEXPDET'+@USER+'#FED_NG_EMP,FACTEXPDET'+@USER+'#FED_GRA_GI_MX,FACTEXPDET'+@USER+'#FED_GRA_GI,FACTEXPDET'+@USER+'#FED_GRA_MO,FACTEXPDET'+@USER+'#FED_GRA_MP,FACTEXPDET'+@USER+'#FED_NG_MP,FACTEXPDET'+@USER+'#FED_NOPARTEAUX,FACTEXPDET'+@USER+'#FED_CANTEMP,FACTEXPDET'+@USER+'#FED_NOPARTE,FACTEXPDET'+@USER+'#MA_EMPAQUE,FACTEXPDET'+@USER+'#FED_CANT FROM '+@TABLA+'  WHERE FACTEXP'+@USER+'#FE_FOLIO=@FACTEXP#FE_FOLIO AND FACTEXP'+@USER+'#FE_TIPO=@FACTEXP#FE_TIPO AND FACTEXP'+@USER+'#TQ_CODIGO=@FACTEXP#TQ_CODIGO
        OPEN CUR_TEMPIMPORT162_1DET
                      FETCH NEXT FROM CUR_TEMPIMPORT162_1DET INTO @Col_7 ,@Cod_3 ,@Cod_5 ,@FACTEXPDET#FED_COS_TOT ,@FACTEXPDET#FED_PES_BRU ,@FACTEXPDET#FED_PES_BRULB ,@FACTEXPDET#FED_PES_NET ,@FACTEXPDET#FED_PES_NETLB ,@FACTEXPDET#FED_NOMBRE ,@FACTEXPDET#FED_NAME ,@FACTEXPDET#FED_COS_UNI ,@FACTEXPDET#FED_GRA_EMP ,@FACTEXPDET#FED_NG_EMP ,@FACTEXPDET#FED_GRA_GI_MX ,@FACTEXPDET#FED_GRA_GI ,@FACTEXPDET#FED_GRA_MO ,@FACTEXPDET#FED_GRA_MP ,@FACTEXPDET#FED_NG_MP ,@FACTEXPDET#FED_NOPARTEAUX ,@FACTEXPDET#FED_CANTEMP ,@FACTEXPDET#FED_NOPARTE ,@FACTEXPDET#MA_EMPAQUE ,@FACTEXPDET#FED_CANT 
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
           SELECT @FACTEXPDET#FED_PARTTYPE=(SELECT  ''FED_PARTTYPE''=CASE WHEN CONFIGURATIPO.CFT_TIPO IN (''P'',''S'') THEN ''A''  ELSE ''C'' END FROM MAESTRO LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_PARTTYPE IS NULL
                SELECT @FACTEXPDET#FED_PARTTYPE=''''
           SELECT @FACTEXPDET#MA_STRUCT=(SELECT MA_CODIGO FROM MAESTRO WHERE MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#MA_STRUCT IS NULL
                SELECT @FACTEXPDET#MA_STRUCT=0
           SELECT @FACTEXPDET#SE_CODIGO=(SELECT isnull(SE_codigo,0) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#SE_CODIGO IS NULL
                SELECT @FACTEXPDET#SE_CODIGO=0
           SELECT @FACTEXPDET#FED_FECHA_STRUCT=(SELECT convert(varchar(11),getdate(),101))
            IF @FACTEXPDET#FED_FECHA_STRUCT IS NULL
                SELECT @FACTEXPDET#FED_FECHA_STRUCT=''''
           SELECT @FACTEXPDET#FED_RETRABAJO=(SELECT ''FED_RETRABAJO''=CASE WHEN @FACTEXP#TQ_CODIGO in (select tq_codigo from tembarque where tq_nombre = ''PRODUCTO TERMINADO (CASO ESPECIAL)'') THEN ''D'' ELSE ''N'' END)
            IF @FACTEXPDET#FED_RETRABAJO IS NULL
                SELECT @FACTEXPDET#FED_RETRABAJO=''N''
           SELECT @FACTEXPDET#TI_CODIGO=ISNULL((SELECT isnull(TI_CODIGO,0) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX),14)
            IF @FACTEXPDET#TI_CODIGO IS NULL
                SELECT @FACTEXPDET#TI_CODIGO=-10
           SELECT @FACTEXPDET#TCO_CODIGO=ISNULL((SELECT ''TCO_CODIGO''=CASE WHEN MAESTRO.MA_TIP_ENS=''A'' AND (SELECT CF_TCOCOMPRAIMP FROM CONFIGURACION)=''S'' THEN (CASE WHEN @FACTEXP#TQ_CODIGO<>16 THEN (SELECT TCO_MANUFACTURA FROM CONFIGURACION) ELSE (SELECT TCO_COMPRA FROM CONFIGURACION) END) ELSE (CASE WHEN @FACTEXP#TQ_CODIGO=8 THEN (CASE WHEN (SELECT MAX(MAC_CODIGO) FROM MAESTROCOST WHERE MA_PERINI<=@FACTEXP#FE_FECHA AND MA_PERFIN>=@FACTEXP#FE_FECHA AND MAESTROCOST.MA_CODIGO=MAESTRO.MA_CODIGO AND TCO_CODIGO=(SELECT TCO_DESPERDICIO FROM CONFIGURACION))>0 THEN (SELECT TCO_DESPERDICIO FROM CONFIGURACION) ELSE (SELECT TCO_COMPRA FROM CONFIGURACION) END) ELSE (CASE WHEN MAESTRO.MA_TIP_ENS=''F'' THEN (SELECT TCO_MANUFACTURA FROM CONFIGURACION) ELSE (SELECT TCO_COMPRA FROM CONFIGURACION) END)  END) END FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX),1)
            IF @FACTEXPDET#TCO_CODIGO IS NULL
                SELECT @FACTEXPDET#TCO_CODIGO=0
           SELECT @FACTEXPDET#SPI_CODIGO=(SELECT isnull(SPI_CODIGO,0) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#SPI_CODIGO IS NULL
                SELECT @FACTEXPDET#SPI_CODIGO=0
           SELECT @FACTEXPDET#PA_CODIGO=ISNULL((SELECT ''PA_CODIGO''=CASE WHEN MAESTRO.MA_TIP_ENS=''A'' THEN (CASE WHEN @FACTEXP#TQ_CODIGO<>16 THEN (SELECT ANEXO24.PA_ORIGENFIS FROM ANEXO24 WHERE ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO) ELSE PA_ORIGEN END) ELSE PA_ORIGEN END FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX),154)
            IF @FACTEXPDET#PA_CODIGO IS NULL
                SELECT @FACTEXPDET#PA_CODIGO=0
           SELECT @FACTEXPDET#ME_CODIGO=ISNULL((SELECT isnull(ME_COM,19) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX),19)
            IF @FACTEXPDET#ME_CODIGO IS NULL
                SELECT @FACTEXPDET#ME_CODIGO=0
           SELECT @FACTEXPDET#ME_AREXPMX=(SELECT isnull(ME_CODIGO,0) FROM ARANCEL WHERE AR_CODIGO=(SELECT AR_EXPMX FROM MAESTRO WHERE MA_INV_GEN=''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX))
            IF @FACTEXPDET#ME_AREXPMX IS NULL
                SELECT @FACTEXPDET#ME_AREXPMX=0
           SELECT @FACTEXPDET#MA_GENERICO=(SELECT ''MA_GENERICO''=CASE WHEN MAESTRO.MA_TIP_ENS=''A'' THEN (CASE WHEN @FACTEXP#TQ_CODIGO<>16 THEN (SELECT ANEXO24.MA_GENERICOFIS FROM ANEXO24 WHERE ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO) ELSE MA_GENERICO END) ELSE MA_GENERICO END FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#MA_GENERICO IS NULL
                SELECT @FACTEXPDET#MA_GENERICO=0
           SELECT @FACTEXPDET#MA_CODIGO=ISNULL((SELECT MA_CODIGO FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX),0)
            IF @FACTEXPDET#MA_CODIGO IS NULL
                SELECT @FACTEXPDET#MA_CODIGO=0
           SELECT @FACTEXPDET#FED_TIP_ENS=ISNULL((SELECT ''MA_TIP_ENS''=CASE WHEN MA_TIP_ENS=''A'' THEN (CASE WHEN @FACTEXP#TQ_CODIGO<>16 THEN ''F'' ELSE ''C'' END) ELSE MA_TIP_ENS END FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX),''F'')
            IF @FACTEXPDET#FED_TIP_ENS IS NULL
                SELECT @FACTEXPDET#FED_TIP_ENS=''''
           SELECT @FACTEXPDET#FED_SEC_IMP=(SELECT isnull(MA_SEC_IMP,0) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_SEC_IMP IS NULL
                SELECT @FACTEXPDET#FED_SEC_IMP=0
           SELECT @FACTEXPDET#AR_EXPMX=(SELECT ''AR_EXPMX''=CASE WHEN MAESTRO.MA_TIP_ENS=''A'' THEN (CASE WHEN @FACTEXP#TQ_CODIGO<>16 THEN (SELECT ANEXO24.AR_EXPMXFIS FROM ANEXO24 WHERE ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO) ELSE AR_EXPMX END) ELSE (CASE WHEN @FACTEXP#TQ_CODIGO=8 THEN AR_DESPMX ELSE AR_EXPMX END) END FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#AR_EXPMX IS NULL
                SELECT @FACTEXPDET#AR_EXPMX=0
           SELECT @FACTEXPDET#FED_POR_DEF=(SELECT dbo.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, MAESTRO.MA_DEF_TIP, MAESTRO.MA_SEC_IMP, MAESTRO.SPI_CODIGO) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_POR_DEF IS NULL
                SELECT @FACTEXPDET#FED_POR_DEF=0
           SELECT @FACTEXPDET#FED_PES_UNILB=(SELECT MA_PESO_LB FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_PES_UNILB IS NULL
                SELECT @FACTEXPDET#FED_PES_UNILB=0
           SELECT @FACTEXPDET#FED_PES_UNI=(SELECT MA_PESO_KG FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_PES_UNI IS NULL
                SELECT @FACTEXPDET#FED_PES_UNI=0
           SELECT @FACTEXPDET#FED_NG_USA=(SELECT MA_NG_USA FROM MAESTROCOST INNER JOIN MAESTRO ON MAESTROCOST.MA_CODIGO=MAESTRO.MA_CODIGO WHERE MAESTROCOST.MA_PERINI <=GETDATE() AND MAESTROCOST.MA_PERFIN >=GETDATE() AND MAESTROCOST.SPI_CODIGO IN (SELECT PAIS.SPI_CODIGO FROM DIR_CLIENTE INNER JOIN PAIS ON DIR_CLIENTE.PA_CODIGO = PAIS.PA_CODIGO INNER JOIN FACTEXP ON DIR_CLIENTE.DI_INDICE=FACTEXP.DI_DESTFIN WHERE FACTEXP.FE_CODIGO=@CONSECUTIVO) AND  MA_INV_GEN=''I'' AND MAESTRO.MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MAESTRO.MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX AND MAESTROCOST.TCO_CODIGO=@FACTEXPDET#TCO_CODIGO)
            IF @FACTEXPDET#FED_NG_USA IS NULL
                SELECT @FACTEXPDET#FED_NG_USA=0
           SELECT @FACTEXPDET#FED_NG_ADD=(SELECT MA_NG_ADD FROM MAESTROCOST INNER JOIN MAESTRO ON MAESTROCOST.MA_CODIGO=MAESTRO.MA_CODIGO WHERE MAESTROCOST.MA_PERINI <=GETDATE() AND MAESTROCOST.MA_PERFIN >=GETDATE() AND MAESTROCOST.SPI_CODIGO IN(SELECT PAIS.SPI_CODIGO FROM DIR_CLIENTE INNER JOIN PAIS ON DIR_CLIENTE.PA_CODIGO = PAIS.PA_CODIGO INNER JOIN FACTEXP ON DIR_CLIENTE.DI_INDICE=FACTEXP.DI_DESTFIN WHERE FACTEXP.FE_CODIGO=@CONSECUTIVO) AND MA_INV_GEN=''I'' AND MAESTRO.MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MAESTRO.MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX AND MAESTROCOST.TCO_CODIGO=@FACTEXPDET#TCO_CODIGO)
            IF @FACTEXPDET#FED_NG_ADD IS NULL
                SELECT @FACTEXPDET#FED_NG_ADD=0
           SELECT @FACTEXPDET#FED_NAFTA=(SELECT dbo.GetNafta(@FACTEXP#FE_FECHA, Maestro.ma_codigo, @FACTEXPDET#AR_EXPMX, @FACTEXPDET#PA_CODIGO, Maestro.ma_def_tip, @FACTEXPDET#FED_TIP_ENS) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_NAFTA IS NULL
                SELECT @FACTEXPDET#FED_NAFTA=''N''
           SELECT @FACTEXPDET#FED_GRA_ADD=(SELECT MA_GRAV_ADD FROM MAESTROCOST INNER JOIN MAESTRO ON MAESTROCOST.MA_CODIGO=MAESTRO.MA_CODIGO WHERE MAESTROCOST.MA_PERINI <=GETDATE() AND MAESTROCOST.MA_PERFIN >=GETDATE() AND MAESTROCOST.SPI_CODIGO IN (SELECT PAIS.SPI_CODIGO FROM DIR_CLIENTE INNER JOIN PAIS ON DIR_CLIENTE.PA_CODIGO = PAIS.PA_CODIGO INNER JOIN FACTEXP ON DIR_CLIENTE.DI_INDICE=FACTEXP.DI_DESTFIN WHERE FACTEXP.FE_CODIGO=@CONSECUTIVO) AND  MA_INV_GEN=''I'' AND MAESTRO.MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MAESTRO.MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX AND MAESTROCOST.TCO_CODIGO=@FACTEXPDET#TCO_CODIGO)
            IF @FACTEXPDET#FED_GRA_ADD IS NULL
                SELECT @FACTEXPDET#FED_GRA_ADD=0
           SELECT @FACTEXPDET#FED_DISCHARGE=(SELECT MA_DISCHARGE FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_DISCHARGE IS NULL
                SELECT @FACTEXPDET#FED_DISCHARGE=''S''
           SELECT @FACTEXPDET#FED_DEF_TIP=(SELECT isnull(MA_DEF_TIP,''G'')  FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_DEF_TIP IS NULL
                SELECT @FACTEXPDET#FED_DEF_TIP=''''
           SELECT @FACTEXPDET#EQ_IMPFO=(SELECT isnull(EQ_IMPFO,1) FROM MAESTRO WHERE MA_INV_GEN=''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#EQ_IMPFO IS NULL
                SELECT @FACTEXPDET#EQ_IMPFO=-1
           SELECT @FACTEXPDET#EQ_GEN=(SELECT isnull(EQ_GEN,1) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#EQ_GEN IS NULL
                SELECT @FACTEXPDET#EQ_GEN=-1
           SELECT @FACTEXPDET#EQ_EXPMX=(SELECT isnull(EQ_EXPMX,1) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#EQ_EXPMX IS NULL
                SELECT @FACTEXPDET#EQ_EXPMX=-1
           SELECT @FACTEXPDET#CS_CODIGO=(SELECT CS_CODIGO FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#CS_CODIGO IS NULL
                SELECT @FACTEXPDET#CS_CODIGO=-8
           SELECT @FACTEXPDET#CL_CODIGO=(SELECT CL_MATRIZ FROM CLIENTE WHERE CL_EMPRESA=''S'')
            IF @FACTEXPDET#CL_CODIGO IS NULL
                SELECT @FACTEXPDET#CL_CODIGO=0
           SELECT @FACTEXPDET#AR_IMPMX=(SELECT isnull(AR_IMPMX,0) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#AR_IMPMX IS NULL
                SELECT @FACTEXPDET#AR_IMPMX=0
           SELECT @FACTEXPDET#AR_IMPFO=(SELECT ''AR_IMPFO''=CASE WHEN @FACTEXP#TQ_CODIGO=8 THEN MAESTRO.AR_DESP ELSE (CASE WHEN MAESTRO.MA_TIP_ENS=''A'' THEN (CASE WHEN @FACTEXP#TQ_CODIGO<>16 THEN (SELECT ANEXO24.AR_IMPFOFIS FROM ANEXO24 WHERE ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO) ELSE AR_IMPFO END) ELSE (CASE WHEN @FACTEXPDET#FED_NAFTA=''S'' AND isnull((dbo.Get9801(@FACTEXP#FE_FECHA, MAESTRO.MA_CODIGO, @FACTEXPDET#AR_EXPMX, @FACTEXPDET#PA_CODIGO, MAESTRO.MA_DEF_TIP)),''N'')=''S'' AND CONFIGURATIPO.CFT_TIPO NOT IN (''P'',''S'') THEN ISNULL(MAESTRO.AR_IMPFOUSA,MAESTRO.AR_IMPFO) ELSE MAESTRO.AR_IMPFO END) END) END FROM MAESTRO LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#AR_IMPFO IS NULL
                SELECT @FACTEXPDET#AR_IMPFO=0
           SELECT @FACTEXPDET#AR_ORIG=(SELECT case when @FACTEXPDET#FED_NAFTA=''S'' or CONFIGURATIPO.CFT_TIPO NOT IN (''P'',''S'') or @FACTEXPDET#FED_NG_USA=0 then 0 else ( case when isnull((select max(ar_codigo)  from bom_arancel where ba_tipocosto=''N'' and bom_arancel.ma_codigo=maestro.ma_codigo),0)=0 then  isnull(AR_IMPFOUSA,0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto=''N'' and bom_arancel.ma_codigo=maestro.ma_codigo),0) end) end FROM MAESTRO LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#AR_ORIG IS NULL
                SELECT @FACTEXPDET#AR_ORIG=0
           SELECT @FACTEXPDET#AR_NG_EMP=(SELECT case when @FACTEXPDET#FED_NAFTA=''S'' or @FACTEXPDET#FED_NG_EMP=0 then 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto=''3'' and bom_arancel.ma_codigo=maestro.ma_codigo),0) end FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#AR_NG_EMP IS NULL
                SELECT @FACTEXPDET#AR_NG_EMP=0
           SELECT @FACTEXPDET#FED_RATEIMPFO=(SELECT dbo.GetAdvalorem(@FACTEXPDET#AR_IMPFO, @FACTEXPDET#PA_CODIGO, (CASE WHEN @FACTEXPDET#FED_NAFTA=''S'' THEN ''P'' ELSE ''G'' END), 0, 0) FROM MAESTRO WHERE MA_INV_GEN = ''I'' AND MA_NOPARTE=@FACTEXPDET#FED_NOPARTE AND MA_NOPARTEAUX=@FACTEXPDET#FED_NOPARTEAUX)
            IF @FACTEXPDET#FED_RATEIMPFO IS NULL
                SELECT @FACTEXPDET#FED_RATEIMPFO=0
           SELECT @FACTEXPDET#ME_GENERICO=(SELECT isnull(ME_COM,0) FROM MAESTRO WHERE MA_CODIGO=@FACTEXPDET#MA_GENERICO)
            IF @FACTEXPDET#ME_GENERICO IS NULL
                SELECT @FACTEXPDET#ME_GENERICO=0
          EXEC SP_GETCONSECUTIVO @TIPO=''FED'',@VALUE=@CONSDET OUTPUT
                INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_COS_TOT ,FED_PES_BRU ,FED_PES_BRULB ,FED_PES_NET ,FED_PES_NETLB ,FED_NOMBRE ,FED_NAME ,FED_COS_UNI ,FED_GRA_EMP ,FED_NG_EMP ,FED_GRA_GI_MX ,FED_GRA_GI ,FED_GRA_MO ,FED_GRA_MP ,FED_NG_MP ,FED_NOPARTEAUX ,FED_CANTEMP ,FED_NOPARTE ,MA_EMPAQUE ,FED_CANT ,FED_PARTTYPE ,MA_STRUCT ,SE_CODIGO ,FED_FECHA_STRUCT ,FED_RETRABAJO ,TI_CODIGO ,TCO_CODIGO ,SPI_CODIGO ,PA_CODIGO ,ME_CODIGO ,ME_AREXPMX ,MA_GENERICO ,MA_CODIGO ,FED_TIP_ENS ,FED_SEC_IMP ,AR_EXPMX ,FED_POR_DEF ,FED_PES_UNILB ,FED_PES_UNI ,FED_NG_USA ,FED_NG_ADD ,FED_NAFTA ,FED_GRA_ADD ,FED_DISCHARGE ,FED_DEF_TIP ,EQ_IMPFO ,EQ_GEN ,EQ_EXPMX ,CS_CODIGO ,CL_CODIGO ,AR_IMPMX ,AR_IMPFO ,AR_ORIG ,AR_NG_EMP ,FED_RATEIMPFO ,ME_GENERICO ) VALUES (@CONSDET,@CONSECUTIVO,@FACTEXPDET#FED_COS_TOT ,@FACTEXPDET#FED_PES_BRU ,@FACTEXPDET#FED_PES_BRULB ,@FACTEXPDET#FED_PES_NET ,@FACTEXPDET#FED_PES_NETLB ,@FACTEXPDET#FED_NOMBRE ,@FACTEXPDET#FED_NAME ,@FACTEXPDET#FED_COS_UNI ,@FACTEXPDET#FED_GRA_EMP ,@FACTEXPDET#FED_NG_EMP ,@FACTEXPDET#FED_GRA_GI_MX ,@FACTEXPDET#FED_GRA_GI ,@FACTEXPDET#FED_GRA_MO ,@FACTEXPDET#FED_GRA_MP ,@FACTEXPDET#FED_NG_MP ,@FACTEXPDET#FED_NOPARTEAUX ,@FACTEXPDET#FED_CANTEMP ,@FACTEXPDET#FED_NOPARTE ,@FACTEXPDET#MA_EMPAQUE ,@FACTEXPDET#FED_CANT ,@FACTEXPDET#FED_PARTTYPE,@FACTEXPDET#MA_STRUCT,@FACTEXPDET#SE_CODIGO,@FACTEXPDET#FED_FECHA_STRUCT,@FACTEXPDET#FED_RETRABAJO,@FACTEXPDET#TI_CODIGO,@FACTEXPDET#TCO_CODIGO,@FACTEXPDET#SPI_CODIGO,@FACTEXPDET#PA_CODIGO,@FACTEXPDET#ME_CODIGO,@FACTEXPDET#ME_AREXPMX,@FACTEXPDET#MA_GENERICO,@FACTEXPDET#MA_CODIGO,@FACTEXPDET#FED_TIP_ENS,@FACTEXPDET#FED_SEC_IMP,@FACTEXPDET#AR_EXPMX,@FACTEXPDET#FED_POR_DEF,@FACTEXPDET#FED_PES_UNILB,@FACTEXPDET#FED_PES_UNI,@FACTEXPDET#FED_NG_USA,@FACTEXPDET#FED_NG_ADD,@FACTEXPDET#FED_NAFTA,@FACTEXPDET#FED_GRA_ADD,@FACTEXPDET#FED_DISCHARGE,@FACTEXPDET#FED_DEF_TIP,@FACTEXPDET#EQ_IMPFO,@FACTEXPDET#EQ_GEN,@FACTEXPDET#EQ_EXPMX,@FACTEXPDET#CS_CODIGO,@FACTEXPDET#CL_CODIGO,@FACTEXPDET#AR_IMPMX,@FACTEXPDET#AR_IMPFO,@FACTEXPDET#AR_ORIG,@FACTEXPDET#AR_NG_EMP,@FACTEXPDET#FED_RATEIMPFO,@FACTEXPDET#ME_GENERICO)
              update FACTEXPDET set FED_COS_TOT = isnull(( VMAESTROCOST$5254_1.MA_COSTO*@Col_7 ),0)
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_PES_BRU = ( MAESTRO$404_1.MA_PESO_KG*dbo.StrToFloat(@Col_7) )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_PES_BRULB = ( MAESTRO$404_1.MA_PESO_KG*dbo.StrToFloat(@Col_7) )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_PES_NET = ( MAESTRO$404_1.MA_PESO_LB*dbo.StrToFloat(@Col_7) )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_PES_NETLB = ( MAESTRO$404_1.MA_PESO_LB*dbo.StrToFloat(@Col_7) )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_NOMBRE = ( MAESTRO$404_1.MA_NOMBRE )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_NAME = ( MAESTRO$404_1.MA_NAME )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_COS_UNI = ( VMAESTROCOST$5254_1.MA_COSTO )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_GRA_EMP = ( VMAESTROCOST$5254_1.MA_GRAV_EMP )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_NG_EMP = ( VMAESTROCOST$5254_1.MA_NG_EMP )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_GRA_GI_MX = ( VMAESTROCOST$5254_1.MA_GRAV_GI_MX )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_GRA_GI = ( VMAESTROCOST$5254_1.MA_GRAV_GI )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_GRA_MO = ( VMAESTROCOST$5254_1.MA_GRAV_MO )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_GRA_MP = ( VMAESTROCOST$5254_1.MA_GRAV_MP )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
              update FACTEXPDET set FED_NG_MP = ( VMAESTROCOST$5254_1.MA_NG_MP )
              from FACTEXPDET
              left outer join FACTEXP on  
             FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
			LEFT OUTER JOIN MAESTRO MAESTRO$404_1 ON FACTEXPDET.FED_NOPARTE = MAESTRO$404_1.MA_NOPARTE
			LEFT OUTER JOIN VMAESTROCOST VMAESTROCOST$5254_1 ON MAESTRO$404_1.MA_CODIGO = VMAESTROCOST$5254_1.MA_CODIGO
              where FACTEXPDET.FED_INDICED = @CONSDET
            FETCH NEXT FROM CUR_TEMPIMPORT162_1DET INTO @Col_7 ,@Cod_3 ,@Cod_5 ,@FACTEXPDET#FED_COS_TOT ,@FACTEXPDET#FED_PES_BRU ,@FACTEXPDET#FED_PES_BRULB ,@FACTEXPDET#FED_PES_NET ,@FACTEXPDET#FED_PES_NETLB ,@FACTEXPDET#FED_NOMBRE ,@FACTEXPDET#FED_NAME ,@FACTEXPDET#FED_COS_UNI ,@FACTEXPDET#FED_GRA_EMP ,@FACTEXPDET#FED_NG_EMP ,@FACTEXPDET#FED_GRA_GI_MX ,@FACTEXPDET#FED_GRA_GI ,@FACTEXPDET#FED_GRA_MO ,@FACTEXPDET#FED_GRA_MP ,@FACTEXPDET#FED_NG_MP ,@FACTEXPDET#FED_NOPARTEAUX ,@FACTEXPDET#FED_CANTEMP ,@FACTEXPDET#FED_NOPARTE ,@FACTEXPDET#MA_EMPAQUE ,@FACTEXPDET#FED_CANT 
                      
        END
        CLOSE CUR_TEMPIMPORT162_1DET
        DEALLOCATE CUR_TEMPIMPORT162_1DET
  END
  FETCH NEXT FROM CUR_TEMPIMPORT162_1 INTO @Col_7 ,@Cod_3 ,@Cod_5 ,@FACTEXP#FE_TIPO ,@FACTEXP#TQ_CODIGO ,@FACTEXP#TF_CODIGO ,@FACTEXP#FE_FOLIO 
END
CLOSE CUR_TEMPIMPORT162_1
DEALLOCATE CUR_TEMPIMPORT162_1')

exec('
declare @fed_indiced int, @fe_codigo int, @CONSCONT int, @inserto int, @fed_noparte varchar(150)
set @inserto = 0
declare cur_factexp cursor for
select fed_indiced, factexpdet.fe_codigo, factexpdet.fed_noparte
from factexp 
	left outer join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo
where fe_folio IN (select FACTEXP'+@USER+'#FE_FOLIO from '+@TABLA+')
open cur_factexp
FETCH NEXT FROM cur_factexp INTO @fed_indiced, @fe_codigo, @fed_noparte
WHILE (@@FETCH_STATUS = 0)
BEGIN

   EXEC SP_GETCONSECUTIVO @TIPO=''FEC'',@VALUE=@CONSCONT OUTPUT
   INSERT INTO FACTEXPCONT (FE_CODIGO,FED_INDICED,FEC_INDICEC,FEC_SERIE ) 
	select top 1 factexp.FE_CODIGO, @fed_indiced,@CONSCONT, factexpcont'+@USER+'#fec_serie
	from '+@TABLA+' 
		left outer join factexp	on '+@TABLA+'.FACTEXP'+@USER+'#FE_FOLIO = FACTEXP.FE_FOLIO
	where factexpcont'+@USER+'#fec_serie not in (select FEC_SERIE from FACTEXPCONT where FACTEXP.FE_CODIGO = FACTEXPCONT.FE_CODIGO)
		and factexpdet'+@USER+'#fed_noparte = @fed_noparte
		
	IF @@ROWCOUNT > 0 AND @inserto = 0
		begin
		   INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO,RI_TIPO,RI_CBFORMA, RI_USERID) 
		   VALUES (''CONTENIDO (SERIE)'',''I'',20,'+@USER+') 
		   set @inserto = 1
		end
	
	FETCH NEXT FROM cur_factexp INTO @fed_indiced, @fe_codigo, @fed_noparte
END
close cur_factexp
deallocate cur_factexp')
GO
