SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ImportFile1] (@BORRARBOM char(1), @ARIMPMX char(1), @ARIMPFO char (1), @UPDATEMAESTRO char (1), @MAESTRO char (1), @RUTAS char (1), @FACTURA char (1), @vieneDTS char(1)='N')   as


declare @maximo int, @MA_CODIGO INT, @AR_FRACCION VARCHAR(10),@ME_CODIGO INT, @ME_CODIGO2 INT, @CONSECUTIVO int, @TCO_MANUFACTURA INT, 
@TCO_COMPRA INT, @AR_CODIGO INT, @FID_INDICED int, @FI_CODIGO int, @FE_CODIGO int, @PL_CODIGO int,
@FIC_INDICEC int, @FEC_INDICEC INT, @FED_INDICED int, @PLC_INDICEC INT, @PLD_INDICED int


	SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA FROM dbo.CONFIGURACION


	TRUNCATE TABLE REGISTROSIMPORTADOS

/*Verifica si todos los numeros de parte tienen asignado un PAIS de Origen y que este tenga clave SAAI, de lo contrario detiene la importacion del File 1*/

insert into importlog (iml_mensaje, iml_cbforma)
select 'El No.Parte : '+ltrim(PartNo) + ' de la factura : '+ltrim(TMMBCTransNumber)+ ' NO tiene clave de PAIS SAAIM3', 131
from tempimpfile1  
where 
   (select  PA_SAAIM3 from pais where pa_codigo=CountryOriginDest)=''
                or not exists (select  PA_SAAIM3 from pais where pa_codigo=CountryOriginDest)

insert into importlog (iml_mensaje, iml_cbforma)
select 'El No.Parte : '+ltrim(PartNo) + ' de la factura : '+ltrim(TMMBCTransNumber)+ ' NO tiene Descrip.en Espanol', 131
from tempimpfile1  
where 
                  DescripSpa=''


insert into importlog (iml_mensaje, iml_cbforma)
select 'El No.Parte : '+ltrim(PartNo) + ' de la factura : '+ltrim(TMMBCTransNumber)+ ' NO tiene MEX HTS', 131
from tempimpfile1  
where 

 ( 
                  (select  AR_FRACCION from arancel where ar_fraccion=HTSMex)=''
              )



	if @vieneDTS ='S'
	begin
		update TempImpFile1
		set CountryOriginDest= isnull((select pa_codigo from pais where pa_iso=replace(TempImpFile1.CountryOriginDest,' ','')),0)
	end


	--yolanda 01-abril-2006  estos cambios son para que identifique el sistema que una empresa puede tener varios valores para el campo cl_codehtc 


	update TempImpFile1
	set TempImpFile1.importer= '0093040'
	where  TMMBCTransNumber like 'V%'
               and ltrim(rtrim(TempImpFile1.importer))='CAMX'

	update TempImpFile1
	set TempImpFile1.importer= '02391'
	where  TMMBCTransNumber like 'V%'
               and ltrim(rtrim(TempImpFile1.importer))='BUDD'


	update TempImpFile1
	set TempImpFile1.importer= '20801'
	where  TMMBCTransNumber like 'V%'
               and ltrim(rtrim(TempImpFile1.importer))='KYOMEX'

------------

	update TempImpFile1
	set OriginId= '0093040'
	where  TMMBCTransNumber like 'V%'
               and ltrim(rtrim(TempImpFile1.OriginId))='CAMX'

	update TempImpFile1
	set OriginId= '02391'
	where  TMMBCTransNumber like 'V%'
               and ltrim(rtrim(TempImpFile1.OriginId))='BUDD'


	update TempImpFile1
	set OriginId= '20801'
	where  TMMBCTransNumber like 'V%'
               and ltrim(rtrim(TempImpFile1.OriginId))='KYOMEX'
	--yolanda 01-abril-2006  estos cambios son para que identifique el sistema que una empresa puede tener varios valores para el campo cl_codehtc 


	update TempImpFile1
	set importer= isnull((select cl_codigo from cliente where cl_codehtc=replace(TempImpFile1.importer,' ','')),0) 
	where  TMMBCTransNumber not like 'V%'
	        and TempImpFile1.importer <>''


	--yolanda 30-enero-2006
            --esta parte es solo para Facturas de Importacion VIRTUALES ya que el OriginID trae la info que debo comparar con el campo "cl_codehtc" de la tabla cliente
	update TempImpFile1
	set OriginId= (case when ltrim(rtrim(TempImpFile1.OriginId)) in ('02391', '20801','0093040', '4ALAT') then 
		(select cl_codigo from cliente where cl_codehtc=TempImpFile1.OriginId)
			else
			isnull((select cl_codigo from cliente  where cl_codehtc='TMMNA'),0) end)
	where  TMMBCTransNumber like 'V%'





           --Yolanda 30-enero-2006
          --poner codigo que asigne el supplier correcto de acuerdo al campo "OriginId"

           --Yolanda 30-enero-2006
           -- Las lineas de abajo no estan tomando el campo de donde deben, ver codigo que se puso arriba
	update TempImpFile1
	set importer= (case when TempImpFile1.importer in ('02391', '20801','0093040', '4ALAT') then 
		(select cl_codigo from cliente where cl_codehtc=TempImpFile1.importer)
			else
			isnull((select cl_codigo from cliente  where cl_codehtc='TMMNA'),0) end)
	where  TMMBCTransNumber like 'V%'
	        and TempImpFile1.importer <>''


	update TempImpFile1
	set importer= 0
	where  TempImpFile1.importer =''




	if not exists (select * from dbo.sysobjects where name='TempImpFile1Temp')	
	begin

		SELECT     RecordType, BCNo, FileType, TMMBCTransNumber, TMMBCTransNumberOri, NumberRecords, TrailerNo, PedimentoClass, InsuranceCost, 
		                      FreightCost, PackingCost, OthersCost, CountryExport, OriginId, Route, ShipDate, ShipTime, ETAatswitching, TotalValue, TotalPackages, TotalMetalPck, 
		                      TotalPlasticPck, DRecordType, TMMBCManifiestPO, PartNo, DescripEng, DescripSpa, VINNumber, NetWeight, Hazard, Mileage, QtyofPart, UMofPart, 
		                      UnitPrice, CountryOriginDest, CountrySupplierPurch, Importer, CommercialTreatment, HTSMex, QtyHTSMex, UMHTSMex, USHTS, QtyUSHTS1, 
		                      UMHTS1, QtyUSHTS2, UMHTS2
		INTO dbo.TempImpFile1Temp
		FROM         TempImpFile1

		exec Sp_CreaTempImpFile1	
	
		if (SELECT     COUNT(FileType) FROM TempImpFile1Temp WHERE TMMBCTransNumber LIKE 'S%' OR TMMBCTransNumber LIKE 'V%')>0
		begin
			select @maximo=isnull(max(fid_indiced),0)+1 from factimpdet
			dbcc checkident (TempImpFile1, reseed, @maximo) WITH NO_INFOMSGS
		end
		else
		begin
			select @maximo=isnull(max(fed_indiced),0)+1 from factexpdet
			dbcc checkident (TempImpFile1, reseed, @maximo) WITH NO_INFOMSGS
	
		end
	

		INSERT INTO TempImpFile1(RecordType, BCNo, FileType, TMMBCTransNumber, TMMBCTransNumberOri, NumberRecords, TrailerNo, PedimentoClass, InsuranceCost, 
		                      FreightCost, PackingCost, OthersCost, CountryExport, OriginId, Route, ShipDate, ShipTime, ETAatswitching, TotalValue, TotalPackages, TotalMetalPck, 
		                      TotalPlasticPck, DRecordType, TMMBCManifiestPO, PartNo, DescripEng, DescripSpa, VINNumber, NetWeight, Hazard, Mileage, QtyofPart, UMofPart, 
		                      UnitPrice, CountryOriginDest, CountrySupplierPurch, Importer, CommercialTreatment, HTSMex, QtyHTSMex, UMHTSMex, USHTS, QtyUSHTS1, 
		                      UMHTS1, QtyUSHTS2, UMHTS2)
		SELECT     RecordType, BCNo, FileType, TMMBCTransNumber, TMMBCTransNumberOri, NumberRecords, TrailerNo, PedimentoClass, InsuranceCost, 
		                      FreightCost, PackingCost, OthersCost, CountryExport, OriginId, Route, ShipDate, ShipTime, ETAatswitching, TotalValue, TotalPackages, TotalMetalPck, 
		                      TotalPlasticPck, DRecordType, TMMBCManifiestPO, PartNo, DescripEng, DescripSpa, VINNumber, NetWeight, Hazard, Mileage, QtyofPart, UMofPart, 
		                      UnitPrice, 
				        CASE WHEN ((select  PA_SAAIM3 from pais where pa_codigo=CountryOriginDest)='') or not exists (select  PA_SAAIM3 from pais where pa_codigo=CountryOriginDest) then 0 else CountryOriginDest END ,
				        
				CountrySupplierPurch, Importer, CommercialTreatment, HTSMex, QtyHTSMex, UMHTSMex, USHTS, QtyUSHTS1, 
		                      UMHTS1, QtyUSHTS2, UMHTS2
		FROM         TempImpFile1Temp

		--yolanda 30-enero-2006
		exec sp_droptable 'TempImpFile1Temp'	
	end
 



-- fracciones mexico

	if (@ARIMPMX='S' or @ARIMPFO='S')
	begin
		exec sp_droptable 'tempimparancel'
		
		CREATE TABLE [dbo].[tempimparancel] (
			[AR_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[AR_FRACCION] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[AR_OFICIAL] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[ME_CODIGO] [int] NOT NULL ,
			[ME_CODIGO2] [int] NOT NULL ,
			[PA_CODIGO] [int] NOT NULL ,
			[AR_TIPO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tempimparancel_AR_TIPO] DEFAULT ('A'),
			[AR_TIPOREG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tempimparancel_AR_TIPOREG] DEFAULT ('F'),
			CONSTRAINT [PK_tempimparancel] PRIMARY KEY  CLUSTERED 
			(
				[AR_FRACCION]
			)  ON [PRIMARY] 
		) ON [PRIMARY]
		
		select @maximo=isnull(max(ar_codigo),0)+1 from arancel
		
		dbcc checkident (tempimparancel, reseed, @maximo) WITH NO_INFOMSGS

	end

	if @ARIMPMX='S'
	begin
		insert into tempimparancel(AR_OFICIAL ,PA_CODIGO ,AR_TIPO ,AR_TIPOREG ,AR_FRACCION ,ME_CODIGO, ME_CODIGO2)
		SELECT     'TEMP' ,154 ,'A' ,'F' , TempImpFile1.HTSMex, TempImpFile1.UMHTSMex, 0
		FROM         TempImpFile1 LEFT OUTER JOIN
		                      ARANCEL    ON TempImpFile1.HTSMex = ARANCEL.AR_FRACCION
		WHERE     (ARANCEL.AR_FRACCION IS NULL)
		GROUP BY TempImpFile1.HTSMex, TempImpFile1.UMHTSMex


 	          INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO,RI_TIPO, RI_CBFORMA) 
		SELECT     'AR_FRACCION = '+CONVERT(varchar(100),TempImpFile1.HTSMex),'I',131 
		FROM         TempImpFile1 LEFT OUTER JOIN
		                      ARANCEL    ON TempImpFile1.HTSMex = ARANCEL.AR_FRACCION
		WHERE     (ARANCEL.AR_FRACCION IS NULL)
		GROUP BY TempImpFile1.HTSMex, TempImpFile1.UMHTSMex
	end
	
-- fracciones usa
	if @ARIMPFO='S'
	begin

		insert into tempimparancel(AR_OFICIAL ,PA_CODIGO ,AR_TIPO ,AR_TIPOREG ,AR_FRACCION ,ME_CODIGO, ME_CODIGO2)
		SELECT     'TEMP' ,233 ,'A' ,'F' , TempImpFile1.USHTS, TempImpFile1.UMHTS1, isnull(TempImpFile1.UMHTS2,0)
		FROM         TempImpFile1 LEFT OUTER JOIN
		                      ARANCEL    ON TempImpFile1.USHTS = ARANCEL.AR_FRACCION 
		WHERE     (ARANCEL.AR_FRACCION IS NULL)
		GROUP BY TempImpFile1.USHTS, TempImpFile1.UMHTS1, isnull(TempImpFile1.UMHTS2,0)


 	          INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO,RI_TIPO,RI_CBFORMA) 
		SELECT     'AR_FRACCION = '+CONVERT(varchar(100),TempImpFile1.USHTS),'I',131 
		FROM         TempImpFile1 LEFT OUTER JOIN
		                      ARANCEL    ON TempImpFile1.USHTS = ARANCEL.AR_FRACCION 
		WHERE     (ARANCEL.AR_FRACCION IS NULL)
		GROUP BY TempImpFile1.USHTS, TempImpFile1.UMHTS1, TempImpFile1.UMHTS2
	end

	if (@ARIMPMX='S' or @ARIMPFO='S')
	begin
	
		INSERT INTO ARANCEL(AR_CODIGO, AR_FRACCION, AR_OFICIAL, ME_CODIGO, ME_CODIGO2, PA_CODIGO, AR_TIPO, AR_TIPOREG)
		
		SELECT     AR_CODIGO, AR_FRACCION, AR_OFICIAL, ME_CODIGO, ME_CODIGO2, PA_CODIGO, AR_TIPO, AR_TIPOREG
		FROM         tempimparancel
		
		
		exec sp_droptable 'tempimparancel'
		
		select @AR_CODIGO= max(AR_CODIGO) from ARANCEL
		
			update consecutivo
			set cv_codigo =  isnull(@AR_CODIGO,0) + 1
			where cv_tipo = 'AR'
	
	end
	
-- ==================================== actualiza maestro ========================
if @UPDATEMAESTRO='S'
begin
	alter table [MAESTRO] disable trigger [Update_Maestro]
	
	-- actualizacion de cat. Maestro
		UPDATE MAESTRO
		SET     MAESTRO.MA_NOMBRE= TempImpFile1.DescripSpa, MAESTRO.MA_NAME= TempImpFile1.DescripEng, 
			         MAESTRO.ME_COM=TempImpFile1.UMofPart, 
 			               MAESTRO.PA_ORIGEN= TempImpFile1.CountryOriginDest ,
                                       
                                       MAESTRO.PA_PROCEDE=TempImpFile1.CountryExport,  
			         MAESTRO.AR_IMPMX= dbo.ARANCEL.AR_CODIGO, 
		                      MAESTRO.AR_IMPFO= ARANCEL_1.AR_CODIGO, MAESTRO.MA_PESO_LB= TempImpFile1.NetWeight/10000 * 2.20462442018378, 
		                      MAESTRO.MA_PESO_KG= TempImpFile1.NetWeight/10000, MAESTRO.MA_PELIGROSO= REPLACE(TempImpFile1.Hazard, 'Y', 'S') 
		FROM            TempImpFile1 INNER JOIN
		                      MAESTRO    ON TempImpFile1.PartNo = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      dbo.ARANCEL ARANCEL_1    ON TempImpFile1.USHTS = ARANCEL_1.AR_FRACCION LEFT OUTER JOIN
		                      dbo.ARANCEL    ON TempImpFile1.HTSMex = dbo.ARANCEL.AR_FRACCION 


	-- actualiza costos de los ya existentes
                          /*Este insert es para agregar el numero de parte en MAESTROCOST en el caso de que el numero de parte no tenga ningun COSTO ASIGNADO */
		INSERT INTO MAESTROCOST(MA_CODIGO, TCO_CODIGO, TV_CODIGO, MA_COSTO, SPI_CODIGO, MA_PERINI, MA_PERFIN)
		SELECT max(MA_CODIGO), (SELECT TCO_COMPRA FROM dbo.CONFIGURACION),  (SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'), 0, 22, CONVERT(VARCHAR(11),GETDATE(),101), '01/01/9999'
		FROM MAESTRO
                           INNER JOIN TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo  
		WHERE MA_INV_GEN='I' AND MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCOST)
                          group by ma_codigo

		IF (SELECT    count( MAESTROCOST.MA_COSTO)
		FROM         MAESTRO  INNER JOIN
		                      TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo INNER JOIN
	                      MAESTROCOST  ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
		WHERE MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6))
		 > = 1
               
                
                BEGIN

			UPDATE MAESTROCOST
			SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
			FROM MAESTROCOST INNER JOIN
                      	MAESTRO ON MAESTROCOST.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
                      	TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo
			WHERE MAESTROCOST.MAC_CODIGO not in
				(SELECT MAX(C1.MAC_CODIGO)
				FROM MAESTROCOST C1
				WHERE C1.SPI_CODIGO = 22 AND C1.TCO_CODIGO = (SELECT TCO_COMPRA FROM dbo.CONFIGURACION) AND C1.MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
				GROUP BY C1.MA_CODIGO)
			 AND MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6)


			INSERT INTO MAESTROCOST(MA_CODIGO, TCO_CODIGO, TV_CODIGO, MA_COSTO, SPI_CODIGO, MA_PERINI, MA_PERFIN)
			SELECT MAESTRO.MA_CODIGO, (SELECT TCO_COMPRA FROM dbo.CONFIGURACION),  (SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'), round(TempImpFile1.UnitPrice/10000,6), 22, CONVERT(VARCHAR(11),GETDATE(),101), '01/01/9999'
			FROM MAESTRO INNER JOIN
			     TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo INNER JOIN
		             MAESTROCOST  ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
			 WHERE MAESTRO.MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6)
			and not
			(maestrocost.MA_PERINI=CONVERT(VARCHAR(11),GETDATE(),101) and  maestrocost.MA_PERFIN='01/01/9999' 
			and maestrocost.tco_codigo=(SELECT TCO_COMPRA FROM dbo.CONFIGURACION))
                                         group by MAESTRO.MA_CODIGO,round(TempImpFile1.UnitPrice/10000,6)

			update  MAESTROCOST
                                       set TV_CODIGO=(SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'),
			 MA_COSTO= round(TempImpFile1.UnitPrice/10000,6),
			MA_PERINI=CONVERT(VARCHAR(11),GETDATE(),101), 
			MA_PERFIN= '01/01/9999'
			FROM MAESTRO INNER JOIN
			     TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo INNER JOIN
		             MAESTROCOST  ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
			 WHERE MAESTRO.MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6)
			and 
			(maestrocost.MA_PERINI=CONVERT(VARCHAR(11),GETDATE(),101) and  maestrocost.MA_PERFIN='01/01/9999' and maestrocost.tco_codigo=(SELECT TCO_COMPRA FROM dbo.CONFIGURACION))



		END



	
	
	alter table [MAESTRO] enable trigger [Update_Maestro]
end
-- ===================================================================================
	if @MAESTRO='S'
	begin
		exec sp_droptable 'tempimpmaestro'
		
		CREATE TABLE [dbo].[tempimpmaestro] (
			[MA_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[MA_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[MA_INV_GEN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tempimpmaestro_MA_INV_GEN] DEFAULT ('I'),
			[TI_CODIGO] [smallint] NOT NULL ,
			[MA_NOMBRE] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[MA_NAME] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[ME_COM] [int] NOT NULL ,
			[PA_ORIGEN] [int] NOT NULL ,
			[PA_PROCEDE] [int] NOT NULL ,
			[MA_GENERICO] [int] NOT NULL CONSTRAINT [DF_tempimpmaestro_MA_GENERICO] DEFAULT (0),
			[AR_IMPMX] [int] NULL ,
			[AR_EXPMX] [int] NULL ,
			[AR_IMPFO] [int] NULL ,
			[MA_PESO_KG] decimal(38,6) NULL ,
			[MA_PESO_LB] decimal(38,6) NULL ,
			[MA_PELIGROSO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tempimpmaestro_MA_PELIGROSO] DEFAULT ('N'),
			[EQ_IMPMX] decimal(28,14) CONSTRAINT [DF_tempimpmaestro_EQ_IMPMX] DEFAULT (1),
			[EQ_EXPFO] decimal(28,14) CONSTRAINT [DF_tempimpmaestro_EQ_EXPFO] DEFAULT (1),
			[EQ_IMPFO] decimal(38,6) CONSTRAINT [DF_tempimpmaestro_EQ_IMPFO] DEFAULT (1),
			[EQ_IMPFO2] decimal(38,6) CONSTRAINT [DF_tempimpmaestro_EQ_IMPFO2] DEFAULT (1),
			[MA_DEF_TIP] [char] (1) CONSTRAINT [DF_tempimpmaestro_MA_DEF_TIP] DEFAULT ('G'),
			[MA_SEC_IMP] [int] NULL ,
			[SPI_CODIGO] [int] NULL ,
			CONSTRAINT [PK_tempimpmaestro] PRIMARY KEY  CLUSTERED 
			(
				[MA_NOPARTE],
				[MA_INV_GEN]
			)  ON [PRIMARY] 
		) ON [PRIMARY]
		
		select @maximo=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'
		dbcc checkident (tempimpmaestro, reseed, @maximo) WITH NO_INFOMSGS
		
		
			insert into tempimpmaestro (ma_noparte, ma_name, ma_nombre, pa_origen,  pa_procede, ma_peso_kg, ma_peso_lb, ma_peligroso, me_com, ar_impmx, ar_expmx, ar_impfo, ti_codigo, ma_inv_gen,
						eq_impfo, eq_impmx, spi_codigo, ma_sec_imp, ma_def_tip)

			SELECT     TempImpFile1.PartNo, max(TempImpFile1.DescripEng), max(TempImpFile1.DescripSpa), 
			           
			               max(TempImpFile1.CountryOriginDest), max(TempImpFile1.CountryExport), 
			           max(TempImpFile1.NetWeight/10000), 
			                      max(TempImpFile1.NetWeight/10000) * 2.20462442018378, REPLACE(max(TempImpFile1.Hazard), 'Y', 'S'), max(TempImpFile1.UMofPart), 
			                      max(dbo.ARANCEL.AR_CODIGO), max(dbo.ARANCEL.AR_CODIGO), max(ARANCEL_1.AR_CODIGO), 10, 'I',
				         'EQ_IMPFO'=CASE WHEN (sum(QtyUSHTS1)>0) and (sum(QtyofPart)>0) then sum(QtyUSHTS1)/sum(QtyofPart) else 1  END,
				         'EQ_IMPMX'=CASE WHEN (sum(QtyHTSMex)>0) and (sum(QtyofPart)>0) then (sum((QtyHTSMex/10000)/QtyofPart)) else 1  END,
                                          --22-mayo-06
				             --'SPI_CODIGO'=CASE WHEN max(CommercialTreatment)='TL'  AND max(TempImpFile1.CountrySupplierPurch)=233 then (select spi_codigo from spi where spi_clave='NAFTA') else 0 end,
				             'SPI_CODIGO'=CASE WHEN max(CommercialTreatment)='TL'  AND (max(TempImpFile1.CountrySupplierPurch)=233 or max(TempImpFile1.CountrySupplierPurch) =154 or max(TempImpFile1.CountrySupplierPurch) =35)
                                                      then (select spi_codigo from spi where spi_clave='NAFTA') else 0 end,   
                                          --22-mayo-06
        				        'MA_SEC_IMP'=case when max(CommercialTreatment)='PS' then (SELECT SE_CODIGO FROM SECTOR WHERE SE_CLAVE='XIXa') else 0 end,
				        'MA_DEF_TIP'= CASE WHEN max(CommercialTreatment)='PS' then 'S' WHEN max(CommercialTreatment)='TL' then 'P' else 'G'  END
			FROM         TempImpFile1 LEFT OUTER JOIN
			                      dbo.ARANCEL ARANCEL_1  ON TempImpFile1.USHTS = ARANCEL_1.AR_FRACCION LEFT OUTER JOIN
			                      dbo.ARANCEL  ON TempImpFile1.HTSMex = dbo.ARANCEL.AR_FRACCION 
			WHERE TempImpFile1.PartNo NOT IN(SELECT MA_NOPARTE FROM MAESTRO)
			GROUP BY TempImpFile1.PartNo 
		
			insert into maestro (ma_codigo, ma_noparte, ma_nombre, ma_name, ar_impmx, ar_expmx, ar_impfo, me_com, ti_codigo, pa_origen, pa_procede, ma_inv_gen, ma_peso_kg, ma_peso_lb, eq_impfo, eq_impmx, spi_codigo, ma_sec_imp, ma_def_tip/*, ma_nafta*/)
			select ma_codigo, ma_noparte, ma_nombre, ma_name, ar_impmx, ar_expmx, ar_impfo, me_com, ti_codigo, pa_origen, pa_procede, ma_inv_gen, ma_peso_kg, ma_peso_lb, round(eq_impfo,6), round(eq_impmx,6), spi_codigo, ma_sec_imp,
			ma_def_tip
			from tempimpmaestro
			where ma_noparte is not null 




		        INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_TIPO, RI_CBFORMA) 
			select 'MA_NOPARTE = '+ma_noparte+', MA_NOPARTEAUX = ', 'I',131
			from tempimpmaestro
			where ma_noparte is not null 

		
			INSERT INTO MAESTROCOST(MA_CODIGO, TCO_CODIGO, TV_CODIGO, MA_COSTO, SPI_CODIGO, MA_PERINI, MA_PERFIN)
			SELECT max(MA_CODIGO), (SELECT TCO_COMPRA FROM dbo.CONFIGURACION),  (SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'), 0, 22, CONVERT(VARCHAR(11),GETDATE(),101), '01/01/9999'
			FROM MAESTRO  
		                           INNER JOIN TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo  
			WHERE MA_INV_GEN='I' AND MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCOST)
             		                          group by maestro.ma_codigo
		
		

		exec sp_droptable 'tempimpmaestro'
		
		select @MA_CODIGO= max(isnull(MA_CODIGO,0))+1 from MAESTRO
		

		if exists(select * from maestrorefer) and (select max(isnull(ma_codigo,0)) from maestrorefer)>@MA_CODIGO
		select @MA_CODIGO= max(isnull(MA_CODIGO,0))+1 from MAESTROREFER

			update consecutivo
			set cv_codigo = @MA_CODIGO
			where cv_tipo = 'MA'

	-- actualiza costos de los ya existentes
		IF (SELECT    count(MAESTROCOST.MA_COSTO)
		FROM         MAESTRO  INNER JOIN
		                      TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo INNER JOIN
	                      MAESTROCOST  ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
		WHERE MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6))
		>=1
		BEGIN


			UPDATE MAESTROCOST
			SET MAESTROCOST.MA_PERFIN =convert(varchar(11),getdate()-1,101)
			FROM MAESTROCOST INNER JOIN
                      	MAESTRO ON MAESTROCOST.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
                      	TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo
			WHERE MAESTROCOST.MAC_CODIGO not in
				(SELECT MAX(C1.MAC_CODIGO)
				FROM MAESTROCOST C1
				WHERE C1.SPI_CODIGO = 22 AND C1.TCO_CODIGO = (SELECT TCO_COMPRA FROM dbo.CONFIGURACION) AND C1.MA_PERINI = CONVERT(varchar(11), GETDATE(), 101)
				GROUP BY C1.MA_CODIGO)
			 AND MAESTRO.MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6)

			INSERT INTO MAESTROCOST(MA_CODIGO, TCO_CODIGO, TV_CODIGO, MA_COSTO, SPI_CODIGO, MA_PERINI, MA_PERFIN)
			SELECT MAESTRO.MA_CODIGO, (SELECT TCO_COMPRA FROM dbo.CONFIGURACION),  (SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'), round(TempImpFile1.UnitPrice/10000,6), 22, CONVERT(VARCHAR(11),GETDATE(),101), '01/01/9999'
			FROM         MAESTRO  INNER JOIN
			                      TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo INNER JOIN
		                      MAESTROCOST  ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
			 WHERE MAESTRO.MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6)
			and not
			(maestrocost.MA_PERINI=CONVERT(VARCHAR(11),GETDATE(),101) and  maestrocost.MA_PERFIN='01/01/9999' 
			and maestrocost.tco_codigo=(SELECT TCO_COMPRA FROM dbo.CONFIGURACION))

			update  MAESTROCOST
                                       set TV_CODIGO=(SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'),
			 MA_COSTO= round(TempImpFile1.UnitPrice/10000,6),
			MA_PERINI=CONVERT(VARCHAR(11),GETDATE(),101), 
			MA_PERFIN= '01/01/9999'
			FROM MAESTRO INNER JOIN
			     TempImpFile1 ON MAESTRO.MA_NOPARTE = TempImpFile1.PartNo INNER JOIN
		             MAESTROCOST  ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
			 WHERE MAESTRO.MA_INV_GEN='I' AND MAESTROCOST.MA_COSTO<> round(TempImpFile1.UnitPrice/10000,6)
			and 
			(maestrocost.MA_PERINI=CONVERT(VARCHAR(11),GETDATE(),101) and  maestrocost.MA_PERFIN='01/01/9999' and maestrocost.tco_codigo=(SELECT TCO_COMPRA FROM dbo.CONFIGURACION))


		END


	end
-- ===================================================================================

-- insercion de rutas
if @RUTAS='S'
begin
	INSERT INTO RUTA (RU_CORTO, RU_DESC)
	SELECT     TempImpFile1.Route, TempImpFile1.Route
	FROM         TempImpFile1 LEFT OUTER JOIN
	                      dbo.RUTA ON TempImpFile1.Route = dbo.RUTA.RU_CORTO
	GROUP BY TempImpFile1.Route, dbo.RUTA.RU_CORTO
	HAVING      (dbo.RUTA.RU_CORTO IS NULL) AND (TempImpFile1.Route IS NOT NULL)
	AND (TempImpFile1.Route <>'') 
end

--========================================================= factura ==================================================================
DECLARE @AG_MEX INT, @AG_USA INT, @CL_CODIGO INT, @CL_MATRIZ INT, @CL_TRAFICO INT, @CT_CODIGO INT, @DIRMATRIZ INT, 
	@MT_CODIGO INT, @PU_CARGA INT, @PU_DESTINO INT, @PU_ENTRADA INT, @PU_SALIDA INT, @ZO_CODIGO INT, @DIRPRINC INT,
	@FECHATEXT VARCHAR(11), @MO_CODIGO INT, @IT_ENTRADA INT, @InsuranceCost decimal(38,6), @FreightCost decimal(38,6), @PackingCost decimal(38,6), @OthersCost decimal(38,6),
	@TotalMetalPck decimal(38,6), @TotalPlasticPck decimal(38,6)


declare @FileType varchar(6), @TMMBCTransNumber varchar(10), @TMMBCTransNumberOri varchar(10), @Route varchar(10), @Tf_codigo int, @Folio varchar(20), 
	@TrailerNo varchar(20), @TotalPackages int

             SELECT @AG_MEX=AG_MEX,  @AG_USA=AG_USA, @CL_CODIGO=CL_CODIGO, @CL_MATRIZ=CL_MATRIZ, @CL_TRAFICO=CL_TRAFICO, 
		@CT_CODIGO=CT_CODIGO, @MT_CODIGO=MT_CODIGO, @PU_CARGA=PU_CARGA, @PU_DESTINO=PU_DESTINO, 
		@PU_ENTRADA=PU_ENTRADA, @PU_SALIDA=PU_SALIDA, @ZO_CODIGO=ZO_CODIGO,
		@IT_ENTRADA= IT_ENTRADA, @MO_CODIGO=MO_CODIGO, 
 		@DIRPRINC=(SELECT MAX(DI_INDICE) FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_CODIGO),
		@DIRMATRIZ=(SELECT MAX(DI_INDICE) FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_MATRIZ)
	 FROM CLIENTE  WHERE CL_EMPRESA='S'

	SET @FECHATEXT = dbo.DateToText(GETDATE(),101)


	-- insercion de facturas
	exec sp_importFile1SinoExiste

	
	if (SELECT     COUNT(FileType) FROM TempImpFile1 WHERE TMMBCTransNumber LIKE 'S%' or TMMBCTransNumber LIKE 'V%')>0
	begin
		update factimp
		set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
		where fi_cuentadet<>(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)

		select @FID_INDICED= max(fid_indiced) from factimpdet
	
		update consecutivo
		set cv_codigo =  isnull(@fid_indiced,0) + 1
		where cv_tipo = 'FID'
	
		select @FIC_INDICEC= max(fic_indicec) from factimpcont
	
		update consecutivo
		set cv_codigo =  isnull(@fic_indicec,0) + 1
		where cv_tipo = 'FIC'
	
	
		select @FI_CODIGO= max(fi_codigo) from factimp
	
		update consecutivo
		set cv_codigo =  isnull(@fi_codigo,0) + 1
		where cv_tipo = 'FI'
	

	end

	if (SELECT     COUNT(FileType) FROM TempImpFile1 WHERE TMMBCTransNumber LIKE 'N%')>0
	begin
		update factexp
		set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
		where fe_cuentadet<>(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)


		select @FED_INDICED= max(fed_indiced) from factexpdet
	
		update consecutivo
		set cv_codigo =  isnull(@fed_indiced,0) + 1
		where cv_tipo = 'FED'
	
		select @FEC_INDICEC= max(fec_indicec) from factexpcont
	
		update consecutivo
		set cv_codigo =  isnull(@fic_indicec,0) + 1
		where cv_tipo = 'FEC'
	
		select @FE_CODIGO= max(fe_codigo) from factexp
		update consecutivo
		set cv_codigo =  isnull(@fe_codigo,0) + 1
		where cv_tipo = 'FE'

	end




             exec sp_droptable 'tempimpfactimpdetauto'
	exec sp_droptable 'tempImpfactexpdetauto'
	exec sp_droptable 'TempImpFile1Temp'
	exec sp_droptable 'TempImpFile1'
























GO
