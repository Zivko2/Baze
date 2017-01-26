SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARANCEL] (@ar_codigo int, @ma_codigo int )   as

SET NOCOUNT ON 
declare @me_codigo int , @me_codigo2 int,  @me_com int

select @ME_CODIGO2=me_codigo2 from arancel where ar_codigo=@ar_codigo

select @ME_CODIGO=me_codigo from arancel where ar_codigo=@ar_codigo

select @me_com= me_com from maestro where ma_codigo = @ma_codigo



if @ma_codigo=-1
begin

/*	update maestro set ma_peso_lb=1, 
	ma_peso_kg=0.45359229 where me_com=43*/

	if exists (select * from maestro where ar_impmx=@ar_codigo) 
	begin
		-- si existe en equivalencias
		if exists (SELECT     dbo.MAESTRO.EQ_IMPMX FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' )

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_IMPMX= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I'

		else
			UPDATE MAESTRO
			SET EQ_IMPMX = 1
			WHERE ar_impmx = @ar_codigo and ma_inv_gen='I' 


		-- si la unidad de medida es kilogramos
		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_IMPMX = MA_PESO_KG
			WHERE ar_impmx = @ar_codigo and MA_PESO_KG>0 and ma_inv_gen='I'

			UPDATE MAESTRO
			SET EQ_IMPMX = 1
			WHERE ar_impmx = @ar_codigo and MA_PESO_KG=0 and ma_inv_gen='I'


		end

	end


	/* factor de conversion de fraccion exportacion mx */


	if exists (select * from maestro where ar_EXPMX=@ar_codigo) 
	begin

		if exists (SELECT     dbo.MAESTRO.EQ_EXPMX FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' )

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPMX= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' 

		else
			UPDATE MAESTRO
			SET EQ_EXPMX = 1
			WHERE ar_EXPMX = @ar_codigo and ma_inv_gen='I' 



		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_EXPMX = MA_PESO_KG
			WHERE ar_EXPMX = @ar_codigo and MA_PESO_KG>0 and ma_inv_gen='I'

			UPDATE MAESTRO
			SET EQ_EXPMX = 1
			WHERE ar_EXPMX = @ar_codigo and MA_PESO_KG=0 and ma_inv_gen='I'



		end

	end




	/* factor de conversion de fraccion importacion usa */


	if exists (select * from maestro where ar_expfo=@ar_codigo) 
	begin

		/* cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		sea kg despues lo actualiza*/
		
		if exists (SELECT     dbo.MAESTRO.EQ_EXPFO FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.ar_expfo = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' )

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPFO= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.ar_expfo = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' 
		else
			UPDATE MAESTRO
			SET EQ_EXPFO = 1
			WHERE ar_expfo = @ar_codigo and ma_inv_gen='I'




		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_EXPFO = MA_PESO_KG
			WHERE ar_expfo = @ar_codigo and MA_PESO_KG>0 and ma_inv_gen='I'


			UPDATE MAESTRO
			SET EQ_EXPFO = 1
			WHERE ar_expfo = @ar_codigo and MA_PESO_KG=0 and ma_inv_gen='I'


		end

		--EXPFO2
		if exists (SELECT     dbo.MAESTRO.EQ_EXPFO2 FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.ar_expfo = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' )

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPFO2= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.ar_expfo = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and ma_inv_gen='I' 
		else
			UPDATE MAESTRO
			SET EQ_EXPFO2 = 1
			WHERE ar_expfo = @ar_codigo and ma_inv_gen='I'




		if @ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_EXPFO2 = MA_PESO_KG
			WHERE ar_expfo = @ar_codigo and MA_PESO_KG>0 and ma_inv_gen='I'

			UPDATE MAESTRO
			SET EQ_EXPFO2 = 1
			WHERE ar_expfo = @ar_codigo and MA_PESO_KG=0 and ma_inv_gen='I'

		end


	end


	if exists (select * from maestro inner join anexo24 on maestro.ma_codigo=anexo24.ma_codigo where ar_impfofis=@ar_codigo) 
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
			and ANEXO24.AR_IMPFOFIS=@ar_codigo

			UPDATE anexo24
			SET anexo24.eq_impfofis = maestro.MA_PESO_KG
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG>0 and maestro.ma_inv_gen='I'
			and anexo24.ar_impfofis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.AR_IMPFOFIS=@ar_codigo

			UPDATE anexo24
			SET anexo24.eq_impfofis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG=0 and maestro.ma_inv_gen='I'
			and anexo24.ar_impfofis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.AR_IMPFOFIS=@ar_codigo

	end


	/* factor de conversion de fraccion exportacion mexico fisico*/

	if exists (select * from maestro inner join anexo24 on maestro.ma_codigo=anexo24.ma_codigo where ar_expmxfis=@ar_codigo) 
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
			and ANEXO24.ar_expmxfis=@ar_codigo

			UPDATE anexo24
			SET anexo24.eq_expmxfis = maestro.MA_PESO_KG
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG>0 and maestro.ma_inv_gen='I'
			and anexo24.ar_expmxfis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.ar_expmxfis=@ar_codigo

			UPDATE anexo24
			SET anexo24.eq_expmxfis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG=0 and maestro.ma_inv_gen='I'
			and anexo24.ar_expmxfis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.ar_expmxfis=@ar_codigo

	end

end
else  -- se corre desde el cat. maestro
begin
/*	if (@me_com is not null) and ((@me_com = 43) or (@me_com = 36))
	  update maestro set ma_peso_lb=1, 
	  ma_peso_kg=0.45359229 where (me_com=43 or me_com=36)
	  and ma_codigo=@ma_codigo*/

	/* factor de conversion de fraccion exportacion mx */

	if exists (select * from maestro where ma_codigo=@ma_codigo and ar_expmx=@ar_codigo) 
	begin

		if exists (SELECT     dbo.MAESTRO.EQ_EXPMX FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo)

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPMX= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo

		else
			UPDATE MAESTRO
			SET EQ_EXPMX = 1
			WHERE ar_EXPMX = @ar_codigo and dbo.MAESTRO.MA_CODIGO=@ma_codigo



		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_EXPMX = MA_PESO_KG
			WHERE ar_EXPMX = @ar_codigo and MA_PESO_KG>0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo

			UPDATE MAESTRO
			SET EQ_EXPMX = 1
			WHERE ar_EXPMX = @ar_codigo and MA_PESO_KG=0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo


		end

	end


	/* factor de conversion de fraccion importacion usa */


	if exists (select * from maestro where ma_codigo=@ma_codigo and ar_impfo=@ar_codigo) 
	begin

		-- cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		-- actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		-- sea kg despues lo actualiza
		
		if exists (SELECT     dbo.MAESTRO.EQ_IMPFO FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo)

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_IMPFO= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo
		else
			UPDATE MAESTRO
			SET EQ_IMPFO = 1
			WHERE ar_impfo = @ar_codigo and dbo.MAESTRO.MA_CODIGO=@ma_codigo



		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_IMPFO = MA_PESO_KG
			WHERE ar_impfo = @ar_codigo and MA_PESO_KG>0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo

			UPDATE MAESTRO
			SET EQ_IMPFO = 1
			WHERE ar_impfo = @ar_codigo and MA_PESO_KG=0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo


		end
	end

	--2010-11-26
	if exists (select * from maestro where ma_codigo=@ma_codigo and ar_impfoUSA=@ar_codigo) 
	begin

		-- cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		-- actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		-- sea kg despues lo actualiza
		
		if exists (SELECT     dbo.MAESTRO.EQ_IMPFOUSA FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFOUSA = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo)

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_IMPFOUSA= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFOUSA = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo
		else
			UPDATE MAESTRO
			SET EQ_IMPFOUSA = 1
			WHERE ar_impfoUSA = @ar_codigo and dbo.MAESTRO.MA_CODIGO=@ma_codigo



		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_IMPFOUSA = MA_PESO_KG
			WHERE ar_impfoUSA = @ar_codigo and MA_PESO_KG>0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo

			UPDATE MAESTRO
			SET EQ_IMPFOUSA = 1
			WHERE ar_impfoUSA = @ar_codigo and MA_PESO_KG=0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo


		end
	end




	if exists (select * from maestro where ma_codigo=@ma_codigo and AR_EXPFO=@ar_codigo) 
	begin

		-- cuando existe la equivalencia entre la unidad de medida del no. de parte vs um arancel se
		-- actualiza, pero si no que actualice a 1, en dado caso que la um de la fraccion 
		-- sea kg despues lo actualiza
		
		if exists (SELECT     dbo.MAESTRO.EQ_EXPFO FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo)

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPFO= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo
		else
			UPDATE MAESTRO
			SET EQ_EXPFO = 1
			WHERE AR_EXPFO = @ar_codigo and dbo.MAESTRO.MA_CODIGO=@ma_codigo



		if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_EXPFO = MA_PESO_KG
			WHERE AR_EXPFO = @ar_codigo and MA_PESO_KG>0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo

			UPDATE MAESTRO
			SET EQ_EXPFO = 1
			WHERE AR_EXPFO = @ar_codigo and MA_PESO_KG=0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo


		end

		--expfo2
		if exists (SELECT     dbo.MAESTRO.EQ_EXPFO FROM dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo)

			update dbo.MAESTRO
			SET     dbo.MAESTRO.EQ_EXPFO2= dbo.EQUIVALE.EQ_CANT
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.ARANCEL ON dbo.MAESTRO.AR_EXPFO = dbo.ARANCEL.AR_CODIGO INNER JOIN
			                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2
			WHERE     (dbo.ARANCEL.AR_CODIGO = @ar_codigo) and dbo.MAESTRO.MA_CODIGO=@ma_codigo
		else
			UPDATE MAESTRO
			SET EQ_EXPFO2 = 1
			WHERE AR_EXPFO = @ar_codigo and dbo.MAESTRO.MA_CODIGO=@ma_codigo



		if @ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion) 
		begin
			UPDATE MAESTRO
			SET EQ_EXPFO2 = MA_PESO_KG
			WHERE AR_EXPFO = @ar_codigo and MA_PESO_KG>0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo

			UPDATE MAESTRO
			SET EQ_EXPFO2 = 1
			WHERE AR_EXPFO = @ar_codigo and MA_PESO_KG=0 and dbo.MAESTRO.MA_CODIGO=@ma_codigo

		end
	end




	if exists (select * from maestro inner join anexo24 on maestro.ma_codigo=anexo24.ma_codigo where ar_impfofis=@ar_codigo and maestro.ma_codigo=@ma_codigo) 
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
			and ANEXO24.AR_IMPFOFIS=@ar_codigo and maestro.ma_codigo=@ma_codigo

			UPDATE anexo24
			SET anexo24.eq_impfofis = maestro.MA_PESO_KG
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG>0 and maestro.ma_inv_gen='I'
			and anexo24.ar_impfofis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.AR_IMPFOFIS=@ar_codigo and maestro.ma_codigo=@ma_codigo

			UPDATE anexo24
			SET anexo24.eq_impfofis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG=0 and maestro.ma_inv_gen='I'
			and anexo24.ar_impfofis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.AR_IMPFOFIS=@ar_codigo and maestro.ma_codigo=@ma_codigo

	end


	/* factor de conversion de fraccion exportacion mexico fisico*/

	if exists (select * from maestro inner join anexo24 on maestro.ma_codigo=anexo24.ma_codigo where ar_expmxfis=@ar_codigo and maestro.ma_codigo=@ma_codigo) 
	begin

			UPDATE anexo24
			SET anexo24.eq_expmxfis = 1			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.ma_inv_gen='I' AND (anexo24.eq_expmxfis IS NULL OR anexo24.eq_expmxfis=0)

		
			update anexo24
			SET  anexo24.eq_expmxfis= EQUIVALE.EQ_CANT
			FROM    MAESTRO INNER JOIN
		                      EQUIVALE ON MAESTRO.ME_COM = EQUIVALE.ME_CODIGO1 INNER JOIN
		                      ARANCEL ON EQUIVALE.ME_CODIGO2 = ARANCEL.ME_CODIGO INNER JOIN
		                      ANEXO24 ON MAESTRO.MA_CODIGO = ANEXO24.MA_CODIGO AND ARANCEL.AR_CODIGO = ANEXO24.ar_expmxfis				
			WHERE maestro.ma_inv_gen='I' 
			and ANEXO24.ar_expmxfis=@ar_codigo and maestro.ma_codigo=@ma_codigo

			UPDATE anexo24
			SET anexo24.eq_expmxfis = maestro.MA_PESO_KG
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG>0 and maestro.ma_inv_gen='I'
			and anexo24.ar_expmxfis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.ar_expmxfis=@ar_codigo and maestro.ma_codigo=@ma_codigo

			UPDATE anexo24
			SET anexo24.eq_expmxfis = 1
			FROM ANEXO24 INNER JOIN MAESTRO ON ANEXO24.MA_CODIGO=MAESTRO.MA_CODIGO
			WHERE maestro.MA_PESO_KG=0 and maestro.ma_inv_gen='I'
			and anexo24.ar_expmxfis in (select ar_codigo from arancel where me_codigo in (select ME_KILOGRAMOS from configuracion))
			and ANEXO24.ar_expmxfis=@ar_codigo and maestro.ma_codigo=@ma_codigo


	end


end




















GO
