SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE PROCEDURE dbo.stpTipoCosto (@bst_codigo int, @bst_trans char(1), @pa_codigo int, @tipocosto char(1) output)  as

SET NOCOUNT ON 

BEGIN
	DECLARE @esGravable char(1), @esAnadido  char(1), @esMP char(1), @Res char(1), @esSUB Char(1), @ma_def_tip char(1),
	@ma_servicio char(1), @spi_codigo int, @bst_hijo int, @bst_perini datetime, @ar_expmx int, @ma_consta char(1),
	@ar_fraccion varchar(6)


	if exists(select * from bom_struct where bst_codigo=@bst_codigo and bst_Perini<=getdate() and bst_perfin>=getdate())
	begin
		select @bst_perini=convert(varchar(11),getdate(),101)
		select @bst_hijo=bst_hijo from bom_struct where bst_codigo=@bst_codigo
	end
	else
	select @bst_hijo=bst_hijo, @bst_perini=bst_perini from bom_struct where bst_codigo=@bst_codigo


	select @ma_def_tip=ma_def_tip, @spi_codigo=spi_codigo, @ma_servicio=ma_servicio, @ar_expmx= isnull(ar_expmx,ar_impmx),
		@ma_consta=ma_consta
	 from maestro where ma_codigo =@bst_hijo

	select @ar_fraccion=left(replace(ar_fraccion,'.',''),6) from arancel where ar_codigo=@ar_expmx

-- @ma_servicio='S'  significa solo se utiliza en servicios, en dado caso se considera no gravable
-- al ser transformafo automaticamente se convierte en gravable

	IF ((@pa_codigo in (SELECT CF_PAIS_MX FROM dbo.CONFIGURACION)) OR (@pa_codigo in (SELECT     CF_PAIS_USA
	FROM dbo.CONFIGURACION)) OR (@pa_codigo in (SELECT CF_PAIS_CA FROM dbo.CONFIGURACION)))
	begin  -- origen usa mx o ca
		if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' -- basandose si existe certificado de origen
		begin
			if (@bst_trans = 'N') and exists (SELECT CERTORIGMPDET.MA_CODIGO
							FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
						         WHERE CERTORIGMP.SPI_CODIGO in (select spi_codigo from spi where spi_clave= 'NAFTA')
							     AND CERTORIGMP.CMP_ESTATUS='V' and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''), 6)=@ar_fraccion
							     AND CERTORIGMP.CMP_IFECHA <= getdate()/*@bst_perini*/ AND CERTORIGMP.CMP_FECHATRANS >= getdate()/*@bst_perini*/
							     AND CERTORIGMPDET.MA_CODIGO = @bst_hijo)

			begin
				IF (@pa_codigo in (SELECT CF_PAIS_CA FROM dbo.CONFIGURACION)) or (@pa_codigo in (SELECT CF_PAIS_MX FROM dbo.CONFIGURACION))
				begin
					  set @esGravable = 'X'			

				end
				else
					set @esGravable = 'N'

			end
			else
			if @ma_servicio='S'
				set @esGravable = 'X'
			else
				set @esGravable = 'S'



		end
		else -- segun el tipo de tasa	
		begin
			if (@bst_trans = 'N') and @ma_def_tip='P' and @spi_codigo=(select spi_codigo from spi where spi_clave='NAFTA')
			begin
				-- no gravables
				IF ((@pa_codigo in (SELECT CF_PAIS_MX FROM dbo.CONFIGURACION)) OR (@pa_codigo in (SELECT CF_PAIS_CA FROM dbo.CONFIGURACION))) 
					set @esGravable = 'X'		-- no gravable para mx pero gravable para usa
				else
					set @esGravable = 'N'		-- origen usa
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
	
	/* Es Anadida? */   
	IF (SELECT ma.MA_REPARA
	FROM MAESTRO ma RIGHT OUTER JOIN BOM_STRUCT st ON ma.MA_CODIGO = st.BST_HIJO
	WHERE (st.BST_CODIGO = @bst_codigo)) <> 'A'
		set @esAnadido = 'N'
	ELSE
		set @esAnadido = 'S'


	
	/* Es Materia Prima? */
	IF (select cft_Tipo from configuratipo ct, maestro st where ct.ti_codigo = st.ti_codigo and st.ma_codigo = @bst_hijo) = 'R' or 
	(select cft_Tipo from configuratipo ct, maestro st where ct.ti_codigo = st.ti_codigo and st.ma_codigo = @bst_hijo) = 'L' or
	(select cft_Tipo from configuratipo ct, maestro st where ct.ti_codigo = st.ti_codigo and st.ma_codigo = @bst_hijo) = 'M' or
	(select cft_Tipo from configuratipo ct, maestro st where ct.ti_codigo = st.ti_codigo and st.ma_codigo = @bst_hijo) = 'O'
		set @esMP = 'S'
	ELSE
		set @esMP = 'N'
	
	/* Es Subensamble? */
	IF (select cft_Tipo
	from configuratipo ct, maestro st where ct.ti_codigo = st.ti_codigo and st.ma_codigo = @bst_hijo) = 'S'
		set @esSUB = 'S'
	ELSE
		set @esSUB = 'N'
	
	/* Se asigna el tipo de costo */   
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
END













GO
