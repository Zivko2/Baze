SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ExplosionayDescargaFactExp] (@fe_codigo Int, @MetodoDescarga Varchar(4),  @user int, @Concilia char(1)='N')   as

declare @Fechaactual varchar(10), @em_codigo int, @fe_fecha varchar(11), @hora varchar(15), @CF_CONTENEDOR CHAR(1),
@DescargaEmpaqueDet char(1), @DescargaEmpaque char(1), @empaqueadicional int, @TEmbarque char(1), @tipodescarga varchar(2),
@DI_PROD int, @fe_folio char(25), @cuentamaq int, @cuentaeq int, @fed_indicedMIN int, @fed_indiced int, @fed_retrabajo char(1),
@fed_tip_ens char(1),  @ma_codigo int, @CFT_TIPO CHAR(1), @CantGen decimal(38,6), @Fed_fecha_struct varchar(11), @pid_indiced int,
@fed_cant decimal(38,6), @KAP_Saldo_FED decimal(38,6), @BST_HIJO int, @CANTDESC decimal(38,6), @Kap_codigoSaldo int, 
@Kap_CantDesc decimal(38,6)

	  SET @FechaActual = convert(varchar(25), getdate(),120)


	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

-- borra la tabla a llenar
	--exec sp_droptable  'BOM_DESCTEMP'
	--exec sp_CreaBOM_DESCTEMP

	select @fe_fecha=convert(varchar(11),fe_fecha,101), @DI_PROD=DI_PROD, @fe_folio=fe_folio  from factexp where fe_codigo=@fe_codigo

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	--insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_hora, ava_fecha, em_codigo)

	
	SELECT     @CF_CONTENEDOR = CF_CONTENEDOR, @DescargaEmpaqueDet = CF_MAN_EMPAQUE,
	@DescargaEmpaque = CF_EMPAQUE_BOM
	FROM         dbo.CONFIGURACION


	if exists(select MA_CODIGO  FROM FACTEXPEMPAQUEADICIONAL
	WHERE FE_CODIGO = @fe_codigo)
	SET @empaqueadicional=1


	SELECT     @TEmbarque = dbo.CONFIGURATEMBARQUE.CFQ_TIPO
	FROM         dbo.FACTEXP LEFT OUTER JOIN
	              dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO
	GROUP BY dbo.CONFIGURATEMBARQUE.CFQ_TIPO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_TIPO
	HAVING      (dbo.FACTEXP.FE_CODIGO = @Fe_codigo)




	if @TEmbarque='D'
		set @tipodescarga = 'D'
	else
			set @tipodescarga = 'N'


	


	/*	if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' and (select count(*) from factexp where fe_codigo=@fed_indiced and cp_codigo in
			(select cp_codigo from claveped where cp_clave in ('A1', 'T1', 'C1', 'I1')))>0
		  	 EXEC SP_CreaVPIDescarga 'D', @fe_fecha
		else*/

		if (select count(*) from factexp inner join configuratfact on factexp.tf_codigo=configuratfact.tf_codigo
		    where fe_codigo=@fe_codigo and configuratfact.cff_tipo='EC')>0
			   EXEC SP_CreaVPIDescarga 'C', @fe_fecha, @DI_PROD
		else	
		if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N' 
		and (select count(*) from factexp where fe_codigo=@fe_codigo and tq_codigo in (select tq_codigo from configuratembarque where cfq_tipo ='T'))>0
	
			   EXEC SP_CreaVPIDescarga 'R', @fe_fecha, @DI_PROD
		else
		if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='N' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N' 
		and (select count(*) from factexp where fe_codigo=@fe_codigo and tq_codigo in (select tq_codigo from configuratembarque where cfq_tipo ='T'))>0
	
			   EXEC SP_CreaVPIDescarga 'T', @fe_fecha, @DI_PROD
		else
		begin
			if @cuentamaq =0 and @cuentaeq >0
			   EXEC SP_CreaVPIDescarga 'F', @fe_fecha, @DI_PROD
			else
			   EXEC SP_CreaVPIDescarga 'M', @fe_fecha, @DI_PROD
		end




		Declare @X Int
	
	
		UPDATE PIDESCARGA
		SET PID_IDDESCARGA=-1
		FROM PIDESCARGA INNER JOIN VPIDESCARGA ON PIDESCARGA.PID_INDICED = VPIDESCARGA.PID_INDICED
		WHERE PIDESCARGA.PID_IDDESCARGA IS NULL OR PIDESCARGA.PID_IDDESCARGA>-1
		
		/*Select VPIDESCARGA.PID_INDICED, VPIDESCARGA.PID_IDDESCARGA
		Into dbo.[#TempX] 
		FROM PIDESCARGA INNER JOIN VPIDESCARGA ON PIDESCARGA.PID_INDICED = VPIDESCARGA.PID_INDICED
		ORDER BY VPIDESCARGA.PI_FEC_ENT, vPIDescarga.MA_CODIGO, vPIDescarga.MA_GENERICO*/

		Select VPIDESCARGA.PID_INDICED, vPIDescarga.MA_CODIGO, VPIDESCARGA.PI_FEC_ENT, vPIDescarga.MA_GENERICO
		Into dbo.[#TempXX] 
		FROM PIDESCARGA INNER JOIN VPIDESCARGA ON PIDESCARGA.PID_INDICED = VPIDESCARGA.PID_INDICED


		Select PID_INDICED, -1 as PID_IDDESCARGA
		Into dbo.[#TempX] 
		FROM dbo.[#TempXX] 
		ORDER BY PI_FEC_ENT, MA_CODIGO, MA_GENERICO
	
		
		SET @X=0
		
		Update dbo.[#TempX]  
		SET PID_IDDESCARGA=@X, @X=@X+1
		
		Update PIDESCARGA 
		SET PID_IDDESCARGA=T.PID_IDDESCARGA 
		From dbo.[#TempX]  T inner join PIDESCARGA on T.Pid_indiced=PIDESCARGA.pid_indiced
	
		DROP TABLE dbo.[#TempX] 
		DROP TABLE dbo.[#TempXX] 	



		select @fed_indicedMIN=min(fed_indiced) from factexpdet where fe_codigo=@fe_codigo


		declare cur_descargafactexpdet cursor for
			SELECT     FED_INDICED, FED_TIP_ENS, MA_CODIGO, CFT_TIPO,
			ROUND(FED_CANT * ISNULL(EQ_GEN, 1),6), convert(varchar(11),FED_FECHA_STRUCT,101), PID_INDICED, FED_CANT
			FROM FACTEXPDET LEFT OUTER JOIN CONFIGURATIPO ON FACTEXPDET.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
			WHERE FE_CODIGO=@fe_codigo AND ((FED_TIP_ENS='C' AND FED_DISCHARGE='S') OR FED_TIP_ENS<>'C') and FED_RETRABAJO='N'
			order by fed_indiced
		open cur_descargafactexpdet
		
		
			FETCH NEXT FROM cur_descargafactexpdet INTO @fed_indiced, @fed_tip_ens, @ma_codigo, @CFT_TIPO, @CantGen, @Fed_fecha_struct, @pid_indiced, @fed_cant
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

				if @pid_indiced=-1
				begin
						exec sp_DescargaXProducto @CFT_TIPO, @Fe_codigo, @MetodoDescarga, @fed_indiced, @MA_CODIGO,
										@tipodescarga, @Fed_fecha_struct, @CantGen, @CantGen, @KAP_Saldo_FED Output		

				end
				else
				begin
						-----------------------------------inserta en kardesped la informacion de la seleccion de equipo que ya tiene asignado un pedimento  ---------------------------------------------------------
		
						--ANTES EN PROCESO exec sp_DescargaSelEquipo @fed_indiced, @FechaActual
						INSERT INTO KARDESPEDTemp (KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, 
						MA_HIJO, KAP_TIPO_DESC, KAP_CANTDESC, 
						KAP_CantTotADescargar, KAP_Saldo_FED, KAP_ESTATUS)
		
		
						values (@fe_codigo, @fed_indiced, @pid_indiced, @ma_codigo, 'N', @fed_cant, @fed_cant, 0, 'D')
					
						/*SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.PID_INDICED, 
								dbo.PEDIMPDET.MA_CODIGO AS MA_HIJO,  'N', dbo.FACTEXPDET.FED_CANT, 
								dbo.FACTEXPDET.FED_CANT AS KAP_CantTotADescargar, 0, 'D'
						FROM         dbo.MAESTRO RIGHT OUTER JOIN
						                      dbo.PEDIMPDET ON dbo.MAESTRO.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO RIGHT OUTER JOIN
						                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICED LEFT OUTER JOIN
						                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
						WHERE     (dbo.FACTEXPDET.PID_INDICED <> - 1) AND dbo.FACTEXPDET.FED_INDICED=@fed_indiced*/
				

				end

				exec SP_ESTATUSKARDESPEDFED @fed_indiced

		
				update factexpdet
				set fed_descargado='S'
				 where Fed_Indiced=@fed_indiced and pid_indiced<>-1

			
				if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indiced)
				EXEC SP_FILL_KARDESPED	
			
				update factexpdet
				set fed_descargado ='S' where fed_indiced  = @fed_indiced and fed_descargado ='N'
			


	
			FETCH NEXT FROM cur_descargafactexpdet INTO @fed_indiced, @fed_tip_ens, @ma_codigo, @CFT_TIPO, @CantGen, @Fed_fecha_struct, @pid_indiced, @fed_cant
		
		END
		
		CLOSE cur_descargafactexpdet
		DEALLOCATE cur_descargafactexpdet



		/*====================== retrabajo ===========================*/

		declare cur_descargaRetrabajo cursor for
			SELECT     FED_INDICED
			FROM FACTEXPDET
			WHERE FE_CODIGO=@fe_codigo AND FED_RETRABAJO<>'N'
			order by fed_indiced
		open cur_descargaRetrabajo
		
		
			FETCH NEXT FROM cur_descargaRetrabajo INTO @fed_indiced
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

						truncate table BOM_DESCTEMP

						EXEC sp_DescExplosion_FedRetrabajo @fed_indiced -- inserta en bom_desctemp la lista de retrabajo 
				
						exec  sp_DescRetrabajoDespFed @fed_indiced  -- inserta a almacen de desperdicio el desperdicio del retrabajo -- no descargable 


	
						declare cur_descargaHijo cursor for
							SELECT     BST_HIJO, SUM(FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)) AS CANTDESC
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED=@fed_indiced and BST_DISCH = 'S'
							GROUP BY BST_HIJO
						open cur_descargaHijo
						
						
							FETCH NEXT FROM cur_descargaHijo INTO @BST_HIJO, @CANTDESC
						
							WHILE (@@FETCH_STATUS = 0) 
							BEGIN
	
								
								exec sp_DescargaxComponente 'S', @Fe_codigo, @MetodoDescarga, @fed_indiced, 0, @BST_HIJO,
								@tipodescarga, @CANTDESC, @CANTDESC, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output

				
					
							FETCH NEXT FROM cur_descargaHijo INTO @BST_HIJO, @CANTDESC
						
							end
						
						CLOSE cur_descargaHijo
						DEALLOCATE cur_descargaHijo
		



				exec SP_ESTATUSKARDESPEDFED @fed_indiced

		
				update factexpdet
				set fed_descargado='S'
				 where Fed_Indiced=@fed_indiced and pid_indiced<>-1

			
				if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indiced)
				EXEC SP_FILL_KARDESPED	
			
				update factexpdet
				set fed_descargado ='S' where fed_indiced  = @fed_indiced and fed_descargado ='N'
			


	
			FETCH NEXT FROM cur_descargaRetrabajo INTO @fed_indiced
		
		END
		
		CLOSE cur_descargaRetrabajo
		DEALLOCATE cur_descargaRetrabajo



		/* ================== material adicional ==================*/


					truncate table BOM_DESCTEMP

					-- se agrega empaque por detalle 
					 IF (@DescargaEmpaque ='N'  or exists (select * from factexpdet left outer join maestro on factexpdet.ma_empaque= maestro.ma_codigo
									          where maestro.ma_genera_emp in ('R','T') and factexpdet.fe_codigo= @fed_indiced))
					   and @DescargaEmpaqueDet ='I'
				
					BEGIN
						if @DescargaEmpaque ='N' 
							 EXEC sp_DescEmpDetalleFed  @fe_codigo, @fed_indicedMIN, 'N'
						else
							 EXEC sp_DescEmpDetalleFed  @fe_codigo, @fed_indicedMIN, 'S'
				
					END

					-- se agrega empaque adicional 
					if @empaqueadicional <> 0 and (@DescargaEmpaque ='N' or exists (select * from factexpempaqueadicional left outer join maestro on factexpempaqueadicional.ma_codigo= maestro.ma_codigo
									          where maestro.ma_genera_emp in ('R','T') and factexpempaqueadicional.fe_codigo= @fed_indiced))
					BEGIN
						if @DescargaEmpaque ='N'
					              	EXEC sp_DescEmpAdicionalFed  @fe_codigo, @fed_indicedMIN, 'N'
						else
					              	EXEC sp_DescEmpAdicionalFed  @fe_codigo, @fed_indicedMIN, 'S'
				
					END




					IF @CF_CONTENEDOR = 'S'
					BEGIN
						 EXEC sp_DescContenedorFed  @fe_codigo, @fed_indicedMIN
					END


					if exists(select * from BOM_DESCTEMP)
					begin
						declare cur_descargaEmpaque cursor for
							SELECT     BST_HIJO, SUM(FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)) AS CANTDESC
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED=@fed_indicedMIN and BST_DISCH = 'S'
							GROUP BY BST_HIJO
						open cur_descargaEmpaque
						
						
							FETCH NEXT FROM cur_descargaEmpaque INTO @BST_HIJO, @CANTDESC
						
							WHILE (@@FETCH_STATUS = 0) 
							BEGIN
	
								
								exec sp_DescargaxComponente 'S', @Fe_codigo, @MetodoDescarga, @fed_indicedMIN, 0, @BST_HIJO,
								@tipodescarga, @CANTDESC, @CANTDESC, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output

				
					
							FETCH NEXT FROM cur_descargaEmpaque INTO @BST_HIJO, @CANTDESC
						
							end
						
						CLOSE cur_descargaEmpaque
						DEALLOCATE cur_descargaEmpaque



						exec SP_ESTATUSKARDESPEDFED @fed_indicedMIN
					
							
						update factexpdet
						set fed_descargado='S'
						 where Fed_Indiced=@fed_indicedMIN and pid_indiced<>-1
		
					
						if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indicedMIN)
						EXEC SP_FILL_KARDESPED	
					
						update factexpdet
						set fed_descargado ='S' where fed_indiced  = @fed_indicedMIN and fed_descargado ='N'
			
					end		



		--if not exists (select fed_indiced from factexpdet where Fed_Indiced=@fed_indiced
		--and pid_indiced=-1)
		UPDATE FACTEXP
		SET fe_fechadescarga=@FechaActual
		WHERE FE_CODIGO=@FE_CODIGO
	
	
		exec SP_ACTUALIZAESTATUSFACTEXP @FE_CODIGO
GO
