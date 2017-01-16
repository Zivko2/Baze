SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_DESPPESO] (@Fei_codigo Int)   as

SET NOCOUNT ON 

declare @fei_totalpeso decimal(38,6), @fei_porcentaje decimal(38,6), @ma_codigo int, @fe_codigo int, 
@pesounit decimal(38,6), @pesoneto decimal(38,6), @consecutivo int, @manombre varchar (150), @manoparte varchar(30),
@maname varchar(150), @mecom int, @macosto decimal(38,6), @pesounitlb decimal(38,6), @megenerico int, 
@magenerico int, @paorigen int, @eqgen decimal(38,6), @eqdesp decimal(38,6), @eqexpmx decimal(38,6), @marateexpmx decimal(38,6), @ardespmx int, 
@maratedesp decimal(38,6), @madischarge char(1), @arexpmx int, @ardesp int, @cantidad decimal(38,6), @fedindiced int, @ti_codigo int,
@ma_tip_ens char(1), @meexpmx int, @fei_totalcosto decimal(38,6), @costoneto decimal(38,6), @TCO_MANUFACTURA int, @TCO_COMPRA int, @tco_codigo int, @cft_tipo char(1)

SELECT    @TCO_MANUFACTURA=TCO_MANUFACTURA, @TCO_COMPRA=TCO_COMPRA FROM dbo.CONFIGURACION

SELECT     @fe_codigo = FE_CODIGO, @ma_codigo =MA_CODIGO, @fei_porcentaje = FEI_PORCENTAJE, 
	@fei_totalpeso = FEI_TOTALPESO, @fei_totalcosto = FEI_TOTALCOSTO
FROM         dbo.FACTEXPDESP
WHERE     (FEI_CODIGO = @Fei_codigo)


SELECT @fei_totalpeso=MAX(FEI_TOTALPESO) FROM FACTEXPDESP
WHERE FE_CODIGO=@fe_codigo

UPDATE FACTEXPDESP
SET FEI_TOTALPESO=@fei_totalpeso
WHERE FEI_TOTALPESO=0 AND FE_CODIGO=@fe_codigo


SELECT     @manombre = case when isnull(dbo.MAESTRO.MA_NOMBREDESP,'')='' then 'DESPERDICIO DE '+isnull(dbo.MAESTRO.MA_NOMBRE,'') else dbo.MAESTRO.MA_NOMBREDESP end ,
             @manoparte = dbo.MAESTRO.MA_NOPARTE, @maname =case when isnull(dbo.MAESTRO.MA_NAMEDESP,'')='' then 'SCRAP OF '+isnull(dbo.MAESTRO.MA_NAME,'') else dbo.MAESTRO.MA_NAMEDESP end, 
	@mecom = isnull(dbo.MAESTRO.ME_COM,19),  @pesounit = isnull(dbo.MAESTRO.MA_PESO_KG,0), 
	@pesounitlb = isnull(dbo.MAESTRO.MA_PESO_LB,0), @megenerico = isnull(MAESTRO_1.ME_COM,0), @magenerico = isnull(dbo.MAESTRO.MA_GENERICO,0), 
        @paorigen = isnull(dbo.MAESTRO.PA_ORIGEN,0), @eqgen = isnull(dbo.MAESTRO.EQ_GEN,1), @eqdesp = isnull(dbo.MAESTRO.EQ_DESP,1),
	@eqexpmx = isnull(dbo.MAESTRO.EQ_EXPMX,1), @marateexpmx = dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.PA_ORIGEN, 'G', isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
        @maratedesp = dbo.GetAdvalorem(dbo.MAESTRO.AR_DESP, dbo.MAESTRO.PA_ORIGEN, 'G', isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), @madischarge = isnull(dbo.MAESTRO.MA_DISCHARGE, 'S'), 
	@arexpmx = isnull(dbo.MAESTRO.AR_EXPMX,0), @ardesp = isnull(dbo.MAESTRO.AR_DESP,0), @ardespmx = isnull(dbo.MAESTRO.AR_DESPMX,0), @ti_codigo = isnull(dbo.MAESTRO.TI_CODIGO,10),
	@ma_tip_ens= isnull(dbo.MAESTRO.MA_TIP_ENS,'C')
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
WHERE     (dbo.MAESTRO.MA_CODIGO = @ma_codigo)


	select @cft_tipo=cft_tipo from configuratipo where ti_codigo =@ti_codigo

	if (@cft_tipo='P' or @cft_tipo='S') 
	set @tco_codigo=@TCO_MANUFACTURA 
	else
	set @tco_codigo=@TCO_COMPRA


	set @pesoneto = round(@fei_porcentaje * @fei_totalpeso / 100,6)
	if @pesounit>0
	set @cantidad = round(isnull(@pesoneto/@pesounit,0),6)
	else
	set @cantidad = 0


	if @fei_totalcosto is not null and @fei_totalcosto>0
	begin	
		-- costoneto = costo total por registro
		set @costoneto = round(@fei_porcentaje * @fei_totalcosto / 100,6)
		if @cantidad>0
		set @macosto = round(isnull(@costoneto/@cantidad,0),6)
		else
		set @macosto = 0
	end
	else
	begin
		-- costo de desperdicio
		if exists(select * from maestrocost where ma_codigo=@ma_codigo and tco_codigo=4)
		begin
		select  @macosto = isnull(MA_COSTO,0) from maestrocost where ma_codigo=@ma_codigo and tco_codigo=4
		end
		else
		begin
			-- de compra 
			if exists(select * from maestrocost where ma_codigo=@ma_codigo and tco_codigo=3)
			    select  @macosto = MA_COSTO from maestrocost where ma_codigo=@ma_codigo and tco_codigo=3
			else
			    set  @macosto = 0
		end
	end



SELECT @CONSECUTIVO=ISNULL(MAX(FED_INDICED),0) FROM FACTEXPDET

SET @CONSECUTIVO=@CONSECUTIVO+1

	if @maratedesp is null
		set @maratedesp = -1
	if @marateexpmx is null 
		set @marateexpmx = -1



        if @ardespmx is not null and @ardespmx>0
          set @arexpmx=@ardespmx



	if @arexpmx is null or @arexpmx=0
          set @meexpmx=0
	else
   	  select @meexpmx=me_codigo from arancel where ar_codigo=@arexpmx





	insert into factexpdet (FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, 
	FED_NAME, ME_CODIGO, FED_CANT, FED_COS_UNI, FED_COS_TOT, FED_PES_UNI, FED_PES_NET, 
	FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, FED_PES_BRULB, ME_GENERICO, MA_GENERICO, 
	PA_CODIGO, EQ_GEN, EQ_IMPFO, EQ_EXPMX, FED_RATEEXPMX, FED_RATEIMPFO, FED_DISCHARGE, 
	FED_RETRABAJO, FED_DESCARGADO, FED_PARTTYPE, AR_EXPMX, AR_IMPFO, TI_CODIGO,
	FED_TIP_ENS, ME_AREXPMX, TCO_CODIGO)

	VALUES
	(@CONSECUTIVO, @fe_codigo, @ma_codigo, @manombre, @manoparte, 
	 @maname, @mecom, @cantidad, @macosto, @macosto*@cantidad,  @pesounit, @pesoneto,
	 @pesoneto, @pesounitlb, @pesoneto* 2.20462442018378, @pesoneto* 2.20462442018378, @megenerico, @magenerico, 
              @paorigen, @eqgen, @eqdesp, @eqexpmx, 0, @maratedesp, @madischarge, 
	 'N', 'N', 'S', @arexpmx, @ardesp, @ti_codigo, @ma_tip_ens, isnull(@meexpmx,0), @tco_codigo)


SELECT @fedindiced=ISNULL(MAX(FED_INDICED),0) FROM FACTEXPDET

	update consecutivo
	set cv_codigo =  isnull(@fedindiced,0) + 1
	where cv_tipo = 'FED'


GO
