SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_calculoDTAFactImp]  (@ficodigo int, @tipodta varchar(3)='OM' output)   as

SET NOCOUNT ON 
declare @valdta decimal(38,6), @cfijadta decimal(38,6), @fi_val_adu decimal(38,6), @CP_PAGODTA CHAR(1), @pi_numvehiculos int,
@registrosnonafta int

	if (select cp_usanaftadta from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@ficodigo))='S'
	begin

		SELECT     @fi_val_adu= SUM((dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
		                       )* dbo.FACTIMP.FI_TIPOCAMBIO)
		FROM         dbo.FACTIMPDET LEFT OUTER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
		                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
		WHERE     (dbo.FACTIMPDET.FI_CODIGO = @ficodigo)
	end
	else
	begin

		SELECT     @fi_val_adu= SUM((dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
		                       )* dbo.FACTIMP.FI_TIPOCAMBIO)
		FROM         dbo.FACTIMPDET LEFT OUTER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
		                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
		WHERE  (dbo.FACTIMPDET.FID_DEF_TIP <> 'P') and   (dbo.FACTIMPDET.FI_CODIGO = @ficodigo)

	end

	SELECT     @CP_PAGODTA=CLAVEPED.CP_PAGODTA 
	FROM         dbo.REVORIGEN INNER JOIN
	                      dbo.CLAVEPED ON dbo.REVORIGEN.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO
	WHERE     (dbo.REVORIGEN.FI_CODIGO = @ficodigo)

	select @cfijadta=cof_valor 
	from contribucionfija 
	where con_codigo in(select con_codigo from contribucion where con_clave='1') 
	and cof_perini<=(SELECT RVF_FECHACRUCE FROM REVORIGEN WHERE FI_CODIGO = @ficodigo)
	and cof_perfin>=(SELECT RVF_FECHACRUCE FROM REVORIGEN WHERE FI_CODIGO = @ficodigo)
	and cof_tipo='I'


	select @pi_numvehiculos=fi_numvehiculos from factimp where fi_codigo=@ficodigo

	select @registrosnonafta=count(*) from factimpdet where fi_codigo=@ficodigo  and fid_def_tip<>'P' and spi_codigo not in (select spi_codigo from spi where spi_clave='nafta')


	if @registrosnonafta>0	-- si todos son nafta no paga DTA
	begin
		if @CP_PAGODTA='O'  -- 8 al millar
		begin
			if (@fi_val_adu*.008)<@cfijadta
			begin
				set @valdta=@cfijadta
				set @tipodta='CFM'
			end
			else
			begin
				set @valdta=@fi_val_adu*.008
				set @tipodta='OM'
			end
		end
		else
		begin
			if @CP_PAGODTA='U' --1.76 al millar
			begin
				if (@fi_val_adu*.00176)<@cfijadta
				begin
					set @valdta=@cfijadta
					set @tipodta='CFM'
				end
				else
				begin
					set @valdta=@fi_val_adu*.00176
					set @tipodta='SM'
				end
			end
			else
			begin
				if @CP_PAGODTA='C' -- cuota fija
				begin
					set @valdta=@cfijadta
					set @tipodta='CF'
				end  
				else
				begin
					if @CP_PAGODTA='V' -- cuota fija por el no. de vehiculos
					begin
						set @valdta=@cfijadta*isnull(@pi_numvehiculos,1)
						set @tipodta='CFV'
					end
					else
					begin

						if @CP_PAGODTA='A'  -- insumos cuotafija, actijo fijo 8 al millar
						begin
							if exists(select * from vspivaladu where cft_tipo in ('Q', 'X') and pi_codigo = @ficodigo)
							begin
								if (@fi_val_adu*.008)<@cfijadta
								begin
									set @valdta=@cfijadta
									set @tipodta='CFM'
								end
								else
								begin
									set @valdta=@fi_val_adu*.008
									set @tipodta='OM'
								end
							end
							else
							begin
								set @valdta=@cfijadta
								set @tipodta='CF'
							end
						end
						else
						begin
							set @valdta=0
							set @tipodta='SIN'	
						end
					end
				end
			end
		end



		/*if exists (select * from RevOrigenContrib where fi_codigo =@ficodigo and con_codigo in (select con_codigo from contribucion where con_clave='1'))
		delete from RevOrigenContrib where fi_codigo=@ficodigo and con_codigo in (select con_codigo from contribucion where con_clave='1')
	
	
		insert into RevOrigenContrib(FI_CODIGO, CON_CODIGO, RVC_MONTO)
		select @ficodigo, (select con_codigo from contribucion where con_clave='1'), isnull(round(@valdta,0),0)*/
	

	end

GO
