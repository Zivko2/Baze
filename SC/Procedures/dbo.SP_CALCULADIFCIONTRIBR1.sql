SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_CALCULADIFCIONTRIBR1] (@PI_CODIGO INT)   as

declare @pi_rectifica int, @PIT_CONTRIBTOTMNANT decimal(38,6), @VALOR decimal(38,6), @CON_CODIGO int, @PIT_CONTRIBTOTMN decimal(38,6), @PG_CODIGO int, @cfijadta decimal(38,6), @pi_fec_pag DATETIME,
@pi_movimiento CHAR(1), @VALOR2 decimal(38,6)


	select @pi_rectifica=pi_rectifica, @pi_fec_pag=pi_fec_pagr1, @pi_movimiento=pi_movimiento from pedimp where pi_codigo=@PI_CODIGO


	if exists(select * from PEDIMPCONTRIBUCIONDIFR1 where pi_codigo=@PI_CODIGO)
		delete from PEDIMPCONTRIBUCIONDIFR1 where pi_codigo=@PI_CODIGO



-- a nivel partida
declare cur_ContribucionPartida cursor for
	SELECT CON_CODIGO, 
	SUM(ROUND(ISNULL(PIB_CONTRIBTOTMN,0), 0)), 
	    PG_CODIGO
	FROM PEDIMPDETBCONTRIBUCION
	WHERE PI_CODIGO=@PI_CODIGO
	GROUP BY CON_CODIGO, PG_CODIGO
	HAVING SUM(ROUND(ISNULL(PIB_CONTRIBTOTMN,0), 0))>0

	SET @VALOR2=0

open cur_ContribucionPartida
	FETCH NEXT FROM cur_ContribucionPartida INTO @CON_CODIGO, @PIT_CONTRIBTOTMN, @PG_CODIGO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	-- pedimento rectificado
	SELECT @PIT_CONTRIBTOTMNANT =SUM(ROUND(ISNULL(PIB_CONTRIBTOTMN,0), 0)) 
	FROM PEDIMPDETBCONTRIBUCION
	WHERE PI_CODIGO=@pi_rectifica
	            and CON_CODIGO=@CON_CODIGO
	GROUP BY CON_CODIGO

		IF @PIT_CONTRIBTOTMN > isnull(@PIT_CONTRIBTOTMNANT,0)
		begin
			
			SELECT @VALOR=ROUND(@PIT_CONTRIBTOTMN-@PIT_CONTRIBTOTMNANT,6)

			INSERT INTO PEDIMPCONTRIBUCIONDIFR1 (PI_CODIGO, CON_CODIGO, PIF_CONTRIBTOTMN, PG_CODIGO)
			VALUES(@PI_CODIGO, @CON_CODIGO, @VALOR, @PG_CODIGO)

		end
		else
		begin
			SELECT @VALOR2=ROUND(@PIT_CONTRIBTOTMNANT-@PIT_CONTRIBTOTMN,6)+@VALOR2


		end

		

	FETCH NEXT FROM cur_ContribucionPartida INTO @CON_CODIGO, @PIT_CONTRIBTOTMN, @PG_CODIGO

	END

CLOSE cur_ContribucionPartida
DEALLOCATE cur_ContribucionPartida




-- a nivel general
declare cur_ContribucionGeneral cursor for
	SELECT CON_CODIGO, 
	     SUM(ROUND(ISNULL(PIT_CONTRIBTOTMN,0), 0)), 
	    PG_CODIGO
	FROM PEDIMPCONTRIBUCION
	WHERE PIT_TIPO='N' AND PI_CODIGO=@PI_CODIGO
	GROUP BY CON_CODIGO, PG_CODIGO
	HAVING SUM(ROUND(ISNULL(PIT_CONTRIBTOTMN,0), 0)) >0
open cur_ContribucionGeneral
	FETCH NEXT FROM cur_ContribucionGeneral INTO @CON_CODIGO, @PIT_CONTRIBTOTMN, @PG_CODIGO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	-- pedimento rectificado
	SELECT @PIT_CONTRIBTOTMNANT=SUM(ROUND(ISNULL(PIT_CONTRIBTOTMN,0), 0)) 
	FROM PEDIMPCONTRIBUCION
	WHERE PIT_TIPO='N' AND PI_CODIGO=@pi_rectifica
		and CON_CODIGO=@CON_CODIGO
	GROUP BY CON_CODIGO


		IF @PIT_CONTRIBTOTMN > isnull(@PIT_CONTRIBTOTMNANT,0)
		begin
			
			SELECT @VALOR=ROUND(@PIT_CONTRIBTOTMN-@PIT_CONTRIBTOTMNANT,6)

			INSERT INTO PEDIMPCONTRIBUCIONDIFR1 (PI_CODIGO, CON_CODIGO, PIF_CONTRIBTOTMN, PG_CODIGO)
			VALUES(@PI_CODIGO, @CON_CODIGO, @VALOR, @PG_CODIGO)

		end
		else
		begin
			SELECT @VALOR2=ROUND(@PIT_CONTRIBTOTMNANT-@PIT_CONTRIBTOTMN,6)+@VALOR2


		end

		

	FETCH NEXT FROM cur_ContribucionGeneral INTO @CON_CODIGO, @PIT_CONTRIBTOTMN, @PG_CODIGO

	END

CLOSE cur_ContribucionGeneral
DEALLOCATE cur_ContribucionGeneral


	IF @VALOR2 >0 
	begin
		INSERT INTO PEDIMPCONTRIBUCIONDIFR1 (PI_CODIGO, CON_CODIGO, PIF_CONTRIBTOTMN, PG_CODIGO)
		SELECT @PI_CODIGO, (select con_codigo from contribucion where con_clave='50'), @VALOR2, (select pg_codigo from tpago where pg_clavem3='16')
	end



	if @pi_fec_pag is not null
	begin
		if (@pi_movimiento='E')
			select @cfijadta=cof_valor from contribucionfija where con_codigo in(select con_codigo from contribucion where con_clave='1') and cof_perini<=@pi_fec_pag and cof_perfin>=@pi_fec_pag
			and cof_tipo='I'
		else
			select @cfijadta=cof_valor from contribucionfija where con_codigo in(select con_codigo from contribucion where con_clave='1') and cof_perini<=@pi_fec_pag and cof_perfin>=@pi_fec_pag
			and cof_tipo='E'
	end



	if exists(select * from PEDIMPCONTRIBUCIONDIFR1 where con_codigo in(select con_codigo from contribucion where con_clave='1') and pi_codigo=@PI_CODIGO)
		delete from PEDIMPCONTRIBUCIONDIFR1 where con_codigo in(select con_codigo from contribucion where con_clave='1') and pi_codigo=@PI_CODIGO
	


	if exists(select * from PEDIMPCONTRIBUCION where pi_codigo=@PI_CODIGO and con_codigo in (select con_codigo from contribucion where con_clave='1'))
		INSERT INTO PEDIMPCONTRIBUCIONDIFR1 (PI_CODIGO, CON_CODIGO, PIF_CONTRIBTOTMN, PG_CODIGO)
		SELECT @PI_CODIGO, (select con_codigo from contribucion where con_clave='1'), @cfijadta, (select pg_codigo from tpago where pg_clave='0')




GO
