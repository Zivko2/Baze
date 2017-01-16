SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- explosiona la factura para la escarga
CREATE PROCEDURE [dbo].[SP_DescExplosionFactExpFed] (@fed_retrabajo char(1), @fe_codigo int, @TEmbarque char(1), @Fed_Indiced Int, @fe_fecha varchar(11), @ExplosionParaDescargar char(1)='S')   as

SET NOCOUNT ON 
declare @Fechaactual varchar(10), @COUNTFIS_COMP INT, @COUNTMP INT, @COUNTPT INT, @HayRetrabajo int, @HayNormal Int, @tipodesc char(1),
@bst_hijo int, @fed_cant decimal(38,6), @bst_disch char(1), @ti_codigo char(1), @me_codigo int, @factconv decimal(28,14), @me_gen int,
@fecha datetime, @cs_codigo smallint, @fed_tip_ens char(1)


	  SET @FechaActual = convert(varchar(25), getdate(),120)


-- Luis
SELECT     @COUNTFIS_COMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
FROM         dbo.FACTEXPDET 
WHERE (dbo.FACTEXPDET.FED_TIP_ENS = 'A') AND (dbo.FACTEXPDET.FED_INDICED = @Fed_Indiced)
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS

--

SELECT     @COUNTMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
FROM         dbo.FACTEXPDET 
WHERE (dbo.FACTEXPDET.FED_TIP_ENS = 'C')  AND (dbo.FACTEXPDET.FED_INDICED = @Fed_Indiced)
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS



SELECT     @COUNTPT = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
FROM         dbo.FACTEXPDET 
WHERE  (dbo.FACTEXPDET.FED_TIP_ENS = 'F' OR dbo.FACTEXPDET.FED_TIP_ENS = 'E' )
	AND (dbo.FACTEXPDET.FED_INDICED = @Fed_Indiced)
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS


SELECT     @HayRetrabajo = COUNT(FED_RETRABAJO) 
FROM         dbo.FACTEXPDET
WHERE (FED_INDICED = @Fed_Indiced) AND (FED_RETRABAJO = 'R' OR
                      FED_RETRABAJO = 'D' OR FED_RETRABAJO = 'E' OR FED_RETRABAJO = 'C' OR FED_RETRABAJO = 'A')
GROUP BY FE_CODIGO, FED_RETRABAJO

SELECT     @HayNormal = COUNT(FED_RETRABAJO) 
FROM         dbo.FACTEXPDET
WHERE (FED_INDICED = @Fed_Indiced) AND (FED_RETRABAJO = 'N' OR FED_RETRABAJO = 'C' OR FED_RETRABAJO = 'A')
GROUP BY FE_CODIGO, FED_RETRABAJO










/*	SELECT  @cuentamaq=count(*) from factexp where (tf_codigo in (select tf_codigo from configuratfact where (cff_tipodescarga='M')) or
	tq_codigo in (select tq_codigo from tembarque where (tq_ti_desc='M'))) and 
	(dbo.FACTEXP.FE_CODIGO = @fe_codigo )


	SELECT  @cuentaeq=count(*) from factexpdet where FE_CODIGO = @fe_codigo and ti_codigo in 
	  (select ti_codigo from configuratipo where cft_tipo in ('C', 'H', 'Q', 'X'))


*/
	
	-- cuando hay pt o sub en detalle insertamos en bom_desctemp por medio del  SP_DescExplosionBomFactExp, pero solo cuendo contempla fisicos-comprados 
	-- cuando el fed_retrabajo = N and (select cf_fiscomp_expdesc from configuracion)='S') entonces explosionara en el proceso de busqueda de saldos
	if (@fed_retrabajo = 'N' and (select cf_fiscomp_expdesc from configuracion)='N') or @fed_retrabajo <> 'N'
	IF @COUNTPT > 0 AND @HayNormal >0
	begin
		EXEC SP_FILL_BOM_DESCTEMPFED @Fed_Indiced
	end


	IF @HayRetrabajo >0
	begin
		EXEC sp_DescExplosion_FedRetrabajo @Fed_Indiced -- inserta en bom_desctemp la lista de retrabajo 

		exec  sp_DescRetrabajoDespFed @Fed_Indiced  -- inserta a almacen de desperdicio el desperdicio del retrabajo -- no descargable 
	end



	IF @COUNTMP > 0 OR @COUNTFIS_COMP > 0 
		
	BEGIN

		if @TEmbarque='D'
		set @tipodesc='D'
		else 
		set @tipodesc='N'

	-- cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente y que su clasificacion es diferente de PadreKit
		if exists (select * from factexpdet where PID_INDICED = -1 AND (CS_CODIGO<>2 or CS_CODIGO is null) and fed_indiced=@Fed_Indiced)
		begin

			if (select CF_FISCOMP_EXPDESC from configuracion)='S' -- la explosion lo hace durante el el proceso de descarga
			begin
				insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
				bst_tipodesc, bst_pertenece, bst_tipocosto)
	
				SELECT     @Fed_Indiced, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, 
					  dbo.FACTEXPDET.FED_DISCHARGE, dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
					ISNULL(dbo.MAESTRO.ME_COM, 19), 1, dbo.FACTEXPDET.FED_INDICED, 'MP', FACTEXPDET.FED_TIP_ENS, dbo.FACTEXPDET.FED_FECHA_STRUCT,
					dbo.FACTEXPDET.FED_FECHA_STRUCT, dbo.FACTEXPDET.FED_FECHA_STRUCT, @tipodesc, dbo.FACTEXPDET.MA_CODIGO, 'S'			
				FROM         dbo.FACTEXPDET LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.FACTEXPDET.FED_TIP_ENS ='C' OR dbo.FACTEXPDET.FED_TIP_ENS ='A') AND (dbo.FACTEXPDET.FED_INDICED = @Fed_Indiced) 
					AND (dbo.FACTEXPDET.FED_DISCHARGE = 'S') AND (dbo.FACTEXPDET.PID_INDICED = - 1) AND MAESTRO_1.CS_CODIGO<>2
				GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
				                      dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
				                      dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
				HAVING      (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N')
			end
			else
			begin
				insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
				bst_tipodesc, bst_pertenece, bst_tipocosto)
	
				SELECT     @Fed_Indiced, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, 
					  dbo.FACTEXPDET.FED_DISCHARGE, dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
					ISNULL(dbo.MAESTRO.ME_COM, 19), 1, dbo.FACTEXPDET.FED_INDICED, 'MP', 'C', dbo.FACTEXPDET.FED_FECHA_STRUCT,
					dbo.FACTEXPDET.FED_FECHA_STRUCT, dbo.FACTEXPDET.FED_FECHA_STRUCT, @tipodesc, dbo.FACTEXPDET.MA_CODIGO, 'S'			
				FROM         dbo.FACTEXPDET LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.FACTEXPDET.FED_TIP_ENS ='C' OR (dbo.FACTEXPDET.FED_TIP_ENS ='A' AND dbo.FACTEXPDET.MA_CODIGO
					     IN (SELECT MA_CODIGO FROM VPIDESCARGA))) 
					AND (dbo.FACTEXPDET.FED_INDICED = @Fed_Indiced) 
					AND (dbo.FACTEXPDET.FED_DISCHARGE = 'S') AND (dbo.FACTEXPDET.PID_INDICED = - 1) AND MAESTRO_1.CS_CODIGO<>2
				GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
				                      dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
				                      dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
				HAVING      (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N')


			end
		end

	-- cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente y que su clasificacion es PadreKit
		if exists (select * from factexpdet where PID_INDICED = -1 AND CS_CODIGO=2 and fed_indiced=@Fed_Indiced)
		begin
			declare CUR_DETALLEFACTMP cursor for
				SELECT     dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, dbo.FACTEXPDET.FED_DISCHARGE, 
				                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, ISNULL(dbo.MAESTRO.ME_COM, 19), 
				                      dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
				FROM         dbo.FACTEXPDET LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.FACTEXPDET.FED_TIP_ENS ='C' ) AND (dbo.FACTEXPDET.FED_INDICED = @Fed_Indiced) 
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
					(@Fed_Indiced, @bst_hijo, @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
					@me_codigo, @factconv, @me_gen, 1, @fed_indiced, 'MP', @fecha,  @fecha,  @fecha, @tipodesc, @fed_tip_ens,
					'S')
				end	
				else
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_entravigor, bst_perini, bst_perfin,
					bst_tipodesc, ma_tip_ens, bst_tipocosto)
	
					select @Fed_Indiced, @bst_hijo, bom_struct.bst_hijo, @fed_cant, bom_struct.bst_disch, maestro.ti_codigo,
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



	--HASTA AQUI PROCESO sp_DescargaSelEquipo
	
/*
	select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo in (select tq_codigo from factexp where fe_codigo=@Fed_Indiced)

	if @cfq_tipo<>'D'
	begin
		select @countdescargable=count(*) from bom_desctemp where fe_codigo = @Fed_Indiced
		and bst_tipodesc='N' or bst_tipodesc='M'


		if @countdescargable=0
			update factexp
			set fe_descargable='N'
			where fe_codigo = @Fed_Indiced
		else
			update factexp
			set fe_descargable='S'
			where fe_codigo = @Fed_Indiced
	end
	else
	begin

		select @countdescargable=count(*) from bom_desctemp where fe_codigo = @Fed_Indiced
		and bst_tipodesc='D'
	
		if @countdescargable=0
		update factexp
		set fe_descargable='N'
		where  fe_codigo = @Fed_Indiced
		else
		update factexp
		set fe_descargable='S'
		where  fe_codigo = @Fed_Indiced
	end
*/

	if @COUNTPT > 0
	exec SP_ExplosionaDesviacionFed @Fed_indiced, @fe_fecha


--	print @ExplosionParaDescargar

GO
