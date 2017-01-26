SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[CONCILIAENTRY] (@lenguaje int = 1, @uservar int)   as

declare @etcodigo int, @maximo int, @fraccion varchar(20), @et_codigo int, @INSERTO INT, @9801EMPAQUE INT,
@uservarT varchar(50)


	SELECT @uservarT=CONVERT(VARCHAR(50), @uservar)


	DECLARE @mensaje varchar(5000)

EXEC SP_DROPTABLE 'ENTRYCONCILIALOG'
CREATE TABLE [dbo].[ENTRYCONCILIALOG] (
	[IML_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[IML_MENSAJE] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ET_CODIGO] [int] NULL ,
	[IML_TIPO] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	CONSTRAINT [IX_ENTRYCONCILIALOG] UNIQUE  NONCLUSTERED 
	(
		[IML_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]

	Delete from TempEntryConcilia where Texto<>'ENTRY AGENCIA' and Texto<>'ENTRY NO EXISTE EN INTRADE'

	UPDATE TempEntryConcilia
	SET     TempEntryConcilia.ET_CODIGO= ENTRYSUM.ET_CODIGO
	FROM         TempEntryConcilia INNER JOIN
	                      ENTRYSUM ON rtrim(TempEntryConcilia.BrokerCode collate database_default) + rtrim(TempEntryConcilia.EntryNumber collate database_default) = ENTRYSUM.ET_ENTRY_NO
	WHERE TempEntryConcilia.ET_CODIGO IS NULL


	UPDATE TempEntryConcilia
	SET     TempEntryConcilia.ET_CODIGO= ENTRYSUM.ET_CODIGO
	FROM         TempEntryConcilia INNER JOIN
	                      ENTRYSUM ON rtrim(TempEntryConcilia.EntryNumber collate database_default) = ENTRYSUM.ET_ENTRY_NO collate database_default
	WHERE TempEntryConcilia.ET_CODIGO IS NULL


	UPDATE TempEntryConcilia
	SET PartNumber=NULL
	WHERE PartNumber ='NA' OR PartNumber='N/A'


	UPDATE TempEntryConcilia
	SET     TempEntryConcilia.ETA_CODIGO= NULL

	UPDATE TempEntryConcilia
	SET ClientRefNo=''
	WHERE ClientRefNo IS NULL AND PartNumber IS NOT NULL


	SELECT @9801EMPAQUE=AR_EMPAQUEUSA FROM CONFIGURACION

	-- coincide factura, fraccion, no. parte, pais origen, SpecialProgramIndicator y descripcion de parte
	UPDATE TempEntryConcilia
	SET     TempEntryConcilia.ETA_CODIGO= FACTEXPDET.FED_INDICED
	FROM         TempEntryConcilia INNER JOIN
	                      ENTRYSUMARA ON TempEntryConcilia.ET_CODIGO = ENTRYSUMARA.ET_CODIGO INNER JOIN
	                      FACTEXP ON ENTRYSUMARA.FE_CODIGO = FACTEXP.FE_CODIGO AND rtrim(TempEntryConcilia.SupplierInvNo) = FACTEXP.FE_FOLIO INNER JOIN
	                      ARANCEL ON ENTRYSUMARA.AR_CODIGO = ARANCEL.AR_CODIGO AND rtrim(TempEntryConcilia.HarmonizedNo) = ARANCEL.AR_FRACCION AND 
			TempEntryConcilia.SpecialProgramIndicator = ENTRYSUMARA.MA_NAFTA INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO AND ENTRYSUMARA.ETA_CODIGO = FACTEXPDET.ETA_CODIGO AND 
	                      rtrim(TempEntryConcilia.PartNumber) = FACTEXPDET.FED_NOPARTE and ISNULL(TempEntryConcilia.ClientRefNo,'') = ISNULL(FACTEXPDET.FED_NOPARTEAUX,'') INNER JOIN
	                      PAIS ON FACTEXPDET.PA_CODIGO = PAIS.PA_CODIGO AND rtrim(TempEntryConcilia.Country) = PAIS.PA_ISO
	WHERE     (TempEntryConcilia.ETA_CODIGO IS NULL)


	-- coincide factura, fraccion, no. parte, pais origen y descripcion de parte, no incluye el SpecialProgramIndicator
	UPDATE TempEntryConcilia
	SET     TempEntryConcilia.ETA_CODIGO= FACTEXPDET.FED_INDICED
	FROM         TempEntryConcilia INNER JOIN
	                      ENTRYSUMARA ON TempEntryConcilia.ET_CODIGO = ENTRYSUMARA.ET_CODIGO INNER JOIN
	                      FACTEXP ON ENTRYSUMARA.FE_CODIGO = FACTEXP.FE_CODIGO AND rtrim(TempEntryConcilia.SupplierInvNo) = FACTEXP.FE_FOLIO INNER JOIN
	                      ARANCEL ON ENTRYSUMARA.AR_CODIGO = ARANCEL.AR_CODIGO AND rtrim(TempEntryConcilia.HarmonizedNo) = ARANCEL.AR_FRACCION INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO AND ENTRYSUMARA.ETA_CODIGO = FACTEXPDET.ETA_CODIGO AND 
	                      rtrim(TempEntryConcilia.PartNumber) = FACTEXPDET.FED_NOPARTE and ISNULL(TempEntryConcilia.ClientRefNo,'') = ISNULL(FACTEXPDET.FED_NOPARTEAUX,'') INNER JOIN
	                      PAIS ON FACTEXPDET.PA_CODIGO = PAIS.PA_CODIGO AND rtrim(TempEntryConcilia.Country) = PAIS.PA_ISO
	WHERE     (TempEntryConcilia.ETA_CODIGO IS NULL)


	-- coincide factura, no. parte, pais origen y descripcion de parte, sin fraccion
	UPDATE TempEntryConcilia
	SET     TempEntryConcilia.ETA_CODIGO= FACTEXPDET.FED_INDICED
	FROM         TempEntryConcilia INNER JOIN
	                      ENTRYSUMARA ON TempEntryConcilia.ET_CODIGO = ENTRYSUMARA.ET_CODIGO INNER JOIN
	                      FACTEXP ON ENTRYSUMARA.FE_CODIGO = FACTEXP.FE_CODIGO AND rtrim(TempEntryConcilia.SupplierInvNo) = FACTEXP.FE_FOLIO AND 
			TempEntryConcilia.SpecialProgramIndicator = ENTRYSUMARA.MA_NAFTA INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO AND ENTRYSUMARA.ETA_CODIGO = FACTEXPDET.ETA_CODIGO AND 
	                      rtrim(TempEntryConcilia.PartNumber) = FACTEXPDET.FED_NOPARTE and ISNULL(TempEntryConcilia.ClientRefNo,'') = ISNULL(FACTEXPDET.FED_NOPARTEAUX,'') INNER JOIN
	                      PAIS ON FACTEXPDET.PA_CODIGO = PAIS.PA_CODIGO AND rtrim(TempEntryConcilia.Country) = PAIS.PA_ISO
	WHERE     (TempEntryConcilia.ETA_CODIGO IS NULL)




	Update TempEntryConcilia
	set BrokerCode=(select max(BrokerCode) from TempEntryConcilia where BrokerCode is not null)
	where BrokerCode is null

	Update TempEntryConcilia
	set SpecialProgramIndicator='N'
	where SpecialProgramIndicator is null



-- ===================================== Tabla ENTRYSUM ==============================================
/*
Verificaciones que hace:
- Verifica los entries que no existen en InTrade. 
- Verifica los No. de parte que pudieran venir de mas en una factura en el archivo de UPS. 
- Verifica que las facturas relacionadas al entry en el archivo de UPS se encuentren en la relacion de intrade. 
- Verifica que registros se encuentran en el archivo sin Factura y/o No. de parte (no los concilia). 
- Verifica que registros tienen diferencias en la fraccion arancelaria y la actualiza. 
- Verifica que registros tienen diferencias en el Special Program Indicator y lo actualiza. 
- Verifica que registros tienen diferencias en tasa y la actualiza. 
- Hace una agrupaci>n de informaci>n en base a No. Parte + Entry + Factura y compara las suma de cantidades y valor gravable en base a la agrupaci>n, esto lo hace asi porque en una misma factura puede ir incluido un mismo numero de parte y como 
  la cantidad puede ser uno de los datos que este mal no se hace la liga a traves de este.
*/
		if exists (select et_codigo from TempEntryConcilia where et_codigo is null) 
		begin
			if @lenguaje <> 2 
 				set @mensaje = ', No existe en el sistema'
			else
				set @mensaje = ', Does not exists'

			insert into ENTRYCONCILIALOG(iml_mensaje, IML_TIPO)
			SELECT 'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje, 'E'
			FROM         TempEntryConcilia 
			WHERE     et_codigo is null
			GROUP BY BrokerCode, TempEntryConcilia.EntryNumber
			
			Update TempEntryConcilia
			set Texto='ENTRY NO EXISTE EN INTRADE'
			WHERE  et_codigo is null

		end


		-- No. Partes que no Existen en Factura

			if @lenguaje <> 2 
 				set @mensaje = ', Imposible conciliar el Entry, No. Parte  no Existe en Factura'
			else
				set @mensaje = ', Impossible to conciliate the Entry, Part No. does not exist in Invoice'

			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)
			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje+' (Part: '+RTRIM(PartNumber collate database_default)+', Invoice: '+RTRIM(SupplierInvNo collate database_default)+')', TempEntryConcilia.et_codigo, 'E'
			FROM         TempEntryConcilia
			WHERE (et_codigo IS NOT NULL) and (eta_codigo IS NULL) and (PartNumber IS NOT NULL) and
			                 (SupplierInvNo IS NOT NULL) AND RTRIM(PartNumber collate database_default) +isnull(ClientRefNo collate database_default,'') not in
				(select fed_noparte+isnull(fed_noparteaux,'') from factexpdet inner join factexp on factexpdet.fe_CODIGO=factexp.fe_codigo where factexp.fe_folio=RTRIM(SupplierInvNo))
			GROUP BY EntryNumber, BrokerCode, SupplierInvNo, PartNumber, et_codigo, ClientRefNo


		-- Facturas que no Existen en Entries

			if @lenguaje <> 2 
 				set @mensaje = ', Imposible conciliar el Entry, No. Factura no Existe en Entry'
			else
				set @mensaje = ', Impossible to conciliate the Entry, Invoice No. does not exist in Entry'

			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)
			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje+' (Invoice: '+RTRIM(SupplierInvNo collate database_default)+')', TempEntryConcilia.et_codigo, 'E'
			FROM         TempEntryConcilia
			WHERE (et_codigo IS NOT NULL) and (eta_codigo IS NULL) and (PartNumber IS NOT NULL) and
			                 (SupplierInvNo IS NOT NULL) AND 
				RTRIM(SupplierInvNo) not in (select fe_folio from factexp inner join entrysum on factexp.et_codigo=entrysum.et_codigo where 
								ENTRYSUM.ET_ENTRY_NO= TempEntryConcilia.BrokerCode + TempEntryConcilia.EntryNumber or
								ENTRYSUM.ET_ENTRY_NO = TempEntryConcilia.EntryNumber)
			GROUP BY EntryNumber, BrokerCode, SupplierInvNo, PartNumber, et_codigo


		-- Entries sin Factura y/o No. parte

			if @lenguaje <> 2 
 				set @mensaje = ', Imposible conciliar el Entry sin No. Factura y/o No. Parte'
			else
				set @mensaje = ', Impossible to conciliate the Entry without Invoice No. and/or Part No.'

			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)
			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje, TempEntryConcilia.et_codigo, 'E'
			FROM         TempEntryConcilia
			WHERE (eta_codigo IS NULL) and (PartNumber IS NULL AND
			                 SupplierInvNo IS NULL)
			GROUP BY EntryNumber, BrokerCode, et_codigo



		-- Archivo con Cantidades en Ceros

			if @lenguaje <> 2 
 				set @mensaje = ', Imposible conciliar Registros con Cantidad Cero'
			else
				set @mensaje = ', Impossible to conciliate the Records with Quantity in Zero'

			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)
			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje+', (Part: '+rtrim(TempEntryConcilia.PartNumber collate database_default)+' - '+rtrim(TempEntryConcilia.PartDescription collate database_default)+')', TempEntryConcilia.et_codigo, 'E'
			FROM         TempEntryConcilia INNER JOIN
			                      FACTEXPDET ON TempEntryConcilia.ETA_CODIGO = FACTEXPDET.FED_INDICED
			WHERE     (TempEntryConcilia.ETA_CODIGO IS NOT NULL) and Quantity=0



		-- Fraccion Imp. USA

			if @lenguaje <> 2 
 				set @mensaje = ', Fraccion Arancelaria Diferente (Conciliada)'
			else
				set @mensaje = ', Different HTS (Conciliated)'


			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)
			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje+'(HST Actual: '+ARANCEL.AR_FRACCION collate database_default+', HTS Agencia: '+ARANCEL_1.AR_FRACCION collate database_default+')', TempEntryConcilia.et_codigo, 'A'
			FROM    TempEntryConcilia INNER JOIN
		                      FACTEXPDET ON TempEntryConcilia.ETA_CODIGO = FACTEXPDET.FED_INDICED INNER JOIN
		                      ARANCEL ON FACTEXPDET.AR_IMPFO = ARANCEL.AR_CODIGO AND rtrim(TempEntryConcilia.HarmonizedNo) <> ARANCEL.AR_FRACCION INNER JOIN
		                      ARANCEL ARANCEL_1 ON rtrim(TempEntryConcilia.HarmonizedNo) = ARANCEL_1.AR_FRACCION
			WHERE TempEntryConcilia.eta_codigo IS NOT NULL


			if @lenguaje <> 2 
 				set @mensaje = ', Indicador Nafta Diferente (Conciliado)'
			else
				set @mensaje = ', Different Nafta Indicator (Conciliated)'


			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)

			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje+', (Part: '+rtrim(TempEntryConcilia.PartNumber)+' - '+rtrim(TempEntryConcilia.PartDescription collate database_default)+')', TempEntryConcilia.et_codigo, 'A'
			FROM         TempEntryConcilia INNER JOIN
			                      FACTEXPDET ON TempEntryConcilia.ETA_CODIGO = FACTEXPDET.FED_INDICED AND 
			                      TempEntryConcilia.SpecialProgramIndicator <> FACTEXPDET.FED_NAFTA
			WHERE     (TempEntryConcilia.ETA_CODIGO IS NOT NULL)
	
	
			if @lenguaje <> 2 
 				set @mensaje = ', Tasa Diferente (Conciliado)'
			else
				set @mensaje = ', Different Rate (Conciliated)'


			insert into ENTRYCONCILIALOG(iml_mensaje, et_codigo, IML_TIPO)

			SELECT     'Entry.: '+BrokerCode collate database_default+'-'+right(TempEntryConcilia.EntryNumber collate database_default,8)+@mensaje+', (Part: '+rtrim(TempEntryConcilia.PartNumber)+' - '+rtrim(TempEntryConcilia.PartDescription collate database_default)+')', TempEntryConcilia.et_codigo, 'A'
			FROM         TempEntryConcilia INNER JOIN
			                      FACTEXPDET ON TempEntryConcilia.ETA_CODIGO = FACTEXPDET.FED_INDICED
			WHERE     (TempEntryConcilia.ETA_CODIGO IS NOT NULL) AND ((rtrim(TempEntryConcilia.DutyRate) <> FACTEXPDET.FED_RATEIMPFO) OR
			                (FACTEXPDET.FED_RATEIMPFO IS NULL))


	 
		--A la columna de CommercialValue y GRAVABLE se les excluye el valor no gravable de empaque porque este se separa en otro registro



		INSERT INTO TempEntryConcilia(BrokerCode, EntryNumber, PartNumber, Country, Quantity, SpecialProgramIndicator, HarmonizedNo, CommercialValue, DutyValue, DutyRate, DutyPaid,
	                       SupplierInvNo, Texto, PartDescription, EntryDate, ClientRefNo, NueveOchoCeroDosValue)
		SELECT     LEFT(dbo.ENTRYSUM.ET_ENTRY_NO,3) as BrokerCode, RIGHT(dbo.ENTRYSUM.ET_ENTRY_NO,8) as EntryNumber, FACTEXPDET.FED_NOPARTE, dbo.PAIS.PA_ISO, SUM(FACTEXPDET.FED_CANT) AS FED_CANT, 
					CASE WHEN FED_NAFTA='S' OR ARANCEL.AR_FRACCION LIKE '9801%' then 'N' else FED_NAFTA end, ARANCEL.AR_FRACCION,  
				round(CASE WHEN (max(CFT_TIPO) = 'P' or max(CFT_TIPO) = 'S') AND MAX(FED_TIP_ENS)<>'C' THEN
					SUM((FACTEXPDET.FED_CANT * (FACTEXPDET.FED_GRA_MP + FACTEXPDET.FED_GRA_MO + FACTEXPDET.FED_GRA_EMP + FACTEXPDET.FED_GRA_ADD
		                       + FACTEXPDET.FED_GRA_GI + FACTEXPDET.FED_GRA_GI_MX + FACTEXPDET.FED_NG_MP +/* FACTEXPDET.FED_NG_EMP +*/ FACTEXPDET.FED_NG_ADD))) ELSE SUM(FACTEXPDET.FED_COS_TOT) END,2) AS CommercialValue,
			                      round(CASE WHEN (max(CFT_TIPO) = 'P' or max(CFT_TIPO) = 'S') AND MAX(FED_TIP_ENS)<>'C' THEN
					SUM((FACTEXPDET.FED_CANT * (FACTEXPDET.FED_GRA_MP + FACTEXPDET.FED_GRA_MO + FACTEXPDET.FED_GRA_EMP + FACTEXPDET.FED_GRA_ADD
			                       + FACTEXPDET.FED_GRA_GI + FACTEXPDET.FED_GRA_GI_MX + FACTEXPDET.FED_NG_MP +/* FACTEXPDET.FED_NG_EMP +*/ FACTEXPDET.FED_NG_ADD
			                       - FACTEXPDET.FED_NG_USA))) ELSE (CASE WHEN FED_NAFTA='S' OR ARANCEL.AR_FRACCION LIKE '9801%' THEN 0 ELSE SUM(FACTEXPDET.FED_COS_TOT) END) 
					END,2) AS GRAVABLE, FACTEXPDET.FED_RATEIMPFO,
				        round((CASE WHEN (max(CFT_TIPO) = 'P' or max(CFT_TIPO) = 'S') AND MAX(FED_TIP_ENS)<>'C' THEN
									SUM((FACTEXPDET.FED_CANT * (FACTEXPDET.FED_GRA_MP + FACTEXPDET.FED_GRA_MO + FACTEXPDET.FED_GRA_EMP + FACTEXPDET.FED_GRA_ADD
							                       + FACTEXPDET.FED_GRA_GI + FACTEXPDET.FED_GRA_GI_MX + FACTEXPDET.FED_NG_MP /*+ FACTEXPDET.FED_NG_EMP */+ FACTEXPDET.FED_NG_ADD
							                       - FACTEXPDET.FED_NG_USA))) ELSE (CASE WHEN FED_NAFTA='S' OR ARANCEL.AR_FRACCION LIKE '9801%' THEN 0 ELSE SUM(FACTEXPDET.FED_COS_TOT) END) 
									END)*(FACTEXPDET.FED_RATEIMPFO/100),2) as DutyPaid, FACTEXP.FE_FOLIO, 'INTRADE', left(MAX(FED_NAME),25),
				 right(convert(varchar(11),ENTRYSUM.ET_FEC_ENTRYS,101),2)+left(convert(varchar(11),ENTRYSUM.ET_FEC_ENTRYS,101),2)+
				left(right(convert(varchar(11),ENTRYSUM.ET_FEC_ENTRYS,101),7),2), FACTEXPDET.FED_NOPARTE,
				case WHEN max(CFQ_TIPO) <> 'D' and max(CFQ_TIPO) <> 'T' and
				         (max(CFT_TIPO) = 'P' or max(CFT_TIPO) = 'S') then (CASE when (select CF_PEDEXPVAUSA from configuracion)= 'S' then
				           round(sum(FACTEXPDET.FED_CANT * (FACTEXPDET.FED_NG_USA)),2)
				           else
				           round(sum(FACTEXPDET.FED_CANT * (FACTEXPDET.FED_NG_USA + FACTEXPDET.FED_GRA_GI)),2) end)
					else (CASE WHEN FED_NAFTA =  'S' AND max(CFQ_TIPO) <> 'E' then  round(sum(FED_CANT * FED_COS_UNI),2) ELSE 0 END) end as ETD_NG_MAT
		FROM         dbo.FACTEXPDET INNER JOIN
		                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
		                      dbo.ENTRYSUM ON dbo.FACTEXP.ET_CODIGO = dbo.ENTRYSUM.ET_CODIGO LEFT OUTER JOIN
		                      dbo.ARANCEL ARANCEL_1 ON dbo.FACTEXPDET.AR_ORIG = ARANCEL_1.AR_CODIGO LEFT OUTER JOIN
		                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.FACTEXPDET.PA_CODIGO = dbo.PAIS.PA_CODIGO LEFT OUTER JOIN
				      dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     dbo.FACTEXP.FE_FOLIO IN (SELECT rtrim(SupplierInvNo) FROM TempEntryConcilia WHERE ETA_CODIGO IS NOT NULL GROUP BY rtrim(SupplierInvNo))		
		GROUP BY LEFT(dbo.ENTRYSUM.ET_ENTRY_NO,3), RIGHT(dbo.ENTRYSUM.ET_ENTRY_NO,8), FACTEXPDET.FED_NOPARTE, dbo.PAIS.PA_ISO, FACTEXP.FE_FOLIO, FED_NAFTA,
		ARANCEL.AR_FRACCION, FED_NAFTA, ARANCEL_1.AR_FRACCION, FACTEXPDET.FED_RATEIMPFO, ENTRYSUM.ET_FEC_ENTRYS



-- EMPAQUE USA DEL PRODUCTO TERMINADO


		INSERT INTO TempEntryConcilia(BrokerCode, EntryNumber, PartNumber, Country, Quantity, SpecialProgramIndicator, HarmonizedNo, CommercialValue, DutyValue, DutyRate, DutyPaid,
	                       SupplierInvNo, Texto, PartDescription, EntryDate, ClientRefNo, NueveOchoCeroDosValue)
		SELECT     LEFT(dbo.ENTRYSUM.ET_ENTRY_NO,3) as BrokerCode, RIGHT(dbo.ENTRYSUM.ET_ENTRY_NO,8) as EntryNumber, NULL, 'US', 0, 
					'N', ARANCEL_1.AR_FRACCION, ROUND(SUM(FACTEXPDET.FED_CANT*FACTEXPDET.FED_NG_EMP),2) as CommercialValue, 
			                ROUND(SUM(FACTEXPDET.FED_CANT*FACTEXPDET.FED_NG_EMP),2), 0, 0, FACTEXP.FE_FOLIO, 'INTRADE', 'US GDS EXPD FOR TEMP USE',
				 right(convert(varchar(11),ENTRYSUM.ET_FEC_ENTRYS,101),2)+left(convert(varchar(11),ENTRYSUM.ET_FEC_ENTRYS,101),2)+
				left(right(convert(varchar(11),ENTRYSUM.ET_FEC_ENTRYS,101),7),2), 'NA',
				0
		FROM         dbo.FACTEXPDET INNER JOIN
		                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
		                      dbo.ENTRYSUM ON dbo.FACTEXP.ET_CODIGO = dbo.ENTRYSUM.ET_CODIGO LEFT OUTER JOIN
		                      dbo.ARANCEL ARANCEL_1 ON dbo.FACTEXPDET.AR_NG_EMP = ARANCEL_1.AR_CODIGO 
		WHERE     RIGHT(dbo.ENTRYSUM.ET_ENTRY_NO,8) IN (SELECT rtrim(EntryNumber) FROM TempEntryConcilia WHERE ETA_CODIGO IS NOT NULL GROUP BY rtrim(EntryNumber))		
		AND ARANCEL_1.AR_FRACCION LIKE '9801%'
		GROUP BY LEFT(dbo.ENTRYSUM.ET_ENTRY_NO,3), RIGHT(dbo.ENTRYSUM.ET_ENTRY_NO,8), ARANCEL_1.AR_FRACCION, ENTRYSUM.ET_FEC_ENTRYS, FACTEXP.FE_FOLIO





		if (select count(*) from TempEntryConcilia where Texto='INTRADE')> 0 and
		   (select count(*) from TempEntryConcilia where Texto='ENTRY AGENCIA')> 0 

		INSERT INTO TempEntryConcilia(BrokerCode, EntryNumber, SupplierInvNo, PartNumber, HarmonizedNo, Country, Quantity, DutyValue, CommercialValue, 
		                      NueveOchoCeroDosValue, Texto)
		SELECT     BrokerCode, EntryNumber, SupplierInvNo, PartNumber, HarmonizedNo, Country, round(SUM(Quantity),2), round(SUM(DutyValue),2), round(SUM(CommercialValue),2), 
		                      round(SUM(NueveOchoCeroDosValue),2), 'Z DIFERENCIA'
		FROM         TempEntryConcilia
		WHERE Texto='INTRADE' or Texto='ENTRY AGENCIA'
		GROUP BY BrokerCode, EntryNumber, SupplierInvNo, PartNumber, Country, HarmonizedNo


GO
