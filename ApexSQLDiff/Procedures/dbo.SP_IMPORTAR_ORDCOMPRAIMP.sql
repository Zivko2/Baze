SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









































CREATE PROCEDURE [dbo].[SP_IMPORTAR_ORDCOMPRAIMP] (@fid_indiced int, @fi_codigo int, @cantidadimportar decimal(38,6), @ord_indiced int, @or_codigo int, @tipo char(1))   as

SET NOCOUNT ON 
DECLARE @maximo int, @fi_fecha datetime, @ma_codigo int

-- @tipo S=por orden compra completa, N=por cantidad
select @fi_fecha=fi_fecha from factimp where fi_codigo=@fi_codigo


if @tipo='N'
begin
	insert into factimpdet (fid_indiced, fi_codigo, fid_cant_st, fid_cos_uni, fid_cos_tot, fid_nombre,
	fid_name, fid_noparte, ma_codigo, me_codigo, ti_codigo, tco_codigo, ma_empaque, fid_cantemp, fid_fec_env,
	or_codigo, fid_ord_comp, fid_noorden, ord_indiced, fid_por_def, fid_sec_imp, spi_codigo,
	pa_codigo, ma_generico, ar_impmx, cs_codigo, me_arimpmx, ar_expfo, fid_pes_uni, fid_pes_unilb,
	eq_impmx, eq_expfo, eq_gen, fid_def_tip, ME_GEN, FID_SALDO)
	SELECT     @fid_indiced, @fi_codigo, @cantidadimportar, isnull(dbo.ORDCOMPRADET.ORD_COS_UNI,0), isnull(dbo.ORDCOMPRADET.ORD_COS_TOT,0), dbo.ORDCOMPRADET.ORD_NOMBRE, 
	                      dbo.ORDCOMPRADET.ORD_NAME, dbo.ORDCOMPRADET.ORD_NOPARTE, dbo.ORDCOMPRADET.MA_CODIGO, isnull(dbo.ORDCOMPRADET.ME_CODIGO,0), 
	                      dbo.ORDCOMPRADET.TI_CODIGO, isnull(dbo.ORDCOMPRADET.TCO_CODIGO,10), isnull(dbo.ORDCOMPRADET.MA_EMPAQUE,0), isnull(dbo.ORDCOMPRADET.ORD_CANTEMP,0), 
	                      dbo.ORDCOMPRADET.ORD_FEC_ENV, dbo.ORDCOMPRADET.OR_CODIGO, dbo.ORDCOMPRA.OR_FOLIO, dbo.ORDCOMPRADET.OT_FOLIO, 
	                      dbo.ORDCOMPRADET.ORD_INDICED, 
dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0), 
	                      dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_GENERICO,0), isnull(dbo.MAESTRO.AR_IMPMX,0), dbo.MAESTRO.CS_CODIGO, isnull(dbo.ARANCEL.ME_CODIGO,0), 
	                      isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.MAESTRO.MA_PESO_KG, dbo.MAESTRO.MA_PESO_LB, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.EQ_EXPFO, 
	                      dbo.MAESTRO.EQ_GEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull((SELECT MAESTRO1.ME_COM FROM MAESTRO MAESTRO1 WHERE MAESTRO1.MA_CODIGO=dbo.MAESTRO.MA_GENERICO),0),
		         @cantidadimportar
	FROM         dbo.ORDCOMPRADET LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.ORDCOMPRADET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.ORDCOMPRA ON dbo.ORDCOMPRADET.OR_CODIGO = dbo.ORDCOMPRA.OR_CODIGO LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.ORDCOMPRADET.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
	                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
	WHERE     (dbo.ORDCOMPRADET.ORD_INDICED = @ORD_INDICED)


	update OrdCompradet
	set ord_saldo=ord_saldo-@cantidadimportar
	where ord_indiced=@ord_indiced

	select @ma_codigo=ma_codigo from factimpdet where fid_indiced=@fid_indiced

	update factimpdet
	set fid_fecha_struct =@fi_fecha
	where fi_codigo=@fi_codigo
	and ma_codigo=@ma_codigo

end
else
begin
	TRUNCATE TABLE  tempfactimpdet
	
	SELECT     @maximo= MAX(FID_INDICED)+1
	FROM         dbo.FACTIMPDET

	dbcc checkident (tempfactimpdet, reseed, @maximo) WITH NO_INFOMSGS


	insert into tempfactimpdet (fi_codigo, fid_cant_st, fid_cos_uni, fid_cos_tot, fid_nombre,
	fid_name, fid_noparte, ma_codigo, me_codigo, ti_codigo, tco_codigo, ma_empaque, fid_cantemp, fid_fec_env,
	or_codigo, fid_ord_comp, fid_noorden, ord_indiced, fid_por_def, fid_sec_imp, spi_codigo,
	pa_codigo, ma_generico, ar_impmx, cs_codigo, me_arimpmx, ar_expfo, fid_pes_uni, fid_pes_unilb,
	eq_impmx, eq_expfo, eq_gen, fid_def_tip, ME_GEN)

	SELECT     @fi_codigo, dbo.ORDCOMPRADET.ORD_SALDO, isnull(dbo.ORDCOMPRADET.ORD_COS_UNI,0), isnull(dbo.ORDCOMPRADET.ORD_COS_TOT,0), dbo.ORDCOMPRADET.ORD_NOMBRE, 
	                      dbo.ORDCOMPRADET.ORD_NAME, dbo.ORDCOMPRADET.ORD_NOPARTE, dbo.ORDCOMPRADET.MA_CODIGO, isnull(dbo.ORDCOMPRADET.ME_CODIGO,0), 
	                      dbo.ORDCOMPRADET.TI_CODIGO, isnull(dbo.ORDCOMPRADET.TCO_CODIGO,10), isnull(dbo.ORDCOMPRADET.MA_EMPAQUE,0), isnull(dbo.ORDCOMPRADET.ORD_CANTEMP,0), 
	                      dbo.ORDCOMPRADET.ORD_FEC_ENV, dbo.ORDCOMPRADET.OR_CODIGO, dbo.ORDCOMPRA.OR_FOLIO, dbo.ORDCOMPRADET.OT_FOLIO, 
	                      dbo.ORDCOMPRADET.ORD_INDICED, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
				isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0), 
	                      dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.MA_GENERICO, isnull(dbo.MAESTRO.AR_IMPMX,0), dbo.MAESTRO.CS_CODIGO, isnull(dbo.ARANCEL.ME_CODIGO,0), 
	                      isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.MAESTRO.MA_PESO_KG, dbo.MAESTRO.MA_PESO_LB, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.EQ_EXPFO, 
	                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.MA_DEF_TIP, isnull((SELECT MAESTRO1.ME_COM FROM MAESTRO MAESTRO1 WHERE MAESTRO1.MA_CODIGO=dbo.MAESTRO.MA_GENERICO),0)
	FROM         dbo.ORDCOMPRADET LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.ORDCOMPRADET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.ORDCOMPRA ON dbo.ORDCOMPRADET.OR_CODIGO = dbo.ORDCOMPRA.OR_CODIGO LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.ORDCOMPRADET.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
	                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
	WHERE     (dbo.ORDCOMPRADET.OR_CODIGO = @OR_CODIGO)



	insert into factimpdet (fid_indiced, fi_codigo, fid_cant_st, fid_cos_uni, fid_cos_tot, fid_nombre,
	fid_name, fid_noparte, ma_codigo, me_codigo, ti_codigo, tco_codigo, ma_empaque, fid_cantemp, fid_fec_env,
	or_codigo, fid_ord_comp, fid_noorden, ord_indiced, fid_por_def, fid_sec_imp, spi_codigo,
	pa_codigo, ma_generico, ar_impmx, cs_codigo, me_arimpmx, ar_expfo, fid_pes_uni, fid_pes_unilb,
	eq_impmx, eq_expfo, eq_gen, fid_def_tip, ME_GEN, fid_saldo)

	select fid_indiced, fi_codigo, fid_cant_st, fid_cos_uni, fid_cos_tot, fid_nombre,
	fid_name, fid_noparte, ma_codigo, me_codigo, ti_codigo, tco_codigo, ma_empaque, fid_cantemp, fid_fec_env,
	or_codigo, fid_ord_comp, fid_noorden, ord_indiced, fid_por_def, fid_sec_imp, spi_codigo,
	pa_codigo, ma_generico, ar_impmx, cs_codigo, me_arimpmx, ar_expfo, fid_pes_uni, fid_pes_unilb,
	eq_impmx, eq_expfo, eq_gen, fid_def_tip, ME_GEN, fid_cant_st from tempfactimpdet


	update OrdCompradet
	set ord_saldo=0
	where or_codigo=@or_codigo

	exec SP_ACTUALIZAFID_FECHA_STRUCT @fi_codigo
end

	update factimp
	set fi_cuentadet=(select count(*) from factimpdet where fi_codigo=@fi_codigo)
	where fi_codigo=@fi_codigo








































GO
