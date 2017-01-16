SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure dbo.CalculaConcentradoMultas_Detalles ( @tipoDatos char(1), @tipoPedimento char(1), @fecha datetime,  @IniciaPeriodo datetime, @TerminaPeriodo datetime)    as

SET NOCOUNT ON 
BEGIN
if not exists (select * from sysobjects where name = 'Temporal_ConcentradoMultasAgrupadosxNoParte_Ano') 
		CREATE TABLE  [Temporal_ConcentradoMultasAgrupadosxNoParte_Ano] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[YearImportado] [int] NULL ,
			[MultaAPagar] float,
			[Titulo1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[Titulo2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[UM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		) ON [PRIMARY]
else
	delete from Temporal_ConcentradoMultasAgrupadosxNoParte_Ano

if exists (select * from sysobjects where name = 'Temporal_ConcentradoMultas') 
	drop table Temporal_ConcentradoMultas	
	--declare @fecha datetime
	declare @CoutaMulta float
	
	--set @fecha = '2008-08-01'
	set @CoutaMulta = isnull((select cf_multaexcplazo from configuracion),0.0)
	if @tipoPedimento = 'a'	
	begin
		select 	
			pidescarga.ma_codigo,pedimpdet.pid_noparte /* (select ma_noparte from maestro where maestro.ma_codigo = pidescarga.ma_codigo)*/ as NoParte, 
			@fecha as fecha, pidescarga.pid_fechavence, year(vpedimp.pi_fec_pag) as YearImportado,
			case when @fecha > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
						ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
							 (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
						end
				  end
					
			     else 
				 0
			end   as MultaAPagar
				,
		
			(isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0)) as Saldo,
			pedimpdet.pid_can_gen as cantidadTotal,
			pidescarga.pid_saldogen as CantidadDesc,
			pedimpdet.pid_can_gen - pidescarga.pid_saldogen as CantidadSaldo,
			(select Me_corto from medida where medida.me_codigo = (select me_com from maestro where maestro.ma_codigo = pidescarga.ma_codigo)) as UM,
			case when @fecha > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
						'Multa'
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
							 'Costo'
						end
				  end
					
			     else 
				 'Exento'
			end   as PagaMulta,
		
			case when getdate() > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then
						ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then
							 (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
						end
				  end
					
			     else 
				 0
			end   as MultaAlDia,
			case when getdate() > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then	
						'Multa'
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then
							 'Costo'
						end
				  end
					
			     else 
				 'Exento'
			end   as PagaMultaAlDia
		
		
		into Temporal_ConcentradoMultas	
		from pidescarga
		inner join pedimpdet on pidescarga.pid_indiced = pedimpdet.pid_indiced
		inner join vpedimp on pidescarga.pi_codigo = vpedimp.pi_codigo
		where  --vpedimp.pi_movimiento = 'e'
		--and 
		vpedimp.pi_tipo = @tipoPedimento
		and vpedimp.pi_fec_pag <= @fecha
		and vpedimp.cp_codigo in (select claveped.cp_codigo from claveped where claveped.cp_clave  IN ('H2', 'V1','IN'))
	
	end

	if @tipoPedimento = 'c'	
	begin
		select 	
			pidescarga.ma_codigo,pedimpdet.pid_noparte /* (select ma_noparte from maestro where maestro.ma_codigo = pidescarga.ma_codigo)*/ as NoParte, 
			@fecha as fecha, pidescarga.pid_fechavence, year(vpedimp.pi_fec_pag) as YearImportado,
			case when @fecha > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
						ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
							 (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
						end
				  end
					
			     else 
				 0
			end   as MultaAPagar
				,
		
			(isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0)) as Saldo,
			pedimpdet.pid_can_gen as cantidadTotal,
			pidescarga.pid_saldogen as CantidadDesc,
			pedimpdet.pid_can_gen - pidescarga.pid_saldogen as CantidadSaldo,
			(select Me_corto from medida where medida.me_codigo = (select me_com from maestro where maestro.ma_codigo = pidescarga.ma_codigo)) as UM,
			case when @fecha > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
						'Multa'
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, @fecha) ) /15)  * @CoutaMulta then
							 'Costo'
						end
				  end
					
			     else 
				 'Exento'
			end   as PagaMulta,
		
			case when getdate() > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then
						ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then
							 (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu, 0))
						end
				  end
					
			     else 
				 0
			end   as MultaAlDia,
			case when getdate() > pidescarga.pid_fechavence then  
				  case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) >= ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then	
						'Multa'
					else
				  		case when (isnull(pidescarga.pid_saldogen,0) * isnull(/*pedimpdet.pid_cos_unigen*/pedimpdet.pid_cos_uniadu,0)) < ceiling (convert(float, datediff(day, pidescarga.pid_fechavence, getdate()) ) /15)  * @CoutaMulta then
							 'Costo'
						end
				  end
					
			     else 
				 'Exento'
			end   as PagaMultaAlDia
		
		
		into Temporal_ConcentradoMultas	
		from pidescarga
		inner join pedimpdet on pidescarga.pid_indiced = pedimpdet.pid_indiced
		inner join vpedimp on pidescarga.pi_codigo = vpedimp.pi_codigo
		where  --vpedimp.pi_movimiento = 'e'
		--and 
		vpedimp.pi_tipo = @tipoPedimento
		and vpedimp.pi_fec_pag <= @fecha
		and (vpedimp.pi_fec_pag >=@IniciaPeriodo /*'2006-11-01'*/ and vpedimp.pi_fec_pag <= @TerminaPeriodo /*'2007-10-31'*/)
		and vpedimp.cp_codigo in (select claveped.cp_codigo from claveped where claveped.cp_clave  IN ('H2', 'V1','IN'))
	end	
	
	
	if @tipoDatos = 'D' 
	begin
		if exists (select * from sysobjects where name = 'Temporal_ConcentradoMultasAgrupadosxNoParte_Ano') 
			drop table Temporal_ConcentradoMultasAgrupadosxNoParte_Ano	
		
		CREATE TABLE  [Temporal_ConcentradoMultasAgrupadosxNoParte_Ano] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[YearImportado] [int] NULL ,
			[MultaAPagar] float,
			[Titulo1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[Titulo2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[UM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		) ON [PRIMARY]
		
		
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, YearImportado,MultaAPagar,Titulo1, Titulo2, UM )
		select noparte,YearImportado , sum(MultaAPagar) as MultaAPagar , 'Periodo', convert(varchar(50),yearimportado),
			(select max(concentrado.UM) from Temporal_ConcentradoMultas concentrado where concentrado.noparte = Temporal_ConcentradoMultas.noparte )
		from Temporal_ConcentradoMultas	
		group by noparte, YearImportado
		order by noparte
		
		
		
		
		if exists (select * from sysobjects where name = 'Temporal_ConcentradoMultasPrioridad') 
			drop table Temporal_ConcentradoMultasPrioridad	
		
		CREATE TABLE  [Temporal_ConcentradoMultasPrioridad] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[MultaTotal] float,
			[PrioridadMulta] [int],
			[SaldoTotal] float,
			[PrioridadSaldo] [int],
			cantidadTotal float , 
			cantidadDesc float, 
			cantidadsaldo float, 
			UM [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		
		) ON [PRIMARY]
		
		
		
		insert into Temporal_ConcentradoMultasPrioridad (noparte, MultaTotal, SaldoTotal, cantidadTotal, cantidadDesc, cantidadsaldo, UM)
		select noparte, sum(MultaAPagar) as MultaTotal, sum(Saldo) as SaldoTotal, sum(cantidadTotal) as cantidadTotal, sum(cantidadDesc) as cantidadDesc, sum(cantidadSaldo) as cantidadsaldo, max(UM)
		from Temporal_ConcentradoMultas
		group by noparte
		
		
		
		if exists (select * from sysobjects where name = 'Temporal_ConcentradoPrioridad') 
			drop table Temporal_ConcentradoPrioridad	
		
		CREATE TABLE [Temporal_ConcentradoPrioridad] (
			[noparte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		        --[Total] float,
			[Prioridad] [int] identity (1,1),
		) ON [PRIMARY]
		
		
		
		--Actualiza Prioridad de Multa
		dbcc checkident (Temporal_ConcentradoPrioridad, reseed,1)
		
		--Actualiza Prioridad de Multa
		dbcc checkident (Temporal_ConcentradoPrioridad, noreseed)
		
		insert into Temporal_ConcentradoPrioridad (noparte)
		select noparte
		from Temporal_ConcentradoMultasPrioridad
		order by MultaTotal desc
		
		update Temporal_ConcentradoMultasPrioridad
		set PrioridadMulta = (select prioridad from Temporal_ConcentradoPrioridad where Temporal_ConcentradoPrioridad.noparte = Temporal_ConcentradoMultasPrioridad.noparte)
		
		
		--Actualiza Prioridad de Saldo
		delete from  Temporal_ConcentradoPrioridad
		
		dbcc checkident (Temporal_ConcentradoPrioridad, reseed,0)
		
		insert into Temporal_ConcentradoPrioridad (noparte)
		select noparte
		from Temporal_ConcentradoMultasPrioridad
		order by SaldoTotal desc
		
		update Temporal_ConcentradoMultasPrioridad
		set PrioridadSaldo = (select prioridad from Temporal_ConcentradoPrioridad where Temporal_ConcentradoPrioridad.noparte = Temporal_ConcentradoMultasPrioridad.noparte)
	
	
		-- aqui es donde se hacen los cambios para que salga como debe en CRYSTAL REPORT
		insert into temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaaPagar, Titulo1, titulo2, UM)
		select noparte, sum(multaapagar), 'Periodo', 'Total (MN)', UM
		from temporal_ConcentradoMultasAgrupadosxNoParte_Ano
		--WHERE not yearimportado is null
		group by noparte, UM
					
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, multatotal,'Multas', 'MultaTotal (MN)', UM
		from Temporal_ConcentradoMultasPrioridad
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, prioridadmulta,'Multas', 'PrioridadMulta', UM
		from Temporal_ConcentradoMultasPrioridad
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, saldoTotal,'Saldos', 'SaldoTotal (MN)', UM
		from Temporal_ConcentradoMultasPrioridad
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, prioridadsaldo,'Saldos', 'PrioridadSaldo', UM
		from Temporal_ConcentradoMultasPrioridad
		
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, cantidadTotal,'Cantidades', 'CantidadTotal', UM
		from Temporal_ConcentradoMultasPrioridad
		
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, cantidadDesc,'Cantidades', 'CantidadDesc', UM
		from Temporal_ConcentradoMultasPrioridad
		
		insert into Temporal_ConcentradoMultasAgrupadosxNoParte_Ano (noparte, multaapagar, titulo1, titulo2, UM)
		select noparte, cantidadSaldo,'Cantidades', 'CantidadSaldo', UM
		from Temporal_ConcentradoMultasPrioridad
	end

	
	if @tipoDatos = 'G' 
	begin	
		--Punto #3
		--General
		if exists (select * from sysobjects where name = 'Temporal_ConcentradoMultasGeneral') 
			drop table Temporal_ConcentradoMultasGeneral	
		
		CREATE TABLE [Temporal_ConcentradoMultasGeneral] (
			[yearImportado] [int] NULL ,
			[Multas] [float] NOT NULL ,
			[ValorSaldo] [decimal](38, 6) NOT NULL ,
			[SaldoConMulta] [decimal](38, 6) NOT NULL ,
			[SaldoSinMulta] [decimal](38, 6) NOT NULL ,
			[MultasAlDia] [float] NOT NULL 
		
		) ON [PRIMARY]
		
	
		
		insert into Temporal_ConcentradoMultasGeneral (yearImportado, Multas, ValorSaldo, SaldoConMulta,  SaldoSinMulta, MultasAlDia)
		select yearImportado,  isnull(sum(multaAPagar),0.0) as Multas, isnull(sum(saldo),0.0) as ValorSaldo, 
			isnull((select sum(temporal.saldo) from Temporal_ConcentradoMultas Temporal where temporal.yearimportado = Temporal_ConcentradoMultas.yearimportado and temporal.pagaMulta in ('Multa', 'Costo')),0.0) as SaldoConMulta,
			isnull((select sum(temporal.saldo) from Temporal_ConcentradoMultas Temporal where temporal.yearimportado = Temporal_ConcentradoMultas.yearimportado and temporal.pagaMulta = 'Exento'), 0.0) as SaldoSinMulta,
			isnull((select sum(temporal.multaAlDia) from Temporal_ConcentradoMultas Temporal where temporal.yearimportado = Temporal_ConcentradoMultas.yearimportado and temporal.pagaMultaAlDia in ('Multa', 'Costo')),0.0) as MultaAlDia
		from Temporal_ConcentradoMultas
		group by yearImportado
		order by yearImportado
	
	end
select * from  Temporal_ConcentradoMultasAgrupadosxNoParte_Ano  
--select * from Temporal_ConcentradoMultasGeneral

if @tipoDatos = 'G' 
	select * from Temporal_ConcentradoMultasGeneral
else
begin
	  if @tipoDatos = 'D' 
		--select Temporal_ConcentradoMultasAgrupadosxNoParte_Ano.noparte, yearimportado, multaapagar --,multatotal, prioridadmulta, saldototal, prioridadsaldo, cantidadTotal, cantidadDesc, cantidadSaldo, UM 
		--from Temporal_ConcentradoMultasAgrupadosxNoParte_Ano
		--inner join Temporal_ConcentradoMultasPrioridad on Temporal_ConcentradoMultasAgrupadosxNoParte_Ano.noparte = Temporal_ConcentradoMultasPrioridad.noparte
	
		select * from  Temporal_ConcentradoMultasAgrupadosxNoParte_Ano 
end
END
GO
