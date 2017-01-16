SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARANCELALL]   as

SET NOCOUNT ON 

/*	update maestro set ma_peso_lb=1, 
	ma_peso_kg=0.45359229 where me_com=43*/

	if exists (select * from maestro where ar_impmx>0 and ar_impmx is not null) 
	begin

			UPDATE MAESTRO
			SET EQ_IMPMX = 1 
			WHERE ma_inv_gen='I' AND (EQ_IMPMX IS NULL OR EQ_IMPMX=0) 

			
			UPDATE MAESTRO
			SET EQ_IMPMX = 1 
			WHERE ma_inv_gen='I' AND (AR_IMPMX=0 OR AR_IMPMX IS NULL)

		-- si existe en equivalencias
			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_IMPMX= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     ma_inv_gen='I' 

		-- si la unidad de medida es kilogramos
			UPDATE MAESTRO
			SET EQ_IMPMX = round(MA_PESO_KG,6)
			WHERE MA_PESO_KG>0 and ma_inv_gen='I'
			and ar_impmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))


			UPDATE MAESTRO
			SET EQ_IMPMX = 1
			WHERE MA_PESO_KG=0 and ma_inv_gen='I'
			and ar_impmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))


	end
	


	/* factor de conversion de fraccion exportacion mx */

	if exists (select * from maestro where ar_expmx>0 and ar_expmx is not null) 
	begin
			UPDATE MAESTRO
			SET EQ_EXPMX = 1 
			WHERE ma_inv_gen='I' AND (EQ_EXPMX IS NULL OR EQ_EXPMX=0)


			UPDATE MAESTRO
			SET EQ_EXPMX = 1 
			WHERE ma_inv_gen='I' AND (AR_EXPMX=0 OR AR_EXPMX IS NULL)


			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPMX= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE  ma_inv_gen='I' 


			UPDATE MAESTRO
			SET EQ_EXPMX = round(MA_PESO_KG,6)
			WHERE MA_PESO_KG>0 and ma_inv_gen='I'
			and ar_expmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

			UPDATE MAESTRO
			SET EQ_EXPMX = 1
			WHERE MA_PESO_KG=0 and ma_inv_gen='I'
			and ar_expmx in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))


	end




	/* factor de conversion de fraccion importacion usa */

	if exists (select * from maestro where ar_impfo>0 and ar_impfo is not null) 
	begin

		/* cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		sea kg despues lo actualiza*/			
			UPDATE MAESTRO
			SET EQ_IMPFO = 1
			WHERE ma_inv_gen='I' AND (EQ_IMPFO IS NULL OR EQ_IMPFO=0)



			UPDATE MAESTRO
			SET EQ_IMPFO = 1 
			WHERE ma_inv_gen='I' AND (AR_IMPFO=0 OR AR_IMPFO IS NULL)
		
			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_IMPFO= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE ma_inv_gen='I' 


			UPDATE MAESTRO
			SET EQ_IMPFO = round(MA_PESO_KG,6)
			WHERE MA_PESO_KG>0 and ma_inv_gen='I'
			and ar_impfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

			UPDATE MAESTRO
			SET EQ_IMPFO = 1
			WHERE MA_PESO_KG=0 and ma_inv_gen='I'
			and ar_impfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))


	end

	--2010-11-26
	/* factor de conversion de fraccion importacion usa Orig */

	if exists (select * from maestro where ar_impfoUSA>0 and ar_impfoUSA is not null) 
	begin

		/* cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		sea kg despues lo actualiza*/			
			UPDATE MAESTRO
			SET EQ_IMPFOUSA = 1
			WHERE ma_inv_gen='I' AND (EQ_IMPFOUSA IS NULL OR EQ_IMPFOUSA=0)



			UPDATE MAESTRO
			SET EQ_IMPFOUSA = 1 
			WHERE ma_inv_gen='I' AND (AR_IMPFOUSA=0 OR AR_IMPFOUSA IS NULL)
		
			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_IMPFOUSA= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFOUSA = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE ma_inv_gen='I' 


			UPDATE MAESTRO
			SET EQ_IMPFOUSA = round(MA_PESO_KG,6)
			WHERE MA_PESO_KG>0 and ma_inv_gen='I'
			and ar_impfoUSA in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

			UPDATE MAESTRO
			SET EQ_IMPFOUSA = 1
			WHERE MA_PESO_KG=0 and ma_inv_gen='I'
			and ar_impfoUSA in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))


	end






	if exists (select * from maestro where ar_expfo>0 and ar_expfo is not null) 
	begin

		/* cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		sea kg despues lo actualiza*/			
			UPDATE MAESTRO
			SET EQ_EXPFO = 1
			WHERE ma_inv_gen='I' AND (EQ_EXPFO IS NULL OR EQ_EXPFO=0)



			UPDATE MAESTRO
			SET EQ_EXPFO = 1 
			WHERE ma_inv_gen='I' AND (ar_expfo=0 OR ar_expfo IS NULL)
		
			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPFO= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.ar_expfo = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE ma_inv_gen='I' 


			UPDATE MAESTRO
			SET EQ_EXPFO = round(MA_PESO_KG,6)
			WHERE MA_PESO_KG>0 and ma_inv_gen='I'
			and ar_expfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

			UPDATE MAESTRO
			SET EQ_EXPFO = 1
			WHERE MA_PESO_KG=0 and ma_inv_gen='I'
			and ar_expfo in	(select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))



			--eq_expfo2

			UPDATE MAESTRO
			SET EQ_EXPFO2 = 1
			WHERE ma_inv_gen='I' AND (EQ_EXPFO2 IS NULL OR EQ_EXPFO2=0)

		
			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPFO2= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.ar_expfo = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2
			WHERE ma_inv_gen='I' 


			UPDATE MAESTRO
			SET EQ_EXPFO2 = round(MA_PESO_KG,6)
			WHERE MA_PESO_KG>0 and ma_inv_gen='I'
			and ar_expfo in	(select ar_codigo from arancel where me_codigo2 in (select ME_KILOGRAMOS from configuracion))

			UPDATE MAESTRO
			SET EQ_EXPFO2 = 1
			WHERE MA_PESO_KG=0 and ma_inv_gen='I'
			and ar_expfo in	(select ar_codigo from arancel where me_codigo2 in (select ME_KILOGRAMOS from configuracion))


	end





	/* factor de conversion de fraccion importacion usa fisico*/

	if exists (select * from maestro inner join anexo24 on maestro.ma_codigo=anexo24.ma_codigo where ar_impfofis>0 and ar_impfofis is not null) 
	begin

			UPDATE anexo24
			SET anexo24.eq_impfofis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.ma_inv_gen='I' AND (anexo24.eq_impfofis IS NULL OR anexo24.eq_impfofis=0)
		
		
			update anexo24
			SET  anexo24.eq_impfofis= EQUIVALE.EQ_CANT
			FROM    MAESTRO INNER JOIN
		                      EQUIVALE ON MAESTRO.ME_COM = EQUIVALE.ME_CODIGO1 INNER JOIN
		                      ARANCEL ON EQUIVALE.ME_CODIGO2 = ARANCEL.ME_CODIGO INNER JOIN
		                      ANEXO24 ON MAESTRO.MA_CODIGO = ANEXO24.MA_CODIGO AND ARANCEL.AR_CODIGO = ANEXO24.AR_IMPFOFIS				
			WHERE maestro.ma_inv_gen='I' 


			UPDATE anexo24
			SET anexo24.eq_impfofis = round(maestro.MA_PESO_KG,6)
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG>0 and maestro.ma_inv_gen='I'
			and anexo24.ar_impfofis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

			UPDATE anexo24
			SET anexo24.eq_impfofis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG=0 and maestro.ma_inv_gen='I'
			and anexo24.ar_impfofis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))



	end


	/* factor de conversion de fraccion exportacion mexico fisico*/

	if exists (select * from maestro inner join anexo24 on maestro.ma_codigo=anexo24.ma_codigo where ar_expmxfis>0 and ar_expmxfis is not null) 
	begin

			UPDATE anexo24
			SET anexo24.eq_expmxfis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.ma_inv_gen='I' AND (anexo24.eq_expmxfis IS NULL OR anexo24.eq_expmxfis=0)


		
			update anexo24
			SET  anexo24.eq_expmxfis= EQUIVALE.EQ_CANT
			FROM    MAESTRO INNER JOIN
		                      EQUIVALE ON MAESTRO.ME_COM = EQUIVALE.ME_CODIGO1 INNER JOIN
		                      ARANCEL ON EQUIVALE.ME_CODIGO2 = ARANCEL.ME_CODIGO INNER JOIN
		                      ANEXO24 ON MAESTRO.MA_CODIGO = ANEXO24.MA_CODIGO AND ARANCEL.AR_CODIGO = ANEXO24.ar_expmxfis				
			WHERE maestro.ma_inv_gen='I' 


			UPDATE anexo24
			SET anexo24.eq_expmxfis = round(maestro.MA_PESO_KG,6)
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG>0 and maestro.ma_inv_gen='I'
			and anexo24.ar_expmxfis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

			UPDATE anexo24
			SET anexo24.eq_expmxfis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG=0 and maestro.ma_inv_gen='I'
			and anexo24.ar_expmxfis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))

	end


















GO
