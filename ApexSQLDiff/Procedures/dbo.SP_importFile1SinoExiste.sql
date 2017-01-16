SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_importFile1SinoExiste]   as

declare @maximo int, @MA_CODIGO INT, @AR_FRACCION VARCHAR(10),@ME_CODIGO INT, @ME_CODIGO2 INT, @CONSECUTIVO int, @TCO_MANUFACTURA INT, 
@TCO_COMPRA INT, @AR_CODIGO INT, @FID_INDICED int, @FI_CODIGO int, @FE_CODIGO int,
@FIC_INDICEC int, @FEC_INDICEC INT, @FED_INDICED int, @DIRIMPORTER int, @importer int, @fi_tipo varchar(5)

DECLARE @AG_MEX INT, @AG_USA INT, @CL_CODIGO INT, @CL_MATRIZ INT, @CL_TRAFICO INT, @CT_CODIGO INT, @DIRMATRIZ INT, 
	@MT_CODIGO INT, @PU_CARGA INT, @PU_DESTINO INT, @PU_ENTRADA INT, @PU_SALIDA INT, @ZO_CODIGO INT, @DIRPRINC INT,
	@FECHATEXT VARCHAR(11), @MO_CODIGO INT, @IT_ENTRADA INT, @InsuranceCost decimal(38,6), @FreightCost decimal(38,6), @PackingCost decimal(38,6), @OthersCost decimal(38,6),
	@TotalMetalPck decimal(38,6), @TotalPlasticPck decimal(38,6), @fidIndicedmin int, @cp_codigo int


declare @FileType varchar(6), @TMMBCTransNumber varchar(10), @TMMBCTransNumberOri varchar(10), @Route varchar(10), @Tf_codigo int, @Folio varchar(20), 
	@TrailerNo varchar(20), @TotalPackages int



         SELECT @AG_MEX=AG_MEX,  @AG_USA=AG_USA, @CL_CODIGO=CL_CODIGO, @CL_MATRIZ=CL_MATRIZ, @CL_TRAFICO=CL_TRAFICO, 
		@CT_CODIGO=CT_CODIGO, @MT_CODIGO=MT_CODIGO, @PU_CARGA=PU_CARGA, @PU_DESTINO=PU_DESTINO, 
		@PU_ENTRADA=PU_ENTRADA, @PU_SALIDA=PU_SALIDA, @ZO_CODIGO=ZO_CODIGO,
		@IT_ENTRADA= IT_ENTRADA, @MO_CODIGO=MO_CODIGO, 
 		@DIRPRINC=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_CODIGO),
		@DIRMATRIZ=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_MATRIZ)
	 FROM CLIENTE    WHERE CL_EMPRESA='S'

	SET @FECHATEXT = dbo.DateToText(GETDATE(),101)

	exec sp_droptable 'FolioFile1'
        
	select 'FI_FOLIO' =  CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END,
		0 as 'FI_CODIGO', FileType
	into dbo.FolioFile1
	from TempImpFile1
	group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END, FileType


	if exists(select * from TempImpFile1 where FileType like'FIL1S%' or FileType like 'FIL1N%' )
	begin
		Declare Cur_FactImp cursor for
			select FileType, TMMBCTransNumber, TMMBCTransNumberOri, max(Route), 'TF_TIPO'=CASE when TMMBCTransNumber like 'V%' then 'V' else 'F' end,
		 		'TF_CODIGO' = CASE WHEN FileType LIKE 'FIL1S%' then (case when PedimentoClass='F2' then 24 when PedimentoClass='A6' then 5  when PedimentoClass='V1' then 11 else 4 end)
				else  (case when PedimentoClass='I1' or PedimentoClass='H1' then 25  when PedimentoClass='V1' then 12 else 2 end) end,
			              'FI_FOLIO' =  CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO') then TMMBCTransNumber else TMMBCTransNumberOri END, 
				max(TrailerNo), max(TotalPackages),
				max(InsuranceCost)/10000, max(FreightCost)/10000, max(PackingCost)/10000, max(OthersCost)/10000, sum(TotalMetalPck), sum(TotalPlasticPck), max(importer),
				(select cp_codigo from claveped where cp_clave=PedimentoClass)
			from TempImpFile1
			group by FileType, TMMBCTransNumber, TMMBCTransNumberOri,
		 		CASE WHEN FileType LIKE 'FIL1S%' then (case when PedimentoClass='F2' then 24 when PedimentoClass='A6' then 5 when PedimentoClass='V1' then 11 else 4 end)
				else  (case when PedimentoClass='I1' or PedimentoClass='H1' then 25 when PedimentoClass='V1' then 12 else 2 end) end,
			        CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO') then TMMBCTransNumber else TMMBCTransNumberOri END, PedimentoClass
			order by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO') then TMMBCTransNumber else TMMBCTransNumberOri END
		Open Cur_FactImp
		Fetch Next from Cur_FactImp into @FileType, @TMMBCTransNumber, @TMMBCTransNumberOri, @Route, @fi_tipo,
			@Tf_codigo, @Folio, @TrailerNo, @TotalPackages, @InsuranceCost, @FreightCost, @PackingCost, @OthersCost,
			@TotalMetalPck, @TotalPlasticPck, @importer, @cp_codigo
		While (@@fetch_status =0 )
		begin
	
			SET @DIRIMPORTER = (select max(di_indice) from dir_cliente   where cl_codigo =@importer  and di_fiscal='S'  )			

			if @Folio like 'S%' or @Folio like 'V%' --import
			begin
	                       
			             INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_TIPO, RI_CBFORMA) 
				VALUES ('FI_FOLIO = '+@Folio+', '+'FI_FECHA = '+@FECHATEXT, 'I',131)
	
	
				if not exists (select * from factimp where fi_folio=@Folio)
				begin
				          EXEC SP_GETCONSECUTIVO @TIPO='FI',@VALUE=@CONSECUTIVO OUTPUT
			
				          INSERT INTO FACTIMP (FI_CODIGO,TF_CODIGO ,FI_FECHA ,FI_TIPOCAMBIO ,FI_FOLIO ,FI_TIPO ,TQ_CODIGO ,FI_TRANSNOORIG ,FI_TRANSNO,
						FI_TRAC_MX ,RU_CODIGO ,FI_TOTALB ,AG_MEX ,AG_USA ,/*ymav*/CL_COMP ,CL_DESTFIN ,CL_DESTINT ,CL_EXP ,CL_IMP ,CL_PROD ,CL_VEND ,
						CT_CODIGO, DI_COMP, DI_DESTFIN ,DI_DESTINT ,DI_EXP ,DI_IMP ,DI_PROD ,DI_PROVEE ,DI_VEND ,FI_PFINAL ,FI_PINICIAL ,IT_CODIGO,
						MO_CODIGO, MT_CODIGO, PR_CODIGO ,PU_CARGA ,PU_DESTINO ,PU_ENTRADA ,PU_SALIDA ,ZO_CODIGO, AGT_CODIGO, CP_CODIGO ) 
			
				           SELECT @CONSECUTIVO, @TF_CODIGO, @FECHATEXT, dbo.ExchangeRate(@FECHATEXT), @Folio,
					             @fi_tipo, 12, @TMMBCTransNumber, @TMMBCTransNumberOri, @TrailerNo, isnull((select ru_codigo from ruta where ru_corto=@Route),0), @TotalPackages,
						@AG_MEX, @AG_USA, 
						
    					  /*30-enero-2006 Yolanda */												
								CASE WHEN (@Folio LIKE 'V%') THEN 
											@CL_CODIGO						
						    ELSE
		    			  /*30-enero-2006 Yolanda */												
						
						   
				      			 @CL_MATRIZ
		    			  
		    			  /*30-enero-2006 Yolanda */																		
						    END	 
		    			  /*30-enero-2006 Yolanda */																		    			  
		    			  						    
							 , 
						
						@CL_CODIGO, @CL_CODIGO, @CL_MATRIZ, @CL_CODIGO, @CL_MATRIZ, @CL_MATRIZ, 
						@CT_CODIGO, 

    					  /*30-enero-2006 Yolanda */												
								CASE WHEN (@Folio LIKE 'V%') THEN 
											@DIRPRINC						
						    ELSE
		    			  /*30-enero-2006 Yolanda */												
					      	
						
						         @DIRMATRIZ
						
		    			  /*30-enero-2006 Yolanda */												
		    			  END
		    			  /*30-enero-2006 Yolanda */												
		    			  		    			  						
						
						, 
						
						
						
						
						@DIRPRINC,@DIRPRINC, @DIRMATRIZ, @DIRPRINC, @DIRMATRIZ, 
					     	
					     	    /*30-enero-2006 Yolanda */						
										CASE WHEN (@Folio like 'V%') then 
														(select di_indice from dir_cliente
														where cl_codigo in (
																	--select OriginId from TempimpFile1
																	--where @Folio in ( 
																	--				select CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END
																	--				from tempimpFile1
																	--				group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END
																	--				)
																	--group by OriginId

--
																	select OriginId from TempimpFile1
																	where (CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END) = ( 
																					select CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END
																					from tempimpFile1
																					where CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END = @Folio	
																					group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END
																					)
																	group by OriginId
																	)
														and dir_cliente.di_fiscal='S')
										   ELSE								     	
					     	    /*30-enero-2006 Yolanda */												
								
									 			case when (@importer is null)  or (@importer=0)  then @DIRMATRIZ else @DIRIMPORTER end

					     	/*30-enero-2006 Yolanda */						
					     	END
					     	/*30-enero-2006 Yolanda */												
									
									,
						
						
						 @DIRMATRIZ, @FECHATEXT, @FECHATEXT, 
						@IT_ENTRADA, @MO_CODIGO, @MT_CODIGO, 
					
					     	/*30-enero-2006 Yolanda */
								CASE WHEN (@Folio like 'V%') then 
											(select OriginId from TempimpFile1
											--where @Folio in ( 
											--			select CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END
											--			from tempimpFile1
											--			group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END
											--			)
											--group by OriginId)

											where (CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END) =( 
														select CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END
														from tempimpFile1
														where CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END = @Folio
														group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END
														)
											group by OriginId)



								  ELSE						
						    /*30-enero-2006 Yolanda */						
						
						
							        case when (@importer is null) or (@importer=0) then @CL_MATRIZ else @importer end
						
						
							 /*30-enero-2006 Yolanda */						
						   END			
						   /*30-enero-2006 Yolanda */						
												
						,
						
						 @PU_CARGA, @PU_DESTINO, @PU_ENTRADA, @PU_SALIDA, @ZO_CODIGO,
						isnull((SELECT AGT_CODIGO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AG_CODIGO = @AG_MEX),0), @cp_codigo
			
	
	
					-- incrementables 
					if @InsuranceCost > 0 and not exists(select * from factimpincrementa where FI_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='SEGURO'))
					begin
						INSERT INTO FACTIMPINCREMENTA(FI_CODIGO, IC_CODIGO, FII_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='SEGURO'), @InsuranceCost
					end
		
					if @FreightCost > 0 and not exists (select * from factimpincrementa where FI_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='FLETES TERRESTRE'))
					begin
						INSERT INTO FACTIMPINCREMENTA(FI_CODIGO, IC_CODIGO, FII_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='FLETES TERRESTRE'), @FreightCost
					end
		
					if @OthersCost > 0 and not exists (select * from factimpincrementa where FI_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='OTROS'))
					begin
						INSERT INTO FACTIMPINCREMENTA(FI_CODIGO, IC_CODIGO, FII_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='OTROS'), @OthersCost
					end
		
					if @PackingCost > 0 and not exists (select * from factimpincrementa where FI_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='EMBALAJE'))
					begin
						INSERT INTO FACTIMPINCREMENTA(FI_CODIGO, IC_CODIGO, FII_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='EMBALAJE'), @PackingCost
					end
		
					-- empaque adicional 
					IF @TotalMetalPck >0 and not exists (select * from FACTIMPEMPAQUEADICIONAL where FI_CODIGO=@CONSECUTIVO and MA_CODIGO in (select ma_codigo from maestro where ma_noparte='METPACK'))
					begin
						INSERT INTO FACTIMPEMPAQUEADICIONAL (FI_CODIGO, MA_CODIGO, MA_NOPARTE, FIAD_CANTIDAD, MA_GENERICO, EQ_GEN, ME_CODIGO)
						SELECT @CONSECUTIVO, (select ma_codigo from maestro where ma_noparte='METPACK'), 'METPACK', @TotalMetalPck, 0, 1, 19
					end
		
		
					IF @TotalPlasticPck >0 and not exists (select * from FACTIMPEMPAQUEADICIONAL where FI_CODIGO=@CONSECUTIVO and MA_CODIGO in (select ma_codigo from maestro where ma_noparte='PLASTPACK'))
					begin
						INSERT INTO FACTIMPEMPAQUEADICIONAL (FI_CODIGO, MA_CODIGO, MA_NOPARTE, FIAD_CANTIDAD, MA_GENERICO, EQ_GEN, ME_CODIGO)
						SELECT @CONSECUTIVO, (select ma_codigo from maestro where ma_noparte='PLASTPACK'), 'PLASTPACK', @TotalPlasticPck, 0, 1, 19
					end
				end
				else
				select @CONSECUTIVO=fi_codigo from factimp where fi_folio=@Folio

	
			end
			else ---------------------------------------------------------------------------  export -------------------------------------------------------------------------------------------------------------
			if @Folio like 'N%'  
			begin
	
 		                INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_TIPO, RI_CBFORMA) 
				VALUES ('FE_FOLIO = '+@Folio+', '+'FE_FECHA = '+@FECHATEXT, 'E', 131)
	
				if not exists (select * from factexp where fe_folio=@Folio)
				begin
	
				          EXEC SP_GETCONSECUTIVO @TIPO='FE',@VALUE=@CONSECUTIVO OUTPUT
			
				          INSERT INTO FACTEXP (FE_CODIGO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_FOLIO, FE_TIPO, TQ_CODIGO, FE_TRANSNOORIG, FE_TRANSNO,
						FE_TRAC_MX1, RU_COMPANY1, FE_TOTALB, AG_MX, AG_US, CL_COMP, CL_DESTFIN, CL_DESTINI, CL_EXP, CL_IMP, CL_PROD, CL_VEND,
						CT_COMPANY1, DI_COMP, DI_DESTFIN, DI_DESTINI, DI_EXP, DI_IMP, DI_PROD,  DI_VEND, FE_PFINAL, FE_PINICIAL, IT_COMPANY1,
						MO_CODIGO, MT_COMPANY1, PU_CARGA, PU_DESTINO, PU_ENTRADA, PU_SALIDA, CL_EXPFIN, DI_EXPFIN, AGT_CODIGO, CP_CODIGO) 
			
	
				           SELECT @CONSECUTIVO, @TF_CODIGO, @FECHATEXT, dbo.ExchangeRate(@FECHATEXT), @Folio, 'F', 12, @TMMBCTransNumber, @TMMBCTransNumberOri, 
						@TrailerNo, isnull((select ru_codigo from ruta where ru_corto=@Route),0), @TotalPackages, @AG_MEX, @AG_USA, @CL_MATRIZ,
						 @CL_MATRIZ, @CL_MATRIZ, @CL_CODIGO, @importer, @CL_CODIGO, @CL_CODIGO, 
						@CT_CODIGO, @DIRMATRIZ, 				
						@DIRMATRIZ,				 
						@DIRMATRIZ, @DIRPRINC, @DIRIMPORTER, @DIRPRINC, @DIRPRINC, @FECHATEXT, @FECHATEXT, 
						@IT_ENTRADA, @MO_CODIGO, @MT_CODIGO, @PU_CARGA, @PU_DESTINO, @PU_ENTRADA, @PU_SALIDA,  @CL_CODIGO, @DIRPRINC,
						isnull((SELECT AGT_CODIGO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AG_CODIGO = @AG_MEX),0)	, @cp_codigo
	
	
					--incrementables	
					if @InsuranceCost > 0 and not exists(select * from FACTEXPINCREMENTA where FE_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='SEGURO'))
					begin
						INSERT INTO FACTEXPINCREMENTA(FE_CODIGO, IC_CODIGO, FEI_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='SEGURO'), @InsuranceCost
					end
	
					if @FreightCost > 0 and not exists (select * from FACTEXPINCREMENTA where FE_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='FLETES TERRESTRE'))
					begin
						INSERT INTO FACTEXPINCREMENTA(FE_CODIGO, IC_CODIGO, FEI_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='FLETES TERRESTRE'), @FreightCost
					end
	
					if @OthersCost > 0 and not exists (select * from FACTEXPINCREMENTA where FE_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='OTROS'))
					begin
						INSERT INTO FACTEXPINCREMENTA(FE_CODIGO, IC_CODIGO, FEI_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='OTROS'), @OthersCost
					end
	
					if @PackingCost > 0 and not exists (select * from FACTEXPINCREMENTA where FE_CODIGO=@CONSECUTIVO and  ic_codigo in (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='EMBALAJE'))
					begin
						INSERT INTO FACTEXPINCREMENTA(FE_CODIGO, IC_CODIGO, FEI_VALOR)
						SELECT @CONSECUTIVO, (SELECT IC_CODIGO FROM INCREMENTABLE WHERE IC_NOMBRE='EMBALAJE'), @PackingCost
					end
	
	
					-- empaque adicional 
					IF @TotalMetalPck >0 and not exists (select * from FACTEXPEMPAQUEADICIONAL where FE_CODIGO=@CONSECUTIVO and MA_CODIGO in (select ma_codigo from maestro where ma_noparte='METPACK'))
					begin
						INSERT INTO FACTEXPEMPAQUEADICIONAL (FE_CODIGO, MA_CODIGO, MA_NOPARTE, FEAD_CANTIDAD, MA_GENERICO, EQ_GEN, ME_CODIGO)
						SELECT @CONSECUTIVO, (select ma_codigo from maestro where ma_noparte='METPACK'), 'METPACK', @TotalMetalPck, 0, 1, 19
					end
	
	
					IF @TotalPlasticPck >0 and not exists (select * from FACTEXPEMPAQUEADICIONAL where FE_CODIGO=@CONSECUTIVO and MA_CODIGO in (select ma_codigo from maestro where ma_noparte='PLASTPACK'))
					begin
						INSERT INTO FACTEXPEMPAQUEADICIONAL (FE_CODIGO, MA_CODIGO, MA_NOPARTE, FEAD_CANTIDAD, MA_GENERICO, EQ_GEN, ME_CODIGO)
						SELECT @CONSECUTIVO, (select ma_codigo from maestro where ma_noparte='PLASTPACK'), 'PLASTPACK', @TotalPlasticPck, 0, 1, 19
					end
					
				end
				else
				select @CONSECUTIVO=fe_codigo from factexp where fe_folio=@Folio



				insert into importlog (iml_mensaje, iml_cbforma)
				select  ( 'En la Factura : '+ltrim(TMMBCTransNumber)+ ' NO coincide el PAIS (Supplier Country) del File 1 con el PAIS de la direccion de la empresa Destino Final '), 131 
				from tempimpfile1 
				where TMMBCTransNumber=@Folio
				AND  (TEMPIMPFILE1.CountrySupplierPurch) <>(SELECT PA_CODIGO FROM DIR_CLIENTE WHERE cl_codigo=@CL_MATRIZ AND DI_FISCAL='S') 

			end
                      
			update FolioFile1
			set fi_codigo=@CONSECUTIVO
			where fi_folio = @Folio	

	
		Fetch Next from Cur_FactImp into @FileType, @TMMBCTransNumber, @TMMBCTransNumberOri, @Route, @fi_tipo,
			@Tf_codigo, @Folio, @TrailerNo, @TotalPackages, @InsuranceCost, @FreightCost, @PackingCost, @OthersCost,
			@TotalMetalPck, @TotalPlasticPck, @importer, @cp_codigo
		end
	
	        Close Cur_FactImp
	        Deallocate Cur_FactImp


		-------------------- insercion de detalles -------------------------------

		if exists(select * from TempImpFile1 where TMMBCTransNumber like 'S%' or TMMBCTransNumber like 'V%')
		begin


			if exists (select * from factimpdet where fi_codigo  in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%'))
				delete from factimpdet where fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')
	
	
			if exists (select * from factimpcont where fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%'))
				delete from factimpcont where fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')



	
		                INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,EQ_EXPFO2 ,EQ_EXPFO ,FID_PES_UNI ,FID_PES_UNILB ,FID_PES_NETLB,
				    FID_PES_BRULB ,FID_COS_TOT ,FID_COS_UNI , FID_PES_NET, FID_PES_BRU ,FID_DEF_TIP ,EQ_IMPMX ,FID_POR_DEF, FID_NOPARTEAUX, 
					    FID_ORD_COMP, FID_NOPARTE, FID_NAME, FID_NOMBRE, FID_CANT_ST, ME_CODIGO, PA_CODIGO, AR_IMPMX, AR_EXPFO, 
					     CS_CODIGO, EQ_GEN, FID_SEC_IMP, MA_CODIGO, MA_GENERICO, ME_ARIMPMX, ME_GEN, PR_CODIGO ,SPI_CODIGO, TI_CODIGO, FID_SALDO) 
		
				SELECT     TempImpFile1.Codigo, (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1SO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END)), 
						 'EQ_EXPFO2'=CASE WHEN (QtyUSHTS2>0) and (QtyofPart>0) then round(QtyUSHTS2/QtyofPart,6) else 1 END,
					         'EQ_EXPFO'=CASE WHEN (QtyUSHTS1>0) and (QtyofPart>0) then round(QtyUSHTS1/QtyofPart,6) else 1  END,
					         round((TempImpFile1.NetWeight / 10000),6), 
					         round((TempImpFile1.NetWeight / 10000) * 2.20462442018378,6), 
				                      round((TempImpFile1.NetWeight / 10000) * 2.20462442018378 * TempImpFile1.QtyofPart,6), 
				                      round((TempImpFile1.NetWeight / 10000) * 2.20462442018378 * TempImpFile1.QtyofPart,6), 
				                      round(TempImpFile1.UnitPrice / 10000 * TempImpFile1.QtyofPart,6), 
					         round(TempImpFile1.UnitPrice / 10000,6), 
				                      round((TempImpFile1.NetWeight / 10000) * TempImpFile1.QtyofPart,6), 
				                      round((TempImpFile1.NetWeight / 10000) * TempImpFile1.QtyofPart,6), 
					         'FID_DEF_TIP'= CASE WHEN (CommercialTreatment='PS') then 'S' WHEN (CommercialTreatment='TL') then 'P' else 'G'  END,
					         'EQ_IMPMX'=CASE WHEN (QtyHTSMex>0) and (QtyofPart>0) then round((QtyHTSMex/10000)/QtyofPart,6) else 1  END,
					         -1, MAESTRO.MA_NOPARTEAUX, TempImpFile1.TMMBCManifiestPO, TempImpFile1.PartNo, TempImpFile1.DescripEng, 
				                      TempImpFile1.DescripSpa, isnull(TempImpFile1.QtyofPart,0), isnull(TempImpFile1.UMofPart,0), TempImpFile1.CountryOriginDest, 

				                      ARANCEL_2.AR_CODIGO, ARANCEL_1.AR_CODIGO, MAESTRO.CS_CODIGO, isnull(MAESTRO.EQ_GEN,1), 
					        'MA_SEC_IMP'=case when CommercialTreatment='PS' then isnull(MAESTRO.MA_SEC_IMP,0) else 0 end, 
				                      MAESTRO.MA_CODIGO, isnull(MAESTRO.MA_GENERICO,0), isnull(ARANCEL_2.ME_CODIGO,36), isnull(MAESTRO_1.ME_COM,19), 
				                      
							     	--30-enero-2006 Yolanda 
										CASE WHEN (@Folio like 'V%') then 
													(select OriginId from TempimpFile1
													--where @Folio in ( 
													--			select CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END
													--			from tempimpFile1
													--			group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END
													--			)
													--group by OriginId)


													where (CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END) =( 
																select CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END
																from tempimpFile1
																where CASE WHEN (FileType='FIL1SO')or (FileType='FIL1NO') then (TMMBCTransNumber) else TMMBCTransNumberOri END = @Folio
																group by CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO')  then TMMBCTransNumber else TMMBCTransNumberOri END
																)
													group by OriginId)

								  		ELSE						
						    		--30-enero-2006 Yolanda 						                      
				                   
				                     @CL_MATRIZ
				                     
						    		--30-enero-2006 Yolanda 										                     
						    		END  
						    		--30-enero-2006 Yolanda 									                     						    		
						    		
				                     , 
				                     
					        'SPI_CODIGO'=CASE WHEN CommercialTreatment='TL' then isnull(MAESTRO.SPI_CODIGO,0) else 0 end, 
				                      isnull(MAESTRO.TI_CODIGO,10), isnull(TempImpFile1.QtyofPart,0)
				FROM         TempImpFile1 INNER JOIN
				                      MAESTRO   ON TempImpFile1.PartNo = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      MAESTRO MAESTRO_1  ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
				                      ARANCEL ARANCEL_1  ON TempImpFile1.USHTS = ARANCEL_1.AR_FRACCION LEFT OUTER JOIN
				                      ARANCEL ARANCEL_2  ON TempImpFile1.HTSMex = ARANCEL_2.AR_FRACCION
				WHERE     (MAESTRO.MA_INV_GEN = 'i') 
					  and ((CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO') then TMMBCTransNumber else TMMBCTransNumberOri END) like 'S%' 
					  or (CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO') then TMMBCTransNumber else TMMBCTransNumberOri END) like 'V%') 
	  				   and TempImpFile1.Codigo not in (select fid_indiced from factimpdet)			
					   and (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1SO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END))>0
				order by (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1SO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END))



			update factimpdet
			set fid_por_def = dbo.GetAdvalorem(factimpdet.AR_IMPMX, factimpdet.pa_codigo, isnull(factimpdet.FID_DEF_TIP,'G'), isnull(factimpdet.FID_SEC_IMP,0), isnull(factimpdet.SPI_CODIGO,0))	
			from factimpdet inner join factimp on factimpdet.fi_codigo = factimp.fi_codigo
			where factimp.fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')




			 update factimpdet
			 set fid_cantemp = (select max(D1.TotalPackages) from TempImpFile1 D1 
					    where (CASE WHEN (D1.FileType='FIL1SO') then D1.TMMBCTransNumber else D1.TMMBCTransNumberOri END)
					    = factimp.fi_folio)
			 from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo
			 where factimp.fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')
			 and fid_indiced in (select min(D2.fid_indiced) from factimpdet D2 where D2.fi_codigo=factimpdet.fi_codigo)


			 update factimpdet
			 set fid_cantemp = (select sum(D1.fid_cant_st) from factimpdet D1 where D1.fi_codigo=factimpdet.fi_codigo)
			 from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo		
			 where factimp.fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')
			 and (FI_TRAC_MX like '530%' or (FI_TRAC_MX not like '530%' and fid_cantemp=0)) and 
			fid_indiced in (select min(D2.fid_indiced) from factimpdet D2 where D2.fi_codigo=factimpdet.fi_codigo)


			 update factimp
			 set fi_totalb = isnull((select sum(fid_cantemp) from factimpdet where fi_codigo=factimp.fi_codigo),0)
			 where fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')


			update factimpdet
			set tco_codigo = (select tco_codigo from maestrocost where ma_codigo=factimpdet.ma_codigo and
				mac_codigo in (select max(mac_codigo) from maestrocost where ma_codigo=factimpdet.ma_codigo))
			 from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo		
			 where factimp.fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')


			insert into importlog (iml_mensaje, iml_cbforma)
			select 'El total de empaques en el archivo viene en ceros, por lo tanto el total de bultos se importara en ceros.', 131
			 from factimp
			 where factimp.fi_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'S%' or fi_folio like 'V%')
			 and FI_TRAC_MX not like '530%' and fi_totalb = 0



				exec sp_droptable 'tempimpfactimpdetauto'
				CREATE TABLE [dbo].[tempimpfactimpdetauto] (
					[FIDA_INDICEA] [int] IDENTITY (1, 1) NOT NULL ,
					[FID_INDICED] [int] NOT NULL ,
					[FI_CODIGO] [int] NOT NULL ,
					[FID_PELIGROSO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
					[FID_VINNO] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
					[FID_MILLAGE] [int] NOT NULL,
				) ON [PRIMARY]
				
				select @maximo=isnull(max(FIC_INDICEC),0)+1 from FACTIMPCONT
				
				dbcc checkident (tempimpfactimpdetauto, reseed, @maximo) WITH NO_INFOMSGS
			

		              INSERT INTO tempimpfactimpdetauto (FI_CODIGO,FID_INDICED, FID_VINNO ,FID_PELIGROSO ,FID_MILLAGE) 
			      SELECT (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1SO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END)), 
				Codigo, VINNumber, replace(Hazard,'Y', 'S'), Mileage
			      FROM TempImpFile1
			      WHERE (VINNumber is not null and VINNumber<>'') or (Mileage is not null and Mileage<>'') or replace(Hazard,'Y', 'S')<>'N'

	
		              INSERT INTO FACTIMPCONT (FI_CODIGO,FID_INDICED,FIC_INDICEC,FIC_SERIE ,FIC_PELIGROSO ,FIC_MILLAGE ) 
	 		      SELECT FI_CODIGO, FID_INDICED, FIDA_INDICEA, FID_VINNO, FID_PELIGROSO, FID_MILLAGE
			      FROM tempimpfactimpdetauto
 			      WHERE FIDA_INDICEA NOT IN (SELECT FIC_INDICEC FROM FACTIMPCONT) and
    				FID_INDICED in (select fid_indiced from factimpdet where fi_codigo=tempimpfactimpdetauto.fi_codigo)
			      and ((FID_VINNO is not null and FID_VINNO<>'') OR (FID_MILLAGE is not null and FID_MILLAGE<>'') OR (FID_PELIGROSO<>'N'))			      
			      GROUP BY FI_CODIGO, FID_INDICED, FIDA_INDICEA, FID_VINNO, FID_PELIGROSO, FID_MILLAGE



			exec SP_ACTUALIZATASAFACTIMPF1
		end

		
		------------------------------- export -------------------------------------------------

		if exists(select * from TempImpFile1 where TMMBCTransNumber like 'N%')
		begin

			if exists (select * from factexpdet where fe_codigo  in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%'))
				delete from factexpdet where fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')

			if exists (select * from factexpcont where fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%'))
				delete from factexpcont where fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')
	
		
	                INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,EQ_IMPFO ,FED_PES_UNI ,FED_PES_UNILB ,FED_PES_NETLB,
				    FED_PES_BRULB ,FED_COS_TOT ,FED_COS_UNI , FED_PES_NET, FED_PES_BRU ,FED_DEF_TIP ,EQ_EXPMX ,FED_POR_DEF, FED_NOPARTEAUX, 
				    FED_ORD_COMP, FED_NOPARTE, FED_NAME, FED_NOMBRE, FED_CANT, ME_CODIGO, PA_CODIGO, AR_EXPMX, AR_IMPFO, 
				     CS_CODIGO, EQ_GEN, FED_SEC_IMP, MA_CODIGO, MA_GENERICO, ME_AREXPMX, ME_GENERICO, CL_CODIGO ,SPI_CODIGO, TI_CODIGO, FED_TIP_ENS, FED_NAFTA) 
	
			SELECT     TempImpFile1.Codigo, (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1NO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END)), 
				         'EQ_IMPFO'=CASE WHEN (QtyUSHTS1>0) and (QtyofPart>0) then round(QtyUSHTS1/QtyofPart,6) else 1  END,
				         round((TempImpFile1.NetWeight / 10000),6), 
				         round((TempImpFile1.NetWeight / 10000) * 2.20462442018378,6), 
			                      round((TempImpFile1.NetWeight / 10000) * 2.20462442018378 * TempImpFile1.QtyofPart,6), 
			                      round((TempImpFile1.NetWeight / 10000) * 2.20462442018378 * TempImpFile1.QtyofPart,6), 			                      round(TempImpFile1.UnitPrice / 10000 * TempImpFile1.QtyofPart,6), 
				         round(TempImpFile1.UnitPrice / 10000,6), 
			                      round((TempImpFile1.NetWeight / 10000) * TempImpFile1.QtyofPart,6), 
			                      round((TempImpFile1.NetWeight / 10000) * TempImpFile1.QtyofPart,6), 
				         'FED_DEF_TIP'= CASE WHEN (CommercialTreatment='PS') then 'S' WHEN (CommercialTreatment='TL') then 'P' else 'G'  END,
				         'EQ_EXPMX'=CASE WHEN (QtyHTSMex>0) and (QtyofPart>0) then round((QtyHTSMex/10000)/QtyofPart,6) else 1  END,
				         -1, MAESTRO.MA_NOPARTEAUX, TempImpFile1.TMMBCManifiestPO, TempImpFile1.PartNo, TempImpFile1.DescripEng, 
			                      TempImpFile1.DescripSpa, isnull(TempImpFile1.QtyofPart,0), TempImpFile1.UMofPart, 
			                      
			                            TempImpFile1.CountryOriginDest, 			                      
			                      ARANCEL_2.AR_CODIGO, ARANCEL_1.AR_CODIGO, MAESTRO.CS_CODIGO, isnull(MAESTRO.EQ_GEN,1), 'MA_SEC_IMP'=case when CommercialTreatment='PS' then (SELECT SE_CODIGO FROM SECTOR WHERE SE_CLAVE='XIXa') else 0 end, 
			                      MAESTRO.MA_CODIGO, isnull(MAESTRO.MA_GENERICO,0), isnull(ARANCEL_2.ME_CODIGO,36), isnull(MAESTRO_1.ME_COM,19), @CL_MATRIZ, 
                                              --22-mayo-06 
                                                 --'SPI_CODIGO'=CASE WHEN CommercialTreatment='TL'  AND (TempImpFile1.CountryOriginDest)=233 then (select spi_codigo from spi where spi_clave='NAFTA') else 0 end, 
                                                 'SPI_CODIGO'=CASE WHEN CommercialTreatment='TL'  AND ((TempImpFile1.CountryOriginDest=233) or (TempImpFile1.CountryOriginDest=154) or (TempImpFile1.CountryOriginDest=35) ) then (select spi_codigo from spi where spi_clave='NAFTA') else 0 end, 
                                              --22-mayo-06
			                      isnull(MAESTRO.TI_CODIGO,10), isnull(MAESTRO.MA_TIP_ENS,'C'), 'MA_NAFTA'= CASE WHEN (CommercialTreatment='TL') then 'S' else 'N'  END
			FROM         TempImpFile1 INNER JOIN
			                      MAESTRO ON TempImpFile1.PartNo = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
			                      MAESTRO MAESTRO_1  ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
			                      ARANCEL ARANCEL_1  ON TempImpFile1.USHTS = ARANCEL_1.AR_FRACCION LEFT OUTER JOIN
			                      ARANCEL ARANCEL_2  ON TempImpFile1.HTSMex = ARANCEL_2.AR_FRACCION
			WHERE     (MAESTRO.MA_INV_GEN = 'i') 
				  and (CASE WHEN (FileType='FIL1SO') or (FileType='FIL1NO') then TMMBCTransNumber else TMMBCTransNumberOri END) like 'N%'
  				   and TempImpFile1.Codigo not in (select FED_indiced from factexpdet)			
				   and (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1NO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END))>0
			order by (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1NO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END))


			update factexpdet
			set fed_por_def = dbo.GetAdvalorem(factexpdet.AR_IMPMX, factexpdet.pa_codigo, isnull(factexpdet.FED_DEF_TIP,'G'), isnull(factexpdet.FED_SEC_IMP,0), isnull(factexpdet.SPI_CODIGO,0))	
			from factexpdet inner join factexp on factexpdet.fe_codigo = factexp.fe_codigo
			 where factexp.fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')


			 update factexpdet
			 set fed_cantemp = (select max(D1.TotalPackages) from TempImpFile1 D1 
					    where (CASE WHEN (D1.FileType='FIL1NO') then D1.TMMBCTransNumber else D1.TMMBCTransNumberOri END)
					    = factexp.fe_folio)
			 from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo
			 where factexp.fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')
			 and fed_indiced in (select min(D2.fed_indiced) from factexpdet D2 where D2.fe_codigo=factexpdet.fe_codigo)
                         
                         
                         --Cambio para que siempre que las placas sean distintas de "530" y la cantidad de Total de paquetes es CERO, asigne como si fueran las placas "530" 
			        update factexpdet
			 	set fed_cantemp = (select sum(D1.fed_cant) from factexpdet D1 where D1.fe_codigo=factexpdet.fe_codigo)
			 	from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo
			 	where factexp.fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')
			 	and FE_TRAC_MX1 not like '530%' and 
				fed_indiced in (select min(D2.fed_indiced) from factexpdet D2 where D2.fe_codigo=factexpdet.fe_codigo 
						)and fed_cantemp=0
                                                                
	
                        
			 update factexpdet
			 set fed_cantemp = (select sum(D1.fed_cant) from factexpdet D1 where D1.fe_codigo=factexpdet.fe_codigo)
			 from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo
			 where factexp.fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')
			 and FE_TRAC_MX1 like '530%' and 
			fed_indiced in (select min(D2.fed_indiced) from factexpdet D2 where D2.fe_codigo=factexpdet.fe_codigo)



			update factexpdet
			set tco_codigo = (select tco_codigo from maestrocost where ma_codigo=factexpdet.ma_codigo and
				mac_codigo in (select max(mac_codigo) from maestrocost where ma_codigo=factexpdet.ma_codigo))
			 from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo		
			 where factexp.fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')


			 update factexp
			   set fe_totalb = isnull((select sum(fed_cantemp) from factexpdet where fe_codigo=factexp.fe_codigo),0)
			 where fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')


			insert into importlog (iml_mensaje, iml_cbforma)
			select 'El total de empaques en el archivo viene en ceros, por lo tanto el total de bultos se importara en ceros.', 131
			 from factexp
			 where factexp.fe_codigo in (select FI_CODIGO from FolioFile1 where fi_folio like 'N%')
			 and FE_TRAC_MX1 not like '530%' and fe_totalb = 0


			exec sp_droptable 'tempImpfactexpdetauto'
			CREATE TABLE [dbo].[tempImpfactexpdetauto] (
				[FEDA_INDICEA] [int] IDENTITY (1, 1) NOT NULL ,
				[FED_INDICED] [int] NOT NULL ,
				[FE_CODIGO] [int] NOT NULL ,
				[FED_PELIGROSO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[FED_VINNO] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[FED_MILLAGE] [int] NOT NULL,
			) ON [PRIMARY]
			
			select @maximo=isnull(max(FEC_INDICEC),0)+1 from FACTEXPCONT
			
			dbcc checkident (tempImpfactExpdetauto, reseed, @maximo) WITH NO_INFOMSGS
		
	
	                      INSERT INTO tempImpfactexpdetauto (FE_CODIGO,FED_INDICED, FED_VINNO ,FED_PELIGROSO ,FED_MILLAGE) 	
			      SELECT (select fi_codigo from FolioFile1 where fi_folio=(CASE WHEN (TempImpFile1.FileType='FIL1NO') then TempImpFile1.TMMBCTransNumber else TempImpFile1.TMMBCTransNumberOri END)),
				      Codigo, VINNumber, replace(Hazard,'Y', 'S'), Mileage
			      FROM TempImpFile1
			      WHERE (VINNumber is not null and VINNumber<>'') or (Mileage is not null and Mileage<>'') or replace(Hazard,'Y', 'S')<>'N'
	
	                      INSERT INTO FACTEXPCONT (FE_CODIGO,FED_INDICED,FEC_INDICEC,FEC_SERIE ,FEC_PELIGROSO ,FEC_MILLAGE ) 
	 		      SELECT FE_CODIGO, FED_INDICED, FEDA_INDICEA, FED_VINNO, FED_PELIGROSO, FED_MILLAGE
			      FROM tempImpfactexpdetauto
				     WHERE FEDA_INDICEA NOT IN (SELECT FEC_INDICEC FROM FACTEXPCONT) and
					FED_INDICED in (select fed_indiced from factexpdet where fe_codigo = tempImpfactexpdetauto.fe_codigo)
			     and ((FED_VINNO is not null and FED_VINNO<>'') OR (FED_MILLAGE is not null and FED_MILLAGE<>'') OR (FED_PELIGROSO<>'N'))
				GROUP BY FE_CODIGO, FED_INDICED, FEDA_INDICEA, FED_VINNO, FED_PELIGROSO, FED_MILLAGE


			exec SP_ACTUALIZATASAFACTEXPF1

		end


	end





	exec sp_droptable 'FolioFile1'












GO
