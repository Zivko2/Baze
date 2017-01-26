SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























/* con este stored se suben materias primas que no esten el catalogo maestro*/
CREATE PROCEDURE [dbo].[SP_IMPEXCELFACTIMP2mp]     as

SET NOCOUNT ON 
DECLARE @ma_noparte varchar(30), @ma_name varchar(150), @ma_nombre varchar (150), @ma_costo decimal(38,6), @ma_peso_kg decimal(38,6), @ma_peso_lb decimal(38,6), @pa_origen int, @pa_procede int,
	@ti_codigo smallint, @ma_inv_gen char(1), @me_com int, @ma_generico int, @consecutivo int, @ma_codigo int,
	@ar_impmx int, @ar_expfo int





DECLARE CUR_maestro CURSOR FOR

SELECT     IMPEXCELFACTIMP2.PART_NUMBER, IMPEXCELFACTIMP2.DESC_ENG, IMPEXCELFACTIMP2.DESC_SPA, 
                      IMPEXCELFACTIMP2.UNIT_COST, IMPEXCELFACTIMP2.NET_WEIGHT / IMPEXCELFACTIMP2.QTY, 
                      (IMPEXCELFACTIMP2.NET_WEIGHT / IMPEXCELFACTIMP2.QTY) * 2.20462442018378, PAIS.PA_CODIGO, 233, 10, 'I', MEDIDA.ME_CODIGO, 
                      ARANCEL.AR_CODIGO, ARANCEL_1.AR_CODIGO
FROM         PAIS RIGHT OUTER JOIN
                      MEDIDA RIGHT OUTER JOIN
                      IMPEXCELFACTIMP2 ON MEDIDA.ME_CORTO = IMPEXCELFACTIMP2.MEASURE LEFT OUTER JOIN
                      ARANCEL ARANCEL_1 ON IMPEXCELFACTIMP2.US_HTS = ARANCEL_1.AR_FRACCION LEFT OUTER JOIN
                      ARANCEL ON IMPEXCELFACTIMP2.MX_HTS = ARANCEL.AR_FRACCION ON 
                      PAIS.PA_CORTO = IMPEXCELFACTIMP2.COUNTRY LEFT OUTER JOIN
                      MAESTRO ON IMPEXCELFACTIMP2.PART_NUMBER = MAESTRO.MA_NOPARTE
WHERE     (MAESTRO.MA_NOPARTE IS NULL)
GROUP BY IMPEXCELFACTIMP2.PART_NUMBER, IMPEXCELFACTIMP2.DESC_ENG, IMPEXCELFACTIMP2.UNIT_COST, 
                      IMPEXCELFACTIMP2.NET_WEIGHT / IMPEXCELFACTIMP2.QTY, 
                      IMPEXCELFACTIMP2.NET_WEIGHT / IMPEXCELFACTIMP2.QTY * 2.20462442018378, IMPEXCELFACTIMP2.DESC_SPA, PAIS.PA_CODIGO, 
                      MEDIDA.ME_CODIGO, ARANCEL.AR_CODIGO, ARANCEL_1.AR_CODIGO
OPEN CUR_maestro
		
FETCH NEXT FROM CUR_maestro INTO @ma_noparte, @ma_name, @ma_nombre, @ma_costo, @ma_peso_kg, @ma_peso_lb, @pa_origen, @pa_procede,
	@ti_codigo, @ma_inv_gen, @me_com, @ar_impmx, @ar_expfo

WHILE (@@FETCH_STATUS = 0) 
BEGIN


	if exists (select ma_codigo from maestro where ma_inv_gen='G' and ar_impmx=@ar_impmx
	and me_com=@me_com)
		select @ma_generico=ma_codigo from maestro where ma_inv_gen='G' and ar_impmx=@ar_impmx
		and me_com=@me_com
	else
		set @ma_generico=0
	
	
	--SELECT @CONSECUTIVO=ISNULL(MAX(MA_CODIGO),0) FROM MAESTRO
	select @CONSECUTIVO=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'

	INSERT INTO MAESTRO(ma_noparte, ma_name, ma_nombre, ma_peso_kg, ma_peso_lb, pa_origen, pa_procede,
	ti_codigo, ma_inv_gen, me_com, ma_generico, ma_codigo, ar_impmx, ar_expfo)
	VALUES
		(@ma_noparte, isnull(@ma_name, 'temp'), isnull(@ma_nombre, 'temp'), isnull(@ma_peso_kg,0), isnull(@ma_peso_lb,0), isnull(@pa_origen,233), @pa_procede,
	@ti_codigo, @ma_inv_gen, isnull(@me_com,19), @ma_generico, @consecutivo, @ar_impmx, @ar_expfo)

	insert into maestrocost (ma_codigo, ma_costo, tco_codigo)
	select @consecutivo, @ma_costo, tco_compra from configuracion


	FETCH NEXT FROM CUR_maestro INTO  @ma_noparte, @ma_name, @ma_nombre, @ma_costo, @ma_peso_kg, @ma_peso_lb, @pa_origen, @pa_procede,
	@ti_codigo, @ma_inv_gen, @me_com, @ar_impmx, @ar_expfo

END


CLOSE CUR_maestro
DEALLOCATE CUR_maestro


	select @MA_CODIGO= max(MA_CODIGO) from MAESTRO

	if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@MA_CODIGO
	select @MA_CODIGO= isnull(max(MA_CODIGO),0) from MAESTROREFER

	update consecutivo
	set cv_codigo =  isnull(@ma_codigo,0) + 1
	where cv_tipo = 'MA'



























GO
