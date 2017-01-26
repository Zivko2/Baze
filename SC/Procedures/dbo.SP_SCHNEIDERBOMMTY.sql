SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_SCHNEIDERBOMMTY] (@BorraLogImporta char(1)='S')   as


/*

if exists (select * from sysobjects where id = object_id(N'[estintMty]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE estintMty

CREATE TABLE [dbo].[estintMty] (
	[CONSECUTIVO] [int] IDENTITY (1, 1) NOT NULL ,
	[ValorArroba] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NumPadre] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NumHijo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SecuenciaArch] [varchar] (3) NULL ,
	[FechaIni] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FechaFin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Cantidad] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ValorNum] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Secuencia] [int] NULL ,
	[ME_CODIGO] [int] NULL 
) ON [PRIMARY]



if exists (select * from sysobjects where id = object_id(N'[REGISTROSIMPORTSCH]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE REGISTROSIMPORTSCH

CREATE TABLE [dbo].[REGISTROSIMPORTSCH] (
	[REGISTRO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]


*/
 if @BorraLogImporta='S'
 TRUNCATE TABLE REGISTROSIMPORTSCH

UPDATE estintMty
SET SECUENCIA=0


UPDATE estintMty
SET ME_CODIGO=ISNULL((SELECT ME_CODIGO FROM MEDIDAAMAPS WHERE ME_AMAPS=estintMty.[UM]),19)
WHERE estintMty.ME_CODIGO IS NULL

UPDATE estintMty
SET FechaFin='99990101'
WHERE FechaFin='          ' OR FechaFin='00000000'

/*
UPDATE estintMty
SET     FechaIni =REPLACE(FechaIni,'29','28')
FROM         estintMty
WHERE     ((RIGHT(LEFT(FechaIni, 5), 2) = '29') and LEFT(FechaIni, 2)='02') 
AND (RIGHT(FechaIni, 4) <> '2000' 
AND RIGHT(FechaIni, 4) <> '2004' 
AND RIGHT(FechaIni, 4) <> '2008'
AND RIGHT(FechaIni, 4) <> '2012'
AND RIGHT(FechaIni, 4) <> '1996' 
AND RIGHT(FechaIni, 4) <> '1992'
AND RIGHT(FechaIni, 4) <> '1988')



UPDATE estintMty
SET     FechaFin =REPLACE(FechaFin,'29','28')
FROM         estintMty
WHERE     ((RIGHT(LEFT(FechaFin, 5), 2) = '29') and LEFT(FechaFin, 2)='02') 
AND (RIGHT(FechaFin, 4) <> '2000' 
AND RIGHT(FechaFin, 4) <> '2004' 
AND RIGHT(FechaFin, 4) <> '2008'
AND RIGHT(FechaFin, 4) <> '2012'
AND RIGHT(FechaFin, 4) <> '1996' 
AND RIGHT(FechaFin, 4) <> '1992'
AND RIGHT(FechaFin, 4) <> '1988')*/

Declare @X Int,@POS Varchar(100)


		Select Consecutivo, ltrim(rtrim([NumPadre])) AS NumPadre, secuencia
		Into dbo.[#Temps] 
		From estintMty 
		where secuencia =0
		Order by Consecutivo


		SET @X=0
		SET @POS=''

		Update #Temps 
		SET secuencia=@X,@X=CASE WHEN @POS = ltrim(rtrim([NumPadre])) THEN @X+1 ELSE 1 END,
                                  @POS=CASE WHEN @POS = ltrim(rtrim([NumPadre])) THEN @POS ELSE ltrim(rtrim([NumPadre])) END
	
		
		Update estintMty 
		SET secuencia=T.secuencia 
		From #Temps T inner join estintMty on T.Consecutivo=estintMty.Consecutivo

/* anexion de registros faltantes al cat. maestro */


		exec Sp_GeneraTablaTemp 'MAESTRO'



		DECLARE @CONSECUTIVO INT
--		SELECT @CONSECUTIVO=isnull((select max(MA_CODIGO) from MAESTRO),0) + 1
		select @CONSECUTIVO=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'

		DBCC CHECKIDENT(TempImportMAESTRO, RESEED, @CONSECUTIVO) WITH NO_INFOMSGS


		INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

		SELECT 'I', 'F', RTRIM(LTRIM([NumPadre])), 16, 'TEMP', 'TEMP (SUBENSAMBLE EN BOM)', 19, 154, 154, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0), 
		isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0), 'N'
		FROM estintMty 
		WHERE RTRIM(LTRIM([NumPadre])) NOT IN (SELECT RTRIM(LTRIM(MA_NOPARTE)) FROM MAESTRO WHERE MA_INV_GEN='I' UNION
							        SELECT RTRIM(LTRIM(MA_NOPARTE)) FROM MAESTROREFER)
		GROUP BY [NumPadre]


		INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

		SELECT 'I', 'C', RTRIM(LTRIM(NumHijo)), 10, 'TEMP', 'TEMP (COMPONENTE EN BOM)', 19, 233, 233, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0), 
		isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0), 'S'
		FROM estintMty 
		WHERE RTRIM(LTRIM(NumHijo)) NOT IN (SELECT RTRIM(LTRIM(MA_NOPARTE)) FROM MAESTRO WHERE MA_INV_GEN='I' UNION
							   SELECT RTRIM(LTRIM(MA_NOPARTE)) FROM MAESTROREFER)
		AND NumHijo NOT IN (SELECT MA_NOPARTE FROM TempImportMAESTRO)
		GROUP BY NumHijo


		INSERT INTO MAESTRO(MA_CODIGO, MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_ULTIMAMODIF, MA_DISCHARGE)

		SELECT MA_CODIGO, MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, GETDATE(), MA_DISCHARGE
		FROM TempImportMAESTRO

		declare @maximo int

		select @maximo= max(MA_CODIGO) from MAESTRO

		if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@maximo
		select @maximo= isnull(max(MA_CODIGO),0) from MAESTROREFER

		update consecutivo
		set cv_codigo =  @maximo + 1
		where cv_tipo = 'MA'
 
---------------------------------------------

ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [DELETE_BOM_STRUCT]
ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [INSERT_BOM_STRUCT]

delete from bom_struct where bsu_noparte in 
(SELECT     [NumPadre]
FROM         estintMty
GROUP BY [NumPadre])




	if (select count(*) from estintMty)>20000
	begin
		declare @valor int, @contador int, @valorini int, @valorfin int


		select @valor= round((max(consecutivo)/20),0)+1 from estintMty
		set @contador=1
		select @valorini =min(consecutivo) from estintMty			
	
		WHILE (@contador<=20) 
		BEGIN				
			set @valorfin=@valorini+@valor

			INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			                      BSU_NOPARTE, BST_NOPARTE, BST_TIP_ENS, BST_SEC)
			
			SELECT     ISNULL(MAESTRO.MA_CODIGO,MAESTROREFER.MA_CODIGO), ISNULL(MAESTRO_1.MA_CODIGO,MAESTROREFER_1.MA_CODIGO), estintMty.Cantidad, 
				ISNULL(MAESTRO_1.MA_DISCHARGE,'N'), estintMty.ME_CODIGO, 
			             ISNULL(ISNULL(MAESTRO_1.EQ_GEN,MAESTROREFER_1.EQ_GEN),1), estintMty.[FechaIni], estintMty.[FechaFin], 
				ISNULL(MAESTRO_2.ME_COM,19), ISNULL(MAESTRO.MA_NOPARTE, MAESTROREFER.MA_NOPARTE), ISNULL(MAESTRO_1.MA_NOPARTE,MAESTROREFER_1.MA_NOPARTE), 
				CASE WHEN ISNULL(MAESTRO_1.MA_TIP_ENS,MAESTROREFER_1.MA_TIP_ENS)='A' THEN 'F' ELSE ISNULL(MAESTRO_1.MA_TIP_ENS,MAESTROREFER_1.MA_TIP_ENS) END, estintMty.SECUENCIA
			FROM         estintMty LEFT OUTER JOIN
			                      MAESTRO ON estintMty.[NumPadre] = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
			                      MAESTRO MAESTRO_1 ON estintMty.NumHijo = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
			                      MAESTRO MAESTRO_2 ON MAESTRO_1.MA_GENERICO = MAESTRO_2.MA_CODIGO LEFT OUTER JOIN
			                      MAESTROREFER ON estintMty.[NumPadre] = MAESTROREFER.MA_NOPARTE LEFT OUTER JOIN
			                      MAESTROREFER MAESTROREFER_1 ON estintMty.NumHijo = MAESTROREFER_1.MA_NOPARTE
			where estintMty.CONSECUTIVO>=@valorini and estintMty.CONSECUTIVO<=@valorfin

			set @contador=@contador+1
			set @valorini=@valorfin+1
	
		END				
	
	end
	else
	INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
	                      BSU_NOPARTE, BST_NOPARTE, BST_TIP_ENS, BST_SEC)

	SELECT     ISNULL(MAESTRO.MA_CODIGO,MAESTROREFER.MA_CODIGO), ISNULL(MAESTRO_1.MA_CODIGO,MAESTROREFER_1.MA_CODIGO), estintMty.Cantidad, 
		   ISNULL(MAESTRO_1.MA_DISCHARGE,'N'), estintMty.ME_CODIGO, 
	                      ISNULL(ISNULL(MAESTRO_1.EQ_GEN,MAESTROREFER_1.EQ_GEN),1), estintMty.[FechaIni], estintMty.[FechaFin], 
				ISNULL(MAESTRO_2.ME_COM,19), ISNULL(MAESTRO.MA_NOPARTE, MAESTROREFER.MA_NOPARTE), ISNULL(MAESTRO_1.MA_NOPARTE,MAESTROREFER_1.MA_NOPARTE), 
	                CASE WHEN ISNULL(MAESTRO_1.MA_TIP_ENS,MAESTROREFER_1.MA_TIP_ENS)='A' THEN 'F' ELSE ISNULL(MAESTRO_1.MA_TIP_ENS,MAESTROREFER_1.MA_TIP_ENS) END, 
			estintMty.SECUENCIA
	FROM         estintMty LEFT OUTER JOIN
	                      MAESTRO ON estintMty.[NumPadre] = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
	                      MAESTRO MAESTRO_1 ON estintMty.NumHijo = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
	                      MAESTRO MAESTRO_2 ON MAESTRO_1.MA_GENERICO = MAESTRO_2.MA_CODIGO LEFT OUTER JOIN
	                      MAESTROREFER ON estintMty.[NumPadre] = MAESTROREFER.MA_NOPARTE LEFT OUTER JOIN
	                      MAESTROREFER MAESTROREFER_1 ON estintMty.NumHijo = MAESTROREFER_1.MA_NOPARTE 



	exec SP_ACTUALIZAEQBOM

ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [DELETE_BOM_STRUCT]
ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [INSERT_BOM_STRUCT]



		--print 'Inserta en la tabla registros importados'
	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registro agregado, Padre= '+rtrim(BOM_STRUCT.BSU_NOPARTE)+' Componente= '+rtrim(BOM_STRUCT.BST_NOPARTE)+'('+convert(varchar(10),BOM_STRUCT.BST_PERINI,101)+','+convert(varchar(10),BOM_STRUCT.BST_PERFIN,101)+')'
		FROM estintMty INNER JOIN BOM_STRUCT ON rtrim(estintMty.NumPadre)+'-'+rtrim(estintMty.NumHijo)+'-'+convert(varchar(10),convert(datetime,estintMty.FechaIni),101)+'-'+convert(varchar(10),convert(datetime,estintMty.FechaFin),101)+'-'+convert(varchar(10),estintMty.SECUENCIA) =
		rtrim(BOM_STRUCT.BSU_NOPARTE)+'-'+rtrim(BOM_STRUCT.BST_NOPARTE)+'-'+convert(varchar(10),BOM_STRUCT.BST_PERINI,101)+'-'+convert(varchar(10),BOM_STRUCT.BST_PERFIN,101)+'-'+convert(varchar(10),BOM_STRUCT.BST_SEC)



	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registro NO agregado, Padre= '+rtrim(estintMty.NumPadre)+' Componente= '+rtrim(estintMty.NumHijo)+'('+estintMty.FechaIni+','+estintMty.FechaFin+')'
		FROM estintMty 
		WHERE rtrim(estintMty.NumPadre)+'-'+rtrim(estintMty.NumHijo)+'-'+convert(varchar(10),convert(datetime,estintMty.FechaIni),101)+'-'+convert(varchar(10),convert(datetime,estintMty.FechaFin),101)+'-'+convert(varchar(10),estintMty.SECUENCIA) NOT IN 
		(SELECT rtrim(BSU_NOPARTE)+'-'+rtrim(BST_NOPARTE)+'-'+convert(varchar(10),BST_PERINI,101)+'-'+convert(varchar(10),BST_PERFIN,101)+'-'+convert(varchar(10),BST_SEC) FROM BOM_STRUCT)
		

	     	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registros agregados: '+convert(varchar(10),COUNT(*))
		FROM REGISTROSIMPORTSCH where REGISTRO like 'Registro agregado, Padre=%' 

	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registros rechazados: '+convert(varchar(10),COUNT(*))
		FROM REGISTROSIMPORTSCH where REGISTRO like 'Registro NO agregado, Padre=%'

	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Fecha ejecucion: '+convert(varchar(20),getdate())

GO
