SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_CALCULASECUENCIAPEDIMP] (@picodigo int, @Sec smallint, @Tipo char(1), @SecResultado smallint output)   as

SET NOCOUNT ON 

Declare @X Int, @OpcionCercana smallint, @Resultado1 smallint, @Resultado2 smallint, @Resultado3 smallint, @Resultado4 smallint, @Resultado5 smallint, @Resultado6 smallint,
@Resultado7 smallint, @Resultado8 smallint, @Resultado9 smallint


	 CREATE TABLE #tabla ( 
		[Descripcion]  varchar(150), 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 



	 CREATE TABLE #tabla2 ( 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 


	 CREATE TABLE #tabla3 ( 
		[TipoTasa]  varchar(1), 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 



	 CREATE TABLE #tabla4 ( 
		[Descripcion]  varchar(150), 
		[TipoTasa]  varchar(1), 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 


	 CREATE TABLE #tabla5 ( 
		[umgen]  int, 
		[TipoTasa]  varchar(1), 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 


	 CREATE TABLE #tabla6 ( 
		[Factura]  int, 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 


	 CREATE TABLE #tabla7 ( 
		[Factura]  int, 
		[fraccion]  varchar(20), 
		[pais]  varchar(20), 
		[TipoTasa]  varchar(1), 
		[Sec]  smallint identity(1,1) 
	 ) ON [PRIMARY] 
	 
	 CREATE TABLE #tabla8 (
		[FolioFactura]	varchar(25),
		[Fid_indiced] int,
		[Sec] smallint identity(1,1)
	) ON [PRIMARY]

	 CREATE TABLE #Resultado ( 
		[Opcion]  smallint, 
		[Resultado]  smallint
	 ) ON [PRIMARY] 



	--print '<==========' + convert(varchar(50), @picodigo) +' --- ' + convert(varchar(50), @Sec) + '==========>' 

	-- por descripcion, fraccion y pais

	if @Tipo=0 or @Tipo=1
	begin
		 truncate table #tabla
		 
		 insert into #tabla(Descripcion, fraccion, pais) 
		 select pid_nombre, ar_fraccion, pa_saaim3  
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
		 group by pid_nombre, ar_fraccion, pa_saaim3  order by pid_nombre, ar_fraccion, pa_saaim3 
		 
		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla  on arancel.ar_fraccion = #tabla.fraccion 
		 and pais.pa_saaim3 = #tabla.pais and pedimpdet.pid_nombre = #tabla.Descripcion 
		 where pi_codigo=@picodigo

		select @Resultado1=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (1, @Resultado1)

	end

	select @Resultado1=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo


	if @Tipo=0 or @Tipo=2
	if @Resultado1<>@Sec 
	begin
		-- por fraccion y pais
		 truncate table #tabla2
		 
		 insert into #tabla2(fraccion, pais) 
		 select ar_fraccion, pa_saaim3  
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
		 group by ar_fraccion, pa_saaim3  order by ar_fraccion, pa_saaim3 


		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla2.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla2  on arancel.ar_fraccion = #tabla2.fraccion 
		 and pais.pa_saaim3 = #tabla2.pais 
		 where pi_codigo=@picodigo

		select @Resultado2=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (2, @Resultado2)

	end

	select @Resultado2=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo



	if @Tipo=0 or @Tipo=3
	if @Resultado2<>@Sec
	begin
		-- por fraccion, pais y tipo de tasa
		 truncate table #tabla3
		 
		 insert into #tabla3(TipoTasa, fraccion, pais) 
		 select pid_def_tip, ar_fraccion, pa_saaim3  
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
		 group by ar_fraccion, pa_saaim3, pid_def_tip  order by ar_fraccion, pa_saaim3, pid_def_tip


		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla3.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla3  on arancel.ar_fraccion = #tabla3.fraccion 
		 and pais.pa_saaim3 = #tabla3.pais and pedimpdet.pid_def_tip = #tabla3.TipoTasa 
		 where pi_codigo=@picodigo


		--if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo)=@Sec
		--EXEC SP_fillpedimpdetB @PICODIGO, 1
		select @Resultado3=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (3, @Resultado3)


	end


	select @Resultado3=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo


	if @Tipo=0 or @Tipo=4
	if @Resultado3<>@Sec
	begin
		-- por descripcion, fraccion, pais y tipo de tasa
		 truncate table #tabla4
		 
		 insert into #tabla4(Descripcion, TipoTasa, fraccion, pais) 
		 select pid_nombre, pid_def_tip, ar_fraccion, pa_saaim3  
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
		 group by pid_nombre, ar_fraccion, pa_saaim3, pid_def_tip  order by pid_nombre, ar_fraccion, pa_saaim3, pid_def_tip
		 
		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla4.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla4  on arancel.ar_fraccion = #tabla4.fraccion 
		 and pais.pa_saaim3 = #tabla4.pais and pedimpdet.pid_def_tip = #tabla4.TipoTasa 
		and pedimpdet.pid_nombre = #tabla4.Descripcion
		 where pi_codigo=@picodigo

		select @Resultado4=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (4, @Resultado4)

		--if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo)=@Sec
		--EXEC SP_fillpedimpdetB @PICODIGO, 1

	end


	select @Resultado4=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo


	
	if @Tipo=0 or @Tipo=5
	if @Resultado4<>@Sec
	begin
		-- por orden de captura
		SET @X=0 	
		Update pedimpdet 
		SET PID_SECUENCIA=@X,@X=@X+1 
		Where pi_codigo=@picodigo


		--if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo)=@Sec
		--EXEC SP_fillpedimpdetB @PICODIGO, 1


		select @Resultado5=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (5, @Resultado5)

	end


	select @Resultado5=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo



	
	if @Tipo=0 or @Tipo=6
	if @Resultado5<>@Sec
	begin
		-- por umgenerico, fraccion, pais y tipo de tasa
		 truncate table #tabla5
		 
		 insert into #tabla5(TipoTasa, fraccion, pais,umgen) 
		 select pid_def_tip, ar_fraccion, pa_saaim3, me_generico
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  
		where pi_codigo=@picodigo
		 group by ar_fraccion, pa_saaim3, pid_def_tip, me_generico  order by ar_fraccion, pa_saaim3, pid_def_tip, me_generico
		 
		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla5.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla5  on arancel.ar_fraccion = #tabla5.fraccion 
		 and pais.pa_saaim3 = #tabla5.pais and pedimpdet.pid_def_tip = #tabla5.TipoTasa 
		and pedimpdet.me_generico = #tabla5.umgen
		 where pi_codigo=@picodigo


		--if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo)=@Sec
		--EXEC SP_fillpedimpdetB @PICODIGO, 1


		select @Resultado6=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (6, @Resultado6)

	end


	select @Resultado6=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo



	if @Tipo=0 or @Tipo=7
	if @Resultado6<>@Sec
	begin
		-- por factura, fraccion y pais 
		 truncate table #tabla6
		 
		 insert into #tabla6(Factura, fraccion, pais) 
		 select pid_codigofact, ar_fraccion, pa_saaim3
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  
		where pi_codigo=@picodigo
		 group by pid_codigofact, ar_fraccion, pa_saaim3  order by pid_codigofact, ar_fraccion, pa_saaim3
		 
		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla6.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla6 on arancel.ar_fraccion = #tabla6.fraccion 
		 and pais.pa_saaim3 = #tabla6.pais 
		and pedimpdet.pid_codigofact = #tabla6.Factura
		 where pi_codigo=@picodigo


		select @Resultado7=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (7, @Resultado7)

	end


	select @Resultado7=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo



	if @Tipo=0 or @Tipo=8
	if @Resultado7<>@Sec
	begin
		-- por factura, fraccion, pais y tipo de tasa
		 truncate table #tabla7
		 
		 insert into #tabla7(Factura, fraccion, pais, TipoTasa) 
		 select pid_codigofact, ar_fraccion, pa_saaim3, pid_def_tip
		 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  
		where pi_codigo=@picodigo
		 group by pid_codigofact, ar_fraccion, pa_saaim3, pid_def_tip  order by pid_codigofact, ar_fraccion, pa_saaim3
		 
		 Update pedimpdet 
		 SET pedimpdet.PID_SECUENCIA=#tabla7.Sec 
		  from pedimpdet left outer join arancel 
		 on pedimpdet.ar_impmx=arancel.ar_codigo  
		 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
		 left outer join #tabla7 on arancel.ar_fraccion = #tabla7.fraccion 
		 and pais.pa_saaim3 = #tabla7.pais and pedimpdet.pid_def_tip = #tabla7.TipoTasa 
		and pedimpdet.pid_codigofact = #tabla7.Factura
		 where pi_codigo=@picodigo


		select @Resultado8=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo

		insert into #Resultado(Opcion, Resultado)
		values (8, @Resultado8)

	end
	
	select @Resultado9=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo
	
	if @Tipo=9
	--if @Resultado9<>@Sec
	begin
		-- por orden alfabetico de factura y orden de captura de las partidas
		truncate table #tabla8
		insert into #tabla8(FolioFactura, Fid_indiced)
		select factimp.fi_folio, factimpdet.fid_indiced
		from pedimpdet
			inner join factimpdet on pedimpdet.pid_indiced = factimpdet.pid_indicedliga
			left outer join factimp on factimpdet.fi_codigo = factimp.fi_codigo
		where pedimpdet.pi_codigo = @picodigo
		order by factimp.fi_folio, factimpdet.fid_indiced			
		
		update pedimpdet set pedimpdet.PID_SECUENCIA = #tabla8.Sec
		from pedimpdet
			inner join factimpdet on pedimpdet.pid_indiced = factimpdet.pid_indicedliga
			left outer join factimp on factimpdet.fi_codigo = factimp.fi_codigo
			left outer join #tabla8 on factimp.fi_folio = #tabla8.FolioFactura and factimpdet.fid_indiced = #tabla8.fid_indiced
		where pedimpdet.pi_codigo = @picodigo
		
		select @Resultado9=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo
		insert into #Resultado(Opcion, Resultado)
		values(9, @Resultado9)
		
	end


	/*================================================================================================================*/
	if @Tipo=0 
	begin
		select @OpcionCercana=opcion from #resultado where abs(@Sec - resultado) in
		(SELECT     MIN(abs(@Sec - resultado)) 
		FROM         #resultado)
	
	
		if @OpcionCercana=1
		begin
			 truncate table #tabla
			 
			 insert into #tabla(Descripcion, fraccion, pais) 
			 select pid_nombre, ar_fraccion, pa_saaim3  
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
			 group by pid_nombre, ar_fraccion, pa_saaim3  order by pid_nombre, ar_fraccion, pa_saaim3 
			 
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla  on arancel.ar_fraccion = #tabla.fraccion 
			 and pais.pa_saaim3 = #tabla.pais and pedimpdet.pid_nombre = #tabla.Descripcion 
			 where pi_codigo=@picodigo
		end
	
	
		if @OpcionCercana=2
		begin
			-- por fraccion y pais
			 truncate table #tabla2
			 
			 insert into #tabla2(fraccion, pais) 
			 select ar_fraccion, pa_saaim3  
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
			 group by ar_fraccion, pa_saaim3  order by ar_fraccion, pa_saaim3 
	
	
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla2.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla2  on arancel.ar_fraccion = #tabla2.fraccion 
			 and pais.pa_saaim3 = #tabla2.pais 
			 where pi_codigo=@picodigo
	
	
		end
	
	
		if @OpcionCercana=3
		begin
			-- por fraccion, pais y tipo de tasa
			 truncate table #tabla3
			 
			 insert into #tabla3(TipoTasa, fraccion, pais) 
			 select pid_def_tip, ar_fraccion, pa_saaim3  
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
			 group by ar_fraccion, pa_saaim3, pid_def_tip  order by ar_fraccion, pa_saaim3, pid_def_tip
	
	
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla3.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla3  on arancel.ar_fraccion = #tabla3.fraccion 
			 and pais.pa_saaim3 = #tabla3.pais and pedimpdet.pid_def_tip = #tabla3.TipoTasa 
			 where pi_codigo=@picodigo
	
	
		end
	
	
	
	
		if @OpcionCercana=4
		begin
			-- por descripcion, fraccion, pais y tipo de tasa
			 truncate table #tabla4
			 
			 insert into #tabla4(Descripcion, TipoTasa, fraccion, pais) 
			 select pid_nombre, pid_def_tip, ar_fraccion, pa_saaim3  
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  where pi_codigo=@picodigo
			 group by pid_nombre, ar_fraccion, pa_saaim3, pid_def_tip  order by pid_nombre, ar_fraccion, pa_saaim3, pid_def_tip
			 
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla4.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla4  on arancel.ar_fraccion = #tabla4.fraccion 
			 and pais.pa_saaim3 = #tabla4.pais and pedimpdet.pid_def_tip = #tabla4.TipoTasa 
			and pedimpdet.pid_nombre = #tabla4.Descripcion
			 where pi_codigo=@picodigo
	
		end
	
	
		if @OpcionCercana=5
		begin
			-- por orden de captura
			SET @X=0 	
			Update pedimpdet 
			SET PID_SECUENCIA=@X,@X=@X+1 
			Where pi_codigo=@picodigo
	
	
			--if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo)=@Sec
			--EXEC SP_fillpedimpdetB @PICODIGO, 1
	
		end	



		if @OpcionCercana=6
		begin
			-- por umgenerico, fraccion, pais y tipo de tasa
			 truncate table #tabla5
			 
			 insert into #tabla5(TipoTasa, fraccion, pais,umgen) 
			 select pid_def_tip, ar_fraccion, pa_saaim3, me_generico
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  
			where pi_codigo=@picodigo
			 group by ar_fraccion, pa_saaim3, pid_def_tip, me_generico  order by ar_fraccion, pa_saaim3, pid_def_tip, me_generico
			 
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla5.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla5  on arancel.ar_fraccion = #tabla5.fraccion 
			 and pais.pa_saaim3 = #tabla5.pais and pedimpdet.pid_def_tip = #tabla5.TipoTasa 
			and pedimpdet.me_generico = #tabla5.umgen
			 where pi_codigo=@picodigo


			--if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo)=@Sec
			--EXEC SP_fillpedimpdetB @PICODIGO, 1
	
		end



		if @OpcionCercana=7
		begin
			-- por factura, fraccion y pais 
			 truncate table #tabla6
			 
			 insert into #tabla6(Factura, fraccion, pais) 
			 select pid_codigofact, ar_fraccion, pa_saaim3
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  
			where pi_codigo=@picodigo
			 group by pid_codigofact, ar_fraccion, pa_saaim3  order by pid_codigofact, ar_fraccion, pa_saaim3
			 
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla6.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla6 on arancel.ar_fraccion = #tabla6.fraccion 
			 and pais.pa_saaim3 = #tabla6.pais 
			and pedimpdet.pid_codigofact = #tabla6.Factura
			 where pi_codigo=@picodigo
	
		end
	
	

	
		if @OpcionCercana=8
		begin
			-- por factura, fraccion, pais y tipo de tasa
			 truncate table #tabla7
			 
			 insert into #tabla7(Factura, fraccion, pais, TipoTasa) 
			 select pid_codigofact, ar_fraccion, pa_saaim3, pid_def_tip
			 from pedimpdet left outer join arancel on pedimpdet.ar_impmx=arancel.ar_codigo 
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo  
			where pi_codigo=@picodigo
			 group by pid_codigofact, ar_fraccion, pa_saaim3, pid_def_tip  order by pid_codigofact, ar_fraccion, pa_saaim3
			 
			 Update pedimpdet 
			 SET pedimpdet.PID_SECUENCIA=#tabla7.Sec 
			  from pedimpdet left outer join arancel 
			 on pedimpdet.ar_impmx=arancel.ar_codigo  
			 left outer join pais on pedimpdet.pa_origen=pais.pa_codigo 
			 left outer join #tabla7 on arancel.ar_fraccion = #tabla7.fraccion 
			 and pais.pa_saaim3 = #tabla7.pais and pedimpdet.pid_def_tip = #tabla7.TipoTasa 
			and pedimpdet.pid_codigofact = #tabla7.Factura
			 where pi_codigo=@picodigo
	
	
		end	
		
		
	end






	/*=======================================================================================================*/


	if (select max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo) <> @Sec
	   select @SecResultado=max(PID_SECUENCIA) from pedimpdet where pi_codigo=@picodigo
	else	
	   set @SecResultado= 0

	drop table #resultado
	drop table #tabla 
	drop table #tabla2
	drop table #tabla3
	drop table #tabla4
	drop table #tabla5
	drop table #tabla6
	drop table #tabla7
GO
