SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[CONTROLRESINASINSERT] ON [dbo].[CONTROLRESINAS] 
FOR INSERT
AS
SET NOCOUNT ON
declare @bstCodigo int, @MA_CodigoOrigen int, @MA_CodigoDestino int, 
		@CRS_FechaInicial datetime, @CRS_FechaFinal datetime, @ma_codigo int, @ma_tip_ens char(1)
if (select count(MA_CodigoDestino) from Inserted) > 0
	begin

		insert into ResinasFacturas (RF_CodigoDocumento, RF_TipoDocumento, TQ_Codigo)
		select maestro.ma_codigo, 'C', 1
		from maestro
			left outer join maestrocost on maestro.ma_codigo = maestrocost.ma_codigo
								and maestrocost.tco_codigo = 1 and ma_perfin >= getdate()
			inner join  Inserted ins on maestro.ma_codigo = ins.ma_codigoDestino
		group by maestro.ma_codigo, ma_noparte, ma_noparteaux, tco_codigo
		having count(tco_codigo) = 0
		
		
		
		insert into maestroCost(ma_codigo, tco_codigo, spi_codigo, ma_costo, MA_GRAV_MO, MA_PERINI)
		select maestro.ma_codigo, 1, 22, 
		(select ma_costo  from vmaestrocost where vmaestrocost.ma_codigo = maestro.ma_codigo),
		(select ma_costo  from vmaestrocost where vmaestrocost.ma_codigo = maestro.ma_codigo), '01/01/1999'
		from maestro
			left outer join maestrocost on maestro.ma_codigo = maestrocost.ma_codigo
								and maestrocost.tco_codigo = 1 and ma_perfin >= getdate()
			inner join  Inserted ins on maestro.ma_codigo = ins.ma_codigoDestino
		group by maestro.ma_codigo, ma_noparte, ma_noparteaux, tco_codigo
		having count(tco_codigo) = 0

		
		update maestro set	MA_TIP_ENS = case tipo.ti_nombre
											when 'MATERIA PRIMA' then 'A'
											when 'PRODUCTO TERMINADO' then 'A'
											when 'SUBENSAMBLE' then 'A'
										 end,
							TI_CODIGO = case tipo.ti_nombre
											when 'MATERIA PRIMA' then (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
											when 'PRODUCTO TERMINADO' then (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
											else (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
										end
		from maestro
			inner join Inserted ins on maestro.ma_codigo = ins.MA_CodigoDestino
			left outer join tipo on maestro.ti_codigo = tipo.ti_codigo 
		
			
		insert into ResinasFacturas (RF_CodigoDocumento, RF_TipoDocumento, TQ_Codigo)
		select maestro.ma_codigo, 'M', convert(int,convert(varchar(2),ascii(maestro.ma_tip_ens)) + convert(varchar(2),maestro.ti_codigo))
		from maestro
			inner join Inserted ins on maestro.ma_codigo = ins.MA_CodigoOrigen
		where ins.MA_CodigoOrigen not in (select RF_CodigoDocumento from ResinasFacturas)
		group by maestro.ma_codigo, maestro.ma_tip_ens, maestro.ti_codigo
		
		update maestro set	MA_TIP_ENS = case tipo.ti_nombre
											when 'MATERIA PRIMA' then 'A'
											when 'PRODUCTO TERMINADO' then 'A'
											when 'SUBENSAMBLE' then 'A'
										 end,
							TI_CODIGO = case tipo.ti_nombre
											when 'MATERIA PRIMA' then (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
											when 'PRODUCTO TERMINADO' then (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
											else (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
										end
		from maestro
			inner join Inserted ins on maestro.ma_codigo = ins.MA_CodigoOrigen
			left outer join tipo on maestro.ti_codigo = tipo.ti_codigo 		
		
		insert into ResinasFacturas (RF_CodigoDocumento, RF_TipoDocumento, TQ_Codigo)
		select factimp.FI_Codigo, 'I', TQ_Codigo
		from factimp
			left outer join factimpdet on factimp.fi_codigo = factimpdet.fi_codigo
			inner join Inserted ins on factimpdet.ma_codigo = ins.MA_CodigoDestino

		Insert into ResinasFacturas (RF_CodigoDocumento, RF_TipoDocumento, TQ_Codigo)
		select factexp.FE_Codigo, 'E', TQ_Codigo
		from FactExp
			left outer join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo
			inner join Inserted ins on factexpdet.ma_codigo = ins.MA_CodigoDestino
		
		update factimp set TQ_Codigo = (select tq_codigo from tembarque where tq_nombre = 'TODO TIPO MATERIAL')
		from factimp
			left outer join factimpdet on factimp.fi_codigo = factimpdet.fi_codigo
			inner join inserted ins on factimpdet.ma_codigo = ins.MA_CodigoDestino
		
		update factimpdet set ti_codigo = (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
		from factimpdet
			inner join inserted ins on factimpdet.ma_codigo = ins.MA_CodigoDestino
		
		update factexp set TQ_codigo = (select tq_codigo from tembarque where tq_nombre = 'TODO TIPO MATERIAL')
		from factexp
			left outer join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo
			inner join inserted ins on factexpdet.ma_codigo = ins.MA_CodigoDestino
		
		update factexpdet set ti_codigo = (select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE')
		from factexpdet
			inner join inserted ins on factexpdet.ma_codigo = ins.MA_CodigoDestino
		
		Insert into ResinasFacturas (RF_CodigoDocumento, RF_TipoDocumento, TQ_Codigo)
		select bom_struct.bst_hijo, 'B', ascii(bst_tip_ens)
		from BOM_STRUCT
			inner join Inserted ins on bom_struct.bst_hijo = ins.MA_CodigoDestino
		
		update bom_struct set BST_TIP_ENS = 'F'
		from bom_struct
			inner join inserted ins on bom_struct.bst_hijo = ins.MA_CodigoDestino

		declare cursor_bom cursor for
		select MA_CodigoOrigen, MA_CodigoDestino, CRS_FechaInicial, CRS_FechaFinal, case when maestro.ma_tip_ens = 'A' then 'F' else maestro.ma_tip_ens end
		from Inserted ins
			left outer join maestro on ins.MA_CodigoOrigen = maestro.ma_codigo
		open cursor_bom
		FETCH NEXT FROM cursor_bom INTO @MA_CodigoOrigen, @MA_CodigoDestino, @CRS_FechaInicial, @CRS_FechaFinal, @ma_tip_ens
		WHILE (@@FETCH_STATUS = 0)
			BEGIN
				exec stpGrabaStruct @MA_CodigoOrigen, @MA_CodigoDestino, @CRS_FechaInicial, @CRS_FechaFinal , 'N', @ma_tip_ens, 0, @bst_codigo = @bstCodigo output
				FETCH NEXT FROM cursor_bom INTO @MA_CodigoOrigen, @MA_CodigoDestino, @CRS_FechaInicial, @CRS_FechaFinal, @ma_tip_ens
			END
		close cursor_bom
		deallocate cursor_bom
		
	end
GO
