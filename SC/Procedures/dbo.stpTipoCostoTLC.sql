SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE PROCEDURE stpTipoCostoTLC (@clt_codigo int, @bst_trans char(1), @pa_codigo int, @tipocosto char(1) output)  as

SET NOCOUNT ON 

BEGIN
	DECLARE @esGravable char(1), @esAnadido  char(1), @esMP char(1), @Res char(1), @esSUB Char(1), @ma_def_tip char(1),
	@ma_servicio char(1), @spi_codigo int, @bst_hijo int, @bst_perini datetime, @nft_codigo int, @spi_codigo2 int, @ti_codigo varchar(5), @ar_expmx int,
	@ar_fraccion varchar(6), @ma_consta char(1)




	select @bst_hijo=bst_hijo, @bst_perini=bst_perini, @nft_codigo=nft_codigo, @ti_codigo=ti_codigo from clasificatlc where clt_codigo=@clt_codigo
	select @spi_codigo=spi_codigo from nafta where nft_codigo= @nft_codigo

	select @ma_def_tip=ma_def_tip, @ma_servicio=ma_servicio, @spi_codigo2=spi_codigo, @ar_expmx= isnull(ar_expmx,ar_impmx),
		@ma_consta=ma_consta  from maestro where ma_codigo =@bst_hijo

	select @ar_fraccion=left(replace(ar_fraccion,'.',''),6) from arancel where ar_codigo=@ar_expmx

-- @ma_servicio='S'  significa solo se utiliza en servicios, en dado caso se considera no gravable

	IF (@pa_codigo in (SELECT CF_PAIS_MX FROM dbo.CONFIGURACION) OR 
	     @pa_codigo in (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO = @spi_codigo))
	begin  -- origen pertenece al tratado
		if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' -- basandose si existe certificado de origen
		begin
			if (@bst_trans = 'N') and exists (SELECT CERTORIGMPDET.MA_CODIGO
							FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
						         WHERE CERTORIGMP.SPI_CODIGO = @spi_codigo and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''), 6)=@ar_fraccion
							     AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= getdate()AND CERTORIGMP.CMP_FECHATRANS >= getdate()
							     AND CERTORIGMPDET.MA_CODIGO = @bst_hijo)
			begin
				  set @esGravable = 'X'			

			end
			else
			if @ma_servicio='S'
				set @esGravable = 'X'
			else
				set @esGravable = 'S'

		end
		else
		begin
			if (@bst_trans = 'N') and @ma_def_tip='P' and @spi_codigo2=@spi_codigo
			begin
				-- no gravables
				set @esGravable = 'X'		-- no gravable para mx pero gravable para usa
			end
			else
			if @ma_servicio='S'
				set @esGravable = 'X' 
			else
				set @esGravable = 'S'

		end


	end
	else  
		if @ma_servicio='S'
			set @esGravable = 'X' -- no gravable para mx pero gravable para usa
		else
			set @esGravable = 'S'
		


	IF (@pa_codigo in (SELECT CF_PAIS_MX FROM dbo.CONFIGURACION))  and @ma_consta='S'
		  set @esGravable = 'Z'		
	
	-- Es Anadida? 
	IF (SELECT ma.MA_REPARA
	FROM MAESTRO ma RIGHT OUTER JOIN CLASIFICATLC st ON ma.MA_CODIGO = st.BST_HIJO
	WHERE (st.clt_codigo = @clt_codigo)) <> 'A'
		set @esAnadido = 'N'
	ELSE
		set @esAnadido = 'S'
	
	-- Es Materia Prima? 
	IF @ti_codigo = 'R' or 
	@ti_codigo = 'L' or
	@ti_codigo = 'M' or
	@ti_codigo= 'O'
		set @esMP = 'S'
	ELSE
		set @esMP = 'N'
	
	-- Es Subensamble? 
	IF @ti_codigo = 'S'
		set @esSUB = 'S'
	ELSE
		set @esSUB = 'N'
	
	-- Se asigna el tipo de costo 
	if @esMP = 'S'
	begin
		if @esGravable = 'S'
		begin
		 	if @esAnadido = 'N'   -- MP Gravable 
			begin
				set @tipocosto = 'A'
			end
			else   -- MP Gravable Aadida
			begin
 				set @tipocosto = 'B'
			end		
		end
		else
		begin
			if @esGravable = 'N' -- MP No Gravable
			begin

				if @esAnadido = 'N'   -- MP No Gravable
				begin
					set @tipocosto = 'C'
				end
				else -- MP No Gravable Anyadida  
				begin
					set @tipocosto = 'D'
				end
			end

			if @esGravable = 'X'  -- @esGravable ='X'   MP No Gravable, pero gravable para usa
			begin
				if @esAnadido = 'N'   
				begin
					set @tipocosto = 'N'
				end
				else -- MP No Gravable Anyadida, , pero gravable para usa
				begin
					set @tipocosto = 'P'
				end
			end

			if @esGravable = 'Z'  -- @esGravable ='X'   MP No Gravable, pero gravable para usa y origen Mx
			begin
				if @esAnadido = 'N'   
				begin
					set @tipocosto = 'Z'
				end
				else -- MP No Gravable Anadida, pero gravable para usa y origen Mx
				begin
					set @tipocosto = 'G'
				end
			end
		end
	end
	else
	begin
		if @esGravable = 'S' or  @esGravable = 'X' or  @esGravable = 'Z'-- Empaque Gravable para usa
		-- se incluye solo el empaque de usa como originario, porque la division de costos es solo para estados unidos y para la clasificacion nafta,
		-- y en la clasificacion nafta no le afecta, puesto que el empaque se divide y no se considera en la clasificacion.
		begin
			if @esGravable = 'Z'
			  set @tipocosto = 'H'
			else
			  set @tipocosto = 'E'
		end
		else -- Empaque No Gravable
		begin
			set @tipocosto = 'F'
		end
	end

	if @esSUB='S'
	begin
		set @tipocosto = 'S'	
	end

	--print @tipocosto
END













GO
