SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedimptransporte]  (@picodigo int)   as

SET NOCOUNT ON 
declare @pi_movimiento char(1)
select @pi_movimiento=pi_movimiento from pedimp where pi_codigo=@picodigo


	-- ctranportistas

	if exists (select * from PEDIMPCTRANSPOR where pi_codigo=@picodigo)
	delete from PEDIMPCTRANSPOR where pi_codigo=@picodigo

	if @pi_movimiento='E'
	begin
		INSERT INTO PEDIMPCTRANSPOR (PI_CODIGO, CT_CODIGO, PA_CTRANPOR, PI_IDENTMTRANSP)
	
		SELECT     @picodigo, isnull(FACTIMP.CT_CODIGO,0), isnull(CTRANSPOR.PA_CODIGO,154), max(isnull(FACTIMP.FI_TRAC_MX,''))
		FROM         FACTIMP LEFT OUTER JOIN
	                      CTRANSPOR ON FACTIMP.CT_CODIGO = CTRANSPOR.CT_CODIGO
		WHERE     (PI_CODIGO = @picodigo OR PI_RECTIFICA = @picodigo)
			and isnull(FACTIMP.CT_CODIGO,0) not in (select CT_CODIGO from PEDIMPCTRANSPOR where pi_codigo=@picodigo)
		GROUP BY isnull(FACTIMP.CT_CODIGO,0), isnull(CTRANSPOR.PA_CODIGO,154)
	end
	else
	begin
	
		INSERT INTO PEDIMPCTRANSPOR (PI_CODIGO, CT_CODIGO, PA_CTRANPOR, PI_IDENTMTRANSP)
	
		SELECT     @picodigo, isnull(CT_COMPANY1,0), isnull(CTRANSPOR.PA_CODIGO,154), max(isnull(FE_TRAC_MX1,''))
		FROM         FACTEXP LEFT OUTER JOIN
	                      CTRANSPOR ON FACTEXP.CT_COMPANY1 = CTRANSPOR.CT_CODIGO
		WHERE     (PI_CODIGO = @picodigo OR PI_RECTIFICA = @picodigo)
			and isnull(CT_COMPANY1,0) not in (select CT_CODIGO from PEDIMPCTRANSPOR where pi_codigo=@picodigo)
		GROUP BY isnull(CT_COMPANY1,0), isnull(CTRANSPOR.PA_CODIGO,154)
	
	end



	-- guias
	if exists (select * from PEDIMPGUIA where pi_codigo=@picodigo)
	delete from PEDIMPGUIA where pi_codigo=@picodigo

	if @pi_movimiento='E'
	begin
		INSERT INTO PEDIMPGUIA (PI_CODIGO, PI_GUIA, PI_TGUIA)
	
		SELECT     @picodigo, isnull(FI_GUIA,''), 'M'
		FROM         FACTIMP 
		WHERE     (PI_CODIGO = @picodigo OR PI_RECTIFICA = @picodigo) and isnull(FI_GUIA,'')<>''
		GROUP BY isnull(FI_GUIA,'')
	end
	else
	begin
		INSERT INTO PEDIMPGUIA (PI_CODIGO, PI_GUIA, PI_TGUIA)
	
		SELECT     @picodigo, isnull(FE_GUIA1,''), 'M'
		FROM         FACTEXP 
		WHERE     (PI_CODIGO = @picodigo OR PI_RECTIFICA = @picodigo) and isnull(FE_GUIA1,'')<>''
		GROUP BY isnull(FE_GUIA1,'')
	end





GO
