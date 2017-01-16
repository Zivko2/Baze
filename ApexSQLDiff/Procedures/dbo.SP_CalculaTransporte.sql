SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CalculaTransporte] (@CTP_CODIGO int, @CTPD_KILOGRAMOS decimal(38,6), @CTPD_PRECIOTOT decimal(38,6) output)   as


declare @Diferencia decimal(38,6), @CT_TIPOCUOTA char(1), @CT_FIJAPARTIRKG decimal(38,6), @CT_TARIFA decimal(38,6), @Valor decimal(38,6),
@CT_TIPOTARIFAADIC char(1), @CT_DECPORADICXKG decimal(38,6), @CT_INCPORADICXKG decimal(38,6), @ValorFin decimal(38,6), @CT_CUOTAMINIMA decimal(38,6), 
@CT_FIJADLS decimal(38,6), @PRECIO decimal(38,6), @CT_CODIGO int


SELECT     @CT_TIPOCUOTA=CTRANSPOR.CT_TIPOCUOTA, @CT_TARIFA=CTRANSPOR.CT_TARIFA, @CT_TIPOTARIFAADIC=CTRANSPOR.CT_TIPOTARIFAADIC, 
	@CT_INCPORADICXKG=CTRANSPOR.CT_INCPORADICXKG, @CT_DECPORADICXKG=CTRANSPOR.CT_DECPORADICXKG, @CT_FIJADLS=CTRANSPOR.CT_FIJADLS, 
	@CT_FIJAPARTIRKG=isnull(CTRANSPOR.CT_FIJAPARTIRKG,0), @CT_CUOTAMINIMA=CTRANSPOR.CT_CUOTAMINIMA, 
	                     @CT_CODIGO= CTRANSPORPAG.CT_CODIGO
FROM         CTRANSPORPAG INNER JOIN
                      CTRANSPOR ON CTRANSPORPAG.CT_CODIGO = CTRANSPOR.CT_CODIGO
WHERE     (CTRANSPORPAG.CTP_CODIGO = @CTP_CODIGO)

set @Diferencia = @CTPD_KILOGRAMOS-@CT_FIJAPARTIRKG


	if @CT_TIPOCUOTA ='K'
	begin
		set @Valor = @CT_TARIFA*@CTPD_KILOGRAMOS

		if @CTPD_KILOGRAMOS>@CT_FIJAPARTIRKG and @CT_FIJAPARTIRKG>0
		begin
		
			if @CT_TIPOTARIFAADIC ='D' --% Decremento x Kg
			begin	
				set @ValorFin = @Valor- (((@Valor * @CT_DECPORADICXKG)/100)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
			else
			if @CT_TIPOTARIFAADIC ='I' --% Incremento x Kg
			begin	
				set @ValorFin = @Valor+ (((@Valor * @CT_INCPORADICXKG)/100)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
			else
			if @CT_TIPOTARIFAADIC ='F' -- Valor Fijo x Kg
			begin	
				set @ValorFin = @Valor+ ((@CT_FIJADLS)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
			else
			if @CT_TIPOTARIFAADIC ='R' --X Rango
			begin	
				SELECT    @PRECIO= CTA_PRECIO
				FROM         CTRANSPORADIC
				WHERE     (CT_CODIGO = @CT_CODIGO) AND (CTA_CANTINI <= @Diferencia) AND (CTA_CANTFIN >= @Diferencia)
				
				set @ValorFin = @Valor+ ((@PRECIO)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
	
		end
		else
		begin
			  set @ValorFin = @Valor
		end

	end
	else -- POR RANGO
	begin
	
		SELECT     @CT_TARIFA= CTR_PRECIO
		FROM         CTRANSPORRANGO
		WHERE     (CT_CODIGO = @CT_CODIGO) AND (CTR_CANTINI <= @Diferencia) AND (CTR_CANTFIN >= @Diferencia)

		set @Valor = @CT_TARIFA*@CTPD_KILOGRAMOS
	
		if @CTPD_KILOGRAMOS>@CT_FIJAPARTIRKG and @CT_FIJAPARTIRKG>0
		begin
		
		
			if @CT_TIPOTARIFAADIC ='D' --% Decremento x Kg
			begin	
				set @ValorFin = @Valor- (((@Valor * @CT_DECPORADICXKG)/100)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
			else
			if @CT_TIPOTARIFAADIC ='I' --% Incremento x Kg
			begin	
				set @ValorFin = @Valor+ (((@Valor * @CT_INCPORADICXKG)/100)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
			else
			if @CT_TIPOTARIFAADIC ='F' -- Valor Fijo x Kg
			begin	
				set @ValorFin = @Valor+ ((@CT_FIJADLS)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
			else
			if @CT_TIPOTARIFAADIC ='R' --X Rango
			begin	
				SELECT    @PRECIO= CTA_PRECIO
				FROM         CTRANSPORADIC
				WHERE     (CT_CODIGO = @CT_CODIGO) AND (CTA_CANTINI <= @Diferencia) AND (CTA_CANTFIN >= @Diferencia)
				
				set @ValorFin = @Valor+ ((@PRECIO)*@Diferencia)
		
				if @ValorFin < @CT_CUOTAMINIMA
				set @ValorFin = @CT_CUOTAMINIMA
			end
	
		end
		else
		  set @ValorFin = @Valor
	
	end
	
--	print @ValorFin
	set @CTPD_PRECIOTOT= @ValorFin




GO
