SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



-- explosiona la factura para la escarga
CREATE PROCEDURE [dbo].[SP_DescExplosionFactExp]
(
   @CodigoFactura Int, @user int, @Borrar char(1) = 'S', @ExplosionParaDescargar char(1) = 'S'
)
as
   SET NOCOUNT ON 

   DECLARE @COUNTMP INT,              @COUNTPT INT,              @COUNTFIS_COMP INT,        @bst_hijo int,
           @fed_cant decimal(38,6),   @bst_disch char(1),        @ti_codigo char(1),	    @me_codigo int,
           @Factconv decimal(28,14),  @me_gen int,               @DescargaEmpaque char(1),  @DescargaEmpaqueDet char(1),
           @fed_indiced int, 	      @HayRetrabajo int,         @HayNormal Int,            @CF_CONTENEDOR CHAR(1),
           @fecha datetime,           @empaqueadicional int,     @DI_PROD INT,	            @countdescargable int,
           @cs_codigo smallint,       @fe_fecha varchar(11),     @TEmbarque char(1),        @tipodesc varchar(5),
           @fed_tip_ens char(1),      @Fechaactual varchar(10),  @cfq_tipo char(1),         @fe_folio varchar(30),
           @hora varchar(15),         @em_codigo int,            @cuentamaq int,            @cuentaeq int,
           @ExisteControlRetrabajo int

   set @ExisteControlRetrabajo = 0
   SET @FechaActual = convert(varchar(25), getdate(), 120)

   select @em_codigo = em_codigo
   from intradeglobal.dbo.empresa
   where em_corto in (select replace(convert(sysname, db_name()), 'intrade', ''))

   -- borra la tabla a llenar
   if @Borrar = 'S'
      begin
         exec sp_droptable  'BOM_DESCTEMP'
         exec sp_CreaBOM_DESCTEMP
      end
  --Borra tabla temporal de las estructuras especiales de retrabajo    
  delete from BomEspecialDescTemp
   
   select @fe_fecha = fe_fecha,
          @fe_folio = fe_folio,
          @DI_PROD  = DI_PROD
   from factexp
   where fe_codigo = @CodigoFactura

   select @hora = substring(convert(varchar(100), getdate(), 9), 13, 8) + ' ' +
                  substring(convert(varchar(100), getdate(), 9), 25, 2)

   insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_hora, ava_fecha, em_codigo)
   values(@user, 1, 'Explosionado Factura Folio Doc.: ' + @fe_folio + ' Fecha Doc.: ' + convert(varchar(11),
          @fe_fecha), @hora, @FechaActual, @em_codigo)

	

   UPDATE FACTEXPDET
   SET FED_RETRABAJO = 'N'
   WHERE
      FACTEXPDET.FE_CODIGO = @CodigoFactura AND
      (FED_RETRABAJO IS NULL OR FED_RETRABAJO = '')
	
	-- Luis
	/*SELECT     @COUNTFIS_COMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
	FROM         dbo.FACTEXPDET 
	GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS
	HAVING      (dbo.FACTEXPDET.FED_TIP_ENS = 'A') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)*/
	--
	
	SELECT     @COUNTMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
	FROM         dbo.FACTEXPDET 
	GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS
	HAVING     (dbo.FACTEXPDET.FED_TIP_ENS = 'C')  AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)
	
	
	SELECT     @COUNTPT = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
	FROM         dbo.FACTEXPDET 
	WHERE  (dbo.FACTEXPDET.FED_TIP_ENS = 'F' OR dbo.FACTEXPDET.FED_TIP_ENS = 'E' OR dbo.FACTEXPDET.FED_TIP_ENS = 'A')
		AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)
	GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS
	
	
	SELECT     @HayRetrabajo = COUNT(FED_RETRABAJO) 
	FROM         dbo.FACTEXPDET
	GROUP BY FE_CODIGO, FED_RETRABAJO
	HAVING      (FE_CODIGO = @CodigoFactura) AND (FED_RETRABAJO = 'R' OR
	                      FED_RETRABAJO = 'D' OR FED_RETRABAJO = 'E' OR FED_RETRABAJO = 'C' OR FED_RETRABAJO = 'A')
	
	SELECT     @HayNormal = COUNT(FED_RETRABAJO) 
	FROM         dbo.FACTEXPDET
	GROUP BY FE_CODIGO, FED_RETRABAJO
	HAVING      (FE_CODIGO = @CodigoFactura) AND (FED_RETRABAJO = 'N' OR FED_RETRABAJO = 'C' OR FED_RETRABAJO = 'A')
	
        SELECT
           @CF_CONTENEDOR = CF_CONTENEDOR, @DescargaEmpaqueDet = CF_MAN_EMPAQUE,
           @DescargaEmpaque = CF_EMPAQUE_BOM
        FROM dbo.CONFIGURACION
	
        SELECT   @TEmbarque = dbo.CONFIGURATEMBARQUE.CFQ_TIPO
        FROM     dbo.FACTEXP LEFT OUTER JOIN
                    dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO
        GROUP BY dbo.CONFIGURATEMBARQUE.CFQ_TIPO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_TIPO
        HAVING      (dbo.FACTEXP.FE_CODIGO = @CodigoFactura)
	
	
        SELECT   @empaqueadicional = COUNT(MA_CODIGO)
        FROM     dbo.FACTEXPEMPAQUEADICIONAL
        GROUP BY FE_CODIGO
        HAVING  (FE_CODIGO = @CodigoFactura)
	
	
        select @fe_fecha = convert(varchar(11),fe_fecha,101)
        from factexp
        where fe_codigo = @CodigoFactura


	

        if exists(select *
                  from factexpdet
                  where
                     fe_codigo = @CodigoFactura and
                     (isnull(pid_indiced,0) = 0 or isnull(pid_indiced,0) = -1))
           begin

	
                SELECT  @cuentamaq = count(*)
                from factexp
                where
                   (tf_codigo in (select tf_codigo from configuratfact where (cff_tipodescarga = 'M')) or
                   tq_codigo in (select tq_codigo from tembarque where (tq_ti_desc = 'M'))) and
                   (dbo.FACTEXP.FE_CODIGO = @CodigoFactura )
	
	
		SELECT  @cuentaeq = count(*) from factexpdet where FE_CODIGO = @CodigoFactura and ti_codigo in 
		  (select ti_codigo from configuratipo where cft_tipo in ('C', 'H', 'Q', 'X'))
	
	
		if (select count(*) from factexp inner join configuratfact on factexp.tf_codigo = configuratfact.tf_codigo
		    where fe_codigo = @CodigoFactura and configuratfact.cff_tipo = 'EC') > 0
			   EXEC SP_CreaVPIDescarga 'C', @fe_fecha, @DI_PROD
		else
		if (select CF_USASALDOPEDIMPDEFINITO from configuracion) = 'S' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION) = 'N' 
		and (select count(*) from factexp where fe_codigo=@CodigoFactura and tq_codigo in (select tq_codigo from configuratembarque where cfq_tipo ='T'))>0
	
			   EXEC SP_CreaVPIDescarga 'R', @fe_fecha, @DI_PROD
		else
		if (select CF_USASALDOPEDIMPDEFINITO from configuracion) = 'N' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION) = 'N' 
		and (select count(*) from factexp where fe_codigo = @CodigoFactura and tq_codigo in (select tq_codigo from configuratembarque where cfq_tipo ='T'))>0
	
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
		SET PID_IDDESCARGA = -1
		FROM PIDESCARGA INNER JOIN VPIDESCARGA ON PIDESCARGA.PID_INDICED = VPIDESCARGA.PID_INDICED
		WHERE PIDESCARGA.PID_IDDESCARGA IS NULL OR PIDESCARGA.PID_IDDESCARGA>-1
		
		Select VPIDESCARGA.PID_INDICED, vPIDescarga.MA_CODIGO, VPIDESCARGA.PI_FEC_ENT, vPIDescarga.MA_GENERICO
		Into dbo.[#TempXX] 
		FROM PIDESCARGA INNER JOIN VPIDESCARGA ON PIDESCARGA.PID_INDICED = VPIDESCARGA.PID_INDICED

		/*
		Select PID_INDICED, -1 as PID_IDDESCARGA
		Into dbo.[#TempX] 
		FROM dbo.[#TempXX] 
		ORDER BY PI_FEC_ENT, MA_CODIGO, MA_GENERICO
	
		
		SET @X=0
		
		Update dbo.[#TempX]  
		SET PID_IDDESCARGA=@X, @X=@X+1*/


		CREATE TABLE #TempX
		(PID_IDDESCARGA [int] IDENTITY (1, 1) NOT NULL, 
		PID_INDICED [int])


		INSERT INTO #TempX(PID_INDICED)
		Select PID_INDICED
		FROM dbo.[#TempXX] 
		ORDER BY PI_FEC_ENT, MA_CODIGO, MA_GENERICO
	
		
		Update PIDESCARGA 
		SET PID_IDDESCARGA = T.PID_IDDESCARGA 
		From dbo.[#TempX]  T inner join PIDESCARGA on T.Pid_indiced = PIDESCARGA.pid_indiced
	
		DROP TABLE dbo.[#TempX] 
		DROP TABLE dbo.[#TempXX] 	
		

	
		IF (@COUNTPT > 0 AND @HayNormal > 0)
			begin 
				EXEC SP_DescExplosionBomFactExp @CodigoFactura
				--establece los saldo para el control de retrabajo, esto solo para cuando se va a descargar
				if ((select CF_APLICACONTROLRETRABAJO from Configuracion) = 'S') /*and (@ExplosionParaDescargar = 'S')*/
					begin
						--Pasa explosion original a tabla temporal
						DBCC CHECKIDENT ([BomEspecialDescTemp], RESEED, 0)
						
						insert into BomEspecialDescTemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
														FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
														BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG, BST_ORIGEN)
						select  FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
								FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
								BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG, 'O'
						from Bom_DescTemp
						
						delete from Bom_descTemp
						--Explosiona la estrcutura especial de retrabajo
						EXEC SP_DescExplosionBomEspecialFactExp @CodigoFactura
						     
						if exists(select count(*) from bom_descTemp)
							set @ExisteControlRetrabajo = 1
						else
							set @ExisteControlRetrabajo = 0
						
						exec SP_EstructuraOriginalVSEstructuraEspecial
						
						delete
						from ControlRetrabajoSaldo
						from ControlRetrabajoSaldo
									inner join ControlRetrabajoSaldoPrevio on ControlRetrabajoSaldo.CR_Codigo = ControlRetrabajoSaldoPrevio.CR_Codigo
																		  and ControlRetrabajoSaldo.CRS_CantidadDescargada = ControlRetrabajoSaldoPrevio.CRP_CantidadDescargada
																		  and ControlRetrabajoSaldo.FED_Indiced = ControlRetrabajoSaldoPrevio.FED_Indiced
							
						insert into ControlRetrabajoSaldo (CR_Codigo, CRS_CantidadDescargada, FED_Indiced)
						select CR_Codigo, CRP_CantidadDescargada, FED_Indiced from ControlRetrabajoSaldoPrevio
					end
			end


	
		IF @HayRetrabajo > 0
		begin
		
			EXEC sp_DescExplosion_Retrabajo @CodigoFactura -- inserta en bom_desctemp la lista de retrabajo 
	
			exec  sp_DescRetrabajoDesp @CodigoFactura  -- inserta a almacen de desperdicio el desperdicio del retrabajo -- no descargable 
		end
	
	
	
		IF @COUNTMP > 0 --OR @COUNTFIS_COMP > 0 
			
		BEGIN
			
			if @TEmbarque = 'D'
			   set @tipodesc = 'D'
			else 
			   set @tipodesc = 'N'
	
		-- cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente y que su clasificacion es diferente de PadreKit
			if exists (select * from factexpdet where PID_INDICED = -1 AND (CS_CODIGO <> 2 or CS_CODIGO is null) and fe_codigo = @CodigoFactura)
			begin
	
				/*if (select CF_FISCOMP_EXPDESC from configuracion)='S' -- la explosion lo hace durante el el proceso de descarga
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
					bst_tipodesc, bst_pertenece, bst_tipocosto)
		
					SELECT     @CodigoFactura, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, 
						  dbo.FACTEXPDET.FED_DISCHARGE, dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
						ISNULL(dbo.MAESTRO.ME_COM, 19), 1, dbo.FACTEXPDET.FED_INDICED, 'MP', FACTEXPDET.FED_TIP_ENS, dbo.FACTEXPDET.FED_FECHA_STRUCT,
						dbo.FACTEXPDET.FED_FECHA_STRUCT, dbo.FACTEXPDET.FED_FECHA_STRUCT, @tipodesc, dbo.FACTEXPDET.MA_CODIGO, 'S'			
					FROM         dbo.FACTEXPDET LEFT OUTER JOIN
					                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
					                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
					WHERE     (dbo.FACTEXPDET.FED_TIP_ENS ='C' OR dbo.FACTEXPDET.FED_TIP_ENS ='A') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) 
						AND (dbo.FACTEXPDET.FED_DISCHARGE = 'S') AND (dbo.FACTEXPDET.PID_INDICED = - 1) AND MAESTRO_1.CS_CODIGO<>2
					GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
					                      dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
					                      dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
					HAVING      (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N')
				end
				else*/
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
					bst_tipodesc, bst_pertenece, bst_tipocosto)
		
					SELECT
					   @CodigoFactura, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, 
					   dbo.FACTEXPDET.FED_DISCHARGE, dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
					   ISNULL(dbo.MAESTRO.ME_COM, 19), 1, dbo.FACTEXPDET.FED_INDICED, 'MP', 'C', dbo.FACTEXPDET.FED_FECHA_STRUCT,
					   dbo.FACTEXPDET.FED_FECHA_STRUCT, dbo.FACTEXPDET.FED_FECHA_STRUCT, @tipodesc, dbo.FACTEXPDET.MA_CODIGO, 'S'			
					FROM
					   dbo.FACTEXPDET LEFT OUTER JOIN
					      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
					      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
					WHERE
					   (dbo.FACTEXPDET.FED_TIP_ENS ='C') AND
					   (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND
					   (dbo.FACTEXPDET.FED_DISCHARGE = 'S') AND
					   (dbo.FACTEXPDET.PID_INDICED = - 1) AND
					   MAESTRO_1.CS_CODIGO <> 2
					GROUP BY
					   dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
					   dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
					   dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
					HAVING
					   (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND
					   (dbo.FACTEXPDET.FED_RETRABAJO = 'N')
	
	
				end
			end
	
		-- cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente y que su clasificacion es PadreKit
			if exists (select * from factexpdet where PID_INDICED = -1 AND CS_CODIGO=2 and fe_codigo=@CodigoFactura)
			begin
				declare CUR_DETALLEFACTMP cursor for
					SELECT     dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, dbo.FACTEXPDET.FED_DISCHARGE, 
					                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, ISNULL(dbo.MAESTRO.ME_COM, 19), 
					                      dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
					FROM         dbo.FACTEXPDET LEFT OUTER JOIN
					                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
					                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
					WHERE     (dbo.FACTEXPDET.FED_TIP_ENS ='C' ) AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) 
						AND (dbo.FACTEXPDET.FED_DISCHARGE = 'S') AND (dbo.FACTEXPDET.PID_INDICED = - 1) and MAESTRO_1.CS_CODIGO=2
						AND (dbo.FACTEXPDET.FED_RETRABAJO='N')
					GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
					                      dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
					                      dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
					HAVING      (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N')
		
				 OPEN CUR_DETALLEFACTMP
		
				  FETCH NEXT FROM CUR_DETALLEFACTMP INTO @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
				@me_codigo, @factconv, @me_gen, @fed_indiced, @fecha, @cs_codigo,@fed_tip_ens
		
				  WHILE (@@fetch_status = 0) 
				  BEGIN  
		
					if exists (select * from vpidescarga where ma_codigo=@bst_hijo and  pi_fec_ent<=@fe_fecha and pid_saldogen>0)
		
					-- si no se encuentra en la tabla pedimpdet con saldo se insertan los componentes para descargar
					begin
						insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
						me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_entravigor, bst_perini, bst_perfin,
						bst_tipodesc, ma_tip_ens, bst_tipocosto)
		
						values
						(@CodigoFactura, @bst_hijo, @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
						@me_codigo, @factconv, @me_gen, 1, @fed_indiced, 'MP', @fecha,  @fecha,  @fecha, @tipodesc, @fed_tip_ens,
						'S')
					end	
					else
					begin
						insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
						me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_entravigor, bst_perini, bst_perfin,
						bst_tipodesc, ma_tip_ens, bst_tipocosto)
		
						select @CodigoFactura, @bst_hijo, bom_struct.bst_hijo, @fed_cant, bom_struct.bst_disch, maestro.ti_codigo,
						bom_struct.me_codigo, bom_struct.factconv, @me_gen, bom_struct.bst_incorpor, @fed_indiced, 'MPK', @fecha, bom_struct.bst_perini, bom_struct.bst_perfin, @tipodesc,
						@fed_tip_ens, 'S'
						from bom_struct left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
						where bsu_subensamble =@bst_hijo and bst_perini<=@fecha and bst_perfin>=@fecha and bst_disch='S'
					end				
		
		
				  FETCH NEXT FROM CUR_DETALLEFACTMP INTO @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
				@me_codigo, @factconv, @me_gen, @fed_indiced, @fecha, @cs_codigo,@fed_tip_ens
		
				END
		
				CLOSE CUR_DETALLEFACTMP
				DEALLOCATE CUR_DETALLEFACTMP
			
			end	
			
		END
	
	
		-- se agrega empaque por pestaa 
	
		/*IF (@DescargaEmpaque ='N' or exists(select factexpdet.* from maestro maestro_1 right outer join factexpempaque on maestro_1.ma_codigo = factexpempaque.ma_emp2 left outer join
					              maestro maestro on factexpempaque.ma_emp1 = maestro.ma_codigo right outer join factexpdet on factexpempaque.fe_codigo = factexpdet.fe_codigo
					               where factexpdet.fe_codigo = @CodigoFactura and (maestro.ma_genera_emp in ('R', 'T') or maestro_1.ma_genera_emp in ('R', 'T')))
		and @DescargaEmpaqueDet ='P')
	
		BEGIN
			if @DescargaEmpaque ='N'
				 EXEC sp_DescEmpPestana  @CodigoFactura, 'N'
			else
				 EXEC sp_DescEmpPestana  @CodigoFactura, 'S'		
	
		END*/
	
		-- se agrega empaque por detalle 
	
	
		 IF (@DescargaEmpaque ='N'  or exists (select * from factexpdet left outer join maestro on factexpdet.ma_empaque= maestro.ma_codigo
						          where maestro.ma_genera_emp in ('R','T') and factexpdet.fe_codigo= @CodigoFactura))
		   and @DescargaEmpaqueDet ='I'
	
		BEGIN
			if @DescargaEmpaque ='N' 
				 EXEC sp_DescEmpDetalle  @CodigoFactura, 'N'
			else
				 EXEC sp_DescEmpDetalle  @CodigoFactura, 'S'
	
		END
	
	
	
	
		-- se agrega empaque adicional 
		if @empaqueadicional <> 0 and (@DescargaEmpaque ='N' or exists (select * from factexpempaqueadicional left outer join maestro on factexpempaqueadicional.ma_codigo= maestro.ma_codigo
						          where maestro.ma_genera_emp in ('R','T') and factexpempaqueadicional.fe_codigo= @CodigoFactura))
		BEGIN
			if @DescargaEmpaque ='N'
		              	EXEC sp_DescEmpAdicional  @CodigoFactura, 'N'
			else
		              	EXEC sp_DescEmpAdicional  @CodigoFactura, 'S'
	
		END
	
	
		IF @CF_CONTENEDOR = 'S'
		BEGIN
			 EXEC sp_DescContenedor  @CodigoFactura
		END
	
	end



	--inserta en kardesped la informacion de la seleccion de equipo que ya tiene asignado un pedimento 
	exec sp_DescargaSelEquipo @CodigoFactura, @FechaActual



	select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo in (select tq_codigo from factexp where fe_codigo=@CodigoFactura)




	if @cfq_tipo <> 'D'
	begin
		select @countdescargable=count(*) from bom_desctemp where fe_codigo = @CodigoFactura
		and bst_tipodesc='N' or bst_tipodesc='M'


		if @countdescargable=0
                   if exists(select *
                             from FactExp
                             where
                                fe_codigo = @CodigoFactura and
                                not (fe_descargable = 'N'))
			update factexp
			set fe_descargable = 'N'
			where fe_codigo = @CodigoFactura
		else
                   if exists(select *
                             from FactExp
                             where
                                fe_codigo = @CodigoFactura and
                                not (fe_descargable = 'S'))
			update factexp
			set fe_descargable = 'S'
			where fe_codigo = @CodigoFactura
	end
	else
	begin

		select @countdescargable=count(*) from bom_desctemp where fe_codigo = @CodigoFactura
		and bst_tipodesc='D'
	
		if @countdescargable=0
                   if exists(select *
                             from FactExp
                             where
                                fe_codigo = @CodigoFactura and
                                not (fe_descargable = 'N'))
		   update factexp
		   set fe_descargable='N'
		   where  fe_codigo = @CodigoFactura
		else
                   if exists(select *
                             from FactExp
                             where
                                fe_codigo = @CodigoFactura and
                                not (fe_descargable = 'S'))
		      update factexp
		      set fe_descargable='S'
		      where  fe_codigo = @CodigoFactura
	end



	exec SP_ExplosionaDesviacion @CodigoFactura, @ExplosionParaDescargar


	--print @ExplosionParaDescargar

	if @ExplosionParaDescargar = 'S' and @ExisteControlRetrabajo = 0
	begin
		-- en este proceso se pierde nivel y pertenece
		exec sp_droptable 'BOM_DESCTEMPbkp'
	
		SELECT
                   FE_CODIGO, FED_INDICED, BST_ENTRAVIGOR, BST_HIJO,
                   SUM(BST_INCORPOR) as BST_INCORPOR,
                   BST_DISCH,
                   max(TI_CODIGO) as TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN,
                   max(BST_TRANS) as BST_TRANS, max(BST_TIPOCOSTO) as BST_TIPOCOSTO, max(BST_COSTO) as BST_COSTO,
                   max(MA_TIP_ENS) as MA_TIP_ENS, FED_CANT, BST_TIPODESC, BST_CONTESTATUS, BST_DESCARGADO,
                   max(BST_PESO_KG) as BST_PESO_KG
                INTO
                   dbo.BOM_DESCTEMPbkp
                FROM
                   BOM_DESCTEMP
		GROUP BY
                   FE_CODIGO, FED_INDICED, BST_ENTRAVIGOR, BST_HIJO, BST_DISCH, ME_CODIGO, FACTCONV,
                   BST_PERINI, BST_PERFIN, ME_GEN, FED_CANT, BST_TIPODESC, 
                   BST_CONTESTATUS, BST_DESCARGADO
		order by
                   FED_INDICED, BST_HIJO
	

		exec sp_droptable  'BOM_DESCTEMP'
		exec sp_CreaBOM_DESCTEMP
	
                INSERT INTO BOM_DESCTEMP(FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR,
                                         BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN,
                                         BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_TIPODESC,
                                         BST_CONTESTATUS, BST_DESCARGADO, BST_PESO_KG)
		SELECT
                   FE_CODIGO, FED_INDICED, 0, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR,
                   BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN,
                   BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_TIPODESC,
                   BST_CONTESTATUS, BST_DESCARGADO, BST_PESO_KG
		FROM
                   BOM_DESCTEMPbkp
		
		
	
		exec sp_droptable 'BOM_DESCTEMPbkp'
	end

	exec SP_ExplosionaDesviacionConDiferenteConsumo @CodigoFactura, @ExplosionParaDescargar
GO
