SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE procedure dbo.CalculaConcentradoDescargasMultas_Detalles ( @tipoDatos char(1), @fecha datetime, @TipoSaldo char(1))    as

SET NOCOUNT ON 
BEGIN
if not exists (select * from sysobjects where name = 'TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano') 
		CREATE TABLE  [TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[YearImportado] [int] NULL ,
			[MultaAPagar] float,
			[Titulo1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[Titulo2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[UM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		) ON [PRIMARY]
		
else
	delete from TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano		

if exists (select * from sysobjects where name = 'TemporalDescargas_ConcentradoMultas') 
	drop table TemporalDescargas_ConcentradoMultas	

	--declare @fecha datetime
	declare @CoutaMulta float
	
	--set @fecha = '2008-08-01'
	set @CoutaMulta = isnull((select cf_multaexcplazo from configuracion),0.0)


	if UPPER(@TipoSaldo) = 'N'	
	begin
		select 	kardesped.ma_hijo, /*(select ma_noparte from maestro where maestro.ma_codigo = kardesped.ma_hijo)*/pedimpdet.pid_noparte as NoParte, 
			@fecha as fecha, 
			--factexpdet.fe_fecha as fechaFactura,  ---solo son de referencia
			--pedimp.pi_fec_pag as fechaPedImport,  ---solo son de referencia
			pidescarga.pid_fechavence, 
			year(pedimp.pi_fec_pag) as YearImportado,
				case when factexp.fe_fecha > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
							ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha) ) /15)  * @CoutaMulta
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
								 (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
							end
					  end
						
				     else 
					 0
				end   as MultaAPagar
					,
		
				(isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0)) as Saldo,
				kardesped.kap_cantDesc as cantidadTotal,
				kardesped.kap_cantDesc as CantidadDesc,
				kardesped.kap_cantDesc as CantidadSaldo,
				(select Me_corto from medida where medida.me_codigo = (select me_com from maestro where maestro.ma_codigo = pidescarga.ma_codigo)) as UM,
		
		
			
				case when factexp.fe_fecha > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
							'Multa'
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
								 'Costo'
							end
					  end
						
				     else 
					 'Exento'
				end   as PagaMulta,
				case when getdate() > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
							ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
								 (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
							end
					  end
						
				     else 
					 0
				end as MultaAlDia,
				case when getdate() > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
							'Multa'
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
								 'Costo'
							end
					  end
						
				     else 
					 'Exento'
				end  as PagaMultaAlDia
		
		into TemporalDescargas_ConcentradoMultas	
		from kardesped
		inner join factexpdet on kardesped.kap_indiced_fact = factexpdet.fed_indiced
		inner join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
		inner join pedimp on pedimpdet.pi_codigo = pedimp.pi_codigo
		inner join pidescarga on pedimpdet.pid_indiced = pidescarga.pid_indiced 
		inner join factexp on factexpdet.fe_codigo = factexp.fe_codigo
		where factexp.fe_fecha < = @fecha
		and factexp.fe_folio not like 'inventario%'
		and pedimp.cp_codigo <>26
		and pedimp.cp_codigo in (select claveped.cp_codigo from claveped where claveped.cp_clave  IN ('H2', 'V1','IN'))
	end	



	if UPPER(@TipoSaldo) = 'C'	
	begin
		select 	kardesped.ma_hijo, /*(select ma_noparte from maestro where maestro.ma_codigo = kardesped.ma_hijo)*/pedimpdet.pid_noparte as NoParte, 
			@fecha as fecha, 
			--factexpdet.fe_fecha as fechaFactura,  ---solo son de referencia
			--pedimp.pi_fec_pag as fechaPedImport,  ---solo son de referencia
			pidescarga.pid_fechavence, 
			year(pedimp.pi_fec_pag) as YearImportado,
				case when factexp.fe_fecha > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
							ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha) ) /15)  * @CoutaMulta
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
								 (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
							end
					  end
						
				     else 
					 0
				end   as MultaAPagar
					,
		
				(isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0)) as Saldo,
				kardesped.kap_cantDesc as cantidadTotal,
				kardesped.kap_cantDesc as CantidadDesc,
				kardesped.kap_cantDesc as CantidadSaldo,
				(select Me_corto from medida where medida.me_codigo = (select me_com from maestro where maestro.ma_codigo = pidescarga.ma_codigo)) as UM,
		
		
			
				case when factexp.fe_fecha > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
							'Multa'
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, factexp.fe_fecha ) ) /15)  * @CoutaMulta then
								 'Costo'
							end
					  end
						
				     else 
					 'Exento'
				end   as PagaMulta,
				case when getdate() > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
							ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
								 (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
							end
					  end
						
				     else 
					 0
				end as MultaAlDia,
				case when getdate() > pidescarga.pid_fechavence then  
					  case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
							'Multa'
						else
					  		case when (isnull(kardesped.kap_cantDesc,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate() ) ) /15)  * @CoutaMulta then
								 'Costo'
							end
					  end
						
				     else 
					 'Exento'
				end  as PagaMultaAlDia
		
		into TemporalDescargas_ConcentradoMultas	
		from kardesped
		inner join factexpdet on kardesped.kap_indiced_fact = factexpdet.fed_indiced
		inner join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
		inner join pedimp on pedimpdet.pi_codigo = pedimp.pi_codigo
		inner join pidescarga on pedimpdet.pid_indiced = pidescarga.pid_indiced 
		inner join factexp on factexpdet.fe_codigo = factexp.fe_codigo
		where factexp.fe_fecha < = @fecha
		and factexp.fe_folio like 'inventario%'
		and pedimp.cp_codigo <>26
		and pedimp.cp_codigo in (select claveped.cp_codigo from claveped where claveped.cp_clave  IN ('H2', 'V1','IN'))
	end	







	if @tipoDatos = 'D' 
	begin
		if exists (select * from sysobjects where name = 'TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano') 
			drop table TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano	
		
		CREATE TABLE  [TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[YearImportado] [int] NULL ,
			[MultaAPagar] float,
			[Titulo1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[Titulo2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[UM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		) ON [PRIMARY]
		
		
		
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, YearImportado,MultaAPagar,Titulo1, Titulo2, UM )
		select noparte,YearImportado , sum(MultaAPagar) as MultaAPagar , 'Periodo', convert(varchar(50),yearimportado),
			(select max(concentrado.UM) from TemporalDescargas_ConcentradoMultas concentrado where concentrado.noparte = TemporalDescargas_ConcentradoMultas.noparte )
		from TemporalDescargas_ConcentradoMultas	
		group by noparte, YearImportado
		order by noparte
		
		
		
		
		if exists (select * from sysobjects where name = 'TemporalDescargas_ConcentradoMultasPrioridad') 
			drop table TemporalDescargas_ConcentradoMultasPrioridad	
		
		CREATE TABLE  [TemporalDescargas_ConcentradoMultasPrioridad] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[MultaTotal] float,
			[PrioridadMulta] [int],
			[SaldoTotal] float,
			[PrioridadSaldo] [int],
			--cantidadTotal float , 
			cantidadDesc float, 
			--cantidadsaldo float, 
			UM [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		
		) ON [PRIMARY]
		
		
		
		insert into TemporalDescargas_ConcentradoMultasPrioridad (noparte, MultaTotal, SaldoTotal,/* cantidadTotal,*/ cantidadDesc, /*cantidadsaldo,*/ UM)
		select noparte, sum(MultaAPagar) as MultaTotal, sum(Saldo) as SaldoTotal, /*sum(cantidadTotal) as cantidadTotal,*/ sum(cantidadDesc) as cantidadDesc, /*sum(cantidadSaldo) as cantidadsaldo,*/ max(UM)
		from TemporalDescargas_ConcentradoMultas
		group by noparte
		
		
		
		if exists (select * from sysobjects where name = 'TemporalDescargas_ConcentradoPrioridad') 
			drop table TemporalDescargas_ConcentradoPrioridad	
		
		CREATE TABLE [TemporalDescargas_ConcentradoPrioridad] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		        --[Total] float,
			[Prioridad] [int] identity (1,1),
		) ON [PRIMARY]
		
		
		
		--Actualiza Prioridad de Multa
		dbcc checkident (TemporalDescargas_ConcentradoPrioridad, reseed,1)
		
		--Actualiza Prioridad de Multa
		dbcc checkident (TemporalDescargas_ConcentradoPrioridad, noreseed)
		
		insert into TemporalDescargas_ConcentradoPrioridad (noparte)
		select noparte
		from TemporalDescargas_ConcentradoMultasPrioridad
		order by MultaTotal desc
		
		update TemporalDescargas_ConcentradoMultasPrioridad
		set PrioridadMulta = (select prioridad from TemporalDescargas_ConcentradoPrioridad where TemporalDescargas_ConcentradoPrioridad.noparte = TemporalDescargas_ConcentradoMultasPrioridad.noparte)
		
		
		--Actualiza Prioridad de Saldo
		delete from  TemporalDescargas_ConcentradoPrioridad
		
		dbcc checkident (TemporalDescargas_ConcentradoPrioridad, reseed,0)
		
		insert into TemporalDescargas_ConcentradoPrioridad (noparte)
		select noparte
		from TemporalDescargas_ConcentradoMultasPrioridad
		order by SaldoTotal desc
		
		update TemporalDescargas_ConcentradoMultasPrioridad
		set PrioridadSaldo = (select prioridad from TemporalDescargas_ConcentradoPrioridad where TemporalDescargas_ConcentradoPrioridad.noparte = TemporalDescargas_ConcentradoMultasPrioridad.noparte)
	
	
		-- aqui es donde se hacen los cambios para que salga como debe en CRYSTAL REPORT
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaaPagar, Titulo1, titulo2, UM)
		select noparte, sum(multaapagar), 'Periodo', 'Total (MN)', UM
		from TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano
		--WHERE not yearimportado is null
		group by noparte, UM
					
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, multatotal,'Multas', 'MultaTotal (MN)', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, prioridadmulta,'Multas', 'PrioridadMulta', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, saldoTotal,'Descargas', 'Valor DSCH (MN)', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, prioridadsaldo,'Descargas', 'Prioridad DSCH', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		
		
		/*insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, cantidadTotal,'Cantidades', 'CantidadTotal', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		*/
		
		insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, cantidadDesc,'Descargas', 'CantidadDescargada', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		
		/*insert into TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, cantidadSaldo,'Cantidades', 'CantidadSaldo', UM
		from TemporalDescargas_ConcentradoMultasPrioridad
		*/



	end


	
	if @tipoDatos = 'G' 
	begin	
		--Punto #3
		--General
		if exists (select * from sysobjects where name = 'TemporalDescargas_ConcentradoMultasGeneral') 
			drop table TemporalDescargas_ConcentradoMultasGeneral	
		
		CREATE TABLE [TemporalDescargas_ConcentradoMultasGeneral] (
			[yearImportado] [int] NULL ,
			[Multas] [float] NOT NULL ,
			[ValorSaldo] [decimal](38, 6) NOT NULL ,
			[SaldoConMulta] [decimal](38, 6) NOT NULL ,
			[SaldoSinMulta] [decimal](38, 6) NOT NULL ,
			[MultasAlDia] [float] NOT NULL 
		
		) ON [PRIMARY]
		
	
		
		insert into TemporalDescargas_ConcentradoMultasGeneral (yearImportado, Multas, ValorSaldo, SaldoConMulta,  SaldoSinMulta, MultasAlDia)
		select yearImportado,  isnull(sum(multaAPagar),0.0) as Multas, isnull(sum(saldo),0.0) as ValorSaldo, 
			isnull((select sum(temporal.saldo) from TemporalDescargas_ConcentradoMultas Temporal where temporal.yearimportado = TemporalDescargas_ConcentradoMultas.yearimportado and temporal.pagaMulta in ('Multa', 'Costo')),0.0) as SaldoConMulta,
			isnull((select sum(temporal.saldo) from TemporalDescargas_ConcentradoMultas Temporal where temporal.yearimportado = TemporalDescargas_ConcentradoMultas.yearimportado and temporal.pagaMulta = 'Exento'), 0.0) as SaldoSinMulta,
			isnull((select sum(temporal.multaAlDia) from TemporalDescargas_ConcentradoMultas Temporal where temporal.yearimportado = TemporalDescargas_ConcentradoMultas.yearimportado and temporal.pagaMultaAlDia in ('Multa', 'Costo')),0.0) as MultaAlDia
		from TemporalDescargas_ConcentradoMultas
		group by yearImportado
		order by yearImportado
	
	end



--select * from TemporalDescargas_ConcentradoMultasGeneral
select * from  TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano 

if @tipoDatos = 'G' 
	select * from TemporalDescargas_ConcentradoMultasGeneral
else
begin
	  if @tipoDatos = 'D' 
		--select TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano.noparte, yearimportado, multaapagar --,multatotal, prioridadmulta, saldototal, prioridadsaldo, cantidadTotal, cantidadDesc, cantidadSaldo, UM 
		--from TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano
		--inner join TemporalDescargas_ConcentradoMultasPrioridad on TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano.noparte = TemporalDescargas_ConcentradoMultasPrioridad.noparte
	
		select * from  TemporalDescargas_ConcentradoMultasAgrupadosxNoParte_Ano 
end

--select * from TemporalDescargas_ConcentradoMultasGeneral

END

GO
