SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[SP_SCHNEIDERBOMTIJ] (@BorraLogImporta char(1)='S')   as


/*

if exists (select * from sysobjects where id = object_id(N'[estintTijtij]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE estintTijtij

CREATE TABLE [dbo].[estintTijtij] (
	[CONSECUTIVO] [int] IDENTITY (1, 1) NOT NULL ,
	[NumPadre] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NumHijo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Cantidad] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CantDesp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FacConvGpo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FechaIni] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FechaFin] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UM] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SeDescarga?] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Sec] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UMComp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UMGenerico] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SECUENCIA] [int] NULL 
) ON [PRIMARY]



if exists (select * from sysobjects where id = object_id(N'[REGISTROSIMPORTSCH]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE REGISTROSIMPORTSCH

CREATE TABLE [dbo].[REGISTROSIMPORTSCH] (
	[REGISTRO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]


*/
 if @BorraLogImporta='S'
 TRUNCATE TABLE REGISTROSIMPORTSCH

UPDATE estintTij
SET SECUENCIA=0

UPDATE estintTij
SET FechaFin='01/01/9999'
WHERE FechaFin='          ' OR FechaFin='00000000'


UPDATE estinttij
SET     FechaIni =REPLACE(FechaIni,'29','28')
FROM         estinttij
WHERE     ((RIGHT(LEFT(FechaIni, 5), 2) = '29') and LEFT(FechaIni, 2)='02') 
AND (RIGHT(FechaIni, 4) <> '2000' 
AND RIGHT(FechaIni, 4) <> '2004' 
AND RIGHT(FechaIni, 4) <> '2008'
AND RIGHT(FechaIni, 4) <> '2012'
AND RIGHT(FechaIni, 4) <> '1996' 
AND RIGHT(FechaIni, 4) <> '1992'
AND RIGHT(FechaIni, 4) <> '1988')



UPDATE estinttij
SET     FechaFin =REPLACE(FechaFin,'29','28')
FROM         estinttij
WHERE     ((RIGHT(LEFT(FechaFin, 5), 2) = '29') and LEFT(FechaFin, 2)='02') 
AND (RIGHT(FechaFin, 4) <> '2000' 
AND RIGHT(FechaFin, 4) <> '2004' 
AND RIGHT(FechaFin, 4) <> '2008'
AND RIGHT(FechaFin, 4) <> '2012'
AND RIGHT(FechaFin, 4) <> '1996' 
AND RIGHT(FechaFin, 4) <> '1992'
AND RIGHT(FechaFin, 4) <> '1988')

Declare @X Int,@POS Varchar(100)

		Select Consecutivo,[NumPadre], secuencia
		Into dbo.[#Temps] 
		From estintTij 
		where secuencia =0
		Order by Consecutivo


		SET @X=0
		SET @POS=''

		Update #Temps 
		SET secuencia=@X,@X=CASE WHEN @POS = [NumPadre] THEN @X+1 ELSE 1 END,
                                  @POS=CASE WHEN @POS = [NumPadre] THEN @POS ELSE [NumPadre] END
	
		
		Update estintTij 
		SET secuencia=T.secuencia 
		From #Temps T inner join estintTij on T.Consecutivo=estintTij.Consecutivo

/* anexion de registros faltantes al cat. maestro */


		exec Sp_GeneraTablaTemp 'MAESTRO'



		DECLARE @CONSECUTIVO INT
		select @CONSECUTIVO=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'

		DBCC CHECKIDENT(TempImportMAESTRO, RESEED, @CONSECUTIVO) WITH NO_INFOMSGS


		INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

		SELECT 'I', 'F', [NumPadre], 16, 'TEMP', 'TEMP (SUBENSAMBLE EN BOM)', 19, 154, 154, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), 
		isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), isnull(max([SeDescarga?]),'N')
		FROM estintTij 
		WHERE RTRIM(LTRIM([NumPadre])) NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='I')
		GROUP BY [NumPadre]


		INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

		SELECT 'I', 'C', NumHijo, 10, 'TEMP', 'TEMP (COMPONENTE EN BOM)', 19, 233, 233, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), 
		isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), isnull(max([SeDescarga?]),'S')
		FROM estintTij 
		WHERE RTRIM(LTRIM(NumHijo)) NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='I')
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
		set cv_codigo =  @maximo +1
		where cv_tipo = 'MA'
 
---------------------------------------------

ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [DELETE_BOM_STRUCT]
ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [INSERT_BOM_STRUCT]

delete from bom_struct where bsu_noparte in 
(SELECT     [NumPadre]
FROM         estintTij
GROUP BY [NumPadre])




	if (select count(*) from estintTij)>20000
	begin
		declare @valor int, @contador int, @valorini int, @valorfin int


		select @valor= round((max(consecutivo)/20),0)+1 from estintTij
		set @contador=1
		select @valorini =min(consecutivo) from estintTij			
	
		WHILE (@contador<=20) 
		BEGIN				
			set @valorfin=@valorini+@valor

			INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			                      BSU_NOPARTE, BST_NOPARTE, BST_TIP_ENS, BST_SEC)
			
			SELECT     MAESTRO.MA_CODIGO, MAESTRO_1.MA_CODIGO, estintTij.Cantidad, MAESTRO_1.MA_DISCHARGE, MAESTRO_1.ME_COM, 
			                      ISNULL(MAESTRO_1.EQ_GEN,1), estintTij.[FechaIni], --left(right(estintTij.[FechaIni],4),2)+'/'+right(estintTij.[FechaIni],2)+'/'+left(estintTij.[FechaIni],4), 
						estintTij.[FechaFin], --left(right(estintTij.[FechaFin],4),2)+'/'+right(estintTij.[FechaFin],2)+'/'+left(estintTij.[FechaFin],4), 
						ISNULL(MAESTRO_2.ME_COM,19), MAESTRO.MA_NOPARTE, MAESTRO_1.MA_NOPARTE, 
						CASE WHEN MAESTRO_1.MA_TIP_ENS='A' THEN 'F' ELSE MAESTRO_1.MA_TIP_ENS END, estintTij.SECUENCIA
			FROM         estintTij INNER JOIN
			                      MAESTRO ON estintTij.[NumPadre] = MAESTRO.MA_NOPARTE INNER JOIN
			                      MAESTRO MAESTRO_1 ON estintTij.NumHijo = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
			                      MAESTRO MAESTRO_2 ON MAESTRO_1.MA_GENERICO = MAESTRO_2.MA_CODIGO
			where estintTij.CONSECUTIVO>=@valorini and estintTij.CONSECUTIVO<=@valorfin

			set @contador=@contador+1
			set @valorini=@valorfin+1
	
		END				
	
	end
	else
	INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
	                      BSU_NOPARTE, BST_NOPARTE, BST_TIP_ENS, BST_SEC)
	
	SELECT     MAESTRO.MA_CODIGO, MAESTRO_1.MA_CODIGO, estintTij.Cantidad, MAESTRO_1.MA_DISCHARGE, MAESTRO_1.ME_COM, 
	                      ISNULL(MAESTRO_1.EQ_GEN,1), estintTij.[FechaIni], --left(right(estintTij.[FechaIni],4),2)+'/'+right(estintTij.[FechaIni],2)+'/'+left(estintTij.[FechaIni],4), 
				estintTij.[FechaFin], --left(right(estintTij.[FechaFin],4),2)+'/'+right(estintTij.[FechaFin],2)+'/'+left(estintTij.[FechaFin],4), 
				ISNULL(MAESTRO_2.ME_COM,19), MAESTRO.MA_NOPARTE, MAESTRO_1.MA_NOPARTE, 
	                      CASE WHEN MAESTRO_1.MA_TIP_ENS='A' THEN 'F' ELSE MAESTRO_1.MA_TIP_ENS END, estintTij.SECUENCIA
	FROM         estintTij INNER JOIN
	                      MAESTRO ON estintTij.[NumPadre] = MAESTRO.MA_NOPARTE INNER JOIN
	                      MAESTRO MAESTRO_1 ON estintTij.NumHijo = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
	                      MAESTRO MAESTRO_2 ON MAESTRO_1.MA_GENERICO = MAESTRO_2.MA_CODIGO



ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [DELETE_BOM_STRUCT]
ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [INSERT_BOM_STRUCT]



		--print 'Inserta en la tabla registros importados'
	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registro agregado, Padre= '+rtrim(BOM_STRUCT.BSU_NOPARTE)+' Componente= '+rtrim(BOM_STRUCT.BST_NOPARTE)+'('+convert(varchar(10),BOM_STRUCT.BST_PERINI,101)+','+convert(varchar(10),BOM_STRUCT.BST_PERFIN,101)+')'
		FROM estintTij INNER JOIN BOM_STRUCT ON rtrim(estintTij.NumPadre)+'-'+rtrim(estintTij.NumHijo)+'-'+estintTij.FechaIni+'-'+estintTij.FechaFin+'-'+convert(varchar(10),estintTij.SECUENCIA) =
		rtrim(BOM_STRUCT.BSU_NOPARTE)+'-'+rtrim(BOM_STRUCT.BST_NOPARTE)+'-'+convert(varchar(10),BOM_STRUCT.BST_PERINI,101)+'-'+convert(varchar(10),BOM_STRUCT.BST_PERFIN,101)+'-'+convert(varchar(10),BOM_STRUCT.BST_SEC)
		

	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registro NO agregado, Padre= '+rtrim(estintTij.NumPadre)+' Componente= '+rtrim(estintTij.NumHijo)+'('+estintTij.FechaIni+','+estintTij.FechaFin+')'
		FROM estintTij 
		WHERE rtrim(estintTij.NumPadre)+'-'+rtrim(estintTij.NumHijo)+'-'+estintTij.FechaIni+'-'+estintTij.FechaFin+'-'+convert(varchar(10),estintTij.SECUENCIA) NOT IN 
		(SELECT rtrim(BSU_NOPARTE)+'-'+rtrim(BST_NOPARTE)+'-'+convert(varchar(10),BST_PERINI,101)+'-'+convert(varchar(10),BST_PERFIN,101)+'-'+convert(varchar(10),BST_SEC) FROM BOM_STRUCT)
		

	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registros agregados: '+convert(varchar(10),COUNT(*))
		FROM REGISTROSIMPORTSCH where REGISTRO like 'Registro agregado, Padre=%' 

	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registros rechazados: '+convert(varchar(10),COUNT(*))
		FROM REGISTROSIMPORTSCH where REGISTRO like 'Registro NO agregado, Padre=%'

GO
