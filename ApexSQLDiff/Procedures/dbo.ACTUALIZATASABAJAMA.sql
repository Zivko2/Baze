SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ACTUALIZATASABAJAMA] (@ma_codigo int)   as

SET NOCOUNT ON 
declare @ar_codigo int, @pa_origen int, @ma_sec_imp int, @fi_fecha varchar(10), 
@ma_generico int, @CF_ACTTASACERTO char(1), @CF_ACTTASAPERPPS char(1), @CF_ACTTASAPER8VA char(1),
@MA_POR_DEF decimal(38,6), @SPI_CODIGO int, @MA_DEF_TIP char(1), @owner varchar(150), @parbennvo decimal(38,6), @spi_codigonvo int,
@SA_PORCENTnva decimal(38,6), @AR_PORCENT_8VAnva decimal(38,6), @AR_ADVDEFnva decimal(38,6)


SELECT     @CF_ACTTASAPER8VA=CF_ACTTASAPER8VA, @CF_ACTTASAPERPPS=CF_ACTTASAPERPPS, @CF_ACTTASACERTO=CF_ACTTASACERTO
FROM         CONFIGURACION

SET @fi_fecha=convert(varchar(10),getdate(), 101)

SELECT     @ar_codigo=AR_IMPMX, @pa_origen=PA_ORIGEN, @ma_sec_imp=MA_SEC_IMP,
@ma_generico=MA_GENERICO
FROM         MAESTRO
WHERE     (ma_codigo=@ma_codigo)


SELECT    @spi_codigo=SPI_CODIGO 
FROM PAIS 
WHERE (PA_CODIGO = @pa_origen)




if exists (SELECT PAR_BEN FROM dbo.PAISARA WHERE (AR_CODIGO = @ar_codigo) AND (PA_CODIGO = @pa_origen) and (PAR_BEN<>-1)
GROUP BY SPI_CODIGO, PAR_BEN)
begin

	SELECT    @spi_codigonvo=SPI_CODIGO, @parbennvo=PAR_BEN
	FROM         dbo.PAISARA 
	WHERE     (AR_CODIGO = @ar_codigo) AND (PA_CODIGO = @pa_origen) and (PAR_BEN<>-1)
	GROUP BY SPI_CODIGO, PAR_BEN


	if not exists (select * from TempTasama where ma_def_tip='P' and ma_codigo=@ma_codigo)
	begin

		insert into TempTasama (ma_codigo, spi_codigo, ma_por_def, ma_def_tip, ma_sec_imp)
		values (@ma_codigo, @spi_codigonvo, @parbennvo, 'P', 0)

	end
	else
	begin
		update TempTasama
		set ma_por_def=@parbennvo, spi_codigo=@spi_codigonvo
		where ma_def_tip='P' and ma_codigo=@ma_codigo

	end	

	-- existe certificado de origen? 
	if @CF_ACTTASACERTO='S' and not exists(SELECT     dbo.CERTORIGMPDET.MA_CODIGO FROM  dbo.CERTORIGMPDET INNER JOIN
                      dbo.CERTORIGMP ON dbo.CERTORIGMPDET.CMP_CODIGO = dbo.CERTORIGMP.CMP_CODIGO
	WHERE     (dbo.CERTORIGMP.CMP_IFECHA <= @fi_fecha) AND (dbo.CERTORIGMP.CMP_VFECHA >= @fi_fecha) 
	AND dbo.CERTORIGMP.CMP_ESTATUS='V' AND (dbo.CERTORIGMP.SPI_CODIGO = @spi_codigo) and dbo.CERTORIGMPDET.MA_CODIGO=@ma_codigo)
	begin
		update TempTasama
		set ma_por_def=-1
		where ma_def_tip='P' and ma_codigo=@ma_codigo

	end
end




if exists(SELECT SA_PORCENT FROM dbo.SECTORARA WHERE (AR_CODIGO = @ar_codigo) AND (SE_CODIGO = @ma_sec_imp) and (SA_PORCENT<>-1)
	GROUP BY SA_PORCENT)
begin

	SELECT @SA_PORCENTnva=SA_PORCENT
	FROM         dbo.SECTORARA
	WHERE     (AR_CODIGO = @ar_codigo) AND (SE_CODIGO = @ma_sec_imp) and (SA_PORCENT<>-1)
	GROUP BY SA_PORCENT


	if not exists (select * from TempTasama where ma_def_tip='S' and ma_codigo=@ma_codigo)
	begin
		insert into TempTasaMa ( ma_codigo, spi_codigo, ma_por_def, ma_def_tip, ma_sec_imp)
		values (@ma_codigo, 0, @SA_PORCENTnva, 'S', @ma_sec_imp)
	end
	else
	begin
		update TempTasama
		set ma_por_def=@SA_PORCENTnva, ma_sec_imp=@ma_sec_imp
		where ma_def_tip='S' and ma_codigo=@ma_codigo

	end

end


if exists (SELECT AR_PORCENT_8VA FROM dbo.ARANCEL WHERE (AR_CODIGO = @ar_codigo) and (AR_PORCENT_8VA<>-1) GROUP BY AR_CODIGO, AR_PORCENT_8VA)
begin

	SELECT     @AR_PORCENT_8VAnva= AR_PORCENT_8VA
	FROM         dbo.ARANCEL
	WHERE      (AR_CODIGO = @ar_codigo) and (AR_PORCENT_8VA<>-1)
	GROUP BY AR_CODIGO, AR_PORCENT_8VA

	if not exists (select * from TempTasaMa where ma_codigo=@ma_codigo and ma_def_tip='R')
	begin
		insert into TempTasaMa ( ma_codigo, spi_codigo, ma_por_def, ma_def_tip, ma_sec_imp)
		values(@ma_codigo, 0, @AR_PORCENT_8VAnva, 'R', 0)
	end
	else
	begin
		update TempTasama
		set ma_por_def=@AR_PORCENT_8VAnva
		where ma_def_tip='R' and ma_codigo=@ma_codigo

	end

	-- existe permiso regla octava con saldo? 
	if @CF_ACTTASAPER8VA='S' and not exists (SELECT     dbo.PERMISODET.MA_GENERICO FROM dbo.PERMISO INNER JOIN
	                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO INNER JOIN
	                      dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
	WHERE     (dbo.IDENTIFICA.IDE_CLAVE LIKE '%C1') AND (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.PERMISODET.PED_SALDO > 0) and
	(dbo.PERMISODET.MA_GENERICO = @ma_generico))
	begin
		update TempTasaMa
		set ma_por_def=-1
		where ma_def_tip='R' and ma_codigo=@ma_codigo
	end

	
end



if exists (SELECT AR_ADVDEF FROM dbo.ARANCEL WHERE (AR_CODIGO = @ar_codigo) and (AR_ADVDEF<>-1) GROUP BY AR_CODIGO, AR_ADVDEF)
begin
	SELECT     @AR_ADVDEFnva=AR_ADVDEF
	FROM         dbo.ARANCEL
	WHERE     (AR_CODIGO = @ar_codigo) and (AR_ADVDEF<>-1)
	GROUP BY AR_CODIGO, AR_ADVDEF

	if not exists (select * from TempTasaMa where ma_codigo=@ma_codigo and ma_def_tip='G')
	begin
		insert into TempTasaMa ( ma_codigo, spi_codigo, ma_por_def, ma_def_tip, ma_sec_imp)
		Values (@ma_codigo, 0, @AR_ADVDEFnva, 'G', 0)

	end
	else
	begin
		update TempTasama
		set ma_por_def=@AR_ADVDEFnva
		where ma_def_tip='G' and ma_codigo=@ma_codigo
	end
end

/* ========================== Actualizacion ===================================*/

SELECT     /*@MA_POR_DEF=MA_POR_DEF, */@SPI_CODIGO=SPI_CODIGO, @MA_SEC_IMP=MA_SEC_IMP, @MA_DEF_TIP=MA_DEF_TIP
FROM       TempTasaMa WHERE TM_CODIGO in
(select min(tm_codigo) from TempTasaMa where ma_por_def in
(select min(ma_por_def) from TempTasaMa where ma_codigo=@ma_codigo and ma_por_def<>-1))

		update maestro
		set /*ma_por_def=isnull(@MA_POR_DEF,-1),*/
		spi_codigo=isnull(@SPI_CODIGO,0),
		ma_sec_imp=isnull(@MA_SEC_IMP,0),
		ma_def_tip=isnull(@MA_DEF_TIP, 'G')
		where ma_codigo=@ma_codigo



























GO
