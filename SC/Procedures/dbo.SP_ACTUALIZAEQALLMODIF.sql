SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQALLMODIF]   as

SET NOCOUNT ON 
DECLARE @ME_KILOGRAMOS int, @fechaactual datetime

select @fechaactual=convert(varchar(11),getdate(),101)

	select @ME_KILOGRAMOS=ME_KILOGRAMOS from configuracion



	UPDATE    MAESTRO
	SET              MA_PESO_KG =0.453597, MA_PESO_LB = 1
	WHERE     (ME_COM = 43)
	
	
	UPDATE    MAESTRO
	SET              MA_PESO_KG =1, MA_PESO_LB = 2.20462442018378
	WHERE     (ME_COM = 36)



	IF EXISTS (SELECT * FROM MAESTRO
		WHERE convert(varchar(11),MA_ULTIMAMODIF,101)=convert(varchar(11),getdate(),101))
	BEGIN

		update dbo.MAESTRO
		SET     dbo.MAESTRO.EQ_GEN = 1
		WHERE dbo.MAESTRO.EQ_GEN <> 1
		AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual

		if exists (SELECT dbo.MAESTRO.EQ_GEN FROM dbo.MAESTRO INNER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND MAESTRO_1.ME_COM = dbo.EQUIVALE.ME_CODIGO2
					      WHERE convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@fechaactual)
			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_GEN= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND MAESTRO_1.ME_COM = dbo.EQUIVALE.ME_CODIGO2
			WHERE dbo.MAESTRO.EQ_GEN<> dbo.EQUIVALE.EQ_CANT
			AND convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@fechaactual

		if exists (SELECT MA_CODIGO FROM MAESTRO WHERE MA_INV_GEN='G' AND ME_COM=@ME_KILOGRAMOS AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual)
		begin
			UPDATE MAESTRO
			SET EQ_GEN = MA_PESO_KG
			WHERE MA_PESO_KG>0 and EQ_GEN <> MA_PESO_KG AND MA_GENERICO IN
			(SELECT MA_CODIGO FROM MAESTRO WHERE MA_INV_GEN='G' AND ME_COM=@ME_KILOGRAMOS)
			AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual

			UPDATE MAESTRO
			SET EQ_GEN = 1
			WHERE MA_PESO_KG=0 and EQ_GEN <> 1
			AND ME_COM not in (SELECT ME_CODIGO1 FROM EQUIVALE WHERE ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))
			AND MA_GENERICO IN (SELECT MA_CODIGO FROM MAESTRO WHERE MA_INV_GEN='G' AND ME_COM=@ME_KILOGRAMOS)
			AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual

			UPDATE MAESTRO
			SET EQ_GEN = 1
			WHERE EQ_GEN <> 1 and ME_COM in (select ME_KILOGRAMOS from configuracion)
			AND MA_GENERICO IN (SELECT MA_CODIGO FROM MAESTRO WHERE MA_INV_GEN='G' AND ME_COM=@ME_KILOGRAMOS)
			AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual

		end



/*========================================== FRACTOR CONVERSION AR_IMPMX =================================*/

		if exists (select * from maestro where ar_impmx>0 and ar_impmx is not null AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual) 
		begin
	
				UPDATE MAESTRO
				SET EQ_IMPMX = 1 
				WHERE ma_inv_gen='I' AND (EQ_IMPMX IS NULL OR EQ_IMPMX=0) 
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
			-- si existe en equivalencias
				update dbo.MAESTRO
				SET     dbo.MAESTRO.EQ_IMPMX= dbo.EQUIVALE.EQ_CANT
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
				                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
				WHERE     ma_inv_gen='I' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
			-- si la unidad de medida es kilogramos
				UPDATE MAESTRO
				SET EQ_IMPMX = MA_PESO_KG
				WHERE MA_PESO_KG>0 and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_impmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_IMPMX = 1
				WHERE MA_PESO_KG=0 and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_impmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_IMPMX = 1
				WHERE ME_COM IN
				(select ME_KILOGRAMOS from configuracion)  and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_impmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
		end
	
	
		/* ============================ factor de conversion de fraccion exportacion mx ===================*/
	
		if exists (select * from maestro where ar_expmx>0 and ar_expmx is not null) 
		begin
				UPDATE MAESTRO
				SET EQ_EXPMX = 1 
				WHERE ma_inv_gen='I' AND (EQ_EXPMX IS NULL OR EQ_EXPMX=0)
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				update dbo.MAESTRO
				SET     dbo.MAESTRO.EQ_EXPMX= dbo.EQUIVALE.EQ_CANT
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
				                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
				WHERE  ma_inv_gen='I' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_EXPMX = MA_PESO_KG
				WHERE MA_PESO_KG>0 and ma_inv_gen='I'				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_expmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_EXPMX = 1
				WHERE MA_PESO_KG=0 and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_expmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_EXPMX = 1
				WHERE ME_COM IN
				(select ME_KILOGRAMOS from configuracion)  and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_expmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
	
		end
	
	
	
	
		/*================================ factor de conversion de fraccion importacion usa =========================================*/
	
		if exists (select * from maestro where ar_impfo>0 and ar_impfo is not null) 
		begin
	
			/* cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
			actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
			sea kg despues lo actualiza*/				UPDATE MAESTRO
				SET EQ_IMPFO = 1
				WHERE ma_inv_gen='I' AND (EQ_IMPFO IS NULL OR EQ_IMPFO=0)
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
			
				update dbo.MAESTRO
				SET     dbo.MAESTRO.EQ_IMPFO= dbo.EQUIVALE.EQ_CANT
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
				                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
				WHERE ma_inv_gen='I' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_IMPFO = MA_PESO_KG
				WHERE MA_PESO_KG>0 and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_impfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_IMPFO = 1
				WHERE MA_PESO_KG=0 and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_impfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
	
				UPDATE MAESTRO
				SET EQ_IMPFO = 1
				WHERE ME_COM IN
				(select ME_KILOGRAMOS from configuracion) and ma_inv_gen='I'
				and ti_codigo in (select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S')
				and ar_impfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
				AND convert(varchar(11),MA_ULTIMAMODIF,101)=@fechaactual
		end
	END






















GO
