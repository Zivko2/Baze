SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_GENERAFACTURAINVFISICO] (@le_folio varchar(25), @fe_no_sem varchar(20), @user_id int, @fecha datetime, @folios varchar(100) output)   as

declare @fe_codigo int, @fed_indiced int, @MA_CODIGO int, @FED_NOMBRE varchar(150), @FED_NOPARTE varchar(30), @FED_NAME varchar(150), @ME_CODIGO int, @FED_CANT decimal(38,6), @FED_GRA_MP decimal(38,6), @FED_GRA_MO decimal(38,6),
						@FED_GRA_EMP decimal(38,6), @FED_GRA_ADD decimal(38,6), @FED_GRA_GI decimal(38,6), @FED_GRA_GI_MX decimal(38,6), @FED_NG_MP decimal(38,6), @FED_NG_EMP decimal(38,6), @FED_NG_ADD decimal(38,6), @FED_NG_USA decimal(38,6), @FED_COS_UNI decimal(38,6),
						@FED_COS_TOT decimal(38,6), @FED_PES_UNI decimal(38,6), @FED_PES_NET decimal(38,6), @FED_PES_BRU decimal(38,6), @FED_PES_UNILB decimal(38,6), @FED_PES_NETLB decimal(38,6), @FED_PES_BRULB decimal(38,6), @FED_SEC_IMP smallint,
						@FED_DEF_TIP char(1), @FED_POR_DEF decimal(38,6), @FED_LOTE varchar(50), @AR_IMPMX int, @AR_EXPMX int, @AR_IMPFO int, @MA_GENERICO int, @PA_CODIGO int , @EQ_GEN decimal(28,14), @EQ_IMPFO decimal(28,14), @EQ_EXPMX decimal(28,14),
						@TI_CODIGO int , @FED_RATEEXPMX decimal(38,6), @FED_RATEIMPFO decimal(38,6), @SPI_CODIGO smallint, @FED_SALDO decimal(38,6), @FED_RETRABAJO char(1), @MA_EMPAQUE int, @FED_CANTEMP decimal(38,6), @FED_TIP_ENS char(1),
						@MA_NOPARTECL varchar(30), @FED_NAFTA char(1), @TCO_CODIGO smallint, @END_INDICED int, @EN_CODIGO int, @CL_CODIGO int, @MA_STRUCT int, @AR_ORIG int, @AR_NG_EMP int, @FED_NOPARTEAUX varchar(10),
						@FED_PRECIO_UNI decimal(38,6), @FED_PRECIO_TOT decimal(38,6), @LE_CODIGO int, @LED_INDICED int,
						@Consecutivo varchar(20), @folio1 varchar(30), @folio2 varchar(30), @tf_codigo int, @tq_codigo int,
						@IIF_NOPARTE varchar(50), @IIF_NOPARTEAUX varchar(50), @IIF_CANTIDAD decimal(38,6), @IIF_TIPOADQUISICION varchar(50)
declare  @pa_origen int, @ma_def_tip varchar(4), @ma_sec_imp int, @ma_tip_ens varchar(5)
--Valida tipo de materia y tipo de adquisicion
if not exists(select IIF_NoParte from importarInvFisico where isnull(IIF_TipoMaterial,'') not in (select TI_Nombre from tipo))
  Begin	
	if not exists(select IIF_NoParte from importarInvFisico where isnull(IIF_TipoAdquisicion,'') not in (select CB_Lookup from comboboxes where cb_field = 'FED_TIP_ENS'))
		Begin	

				delete from factexp where fe_folio = 'TEMPORALINVFISICO-1'

				set @folios = ''
				set @folio1 = ''
				set @folio2 = ''
				--Genera la factuar con PT
				if exists(select subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio))
							from factexp where fe_folio like @le_folio+'-%') 
					begin
						select @Consecutivo = Max(subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio)))
						 from factexp where fe_folio like @le_folio+'-%'
						Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
					end
				else
					begin
						Set @Consecutivo = '1'
					end
				    
				select @fe_codigo = cv_codigo from consecutivo where cv_tipo = 'FE'
				select @tf_codigo = tf_codigo from tfactura where tf_nombre = 'EXPORTACION TEMPORAL'
				select @tq_codigo = tq_codigo from tembarque where tq_nombre = 'PRODUCTO TERMINADO'

				insert into factexp(FE_CODIGO, FE_TIPO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_PRIORIDAD, FE_ESTATUS,
									FE_FOLIO, TQ_CODIGO, TN_CODIGO, FE_NO_SEM, US_CODIGO, AG_MX, AGT_CODIGO,
									AG_US,FE_PINICIAL, FE_PFINAL, CP_CODIGO, CL_PROD, DI_PROD, CL_DESTINI, DI_DESTINI, CL_EXP, DI_EXP,
									CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, CL_COMP, DI_COMP)
				select top 1 @fe_codigo, 'F',@tf_codigo, convert(varchar(11), @fecha,101),
						(select tc_cant from tcambio where tc_fecha = convert(varchar(11), @fecha,101)),'N','D',
						'TEMPORALINVFISICO-1',@tq_codigo, 
						case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
						then 4 
						else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fe_no_sem, 
						
						(select us_codigo from personal
						where sysusrlst_id=@user_id
						and us_codigo in (select max(us_codigo) from personal
						where sysusrlst_id=@user_id)),
						
						(select AG_MEX from cliente where cl_empresa = 'S'),
						(SELECT     AGENCIAPATENTE.AGT_CODIGO
						FROM         CLIENTE INNER JOIN
											  AGENCIAPATENTE ON CLIENTE.AG_MEX = AGENCIAPATENTE.AG_CODIGO
						WHERE     (AGENCIAPATENTE.AGT_DEFAULT = 'S') AND (CLIENTE.CL_EMPRESA = 'S') and (AGENCIAPATENTE.AGT_TIPO='A')),
						(select AG_USA from cliente where cl_empresa = 'S'),
						convert(varchar(11), @fecha,101),convert(varchar(11), @fecha,101),	

						(SELECT 
						  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
						  AND RELTFACTTEMBAR.TF_CODIGO=@tf_codigo) AS CP_CODIGO
						FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
						  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
						WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=@tf_codigo) 
						and tembarque.tq_codigo = @tq_codigo),
						
						
						(SELECT     CL_PROD
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),

						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_PROD
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),
						
						(SELECT     CL_destini
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_DESTINI
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_EXP
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_EXP
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_DESTFIN
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_DESTFIN
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_VEND
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_VEND
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_IMP
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_IMP
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),
						
						(SELECT     CL_COMP
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_COMP
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S')

					
				exec SP_ACTUALIZACONSECUTIVOTABLA 'FE'

				declare detalle cursor for
				select	IIF_NOPARTE , isnull(IIF_NOPARTEAUX,'')
				from importarinvfisico
				where IIF_TIPOMATERIAL = 'PRODUCTO TERMINADO'
					
					open detalle
					FETCH NEXT FROM detalle INTO @IIF_NOPARTE, @IIF_NOPARTEAUX
					WHILE (@@FETCH_STATUS = 0) 
					BEGIN

						
						select @ar_impmx = b.ar_impmx from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @pa_origen = b.pa_origen from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ma_def_tip = b.ma_def_tip from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ma_sec_imp = b.ma_sec_imp from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @spi_codigo = b.spi_codigo from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ma_tip_ens = b.ma_tip_ens from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ar_expmx = b.ar_expmx from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						
						exec SP_GETPORCENTARA_DEF  @ar_impmx, @pa_origen, @ma_def_tip, @ma_sec_imp, @spi_codigo, @fed_por_def


						select @fed_indiced = cv_codigo from consecutivo where cv_tipo = 'FED'
						insert into factexpdet
									(FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_OBSERVA, FED_CANT, FED_GRA_MP, 
														  FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, FED_NG_USA, 
														  FED_COS_UNI, FED_COS_TOT, FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, FED_PES_BRULB, 
														  FED_SEC_IMP, FED_DEF_TIP, FED_POR_DEF, FED_LOTE, AR_IMPMX, AR_EXPMX, AR_IMPFO, FED_CON_PED, MA_GENERICO, PA_CODIGO, 
														  LE_CODIGO, LED_INDICED, EX_CODIGO, FED_ORD_COMP, FED_NOORDEN, FED_USO_COMMINV, EQ_GEN, EQ_IMPFO, EQ_EXPMX, TI_CODIGO, 
														  FED_TENVIO, FED_INBOND, FED_TIPOINBOND, FED_RATEEXPMX, FED_RATEIMPFO, FED_RELEMP, FED_FECHA_STRUCT, FED_DISCHARGE, 
														  LE_FOLIO, SPI_CODIGO, FED_SALDO, FED_RETRABAJO, ADE_CODIGO, MA_EMPAQUE, FED_CANTEMP, FED_FAC_NUM, FED_FEC_ENV, 
														  FED_CON_CERTORIG, FED_COS_UNI_CO, FED_GRA_MAT_CO, FED_EMP_CO, FED_NG_MAT_CO, FED_VA_CO, FED_CANTGEN, MO_CODIGO, 
														  FED_DESCARGADO, FED_PARTTYPE, ME_GENERICO, FED_TIP_ENS, PID_INDICED, MA_NOPARTECL, ME_AREXPMX, FED_NAFTA, FED_DEFTXT1, 
														  FED_DEFTXT2, FED_DEFNO3, FED_DEFNO4, PID_INDICEDLIGA, PID_INDICEDLIGAR1, TCO_CODIGO, PI_ORIGENKITPADRE, CS_CODIGO, 
														  SE_CODIGO, FED_RELCAJAS, END_INDICED, EN_CODIGO, FED_SALDOTRANS, FED_USOTRANS, FED_USOSALDO, CL_CODIGO)
							select 	@fed_indiced, @fe_codigo, maestro.ma_codigo, maestro.ma_nombre, maestro.ma_noparte, maestro.ma_name, maestro.me_com, null, importarinvfisico.iif_cantidad, vmaestrocost.ma_grav_mp,
								vmaestrocost.ma_grav_mo, vmaestrocost.ma_grav_emp, vmaestrocost.ma_grav_add, vmaestrocost.ma_grav_gi, vmaestrocost.ma_grav_gi_mx, vmaestrocost.ma_ng_mp,
								vmaestrocost.ma_ng_emp, vmaestrocost.ma_ng_add, vmaestrocost.ma_ng_usa, vmaestrocost.ma_costo, vmaestrocost.ma_costo * importarinvfisico.iif_cantidad,
								maestro.ma_peso_kg, maestro.ma_peso_kg * importarinvfisico.iif_cantidad, maestro.ma_peso_kg * importarinvfisico.iif_cantidad,
								(maestro.ma_peso_kg * importarinvfisico.iif_cantidad) * 2.20462442018378, (maestro.ma_peso_kg * importarinvfisico.iif_cantidad) * 2.20462442018378,
								(maestro.ma_peso_kg * importarinvfisico.iif_cantidad) * 2.20462442018378, maestro.ma_sec_imp, maestro.ma_def_tip, isnull(@fed_por_def,0), null, @ar_impmx,
								maestro.ar_expmx, maestro.ar_impfo, 'N', maestro.ma_generico, @pa_origen, null, null, null,'','','N', maestro.eq_gen, maestro.eq_impfo, maestro.eq_expmx,
								maestro.ti_codigo, null, null, null, -1, 0, 'N', convert(varchar(11), getdate(),101), 'N', null, @spi_codigo, importarinvfisico.iif_cantidad, 'N', null, 
								isnull(maestro.ma_empaque,0), 0, null, null, 'N', isnull(vmaestrocost.ma_costo,0), vmaestrocost.ma_grav_emp + vmaestrocost.ma_grav_add,vmaestrocost.ma_grav_emp + vmaestrocost.ma_grav_add,
								vmaestrocost.ma_ng_mp + vmaestrocost.ma_grav_emp, vmaestrocost.ma_ng_mp + vmaestrocost.ma_ng_add, 0, null, 'N', 'A', maestrogenerico.me_com, comboboxes.cb_keyfield,
								-1, null, arancel.me_codigo, (select 'ma_nafta'= CASE WHEN MAESTRO.MA_CODIGO in 
												(SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO	WHERE SPI.SPI_CLAVE = 'NAFTA' 
												and NFT_CALIFICO='S' and NFT_PERINI<=convert(varchar(11), getdate(),101) AND NFT_PERFIN>=convert(varchar(11), getdate(),101)) 
												 and TI_CODIGO IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND (@ma_tip_ens='F' OR @ma_tip_ens='E') 
												 then 'S' else (CASE WHEN dbo.MAESTRO.MA_CODIGO in (SELECT CERTORIGMPDET.MA_CODIGO 
												 FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
												 WHERE CERTORIGMP.CMP_TIPO<> 'P' AND LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6) IN (SELECT LEFT(REPLACE(A1.AR_FRACCION,'.',''),6) FROM ARANCEL A1 WHERE AR_CODIGO=@ar_expmx) 
												  AND CERTORIGMPDET.PA_CLASE = @pa_origen
												  AND  CERTORIGMP.SPI_CODIGO IN (SELECT spi_codigo FROM spi WHERE spi_clave = 'nafta') 
												  AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA<=convert(varchar(11), getdate(),101) AND CERTORIGMP.CMP_FECHATRANS>=convert(varchar(11), getdate(),101)) 
												  AND (@ma_tip_ens<>'F' AND @ma_tip_ens<>'E') THEN 'S' ELSE (CASE WHEN (@pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) OR @pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION)) AND (select CF_CONFERIRORIGEN FROM CONFIGURACION)='T' AND @ma_def_tip='P' THEN 'S' 
												 ELSE 'N' END) END) end 
												 from maestro a where a.ma_codigo = maestro.ma_codigo), 
								'', '',null, null, -1,-1, vmaestrocost.tco_codigo, -1, maestro.cs_codigo, isnull(maestro.se_codigo,0), null, null, null, 0, 'N', 'N', (select cl_matriz from cliente where cl_empresa = 'S')
									
									from importarinvfisico 
										left outer join maestro on importarinvfisico.iif_noparte = maestro.ma_noparte and isnull(importarinvfisico.iif_noparteaux,'') = maestro.ma_noparteaux
										left outer join vmaestrocost on maestro.ma_codigo = vmaestrocost.ma_codigo
										left outer join maestro maestrogenerico on maestro.ma_generico = maestrogenerico.ma_codigo
										left outer join arancel on maestro.ar_expmx = arancel.ar_codigo
										left outer join comboboxes on importarinvfisico.IIF_TIPOADQUISICION = comboboxes.CB_Lookup and comboboxes.cb_field = 'fed_tip_ens'
									where importarinvfisico.iif_noparte = @IIF_NOPARTE
						

						exec SP_ACTUALIZACONSECUTIVOTABLA 'FED'
						Set @folio1 = @le_folio+'-'+@Consecutivo
						FETCH NEXT FROM detalle INTO @IIF_NOPARTE, @IIF_NOPARTEAUX
					END
				CLOSE detalle
				DEALLOCATE detalle

				exec SP_DESCEXPLOSIONFACTEXP @fe_codigo, @user_id


				-- Generar Factura para descargar con todas la mp tanto del archivo importado como de la explosion anterior

				set @folios = ''
				set @folio1 = ''
				set @folio2 = ''


				if exists(select subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio))
							from factexp where fe_folio like @le_folio+'-%') 
					begin
						select @Consecutivo = Max(subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio)))
						 from factexp where fe_folio like @le_folio+'-%'
						Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
					end
				else
					begin
						Set @Consecutivo = '1'
					end
				    
				select @fe_codigo = cv_codigo from consecutivo where cv_tipo = 'FE'
				select @tf_codigo = tf_codigo from tfactura where tf_nombre = 'EXPORTACION TEMPORAL'
				select @tq_codigo = tq_codigo from tembarque where tq_nombre = 'TODO TIPO MATERIAL'

				insert into factexp(FE_CODIGO, FE_TIPO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_PRIORIDAD, FE_ESTATUS,
									FE_FOLIO, TQ_CODIGO, TN_CODIGO, FE_NO_SEM, US_CODIGO, AG_MX, AGT_CODIGO,
									AG_US,FE_PINICIAL, FE_PFINAL, CP_CODIGO, CL_PROD, DI_PROD, CL_DESTINI, DI_DESTINI, CL_EXP, DI_EXP,
									CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, CL_COMP, DI_COMP)
				select top 1 @fe_codigo, 'F',@tf_codigo, convert(varchar(11), @fecha,101),
						(select tc_cant from tcambio where tc_fecha = convert(varchar(11), @fecha,101)),'N','D',
						@le_folio+'-'+@Consecutivo,@tq_codigo, 
						case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
						then 4 
						else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fe_no_sem, 
						
						(select us_codigo from personal
						where sysusrlst_id=@user_id
						and us_codigo in (select max(us_codigo) from personal
						where sysusrlst_id=@user_id)),
						
						(select AG_MEX from cliente where cl_empresa = 'S'),
						(SELECT     AGENCIAPATENTE.AGT_CODIGO
						FROM         CLIENTE INNER JOIN
											  AGENCIAPATENTE ON CLIENTE.AG_MEX = AGENCIAPATENTE.AG_CODIGO
						WHERE     (AGENCIAPATENTE.AGT_DEFAULT = 'S') AND (CLIENTE.CL_EMPRESA = 'S') and (AGENCIAPATENTE.AGT_TIPO='A')),
						(select AG_USA from cliente where cl_empresa = 'S'),
						convert(varchar(11), @fecha,101),convert(varchar(11), @fecha,101),	

						(SELECT 
						  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
						  AND RELTFACTTEMBAR.TF_CODIGO=@tf_codigo) AS CP_CODIGO
						FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
						  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
						WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=@tf_codigo) 
						and tembarque.tq_codigo = @tq_codigo),
						
						
						(SELECT     CL_PROD
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),

						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_PROD
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),
						
						(SELECT     CL_destini
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_DESTINI
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_EXP
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_EXP
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_DESTFIN
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_DESTFIN
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_VEND
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_VEND
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),

						(SELECT     CL_IMP
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_IMP
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S'),
						
						(SELECT     CL_COMP
						FROM         CLIENTEENTIDADES
						WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
						
						(select DI_INDICE
						from dir_cliente
						where cl_codigo = (SELECT     CL_COMP
											FROM         CLIENTEENTIDADES
											WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
						and di_fiscal = 'S')

					
				exec SP_ACTUALIZACONSECUTIVOTABLA 'FE'

				declare detalle cursor for
					select IIF_NOPARTE , isnull(IIF_NOPARTEAUX,''), IIF_Cantidad, comboboxes.cb_keyfield
					from importarinvfisico
						left outer join maestro on importarinvfisico.IIF_NOPARTE = maestro.ma_noparte and isnull(importarinvfisico.IIF_NOPARTEAUX,'') = maestro.ma_noparteaux
						left outer join tipo on maestro.ti_codigo = tipo.ti_codigo
						left outer join comboboxes on importarInvFisico.IIF_TipoAdquisicion = comboboxes.cb_lookup and comboboxes.cb_field = 'fed_tip_ens'
					where tipo.ti_nombre <> 'PRODUCTO TERMINADO' or IIF_TIPOADQUISICION = 'COMPRADO'
					union 
					select maestro.ma_noparte, isnull(maestro.MA_NOPARTEAUX,''), bst_incorpor * factconv * factexpdet.fed_cant, BOM_DESCTEMP.ma_tip_ens
					from BOM_DESCTEMP
						left outer join maestro on bom_desctemp.bst_hijo = maestro.ma_codigo
						left outer join factexpdet on bom_desctemp.fed_indiced = factexpdet.fed_indiced

					
					open detalle
					FETCH NEXT FROM detalle INTO @IIF_NOPARTE, @IIF_NOPARTEAUX, @IIF_CANTIDAD, @IIF_TIPOADQUISICION
					WHILE (@@FETCH_STATUS = 0) 
					BEGIN

						
						select @ar_impmx = b.ar_impmx from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @pa_origen = b.pa_origen from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ma_def_tip = b.ma_def_tip from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ma_sec_imp = b.ma_sec_imp from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @spi_codigo = b.spi_codigo from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ma_tip_ens = b.ma_tip_ens from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						select @ar_expmx = b.ar_expmx from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
						
						exec SP_GETPORCENTARA_DEF  @ar_impmx, @pa_origen, @ma_def_tip, @ma_sec_imp, @spi_codigo, @fed_por_def


						select @fed_indiced = cv_codigo from consecutivo where cv_tipo = 'FED'
						insert into factexpdet
									(FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_OBSERVA, FED_CANT, FED_GRA_MP, 
														  FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, FED_NG_USA, 
														  FED_COS_UNI, FED_COS_TOT, FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, FED_PES_BRULB, 
														  FED_SEC_IMP, FED_DEF_TIP, FED_POR_DEF, FED_LOTE, AR_IMPMX, AR_EXPMX, AR_IMPFO, FED_CON_PED, MA_GENERICO, PA_CODIGO, 
														  LE_CODIGO, LED_INDICED, EX_CODIGO, FED_ORD_COMP, FED_NOORDEN, FED_USO_COMMINV, EQ_GEN, EQ_IMPFO, EQ_EXPMX, TI_CODIGO, 
														  FED_TENVIO, FED_INBOND, FED_TIPOINBOND, FED_RATEEXPMX, FED_RATEIMPFO, FED_RELEMP, FED_FECHA_STRUCT, FED_DISCHARGE, 
														  LE_FOLIO, SPI_CODIGO, FED_SALDO, FED_RETRABAJO, ADE_CODIGO, MA_EMPAQUE, FED_CANTEMP, FED_FAC_NUM, FED_FEC_ENV, 
														  FED_CON_CERTORIG, FED_COS_UNI_CO, FED_GRA_MAT_CO, FED_EMP_CO, FED_NG_MAT_CO, FED_VA_CO, FED_CANTGEN, MO_CODIGO, 
														  FED_DESCARGADO, FED_PARTTYPE, ME_GENERICO, FED_TIP_ENS, PID_INDICED, MA_NOPARTECL, ME_AREXPMX, FED_NAFTA, FED_DEFTXT1, 
														  FED_DEFTXT2, FED_DEFNO3, FED_DEFNO4, PID_INDICEDLIGA, PID_INDICEDLIGAR1, TCO_CODIGO, PI_ORIGENKITPADRE, CS_CODIGO, 
														  SE_CODIGO, FED_RELCAJAS, END_INDICED, EN_CODIGO, FED_SALDOTRANS, FED_USOTRANS, FED_USOSALDO, CL_CODIGO)
							select 	@fed_indiced, @fe_codigo, maestro.ma_codigo, maestro.ma_nombre, maestro.ma_noparte, maestro.ma_name, maestro.me_com, null, @IIF_CANTIDAD, vmaestrocost.ma_grav_mp,
								vmaestrocost.ma_grav_mo, vmaestrocost.ma_grav_emp, vmaestrocost.ma_grav_add, vmaestrocost.ma_grav_gi, vmaestrocost.ma_grav_gi_mx, vmaestrocost.ma_ng_mp,
								vmaestrocost.ma_ng_emp, vmaestrocost.ma_ng_add, vmaestrocost.ma_ng_usa, vmaestrocost.ma_costo, vmaestrocost.ma_costo * @IIF_CANTIDAD,
								maestro.ma_peso_kg, maestro.ma_peso_kg * @IIF_CANTIDAD, maestro.ma_peso_kg * @IIF_CANTIDAD,
								(maestro.ma_peso_kg * @IIF_CANTIDAD) * 2.20462442018378, (maestro.ma_peso_kg * @IIF_CANTIDAD) * 2.20462442018378,
								(maestro.ma_peso_kg * @IIF_CANTIDAD) * 2.20462442018378, maestro.ma_sec_imp, maestro.ma_def_tip, isnull(@fed_por_def,0), null, @ar_impmx,
								maestro.ar_expmx, maestro.ar_impfo, 'N', maestro.ma_generico, @pa_origen, null, null, null,'','','N', maestro.eq_gen, maestro.eq_impfo, maestro.eq_expmx,
								maestro.ti_codigo, null, null, null, -1, 0, 'N', convert(varchar(11), getdate(),101), maestro.MA_DISCHARGE, null, @spi_codigo, @IIF_CANTIDAD, 'N', null, 
								isnull(maestro.ma_empaque,0), 0, null, null, 'N', isnull(vmaestrocost.ma_costo,0), vmaestrocost.ma_grav_emp + vmaestrocost.ma_grav_add,vmaestrocost.ma_grav_emp + vmaestrocost.ma_grav_add,
								vmaestrocost.ma_ng_mp + vmaestrocost.ma_grav_emp, vmaestrocost.ma_ng_mp + vmaestrocost.ma_ng_add, 0, null, 'N', 'A', maestrogenerico.me_com, @IIF_TIPOADQUISICION,
								-1, null, arancel.me_codigo, (select 'ma_nafta'= CASE WHEN MAESTRO.MA_CODIGO in 
												(SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO	WHERE SPI.SPI_CLAVE = 'NAFTA' 
												and NFT_CALIFICO='S' and NFT_PERINI<=convert(varchar(11), getdate(),101) AND NFT_PERFIN>=convert(varchar(11), getdate(),101)) 
												 and TI_CODIGO IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND (@ma_tip_ens='F' OR @ma_tip_ens='E') 
												 then 'S' else (CASE WHEN dbo.MAESTRO.MA_CODIGO in (SELECT CERTORIGMPDET.MA_CODIGO 
												 FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
												 WHERE CERTORIGMP.CMP_TIPO<> 'P' AND LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6) IN (SELECT LEFT(REPLACE(A1.AR_FRACCION,'.',''),6) FROM ARANCEL A1 WHERE AR_CODIGO=@ar_expmx) 
												  AND CERTORIGMPDET.PA_CLASE = @pa_origen
												  AND  CERTORIGMP.SPI_CODIGO IN (SELECT spi_codigo FROM spi WHERE spi_clave = 'nafta') 
												  AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA<=convert(varchar(11), getdate(),101) AND CERTORIGMP.CMP_FECHATRANS>=convert(varchar(11), getdate(),101)) 
												  AND (@ma_tip_ens<>'F' AND @ma_tip_ens<>'E') THEN 'S' ELSE (CASE WHEN (@pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) OR @pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION)) AND (select CF_CONFERIRORIGEN FROM CONFIGURACION)='T' AND @ma_def_tip='P' THEN 'S' 
												 ELSE 'N' END) END) end 
												 from maestro a where a.ma_codigo = maestro.ma_codigo), 
								'', '',null, null, -1,-1, vmaestrocost.tco_codigo, -1, maestro.cs_codigo, isnull(maestro.se_codigo,0), null, null, null, 0, 'N', 'N', (select cl_matriz from cliente where cl_empresa = 'S')
									
									from  maestro 
										left outer join vmaestrocost on maestro.ma_codigo = vmaestrocost.ma_codigo
										left outer join maestro maestrogenerico on maestro.ma_generico = maestrogenerico.ma_codigo
										left outer join arancel on maestro.ar_expmx = arancel.ar_codigo
									where maestro.ma_noparte = @IIF_NOPARTE
									  and maestro.ma_noparteaux = @IIF_NOPARTEAUX
						

						exec SP_ACTUALIZACONSECUTIVOTABLA 'FED'
						Set @folio1 = @le_folio+'-'+@Consecutivo
						FETCH NEXT FROM detalle INTO @IIF_NOPARTE, @IIF_NOPARTEAUX, @IIF_CANTIDAD, @IIF_TIPOADQUISICION
					END
				CLOSE detalle
				DEALLOCATE detalle

				delete from factexp where fe_folio = 'TEMPORALINVFISICO-1'

				-- DESCARGAR FACTURA
				exec SP_DESCEXPLOSIONFACTEXP @fe_codigo, @user_id
				exec sp_DescargaFactExp @fe_codigo, 'UEPS', @user_id
				-- REALIZA COMPARACION
				DELETE FROM COMPARACIONINVFISICO
				INSERT INTO COMPARACIONINVFISICO(CIF_NOPARTE, CIF_CANTIDAD, CIF_CANTIDADEXISTENTE, CIF_CANTIDADRESTANTE, CIF_ESTATUS, CIF_NOPARTEAUX)
				select s.fed_noparte [NoParte], kap_cantTotADescargar [CantidadInvFisico], sum(kardesped.kap_cantdesc) [CantidadExistente], isnull(s.pid_saldogen,0) [CantidadRestante],
					'Estatus' = case when sum(kap_cantdesc) = 0 
						then 'No existe'
						else
							case when s.pid_saldogen = 0 and sum(kap_cantdesc) = kap_cantTotADescargar
								then 'Son Iguales'
								else
									case when s.pid_saldogen = 0 and sum(kap_cantdesc) < kap_cantTotADescargar
										then 'Existe menos'
										else
											case when s.pid_saldogen > 0
												then 'Existe más'
											end
									end	
							end
					end, isnull(s.fed_noparteaux,'')
				from kardesped 
					left outer join (
									select factexpdet.ma_codigo, factexpdet.fed_noparte, sum(pidescarga.pid_saldogen) pid_saldogen, factexpdet.fed_noparteaux
									from factexpdet left outer join pidescarga on factexpdet.ma_codigo = pidescarga.ma_codigo
									where fe_codigo = @FE_CODIGO
									group by factexpdet.ma_codigo, factexpdet.fed_noparte, factexpdet.fed_noparteaux) S on kardesped.ma_hijo = s.ma_codigo
				
				
				where kap_factrans = @FE_CODIGO
				group by s.fed_noparte, kap_cantTotADescargar, s.pid_saldogen, s.fed_noparteaux
				
				--Cancela Descarga
				exec sp_descargacancela @fe_codigo
				--Elimina Factura que se descargo
				delete from factexp where fe_codigo = @fe_codigo
				
				-- Genera factura de desperdicio si existe excendente en InTrade.
				set @folios = ''
				set @folio1 = ''
				set @folio2 = ''
				if exists(select CIF_NoParte, CIF_NOPARTEAUX, CIF_CantidadRestante, maestro.ma_tip_ens
							from comparacioninvfisico
								left outer join maestro on comparacionInvFisico.CIF_NOPARTE = maestro.ma_noparte and isnull(comparacionInvFisico.CIF_NoParteAux,'') = Maestro.MA_NoParteAux
							where CIF_Estatus = 'Existe más')
					Begin
						if exists(select subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio))
									from factexp where fe_folio like @le_folio+'-%') 
							begin
								select @Consecutivo = Max(subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio)))
								 from factexp where fe_folio like @le_folio+'-%'
								Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
							end
						else
							begin
								Set @Consecutivo = '1'
							end
						    
						select @fe_codigo = cv_codigo from consecutivo where cv_tipo = 'FE'
						select @tf_codigo = tf_codigo from tfactura where tf_nombre = 'EXPORTACION MAQUILA'
						select @tq_codigo = tq_codigo from tembarque where tq_nombre = 'DESPERDICIO'

						insert into factexp(FE_CODIGO, FE_TIPO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_PRIORIDAD, FE_ESTATUS,
											FE_FOLIO, TQ_CODIGO, TN_CODIGO, FE_NO_SEM, US_CODIGO, AG_MX, AGT_CODIGO,
											AG_US,FE_PINICIAL, FE_PFINAL, CP_CODIGO, CL_PROD, DI_PROD, CL_DESTINI, DI_DESTINI, CL_EXP, DI_EXP,
											CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, CL_COMP, DI_COMP)
						select top 1 @fe_codigo, 'F',@tf_codigo, convert(varchar(11), @fecha,101),
								(select tc_cant from tcambio where tc_fecha = convert(varchar(11), @fecha,101)),'N','D',
								@le_folio+'-'+@Consecutivo,@tq_codigo, 
								case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
								then 4 
								else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fe_no_sem, 
								
								(select us_codigo from personal
								where sysusrlst_id=@user_id
								and us_codigo in (select max(us_codigo) from personal
								where sysusrlst_id=@user_id)),
								
								(select AG_MEX from cliente where cl_empresa = 'S'),
								(SELECT     AGENCIAPATENTE.AGT_CODIGO
								FROM         CLIENTE INNER JOIN
													  AGENCIAPATENTE ON CLIENTE.AG_MEX = AGENCIAPATENTE.AG_CODIGO
								WHERE     (AGENCIAPATENTE.AGT_DEFAULT = 'S') AND (CLIENTE.CL_EMPRESA = 'S') and (AGENCIAPATENTE.AGT_TIPO='A')),
								(select AG_USA from cliente where cl_empresa = 'S'),
								convert(varchar(11), @fecha,101),convert(varchar(11), @fecha,101),	

								(SELECT 
								  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
								  AND RELTFACTTEMBAR.TF_CODIGO=@tf_codigo) AS CP_CODIGO
								FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
								  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
								WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=@tf_codigo) 
								and tembarque.tq_codigo = @tq_codigo),
								
								
								(SELECT     CL_PROD
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),

								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_PROD
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S'),
								
								(SELECT     CL_destini
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
								
								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_DESTINI
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S'),

								(SELECT     CL_EXP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
								
								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_EXP
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S'),

								(SELECT     CL_DESTFIN
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
								
								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_DESTFIN
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S'),

								(SELECT     CL_VEND
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
								
								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_VEND
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S'),

								(SELECT     CL_IMP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
								
								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_IMP
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S'),
								
								(SELECT     CL_COMP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo),
								
								(select DI_INDICE
								from dir_cliente
								where cl_codigo = (SELECT     CL_COMP
													FROM         CLIENTEENTIDADES
													WHERE     OM_TIPO = 'S' and TF_CODIGO = @tf_codigo)
								and di_fiscal = 'S')

							
						exec SP_ACTUALIZACONSECUTIVOTABLA 'FE'


						declare detalle cursor for
							select CIF_NoParte, CIF_NOPARTEAUX, CIF_CantidadRestante, maestro.ma_tip_ens
							from comparacioninvfisico
								left outer join maestro on comparacionInvFisico.CIF_NOPARTE = maestro.ma_noparte and isnull(comparacionInvFisico.CIF_NoParteAux,'') = Maestro.MA_NoParteAux
							where CIF_Estatus = 'Existe más'
							
							open detalle
							FETCH NEXT FROM detalle INTO @IIF_NOPARTE, @IIF_NOPARTEAUX, @IIF_CANTIDAD, @IIF_TIPOADQUISICION
							WHILE (@@FETCH_STATUS = 0) 
							BEGIN

								
								select @ar_impmx = b.ar_impmx from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								select @pa_origen = b.pa_origen from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								select @ma_def_tip = b.ma_def_tip from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								select @ma_sec_imp = b.ma_sec_imp from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								select @spi_codigo = b.spi_codigo from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								select @ma_tip_ens = b.ma_tip_ens from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								select @ar_expmx = b.ar_expmx from maestro b where @IIF_NOPARTE = b.ma_noparte and @IIF_NOPARTEAUX = b.ma_noparteaux
								
								exec SP_GETPORCENTARA_DEF  @ar_impmx, @pa_origen, @ma_def_tip, @ma_sec_imp, @spi_codigo, @fed_por_def


								select @fed_indiced = cv_codigo from consecutivo where cv_tipo = 'FED'
								insert into factexpdet
											(FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_OBSERVA, FED_CANT, FED_GRA_MP, 
																  FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, FED_NG_USA, 
																  FED_COS_UNI, FED_COS_TOT, FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, FED_PES_BRULB, 
																  FED_SEC_IMP, FED_DEF_TIP, FED_POR_DEF, FED_LOTE, AR_IMPMX, AR_EXPMX, AR_IMPFO, FED_CON_PED, MA_GENERICO, PA_CODIGO, 
																  LE_CODIGO, LED_INDICED, EX_CODIGO, FED_ORD_COMP, FED_NOORDEN, FED_USO_COMMINV, EQ_GEN, EQ_IMPFO, EQ_EXPMX, TI_CODIGO, 
																  FED_TENVIO, FED_INBOND, FED_TIPOINBOND, FED_RATEEXPMX, FED_RATEIMPFO, FED_RELEMP, FED_FECHA_STRUCT, FED_DISCHARGE, 
																  LE_FOLIO, SPI_CODIGO, FED_SALDO, FED_RETRABAJO, ADE_CODIGO, MA_EMPAQUE, FED_CANTEMP, FED_FAC_NUM, FED_FEC_ENV, 
																  FED_CON_CERTORIG, FED_COS_UNI_CO, FED_GRA_MAT_CO, FED_EMP_CO, FED_NG_MAT_CO, FED_VA_CO, FED_CANTGEN, MO_CODIGO, 
																  FED_DESCARGADO, FED_PARTTYPE, ME_GENERICO, FED_TIP_ENS, PID_INDICED, MA_NOPARTECL, ME_AREXPMX, FED_NAFTA, FED_DEFTXT1, 
																  FED_DEFTXT2, FED_DEFNO3, FED_DEFNO4, PID_INDICEDLIGA, PID_INDICEDLIGAR1, TCO_CODIGO, PI_ORIGENKITPADRE, CS_CODIGO, 
																  SE_CODIGO, FED_RELCAJAS, END_INDICED, EN_CODIGO, FED_SALDOTRANS, FED_USOTRANS, FED_USOSALDO, CL_CODIGO)
									select 	@fed_indiced, @fe_codigo, maestro.ma_codigo, maestro.ma_nombre, maestro.ma_noparte, maestro.ma_name, maestro.me_com, null, @IIF_CANTIDAD, vmaestrocost.ma_grav_mp,
										vmaestrocost.ma_grav_mo, vmaestrocost.ma_grav_emp, vmaestrocost.ma_grav_add, vmaestrocost.ma_grav_gi, vmaestrocost.ma_grav_gi_mx, vmaestrocost.ma_ng_mp,
										vmaestrocost.ma_ng_emp, vmaestrocost.ma_ng_add, vmaestrocost.ma_ng_usa, vmaestrocost.ma_costo, vmaestrocost.ma_costo * @IIF_CANTIDAD,
										maestro.ma_peso_kg, maestro.ma_peso_kg * @IIF_CANTIDAD, maestro.ma_peso_kg * @IIF_CANTIDAD,
										(maestro.ma_peso_kg * @IIF_CANTIDAD) * 2.20462442018378, (maestro.ma_peso_kg * @IIF_CANTIDAD) * 2.20462442018378,
										(maestro.ma_peso_kg * @IIF_CANTIDAD) * 2.20462442018378, maestro.ma_sec_imp, maestro.ma_def_tip, isnull(@fed_por_def,0), null, @ar_impmx,
										maestro.ar_expmx, maestro.ar_impfo, 'N', maestro.ma_generico, @pa_origen, null, null, null,'','','N', maestro.eq_gen, maestro.eq_impfo, maestro.eq_expmx,
										maestro.ti_codigo, null, null, null, -1, 0, 'N', convert(varchar(11), getdate(),101), maestro.MA_DISCHARGE, null, @spi_codigo, @IIF_CANTIDAD, 'N', null, 
										isnull(maestro.ma_empaque,0), 0, null, null, 'N', isnull(vmaestrocost.ma_costo,0), vmaestrocost.ma_grav_emp + vmaestrocost.ma_grav_add,vmaestrocost.ma_grav_emp + vmaestrocost.ma_grav_add,
										vmaestrocost.ma_ng_mp + vmaestrocost.ma_grav_emp, vmaestrocost.ma_ng_mp + vmaestrocost.ma_ng_add, 0, null, 'N', 'A', maestrogenerico.me_com, @IIF_TIPOADQUISICION,
										-1, null, arancel.me_codigo, (select 'ma_nafta'= CASE WHEN MAESTRO.MA_CODIGO in 
														(SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO	WHERE SPI.SPI_CLAVE = 'NAFTA' 
														and NFT_CALIFICO='S' and NFT_PERINI<=convert(varchar(11), getdate(),101) AND NFT_PERFIN>=convert(varchar(11), getdate(),101)) 
														 and TI_CODIGO IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND (@ma_tip_ens='F' OR @ma_tip_ens='E') 
														 then 'S' else (CASE WHEN dbo.MAESTRO.MA_CODIGO in (SELECT CERTORIGMPDET.MA_CODIGO 
														 FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
														 WHERE CERTORIGMP.CMP_TIPO<> 'P' AND LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6) IN (SELECT LEFT(REPLACE(A1.AR_FRACCION,'.',''),6) FROM ARANCEL A1 WHERE AR_CODIGO=@ar_expmx) 
														  AND CERTORIGMPDET.PA_CLASE = @pa_origen
														  AND  CERTORIGMP.SPI_CODIGO IN (SELECT spi_codigo FROM spi WHERE spi_clave = 'nafta') 
														  AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA<=convert(varchar(11), getdate(),101) AND CERTORIGMP.CMP_FECHATRANS>=convert(varchar(11), getdate(),101)) 
														  AND (@ma_tip_ens<>'F' AND @ma_tip_ens<>'E') THEN 'S' ELSE (CASE WHEN (@pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) OR @pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION)) AND (select CF_CONFERIRORIGEN FROM CONFIGURACION)='T' AND @ma_def_tip='P' THEN 'S' 
														 ELSE 'N' END) END) end 
														 from maestro a where a.ma_codigo = maestro.ma_codigo), 
										'', '',null, null, -1,-1, vmaestrocost.tco_codigo, -1, maestro.cs_codigo, isnull(maestro.se_codigo,0), null, null, null, 0, 'N', 'N', (select cl_matriz from cliente where cl_empresa = 'S')
											
											from  maestro 
												left outer join vmaestrocost on maestro.ma_codigo = vmaestrocost.ma_codigo
												left outer join maestro maestrogenerico on maestro.ma_generico = maestrogenerico.ma_codigo
												left outer join arancel on maestro.ar_expmx = arancel.ar_codigo
											where maestro.ma_noparte = @IIF_NOPARTE
											  and maestro.ma_noparteaux = @IIF_NOPARTEAUX
								

								exec SP_ACTUALIZACONSECUTIVOTABLA 'FED'
								Set @folio1 = @le_folio+'-'+@Consecutivo
								FETCH NEXT FROM detalle INTO @IIF_NOPARTE, @IIF_NOPARTEAUX, @IIF_CANTIDAD, @IIF_TIPOADQUISICION
							END
						CLOSE detalle
						DEALLOCATE detalle
					End	

				if (@folio1 <> '')
					set @folios = @Folio1
				if (@folio2 <> '')
					if (@folios <> '')
						set @folios = @folios+', '+@folio2
					else
						set @folios = @folio2
		End
	Else
		begin
		  set @folios = 'Información incorrecta, el Tipo de Aquisición no existe'
		end		
  End
Else
  Begin
     set @folios = 'Información incorrecta, el Tipo de Material no existe'
  end

GO
