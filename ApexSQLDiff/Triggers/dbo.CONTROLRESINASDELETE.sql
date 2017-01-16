SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[CONTROLRESINASDELETE] ON [dbo].[CONTROLRESINAS] 
instead of DELETE
AS
SET NOCOUNT ON	
	delete from maestrocost
	from maestrocost
		inner join ResinasFacturas on maestroCost.ma_codigo = ResinasFacturas.rf_codigoDocumento
		inner join Deleted del on MaestroCost.ma_codigo = del.MA_CodigoDestino
	where resinasFacturas.rf_tipoDocumento = 'C'
		and MaestroCost.tco_codigo = (select tco_codigo from tcosto where tco_nombre = 'COSTO DE MANUFACTURA')
		
	delete from ResinasFacturas
		from ResinasFacturas 
		inner join Deleted del on ResinasFacturas.rf_CodigoDocumento = del.MA_CodigoDestino
	where resinasFacturas.rf_tipoDocumento = 'C'

	
	update maestro set MA_TIP_ENS = del.MA_TIP_ENSDestino,
						TI_CODIGO = del.TI_CodigoDestino
	from maestro
		inner join Deleted del on maestro.ma_codigo = del.MA_CodigoDestino
		
	--Actualiza el numero de parte origen, siempre y cuando se hayan eliminado todos los numeros de parte destino
	
	update maestro set MA_TIP_ENS = char(left(resinasFacturas.TQ_Codigo,2)),
					   TI_CODIGO = subString(Convert(varchar(5), resinasFacturas.TQ_Codigo),3,len(resinasFacturas.TQ_Codigo))
	from maestro
		inner join 
				(select ControlResinas.ma_codigoOrigen
				from ControlResinas
					left outer join Deleted del1 on del1.crs_codigo = ControlResinas.crs_codigo and del1.MA_CodigoOrigen = ControlResinas.MA_CodigoOrigen
				group by ControlResinas.ma_codigoOrigen
				Having count(ControlResinas.ma_codigoOrigen) = count(del1.ma_codigoOrigen)) del
		on maestro.ma_codigo = del.MA_CodigoOrigen
		inner join ResinasFacturas on maestro.ma_codigo = ResinasFacturas.rf_CodigoDocumento
	where ResinasFacturas.rf_tipoDocumento = 'M'
	
	
	delete from ResinasFacturas
		from ResinasFacturas
			inner join 
			(select ControlResinas.ma_codigoOrigen
			from ControlResinas
				left outer join Deleted del1 on del1.crs_codigo = ControlResinas.crs_codigo and del1.MA_CodigoOrigen = ControlResinas.MA_CodigoOrigen
			group by ControlResinas.ma_codigoOrigen
			Having count(ControlResinas.ma_codigoOrigen) = count(del1.ma_codigoOrigen)) del
			on ResinasFacturas.rf_CodigoDocumento = del.MA_CodigoOrigen
		where ResinasFacturas.rf_TipoDocumento = 'M'

	
	delete from bom_struct
			from bom_struct
			inner join deleted del on bom_struct.bsu_subensamble = del.MA_CodigoDestino
									and bom_struct.bst_hijo = del.MA_CodigoOrigen
	
	update factimp set tq_codigo = resinasFacturas.TQ_Codigo
		from factimp
			left outer join factimpdet on factimp.fi_codigo = factimpdet.fi_codigo
			inner join resinasFacturas on factimp.fi_codigo = resinasFacturas.RF_CodigoDocumento
											and resinasFacturas.RF_TipoDocumento = 'I'
			inner join deleted del on factimpdet.ma_codigo = del.MA_CodigoDestino
		 
	
	update factimpdet set ti_codigo = del.TI_CodigoDestino
		from factimpdet
			inner join deleted del on factimpdet.ma_codigo = del.MA_CodigoDestino
	
	update factexp set TQ_Codigo = resinasFacturas.TQ_Codigo
		from factexp
			inner join resinasFacturas on factexp.fe_codigo = resinasFacturas.RF_CodigoDocumento
			left outer join factExpdet on factexp.fe_codigo = factexpdet.fe_codigo
			inner join deleted del on factexpdet.ma_codigo = del.MA_CodigoDestino
	
	update factexpdet set ti_codigo = del.TI_CodigoDestino
		from factexpdet
			inner join deleted del on factexpdet.ma_codigo = del.MA_CodigoDestino

	update bom_struct set BST_TIP_ENS = char(resinasFacturas.TQ_Codigo)
		from bom_struct
			inner join resinasFacturas on bom_struct.bst_hijo = resinasFacturas.RF_CodigoDocumento
			inner join deleted del on bom_struct.bst_hijo = del.MA_CodigoDestino
		where resinasFacturas.RF_TipoDocumento = 'B'
				
	delete from ResinasFacturas
			from ResinasFacturas
				inner join Deleted del on ResinasFacturas.RF_CodigoDocumento = del.MA_CodigoDestino
									and ResinasFacturas.RF_TipoDocumento = 'B'
			
	delete from ResinasFacturas
			from ResinasFacturas
			left outer join factimp on ResinasFacturas.RF_CodigoDocumento = factimp.fi_codigo
								  and  ResinasFacturas.RF_TipoDocumento = 'I'
			left outer join factimpdet on factimp.fi_codigo = factimpdet.fi_codigo
			inner join deleted del on factimpdet.ma_codigo = del.MA_CodigoDestino
	
	delete from ResinasFacturas
			from ResinasFacturas
			left outer join factexp on ResinasFacturas.RF_CodigoDocumento = factexp.fe_codigo
									and ResinasFacturas.RF_TipoDocumento = 'E'
			left outer join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo
			inner join deleted del on factexpdet.ma_codigo = del.MA_CodigoDestino
			
	
	Insert into ControlResinasEliminadas (MA_CodigoOrigen, MA_CodigoDestino, CRE_FechaInicial, CRE_FechaFinal, TI_CodigoOrigen, TI_CodigoDestino, MA_Tip_EnsDestino, 
										CRE_FechaEliminacion)
	select del.MA_CodigoOrigen, del.MA_CodigoDestino, del.CRS_FechaInicial, del.CRS_FechaFinal, del.TI_CodigoOrigen, del.TI_CodigoDestino, Del.MA_TIP_EnsDestino,
			getdate()
		from Deleted del
	
	delete from ControlResinas
	from ControlResinas 
		inner join deleted del on ControlResinas.crs_codigo = del.crs_codigo
GO
