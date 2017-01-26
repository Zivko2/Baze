SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










/* cursor para todos los subensambles y productos de la factura de exportacion, en base a lo que
se descargo se calcula el costo del producto de exportacion*/
CREATE PROCEDURE [dbo].[SP_DescValorTransaccion]  (@FE_CODIGO int)   as

SET NOCOUNT ON 
declare @fed_indiced int, @mpgrav decimal(38,6), @empgrav decimal(38,6), @mpnograv decimal(38,6), @empnograv decimal(38,6), @cft_tipo char(1),
@fed_cos_uni decimal(38,6), @countdescarga int, @CONSECUTIVO INT, @fed_indiced1 int, @kap_codigo int, @sumcant decimal(38,6), 
@sumdesc decimal(38,6), @fe_tipocambio decimal(38,6), @ngusa decimal(38,6), @fed_cant decimal(38,6)

	select @fe_tipocambio=isnull(fe_tipocambio,1) from factexp where fe_codigo=@FE_CODIGO

declare cur_factexpdet cursor for
	SELECT     FED_INDICED, FED_CANT
	FROM         FACTEXPDET
	WHERE      FE_CODIGO=@FE_CODIGO AND FED_RETRABAJO='N'

open cur_factexpdet
	FETCH NEXT FROM cur_factexpdet INTO @fed_indiced, @fed_cant

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from factexpdet where fed_indiced=@fed_indiced)

		if @cft_tipo='P' or @cft_tipo='S'
		begin

			/* Se toma el PID_COS_UNIGEN porque esta en dolares ademas en la mima unidad de medida de descarga*/	
			/* materia prima no gravable */
			if exists (SELECT SUM(isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) * isnull(dbo.KARDESPED.KAP_CANTDESC,0))
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'M', 'O', 'L') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced AND 
				                      (dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_mx FROM configuracion) OR
				                      dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_ca FROM configuracion) OR
				                      dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_usa FROM configuracion)   AND (dbo.PEDIMPDET.PID_DEF_TIP='P')))
	
				SELECT     @mpnograv=SUM(isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) * isnull(dbo.KARDESPED.KAP_CANTDESC,0))
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
				                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'M', 'O', 'L') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced AND 
				                      (dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_mx FROM configuracion) OR
				                      dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_ca FROM configuracion) OR
				                      dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_usa FROM configuracion)   AND (dbo.PEDIMPDET.PID_DEF_TIP='P'))
			else
				set @mpnograv=0


			/* campo ng_usa */

			if exists (SELECT SUM(isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) * isnull(dbo.KARDESPED.KAP_CANTDESC,0))
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'M', 'O', 'L')) AND (dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced) AND 
				                      ((dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_usa FROM configuracion)   AND (dbo.PEDIMPDET.PID_DEF_TIP='P'))))
	
				SELECT     @ngusa=SUM(isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) * isnull(dbo.KARDESPED.KAP_CANTDESC,0))
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
				                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     (dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'M', 'O', 'L')) AND (dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced) AND 
				                      ((dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_usa FROM configuracion)   AND (dbo.PEDIMPDET.PID_DEF_TIP='P')))
			else
				set @ngusa=0
	
	
			/* empaque no gravable */
			if exists (SELECT  SUM(isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) * isnull(dbo.KARDESPED.KAP_CANTDESC,0))
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('E', 'T') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced 
					AND (/*dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_mx FROM configuracion) OR 
					dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_ca FROM configuracion) OR*/ 
					dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_usa FROM configuracion) 
					AND dbo.PEDIMPDET.PID_DEF_TIP='P'))
	
				SELECT  @empnograv=SUM(isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) * isnull(dbo.KARDESPED.KAP_CANTDESC,0))
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
				                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('E', 'T') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced 
					AND (/*dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_mx FROM configuracion) OR 
					dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_ca FROM configuracion) OR*/ 
					dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_usa FROM configuracion) 
					AND dbo.PEDIMPDET.PID_DEF_TIP='P')
			else
				set @empnograv=0
	 		
			/* materia prima gravable */
			if exists (SELECT     SUM(ISNULL(ISNULL(dbo.PEDIMPDET.PID_COS_UNIGEN, 0) * ISNULL(dbo.KARDESPED.KAP_CANTDESC, 0), 0)) 
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'M', 'O', 'L') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced 
					AND dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_mx FROM configuracion) AND 
					dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_ca FROM configuracion) AND 
					dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_usa FROM configuracion))
	
			SELECT  @mpgrav=   SUM(ISNULL(ISNULL(dbo.PEDIMPDET.PID_COS_UNIGEN, 0) * ISNULL(dbo.KARDESPED.KAP_CANTDESC, 0), 0)) 
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'M', 'O', 'L') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced 
					AND dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_mx FROM configuracion) AND 
					dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_ca FROM configuracion) AND 
					dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_usa FROM configuracion)
			else
				set @mpgrav=0
			
			/* empaque gravable */
			if exists (SELECT     SUM(ISNULL(ISNULL(dbo.PEDIMPDET.PID_COS_UNIGEN, 0) * ISNULL(dbo.KARDESPED.KAP_CANTDESC, 0), 0)) 
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('E', 'T') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced 
					AND (/*dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_mx FROM configuracion) OR 
					dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_ca FROM configuracion) OR*/ 
					dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_usa FROM configuracion) 
					OR dbo.PEDIMPDET.PID_DEF_TIP<>'P'))
	
				SELECT @empgrav=    SUM(ISNULL(ISNULL(dbo.PEDIMPDET.PID_COS_UNIGEN, 0) * ISNULL(dbo.KARDESPED.KAP_CANTDESC, 0), 0)) 
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.KARDESPED ON dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
				                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE     dbo.CONFIGURATIPO.CFT_TIPO IN ('E', 'T') AND dbo.KARDESPED.KAP_INDICED_FACT = @fed_indiced 
						AND (/*dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_mx FROM configuracion) OR 
						dbo.PEDIMPDET.PA_ORIGEN IN (SELECT cf_pais_ca FROM configuracion) OR*/ 
						dbo.PEDIMPDET.PA_ORIGEN NOT IN (SELECT cf_pais_usa FROM configuracion) 
						OR dbo.PEDIMPDET.PID_DEF_TIP<>'P')
				else
					set @empgrav=0


			/* actualizacion de costos cuando es P o S, se tiene que dividir de nuevo por la cantidad porque el valor es unitario,
			en un inicio se multiplica por la cantidad descargada por que los costos unitarios pueden ser diferentes de un pedimento afectado a otro*/

				if @mpgrav>0
					update factexpdet
					set fed_gra_mp=round(isnull(@mpgrav/fed_cant,0),6)
					where fed_indiced=@fed_indiced
				else
					update factexpdet
					set fed_gra_mp=0
					where fed_indiced=@fed_indiced


				if @empgrav>0
					update factexpdet
					set fed_gra_emp=round(isnull(@empgrav/fed_cant,0),6)
					where fed_indiced=@fed_indiced
				else
					update factexpdet
					set fed_gra_emp=0
					where fed_indiced=@fed_indiced


				if @mpnograv>0
					update factexpdet
					set fed_ng_mp =round(isnull(@mpnograv/fed_cant,0),6)
					where fed_indiced=@fed_indiced
				else
					update factexpdet
					set fed_ng_mp =0
					where fed_indiced=@fed_indiced

				if @ngusa>0
					update factexpdet
					set fed_ng_usa=round(isnull(@ngusa/fed_cant,0),6)
					where fed_indiced=@fed_indiced
				else
					update factexpdet
					set fed_ng_usa=0
					where fed_indiced=@fed_indiced



				if @empnograv>0
					update factexpdet
					set fed_ng_emp=round(isnull(@empnograv/fed_cant,0),6)
					where fed_indiced=@fed_indiced
				else
					update factexpdet
					set fed_ng_emp=0
					where fed_indiced=@fed_indiced


				update factexpdet
				set fed_cos_uni= Round((FED_GRA_GI + FED_NG_MP + FED_NG_EMP  + FED_NG_ADD  + FED_GRA_MO  +
					                     FED_GRA_GI_MX + FED_GRA_MP + FED_GRA_EMP + FED_GRA_ADD) ,6 )
				where fed_indiced=@fed_indiced

				update factexpdet
				set fed_cos_tot = fed_cos_uni * fed_cant
				where fed_indiced=@fed_indiced


		end
		else
		begin
			

			SELECT    @fed_cos_uni= SUM(KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / @fed_cant
			FROM         FACTEXPDET INNER JOIN
			                      KARDESPED ON FACTEXPDET.FED_INDICED = KARDESPED.KAP_INDICED_FACT INNER JOIN
			                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED
			WHERE     (KARDESPED.KAP_ESTATUS <> 'N') AND (KARDESPED.KAP_ESTATUS <> 'B') AND (FACTEXPDET.FED_INDICED = @fed_indiced)
			HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)

			if @fed_cos_uni>0
				update factexpdet
				set fed_cos_uni=round(isnull(@fed_cos_uni,0),6)
				where fed_indiced=@fed_indiced
			else
				update factexpdet
				set fed_cos_uni=0
				where fed_indiced=@fed_indiced

				update factexpdet
				set fed_cos_tot = fed_cos_uni * fed_cant
				where fed_indiced=@fed_indiced


		end


	FETCH NEXT FROM cur_factexpdet INTO @fed_indiced, @fed_cant

END

CLOSE cur_factexpdet
DEALLOCATE cur_factexpdet



























GO
