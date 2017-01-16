SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_SCHNEIDERBOM] (@BorraLogImporta char(1)='S')   as


if not exists (select * from sysobjects where id = object_id(N'[REGISTROSIMPORTSCH]') and OBJECTPROPERTY(id, N'IsTable') = 1)
CREATE TABLE [dbo].[REGISTROSIMPORTSCH] (
	[REGISTRO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]

 if @BorraLogImporta='S'
 TRUNCATE TABLE REGISTROSIMPORTSCH

UPDATE estint
SET SECUENCIA=0

UPDATE estint
SET FINAL='01/01/9999'
WHERE FINAL='          '

Declare @X Int,@POS Varchar(100)

		Select Consecutivo,[FINISHED GOOD], secuencia
		Into dbo.[#Temps] 
		From estint 
		where secuencia =0
		Order by Consecutivo


		SET @X=0
		SET @POS=''

		Update #Temps 
		SET secuencia=@X,@X=CASE WHEN @POS = [FINISHED GOOD] THEN @X+1 ELSE 1 END,
                                  @POS=CASE WHEN @POS = [FINISHED GOOD] THEN @POS ELSE [FINISHED GOOD] END
	
		
		Update estint 
		SET secuencia=T.secuencia 
		From #Temps T inner join estint on T.Consecutivo=estint.Consecutivo

/* anexion de registros faltantes al cat. maestro */


		exec Sp_GeneraTablaTemp 'MAESTRO'



		DECLARE @CONSECUTIVO INT
		select @CONSECUTIVO=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'


		DBCC CHECKIDENT(TempImportMAESTRO, RESEED, @CONSECUTIVO) WITH NO_INFOMSGS


		INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

		SELECT 'I', 'F', [FINISHED GOOD], 16, 'TEMP', 'TEMP (SUBENSAMBLE EN BOM)', 19, 154, 154, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), 
		isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), 'N'
		FROM estint 
		WHERE RTRIM(LTRIM([FINISHED GOOD])) NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='I')
		GROUP BY [FINISHED GOOD]



		INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

		SELECT 'I', 'C', COMPONENT, 10, 'TEMP', 'TEMP (COMPONENTE EN BOM)', 19, 233, 233, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), 
		isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SIN FRACCION'),0), 'S'
		FROM estint 
		WHERE RTRIM(LTRIM(COMPONENT)) NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='I')
		AND COMPONENT NOT IN (SELECT MA_NOPARTE FROM TempImportMAESTRO)
		GROUP BY COMPONENT


		INSERT INTO MAESTRO(MA_CODIGO, MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE, MA_ULTIMAMODIF)

		SELECT MA_CODIGO, MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO,
				MA_NAME ,MA_NOMBRE ,ME_COM ,PA_ORIGEN ,PA_PROCEDE, AR_IMPMX ,AR_EXPMX, MA_DISCHARGE, GETDATE()
		FROM TempImportMAESTRO

		declare @maximo int

		select @maximo= isnull(max(MA_CODIGO),0) from MAESTRO

		if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@maximo
		select @maximo= isnull(max(MA_CODIGO),0) from MAESTROREFER

		update consecutivo
		set cv_codigo =  @maximo + 1
		where cv_tipo = 'MA'
 
---------------------------------------------

ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [DELETE_BOM_STRUCT]
ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [INSERT_BOM_STRUCT]

delete from bom_struct where bsu_noparte in 
(SELECT     [FINISHED GOOD]
FROM         estint
GROUP BY [FINISHED GOOD])


INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
                      BSU_NOPARTE, BST_NOPARTE, BST_TIP_ENS, BST_SEC)

SELECT     MAESTRO.MA_CODIGO, MAESTRO_1.MA_CODIGO, estint.QUANTITY, MAESTRO_1.MA_DISCHARGE, MAESTRO_1.ME_COM, 
                      ISNULL(MAESTRO_1.EQ_GEN,1), estint.[BEGIN], estint.FINAL, ISNULL(MAESTRO_2.ME_COM,19), MAESTRO.MA_NOPARTE, MAESTRO_1.MA_NOPARTE, 
                      CASE WHEN MAESTRO_1.MA_TIP_ENS='A' THEN 'F' ELSE MAESTRO_1.MA_TIP_ENS END, estint.SECUENCIA
FROM         estint INNER JOIN
                      MAESTRO ON estint.[FINISHED GOOD] = MAESTRO.MA_NOPARTE INNER JOIN
                      MAESTRO MAESTRO_1 ON estint.COMPONENT = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
                      MAESTRO MAESTRO_2 ON MAESTRO_1.MA_GENERICO = MAESTRO_2.MA_CODIGO



ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [DELETE_BOM_STRUCT]
ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [INSERT_BOM_STRUCT]



		--print 'Inserta en la tabla registros importados'
	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registro agregado, Padre= '+rtrim(BOM_STRUCT.BSU_NOPARTE)+' Componente= '+rtrim(BOM_STRUCT.BST_NOPARTE)+'('+convert(varchar(10),BOM_STRUCT.BST_PERINI,101)+','+convert(varchar(10),BOM_STRUCT.BST_PERFIN,101)+')'
		FROM estint INNER JOIN BOM_STRUCT ON rtrim(estint.[FINISHED GOOD])+'-'+rtrim(estint.COMPONENT)+'-'+estint.[BEGIN]+'-'+estint.FINAL+'-'+convert(varchar(10),estint.SECUENCIA) =
		rtrim(BOM_STRUCT.BSU_NOPARTE)+'-'+rtrim(BOM_STRUCT.BST_NOPARTE)+'-'+convert(varchar(10),BOM_STRUCT.BST_PERINI,101)+'-'+convert(varchar(10),BOM_STRUCT.BST_PERFIN,101)+'-'+convert(varchar(10),BOM_STRUCT.BST_SEC)
		

	       	 INSERT INTO REGISTROSIMPORTSCH (REGISTRO) 
		SELECT 'Registro NO agregado, Padre= '+rtrim(estint.[FINISHED GOOD])+' Componente= '+rtrim(estint.COMPONENT)+'('+estint.[BEGIN]+','+estint.FINAL+')'
		FROM estint 
		WHERE rtrim(estint.[FINISHED GOOD])+'-'+rtrim(estint.COMPONENT)+'-'+estint.[BEGIN]+'-'+estint.FINAL+'-'+convert(varchar(10),estint.SECUENCIA) NOT IN 
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
