SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSFACTIMP] (@CodigoFactura int)   as

SET NOCOUNT ON 

	ALTER TABLE [FACTIMP]  DISABLE TRIGGER [UPDATE_FACTIMP]

declare @fi_tipo char(1), @picodigo int, @cancelada char(1), @fi_con_ped char(1), @fc_codigo int

		select @picodigo = pi_codigo from factimp where fi_codigo=@CodigoFactura


		select @fi_con_ped = case when pi_codigo <0 and pi_rectifica <0 then 'N' else 'S' end, @cancelada =fi_cancelado, @fi_tipo = fi_tipo,
		@fc_codigo=fc_codigo  from factimp where fi_codigo=@CodigoFactura



		if @cancelada='S'
			update factimp set fi_estatus = 'A' where fi_codigo = @CodigoFactura -- A	= Cancelada 
			and fi_estatus <> 'A'
		else
		if @cancelada='N'
			begin
				if @fi_tipo='T' 
				begin
					if @fi_con_ped ='N'
					update factimp set fi_estatus = 'T' where fi_codigo = @CodigoFactura -- T = Transformadores sin integrar
					and fi_estatus <> 'T'
					else
					update factimp set fi_estatus = 'L' where fi_codigo = @CodigoFactura -- L = Transformadores - integrada
					and fi_estatus <> 'L'

				end
				else
				if @fi_tipo<>'T'
				begin
					if @fi_con_ped='N' 
					begin
						update factimp set fi_estatus = 'S' where fi_codigo = @CodigoFactura -- S = Sin Pedimento 
						and fi_estatus <> 'S'
					end
					else
					if @fi_con_ped='S'  
						update factimp set fi_estatus = 'C' where fi_codigo = @CodigoFactura --- C	 = Con Pedimento
						and fi_estatus <> 'C'
				end
			end




	ALTER TABLE [FACTIMP]  ENABLE TRIGGER [UPDATE_FACTIMP]


GO
