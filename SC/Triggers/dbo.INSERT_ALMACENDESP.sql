SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE TRIGGER [INSERT_ALMACENDESP] ON dbo.ALMACENDESP 
FOR INSERT, UPDATE
AS
SET NOCOUNT ON 

declare @ade_cant decimal(38,6), @ade_enuso char(1), @ade_saldo decimal(38,6), @ade_codigo int,@fecha DATETIME,@pi_codigo int,@am_codigo int,@fetr_codigo int,@fetr_tipo char(1),
@ade_cantkg decimal(38,6), @ma_hijo int, @ade_peso_unikg decimal(38,6)

	select @ade_cant=ade_cant, @ade_cantkg=ade_cantkg, @ade_enuso=ade_enuso, @ade_saldo=ade_saldo, @fetr_tipo=fetr_tipo,
                        @ade_codigo=ade_codigo, @pi_codigo=pi_codigo, @am_codigo=am_codigo, @ma_hijo=ma_hijo, @fetr_codigo=fetr_codigo,
	           @ade_peso_unikg=isnull(ade_peso_unikg,0) from inserted


	if update(ade_cantkg) and (@ade_cant =0 or @ade_cant is null) and @ade_peso_unikg <>0
	and @ade_cant <> @ade_cantkg/@ade_peso_unikg
	update almacendesp
	set ade_cant = ade_cantkg/@ade_peso_unikg
	where ade_codigo =@ade_codigo


	if update(ade_cant) and (@ade_cantkg =0 or @ade_cantkg is null) and
	@ade_cantkg <> @ade_cant*@ade_peso_unikg
	update almacendesp
	set ade_cantkg = ade_cant*@ade_peso_unikg
	where ade_codigo =@ade_codigo

	-- actualizacion de saldo
	if @ade_enuso='N'
	if (update(ade_cant) and (@ade_saldo <> @ade_cantkg) or @ade_saldo is null) 
	update almacendesp
	set ade_saldo = ade_cant*@ade_peso_unikg
	where ade_codigo =@ade_codigo


	if update(ade_cant)
	if ((@ade_saldo = @ade_cantkg) or @ade_saldo is null) 
	update almacendesp
	set ade_enuso='N'
	where ade_codigo =@ade_codigo


	if (update(fetr_codigo) or update(fetr_tipo)) and (@fetr_codigo>0)
             begin

	     if (@fetr_tipo <> 'P') 
                select @fecha=FE_FECHA from FACTEXP where FE_CODIGO=@fetr_codigo
                update ALMACENDESP set ADE_FECHA=@fecha where ADE_CODIGO=@ade_codigo 

	   IF @fetr_tipo='P'
                 select @fecha=PI_FEC_ENT from PEDIMP where PI_CODIGO=@fetr_codigo
                 update ALMACENDESP set ADE_FECHA=@fecha where ADE_CODIGO=@ade_codigo 

	end

	if update(am_codigo) and (@am_codigo>0)
             begin
                 select @fecha=AM_REFERFECHA from ALMACENDESPCAR where AM_CODIGO=@am_codigo
                 update ALMACENDESP set ADE_FECHA=@fecha where ADE_CODIGO=@ade_codigo 
	end














































GO
