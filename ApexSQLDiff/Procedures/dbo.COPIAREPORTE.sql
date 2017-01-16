SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COPIAREPORTE] (@bus_origen int, @bus_destino int)  as

SET NOCOUNT ON 
declare @ptrval2 varbinary(16), @long integer, @ptrval1 varchar(1000)

declare @BUS_FORMULANAME varchar(50), @BUS_FORMULASTRING varchar(8000), @BUS_MOSTRAR char(1), @BUM_CODIGO int, @BUF_TIPO char(1), 
@BUF_FORMULATITLE varchar(50), @BUF_DATATYPE char(1), @BUF_AGRUPACION char(1), @BUF_SECCION char(1), 
@BUF_VERIFICADA char(1), @BUF_LONGITUD int, @buf_codigo INT, @BUF_ORDENCOL INT

declare @consecutivo int, @BFI_CAMPO1 int, @BFI_CAMPO2 int, @BFI_OPERADOR int, @BFI_IGUAL varchar(50), 
@BFI_MIN varchar(50), @BFI_MAX varchar(50), @BFI_NULL char(1), @BFI_CODIGO int

		-- caratula
		UPDATE BUSQUEDASEL
		SET BUS_CLASIFICA= (SELECT BUS_CLASIFICA FROM BUSQUEDASEL WHERE BUS_CODIGO=@bus_origen),
		BUS_FORMA=(SELECT BUS_FORMA FROM BUSQUEDASEL WHERE BUS_CODIGO=@bus_origen), 
		BUS_AGRUPACION=(SELECT BUS_AGRUPACION FROM BUSQUEDASEL WHERE BUS_CODIGO=@bus_origen),
		BUS_FILTRO=(SELECT BUS_FILTRO FROM BUSQUEDASEL WHERE BUS_CODIGO=@bus_origen),
		BUS_PARAMTEXT=(SELECT BUS_PARAMTEXT FROM BUSQUEDASEL WHERE BUS_CODIGO=@bus_origen),
		BUS_SQL=(SELECT BUS_SQL FROM BUSQUEDASEL WHERE BUS_CODIGO=@bus_origen)
		WHERE BUS_CODIGO = @bus_destino


		if exists (select * from busquedaseldet where bus_codigo=@bus_destino)
		delete from busquedaseldet where bus_codigo=@bus_destino

		-- tabla de las que jala informacion
		INSERT INTO BUSQUEDASELDET(BUS_CODIGO,BSD_TABLA, BSD_SELECTED)
		SELECT     @bus_destino, BSD_TABLA, BSD_SELECTED
		FROM         BUSQUEDASELDET
		WHERE     (BUS_CODIGO = @bus_origen) 


		-- formulas

		if exists (select * from busquedaformula where bus_codigo=@bus_destino)
		delete from busquedaformula where bus_codigo=@bus_destino


		if exists (select * from busquedaorden where bus_codigo=@bus_destino)
		delete from busquedaorden where bus_codigo=@bus_destino


		if exists (select * from busquedacampos where bus_codigo=@bus_destino)
		delete from busquedacampos where bus_codigo=@bus_destino


			DECLARE cur_formula CURSOR for
				SELECT     BUF_CODIGO, BUS_FORMULANAME, BUS_FORMULASTRING, BUS_MOSTRAR, BUM_CODIGO, BUF_TIPO, BUF_FORMULATITLE, BUF_DATATYPE, 
				                      BUF_AGRUPACION, BUF_SECCION, BUF_VERIFICADA, BUF_LONGITUD, BUF_ORDENCOL
				FROM         BUSQUEDAFORMULA
				WHERE     (BUS_CODIGO = @bus_origen)
			open cur_formula
				FETCH NEXT FROM cur_formula INTO @BUF_CODIGO, @BUS_FORMULANAME, @BUS_FORMULASTRING, @BUS_MOSTRAR, @BUM_CODIGO, @BUF_TIPO, @BUF_FORMULATITLE, @BUF_DATATYPE, 
				                      @BUF_AGRUPACION, @BUF_SECCION, @BUF_VERIFICADA, @BUF_LONGITUD, @BUF_ORDENCOL
			
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN
			
					select @consecutivo=isnull(max(buf_codigo),0)+1 from BUSQUEDAFORMULA
			
					if @BUF_TIPO='C'
					begin

						INSERT INTO BUSQUEDAFORMULA (BUF_CODIGO, BUS_CODIGO, BUS_FORMULANAME, BUS_FORMULASTRING, BUS_MOSTRAR, BUM_CODIGO, BUF_TIPO, BUF_FORMULATITLE, BUF_DATATYPE, 
					                      BUF_AGRUPACION, BUF_SECCION, BUF_VERIFICADA, BUF_LONGITUD, BUF_ORDENCOL)
			
						values (@consecutivo, @bus_destino, replace(@BUS_FORMULANAME,@BUF_CODIGO,@consecutivo), @BUS_FORMULASTRING, @BUS_MOSTRAR, @BUM_CODIGO, @BUF_TIPO, @BUF_FORMULATITLE, @BUF_DATATYPE, 
					                      @BUF_AGRUPACION, @BUF_SECCION, @BUF_VERIFICADA, @BUF_LONGITUD, @BUF_ORDENCOL)
					end
					else
					begin
						INSERT INTO BUSQUEDAFORMULA (BUF_CODIGO, BUS_CODIGO, BUS_FORMULANAME, BUS_FORMULASTRING, BUS_MOSTRAR, BUM_CODIGO, BUF_TIPO, BUF_FORMULATITLE, BUF_DATATYPE, 
					                      BUF_AGRUPACION, BUF_SECCION, BUF_VERIFICADA, BUF_LONGITUD, BUF_ORDENCOL)
			
						values (@consecutivo, @bus_destino, @BUS_FORMULANAME, @BUS_FORMULASTRING, @BUS_MOSTRAR, @BUM_CODIGO, @BUF_TIPO, @BUF_FORMULATITLE, @BUF_DATATYPE, 
					                      @BUF_AGRUPACION, @BUF_SECCION, @BUF_VERIFICADA, @BUF_LONGITUD, @BUF_ORDENCOL)
					end
	


				-- orden dependen de formulas

					if exists (select * from busquedaorden where replace(IMF_CODIGO, 'F', '') = @BUF_CODIGO)
					begin
						INSERT INTO BUSQUEDAORDEN (BUS_CODIGO, BUO_ORDEN, IMF_CODIGO, BUO_TIPO)
						SELECT     @bus_destino, BUO_ORDEN, LEFT(IMF_CODIGO,1)+convert(varchar(10),@consecutivo), BUO_TIPO
						FROM         BUSQUEDAORDEN
						WHERE     (BUS_CODIGO = @bus_origen) and replace(IMF_CODIGO, 'F', '')=@BUF_CODIGO
					end

				-- campos
								
						insert into BUSQUEDACAMPOS (BUS_CODIGO, BSC_TABLA, IMF_CODIGO, BSC_SELECCION, BSC_AGRUPACION, BSC_DESCRIPCION, BUF_CODIGO, BSC_SECCION, 
				                      BSC_LONGITUD)
				
						SELECT     @bus_destino, BSC_TABLA, IMF_CODIGO, BSC_SELECCION, BSC_AGRUPACION, BSC_DESCRIPCION, @consecutivo, BSC_SECCION, 
						                      BSC_LONGITUD
						FROM         BUSQUEDACAMPOS
						WHERE     (BUS_CODIGO = @bus_origen) and buf_codigo=@BUF_CODIGO

		
				FETCH NEXT FROM cur_formula INTO @BUF_CODIGO, @BUS_FORMULANAME, @BUS_FORMULASTRING, @BUS_MOSTRAR, @BUM_CODIGO, @BUF_TIPO, @BUF_FORMULATITLE, @BUF_DATATYPE, 
				                      @BUF_AGRUPACION, @BUF_SECCION, @BUF_VERIFICADA, @BUF_LONGITUD, @BUF_ORDENCOL
			END
			
			CLOSE cur_formula
			DEALLOCATE cur_formula
		

			select @buf_codigo=isnull(max(buf_codigo),0)+1 from BUSQUEDAFORMULA
			
			update consecutivo
			set cv_codigo =  isnull(@buf_codigo,0) + 1
			where cv_tipo = 'BUF'


		-- orden dependen de campos no integrados al reporte
		if exists (select * from busquedaorden where left(IMF_CODIGO, 1) = 'C')
		begin
			INSERT INTO BUSQUEDAORDEN (BUS_CODIGO, BUO_ORDEN, IMF_CODIGO, BUO_TIPO)
			SELECT     @bus_destino, BUO_ORDEN, IMF_CODIGO, BUO_TIPO
			FROM         BUSQUEDAORDEN
			WHERE     (BUS_CODIGO = @bus_origen)
		end





	-- filtros
		if exists (select * from busquedafiltro where bus_codigo=@bus_destino)
		delete from busquedafiltro where bus_codigo=@bus_destino

	
	DECLARE cur_filtro CURSOR for
		SELECT     BFI_CODIGO, BFI_CAMPO1, BFI_CAMPO2, BFI_OPERADOR, BFI_IGUAL, BFI_MIN, BFI_MAX, BFI_NULL
		FROM         BUSQUEDAFILTRO
		WHERE     (BUS_CODIGO = @bus_origen)
	
	open cur_filtro
		FETCH NEXT FROM cur_filtro INTO @BFI_CODIGO, @BFI_CAMPO1, @BFI_CAMPO2, @BFI_OPERADOR, @BFI_IGUAL, @BFI_MIN, @BFI_MAX, @BFI_NULL
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
			select @consecutivo=isnull(max(bfi_codigo),0)+1 from busquedafiltro
	
			INSERT INTO BUSQUEDAFILTRO (BFI_CODIGO, BUS_CODIGO, BFI_CAMPO1, BFI_CAMPO2, BFI_OPERADOR, 
				BFI_IGUAL, BFI_MIN, BFI_MAX, BFI_NULL)
			values (@consecutivo, @bus_destino, @BFI_CAMPO1, @BFI_CAMPO2, @BFI_OPERADOR, 
				@BFI_IGUAL, @BFI_MIN, @BFI_MAX, @BFI_NULL)
	
	
			INSERT INTO BUSQUEDAFILTRO_IN (BFI_CODIGO, BFL_ELEMENTO)
			SELECT     @consecutivo, BFL_ELEMENTO
			FROM         BUSQUEDAFILTRO_IN
			WHERE     (BFI_CODIGO = @BFI_CODIGO)

		FETCH NEXT FROM cur_filtro INTO @BFI_CODIGO, @BFI_CAMPO1, @BFI_CAMPO2, @BFI_OPERADOR, @BFI_IGUAL, @BFI_MIN, @BFI_MAX, @BFI_NULL
	END
	
	CLOSE cur_filtro
	DEALLOCATE cur_filtro
	
	-- parametros
	if exists (select * from busquedaparametro where bus_codigo=@bus_destino)
	delete from busquedaparametro where bus_codigo=@bus_destino

	insert into BUSQUEDAPARAMETRO (BUS_CODIGO, IMF_FIELD, BUP_LABELPARAMETRO, BUP_ORDEN, BUP_OPERADOR, BUP_DISPLAYFIELDS)
	SELECT     @bus_destino, IMF_FIELD, BUP_LABELPARAMETRO, BUP_ORDEN, BUP_OPERADOR, BUP_DISPLAYFIELDS
	FROM         BUSQUEDAPARAMETRO
	WHERE     (BUS_CODIGO = @bus_origen)


	
	select @bfi_codigo=isnull(max(bfi_codigo),0)+1 from busquedafiltro
	
	update consecutivo
	set cv_codigo =  isnull(@bfi_codigo,0) + 1
	where cv_tipo = 'BFI'



GO
