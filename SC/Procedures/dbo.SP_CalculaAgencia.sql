SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_CalculaAgencia] (@AGP_CODIGO int, @PI_CODIGO int, @AGPD_VALPED decimal(38,6), @AGPD_PEDTIPO char(1), @AGPD_NOHOJAS smallint, @AGPD_NOFACT smallint, @AGPD_NOVEHI smallint, @AGPD_PRECIOTOT decimal(38,6) output)   as

declare @agp_tarifahonor decimal(38,6), @ag_codigo int, @cp_codigo int, @AGE_TIPO char(1), @AGE_CUOTAFIJA decimal(38,6), 
@AGE_IMPORTEMINIMO decimal(38,6), @AGE_IMPORTEMINIMONAC decimal(38,6), @pi_fran_int char(1), @REG_CODIGO int, @AGE_TIPOMOV char(1),
@Valor decimal(38,6)


	SELECT @AG_CODIGO=AG_CODIGO FROM AGENCIAPAG WHERE (AGP_CODIGO = @AGP_CODIGO)

	select @agp_tarifahonor=ag_tarifa from agencia where ag_codigo=@AG_CODIGO

	if @AGPD_PEDTIPO='N'
	select @cp_codigo=cp_codigo from pedimp where pi_codigo=@PI_CODIGO
	else
	select @cp_codigo=cp_codigo from claveped where cp_clave='CT'


	select @pi_fran_int=pi_fran_int, @REG_CODIGO=REG_CODIGO, @AGE_TIPOMOV=pi_movimiento from pedimp where pi_codigo=@PI_CODIGO

	-- por clave de pedimento
	if exists(SELECT * FROM AGENCIAHONORARIO WHERE AG_CODIGO = @AG_CODIGO AND CP_CODIGO = @cp_codigo)
	begin
		SELECT  @AGE_TIPO=AGE_TIPO, @AGE_CUOTAFIJA=AGE_CUOTAFIJA, @AGE_IMPORTEMINIMO=isnull(AGE_IMPORTEMINIMO,0), 
			@AGE_IMPORTEMINIMONAC=isnull(AGE_IMPORTEMINIMONAC,0)
		FROM AGENCIAHONORARIO
		WHERE AG_CODIGO = @AG_CODIGO AND CP_CODIGO = @cp_codigo

	end
	else
	-- por regimen
	if exists(SELECT * FROM AGENCIAHONORARIO WHERE AG_CODIGO = @AG_CODIGO AND REG_CODIGO = @REG_CODIGO)
	begin
		SELECT  @AGE_TIPO=AGE_TIPO, @AGE_CUOTAFIJA=AGE_CUOTAFIJA, @AGE_IMPORTEMINIMO=isnull(AGE_IMPORTEMINIMO,0), 
			@AGE_IMPORTEMINIMONAC=isnull(AGE_IMPORTEMINIMONAC,0)
		FROM AGENCIAHONORARIO
		WHERE AG_CODIGO = @AG_CODIGO AND REG_CODIGO = @REG_CODIGO

	end
	else
	-- por tipo de movimiento
	if exists(SELECT * FROM AGENCIAHONORARIO WHERE AG_CODIGO = @AG_CODIGO and AGE_TIPOMOV=@AGE_TIPOMOV)
	begin
		SELECT  @AGE_TIPO=AGE_TIPO, @AGE_CUOTAFIJA=AGE_CUOTAFIJA, @AGE_IMPORTEMINIMO=isnull(AGE_IMPORTEMINIMO,0), 
			@AGE_IMPORTEMINIMONAC=isnull(AGE_IMPORTEMINIMONAC,0)
		FROM AGENCIAHONORARIO
		WHERE AG_CODIGO = @AG_CODIGO and AGE_TIPOMOV=@AGE_TIPOMOV
	end

	
	if @AGE_TIPO='T'  -- tarifa
	begin
		set @Valor= @AGPD_VALPED*(@agp_tarifahonor/100)
	
	end
	else
	if @AGE_TIPO='C' -- cuota fija
	begin
		set @Valor= @AGE_CUOTAFIJA

	end
	else
	if @AGE_TIPO='F' -- x No. Fact.
	begin
		set @Valor= @AGE_CUOTAFIJA*@AGPD_NOFACT

	end
	else
	if @AGE_TIPO='H' -- x No. Hojas
	begin

		set @Valor= @AGE_CUOTAFIJA*@AGPD_NOHOJAS
	end
	else
	if @AGE_TIPO='V' -- x No. vehi
	begin
		set @Valor= @AGE_CUOTAFIJA*@AGPD_NOVEHI

	end

	if @pi_fran_int='I' and @Valor<@AGE_IMPORTEMINIMONAC
	set @Valor=@AGE_IMPORTEMINIMONAC
	
	if @pi_fran_int<>'I' and @Valor<@AGE_IMPORTEMINIMO
	set @Valor=@AGE_IMPORTEMINIMO



	set @AGPD_PRECIOTOT=isnull(@Valor,0)












GO
