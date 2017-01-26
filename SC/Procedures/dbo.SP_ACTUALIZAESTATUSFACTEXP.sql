SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSFACTEXP] (@CodigoFactura int)   as

SET NOCOUNT ON 


	ALTER TABLE [FACTEXP]  DISABLE TRIGGER [UPDATE_FACTEXP]

declare @fe_tipo char(1), @feddescargado int, @fccodigo int, @sDischStatus char(1), @cancelada char(1), @picodigo int,
@fe_con_ped char(1)


/*		SELECT     @feddescargado= COUNT(FED_DESCARGADO)
		FROM         FACTEXPDET
		WHERE      (FED_DESCARGADO = 'S') AND (FE_CODIGO = @CodigoFactura)
*/
		update factexp
		set fe_fechadescarga= null
		where fe_fechadescarga=''


		update factexp
		set fe_descargada='S' where fe_codigo=@CodigoFactura
			and fe_fechadescarga is not NULL

		update factexp
		set fe_descargada='N'
		where  fe_codigo=@CodigoFactura 
			and fe_fechadescarga is NULL


		select @picodigo = pi_codigo from factexp where fe_codigo=@CodigoFactura



		select @sDischStatus=fe_descargada , @fe_con_ped = case when pi_trans<=0 and pi_codigo<=0 then 'N' else 'S' end, @cancelada =fe_cancelado, @fe_tipo = fe_tipo
		from factexp where fe_codigo=@CodigoFactura


		if @cancelada='S'
			update factexp set fe_estatus = 'A' where fe_codigo = @CodigoFactura -- A	= Cancelada 
			and fe_estatus <> 'A'
		else
			if @fe_tipo='T'
			begin
				if @sDischStatus ='S'  	
				update factexp set fe_estatus = 'L' where fe_codigo = @CodigoFactura -- T = Transformadores congelada
				and fe_estatus <> 'L'
				else
				update factexp set fe_estatus = 'T' where fe_codigo = @CodigoFactura -- T = Transformadores sin congelar saldos de pedimentos
				and fe_estatus <> 'T'
			end
			else
			if @fe_tipo='S'
			begin
				if @sDischStatus ='S'  	
				update factexp set fe_estatus = 'V' where fe_codigo = @CodigoFactura -- V = Aviso de traslado descargado
				and fe_estatus <> 'V'
				else
				update factexp set fe_estatus = 'N' where fe_codigo = @CodigoFactura -- N = Aviso de traslado sin descargar
				and fe_estatus <> 'N'
			end
			else
				if @sDischStatus ='S'  		
				begin
					if @fe_con_ped='N' 
						update factexp set fe_estatus = 'S' where fe_codigo = @CodigoFactura  -- S = Descargada - Sin Pedimento
						and fe_estatus <> 'S'
					else
						update factexp set fe_estatus = 'C' where fe_codigo = @CodigoFactura -- C	 = Descarga Con Pedimento
						and fe_estatus <> 'C'
				end
				else
				begin
					if @fe_con_ped='N' 
						update factexp set fe_estatus = 'D' where fe_codigo = @CodigoFactura --D	= Sin Descargar, Sin Pedimento
						and fe_estatus <> 'D'
					else
						update factexp set fe_estatus = 'P' where fe_codigo = @CodigoFactura -- P	= Sin Descargar, Con Pedimento 
						and fe_estatus <> 'P'
				end





	ALTER TABLE [FACTEXP]  ENABLE TRIGGER [UPDATE_FACTEXP]


GO
