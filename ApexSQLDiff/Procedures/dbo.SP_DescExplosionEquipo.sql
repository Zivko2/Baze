SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





















CREATE PROCEDURE [dbo].[SP_DescExplosionEquipo] (@CodigoFactura Int)   as

SET NOCOUNT ON 

DECLARE @COUNTMP INT, @bst_hijo int, @fed_cant decimal(38,6), @bst_disch char(1), @ti_codigo char(1),
	@me_codigo int, @Factconv decimal(28,14), @me_gen int, @fed_indiced int, @fechastruct datetime, @HayRetrabajo int, @HayNormal Int, @fecha datetime, 
	@empaqueadicional int, @cs_codigo smallint, @fe_fecha datetime, @cuentamaq int, @cuentaeq int, @DI_PROD INT

if exists (select * from bom_desctemp where fe_codigo=@CodigoFactura)
delete from bom_desctemp where fe_codigo=@CodigoFactura

	SELECT     @COUNTMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
	FROM         dbo.FACTEXPDET 
	GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS
	HAVING      (dbo.FACTEXPDET.FED_TIP_ENS = 'C') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)


	select @fe_fecha=fe_fecha, @DI_PROD=DI_PROD from factexp where fe_codigo=@CodigoFactura



--select @fe_fecha=convert(varchar(11),fe_fecha,101) from factexp where fe_codigo=@CodigoFactura



	SELECT  @cuentamaq=count(*) from factexp where (tf_codigo in (select tf_codigo from configuratfact where (cff_tipodescarga='M')) or
	tq_codigo in (select tq_codigo from tembarque where (tq_ti_desc='M'))) and 
	(dbo.FACTEXP.FE_CODIGO = @CodigoFactura )


	SELECT  @cuentaeq=count(*) from factexpdet where FE_CODIGO = @CodigoFactura and ti_codigo in 
	  (select ti_codigo from configuratipo where cft_tipo in ('C', 'H', 'Q', 'X'))


/*	if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' and (select count(*) from factexp where fe_codigo=@CodigoFactura and cp_codigo in
		(select cp_codigo from claveped where cp_clave in ('A1', 'T1', 'C1', 'I1')))>0
	  	 EXEC SP_CreaVPIDescarga 'D', @fe_fecha
	else
	begin*/

	if @cuentamaq =0 and @cuentaeq >0
	   EXEC SP_CreaVPIDescarga 'F', @fe_fecha, @DI_PROD
	else
	   EXEC SP_CreaVPIDescarga 'M', @fe_fecha, @DI_PROD
--	end

	IF @COUNTMP > 0 
	BEGIN

/* cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente */
		declare CUR_DETALLEFACTEQ cursor for
			SELECT     dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, dbo.FACTEXPDET.FED_DISCHARGE, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, ISNULL(dbo.MAESTRO.ME_COM, 19), 
			                      dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, MAESTRO_1.CS_CODIGO
			FROM         dbo.FACTEXPDET LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.FACTEXPDET.FED_TIP_ENS = 'C') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND (dbo.FACTEXPDET.FED_DESCARGADO = 'N') AND 
			                      (dbo.FACTEXPDET.PID_INDICED = - 1) AND (dbo.FACTEXPDET.FED_DISCHARGE='S')
			GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
			                      dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
			                      dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO
			HAVING      (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N') 

		 OPEN CUR_DETALLEFACTEQ

		  FETCH NEXT FROM CUR_DETALLEFACTEQ INTO @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
		@me_codigo, @factconv, @me_gen, @fed_indiced, @fechastruct, @cs_codigo

		  WHILE (@@fetch_status = 0) 
		  BEGIN  

			if @cs_codigo<>2  --diferente de PadreKit
			begin

				insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_tipodesc, bst_entravigor, bst_perini, bst_perfin)


				values
				(@CodigoFactura, @bst_hijo, @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
				@me_codigo, @factconv, @me_gen, 1, @fed_indiced, 'MP', 'N', @fecha,  @fecha,  @fecha)
			end
			else
			begin
				if exists (select * from vpidescarga 
					   where ma_codigo=@bst_hijo and pi_fec_ent<=@fe_fecha and pid_saldogen>0)
				/* si no se encuentra en la tabla pedimpdet con saldo se insertan los componentes para descargar*/
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_tipodesc, bst_entravigor, bst_perini, bst_perfin)
	
					values
					(@CodigoFactura, @bst_hijo, @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
					@me_codigo, @factconv, @me_gen, 1, @fed_indiced, 'MP', 'N', @fecha,  @fecha,  @fecha)
				end
				else
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_tipodesc, bst_entravigor, bst_perini, bst_perfin)
	
					select @CodigoFactura, @bst_hijo, bom_struct.bst_hijo, @fed_cant, bom_struct.bst_disch, maestro.ti_codigo,
					bom_struct.me_codigo, bom_struct.factconv, @me_gen, bom_struct.bst_incorpor, @fed_indiced, 'MPK', 'N', @fecha, bom_struct.bst_perini, bom_struct.bst_perfin
					from bom_struct left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
					where bsu_subensamble =@bst_hijo and bst_perini<=@fechastruct and bst_perfin>=@fechastruct
				end				
			end

		  FETCH NEXT FROM CUR_DETALLEFACTEQ INTO @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
		@me_codigo, @factconv, @me_gen, @fed_indiced, @fechastruct, @cs_codigo

		END

		CLOSE CUR_DETALLEFACTEQ
		DEALLOCATE CUR_DETALLEFACTEQ

	END





















GO
