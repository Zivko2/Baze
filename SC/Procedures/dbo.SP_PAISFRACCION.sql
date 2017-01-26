SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PAISFRACCION] (@fed_indiced int)   as

declare @pa_codigo int, @ar_codigo int, @pid_cos_uni decimal(38,6), @ar_fraccion varchar(50), @ar_codigoImp int,
		@CF_TIPOFRACCIONCATETER varchar(1), @ar_codigoMaestro int

declare @paises table(pa_codigo int not null,
                          costototal decimal(38, 6) not null,
                          fraccion varchar(15) not null)

DELETE FROM FACTEXPDETPAISFRACCION where fed_indiced = @fed_indiced

select @CF_TIPOFRACCIONCATETER = CF_TIPOFRACCIONCATETER from configuracion

--Inserta el maximo costo y fraccion con su pais, tanto de no parte descargados como los que no se descargaron
--De los que no se descargaron toma la informacion de catalogo maestro
insert into @paises                          
select pais.pa_codigo, sum(kardesped.kap_cantdesc * pedimpdet.PID_COS_UNIGEN) costoTotal, max(arancel.ar_fraccion) fraccion
from kardesped 
	left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
	left outer join pais on pedimpdet.pa_origen = pais.pa_codigo
	left outer join arancel on pedimpdet.ar_impmx = arancel.ar_codigo
where 	pais.pa_corto not in ('USA','MX','CA') and
	kap_indiced_fact =@fed_indiced
group by pais.pa_codigo, pid_noparte
having sum(kardesped.kap_cantdesc * pedimpdet.PID_COS_UNIGEN) =
		(select  max(a.PID_COS_UNIGEN)PID_COS_UNIGEN 
		  from 
			(select pais.pa_corto,sum(kardesped.kap_cantdesc * pedimpdet.PID_COS_UNIGEN) PID_COS_UNIGEN
			from kardesped 
				left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
				left outer join pais on pedimpdet.pa_origen = pais.pa_codigo
			where 	pais.pa_corto not in ('USA','MX','CA') and
				kap_indiced_fact =@fed_indiced
			group by pa_corto, pid_noparte) a)
union			
select pais.pa_codigo, sum(Kap_CantTotADescargar * 	maestrocost.ma_costo) costoTotal, max(arancel.ar_fraccion) fraccion
from kardesped 
	left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
	left outer join pais on maestro.pa_origen = pais.pa_codigo
	left outer join arancel on maestro.ar_impmx = arancel.ar_codigo
	left outer join factexp on kardesped.kap_factrans = factexp.fe_codigo
	left outer join maestrocost on maestro.ma_codigo = maestrocost.ma_codigo 
								and maestrocost.ma_perini<= factexp.fe_fecha 
								and maestrocost.ma_perfin >= factexp.fe_fecha
where 	pais.pa_corto not in ('USA','MX','CA') and
	kap_indiced_fact =@fed_indiced	and kap_indiced_ped is null
group by pais.pa_codigo, maestro.ma_noparte
having sum(Kap_CantTotADescargar * 	maestrocost.ma_costo) =
		(select  max(a.PID_COS_UNIGEN) PID_COS_UNIGEN 
		  from 
			(select pais.pa_corto,sum(kardesped.Kap_CantTotADescargar * maestrocost.ma_costo) PID_COS_UNIGEN
			from kardesped 
				left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
				left outer join pais on maestro.pa_origen = pais.pa_codigo
				left outer join factexp on kardesped.kap_factrans = factexp.fe_codigo
				left outer join maestrocost on maestro.ma_codigo = maestrocost.ma_codigo 
								and maestrocost.ma_perini<= factexp.fe_fecha 
								and maestrocost.ma_perfin >= factexp.fe_fecha
			where 	pais.pa_corto not in ('USA','MX','CA') and
				kap_indiced_fact =@fed_indiced and kap_indiced_ped is null
			group by pais.pa_corto, maestro.ma_noparte) a)



set @pa_codigo = 0
--Obtiene el pais segun el maximo costo, si hay 2 costos iguales toma el que tenga la maxima fraccion
select @pa_codigo = p.pa_codigo, @pid_cos_uni = p.costototal, @ar_fraccion = p.fraccion 
from @paises p
	inner join (select max(t.costototal) costototal, max(t.fraccion) fraccion from @paises t) x
		on x.costototal = p.costototal and x.fraccion = p.fraccion


set @ar_codigo = 0
--Verifica si la fraccion del PT es igual a la fraccion asignada en configuracion para cateter
--se comento ya que se agrego junto con la condicion de descripcion cateter
/*select @ar_codigo = factexpdet.ar_impfo
  from factexpdet 
  where fed_indiced = @fed_indiced and AR_ImpFO = (select CF_FraccionCateter from configuracion)
*/
--Verifica si existe descripcion con cateter
-- Si es igual a cero, significa que no existe fraccion cateter
if (isnull(@ar_codigo,0) = 0) 
	begin
		if (@CF_TIPOFRACCIONCATETER = 'U')
			begin
			
				--Para USA, aqui verifica si en el BOM se trae un subensamble con CATETER y que la fraccion sea
				--igual que en configuracion, de ser asi esta fraccion es la que se estableceria
				select @ar_codigo = maestro.ar_expfo
				from factexpdet
					left outer join bom_struct on factexpdet.ma_codigo = bom_struct.bsu_subensamble and
													  BOM_STRUCT.BST_PERINI <= fed_fecha_struct AND 
													  BOM_STRUCT.BST_PERFIN >= fed_fecha_struct
					left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
				where fed_indiced = @fed_indiced 
				and (upper(maestro.ma_nombre) like 'CATETER%' or upper(maestro.ma_nombre) like 'CATÉTER%')
				and maestro.ar_expfo in (select CF_FraccionCateter from configuracion)
				--si es cero significa que no hubo ningun subensamble con cateter y con la fraccion igual a configuracion
				--por lo cual hara el calculo con las descargas.
				if @ar_codigo = 0
					begin
						select   @ar_codigo = ar_codigo 
						from arancel 
						where ar_fraccion in
							(select max(arancel.ar_fraccion) ar_fraccion
								from 	kardesped
									left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
									left outer join arancel on pedimpdet.ar_expfo = arancel.ar_codigo
								where 	kap_indiced_fact =@fed_indiced 
								  and (upper(pedimpdet.pid_nombre) like 'CATETER%' or upper(pedimpdet.pid_nombre) like 'CATÉTER%')
							 )
							 and 
							 (select max(arancel.ar_codigo) ar_fraccion
								from 	kardesped
									left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
									left outer join arancel on pedimpdet.ar_expfo = arancel.ar_codigo
								where 	kap_indiced_fact =@fed_indiced 
								  and (upper(pedimpdet.pid_nombre) like 'CATETER%' or upper(pedimpdet.pid_nombre) like 'CATÉTER%')
							 ) = (select CF_FraccionCateter from configuracion)
							 and arancel.ar_tipo = 'I'
						--este se usa para los no de parte que no se descargaron y la informacion la obtiene de catalogo maestro	 
						select   @ar_codigoMaestro = ar_codigo 
						from arancel 
						where ar_fraccion in
							(select max(arancel.ar_fraccion) ar_fraccion
								from 	kardesped
									left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
									left outer join arancel on maestro.ar_expfo = arancel.ar_codigo
								where 	kap_indiced_fact =@fed_indiced and kap_indiced_ped is null
								  and (upper(maestro.ma_nombre) like 'CATETER%' or upper(maestro.ma_nombre) like 'CATÉTER%')
							 )
							 and 
							 (select max(arancel.ar_codigo) ar_fraccion
								from 	kardesped
									left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
									left outer join arancel on maestro.ar_expfo = arancel.ar_codigo
								where 	kap_indiced_fact =@fed_indiced and kap_indiced_ped is null
								  and (upper(maestro.ma_nombre) like 'CATETER%' or upper(maestro.ma_nombre) like 'CATÉTER%')
							 ) = (select CF_FraccionCateter from configuracion)
							 and arancel.ar_tipo = 'I'
							 
							select @ar_codigo = ar_codigo 
							from arancel
							where ar_fraccion in
								(select max(ar_fraccion) from arancel where ar_codigo = @ar_codigo or ar_codigo=@ar_codigoMaestro)
					end
			end
		else
			begin
				if (@CF_TIPOFRACCIONCATETER = 'M')
					begin
						--para mexico, aqui verifica si en el BOM se trae un subensamble con CATETER y que la fraccion sea
						--igual que en configuracion, de ser asi esta fraccion es la que se estableceria
						select @ar_codigo = maestro.ar_impmx
						from factexpdet
							left outer join bom_struct on factexpdet.ma_codigo = bom_struct.bsu_subensamble and
															  BOM_STRUCT.BST_PERINI <= fed_fecha_struct AND 
															  BOM_STRUCT.BST_PERFIN >= fed_fecha_struct
							left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
						where fed_indiced = @fed_indiced 
						and (upper(maestro.ma_nombre) like 'CATETER%' or upper(maestro.ma_nombre) like 'CATÉTER%')
						and maestro.ar_impmx in (select CF_FraccionCateter from configuracion)
						--si es cero significa que no hubo ningun subensamble con cateter y con la fraccion igual a configuracion
						--por lo cual hara el calculo con las descargas.
						if @ar_codigo = 0
							begin
								select   @ar_codigo = ar_codigo 
								from arancel 
								where ar_fraccion in
									(select max(arancel.ar_fraccion) ar_fraccion
										from 	kardesped
											left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
											left outer join arancel on pedimpdet.ar_impmx = arancel.ar_codigo
										where 	kap_indiced_fact =@fed_indiced 
										  and (upper(pedimpdet.pid_nombre) like 'CATETER%' or upper(pedimpdet.pid_nombre) like 'CATÉTER%')
									 )
									 and 
									 (select max(arancel.ar_codigo) ar_fraccion
										from 	kardesped
											left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
											left outer join arancel on pedimpdet.ar_impmx = arancel.ar_codigo
										where 	kap_indiced_fact =@fed_indiced 
										  and (upper(pedimpdet.pid_nombre) like 'CATETER%' or upper(pedimpdet.pid_nombre) like 'CATÉTER%')
									 ) = (select CF_FraccionCateter from configuracion)
								--este query es usado para los no de parte que no fueron descargados y la informacion la obtiene de catalogo maestro
								select   @ar_codigoMaestro = ar_codigo 
								from arancel 
								where ar_fraccion in
									(select max(arancel.ar_fraccion) ar_fraccion
										from 	kardesped
											left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
											left outer join arancel on maestro.ar_impmx = arancel.ar_codigo
										where 	kap_indiced_fact =@fed_indiced and kap_indiced_ped is null
										  and (upper(maestro.ma_nombre) like 'CATETER%' or upper(maestro.ma_nombre) like 'CATÉTER%')
									 )
									 and 
									 (select max(arancel.ar_codigo) ar_fraccion
										from 	kardesped
											left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
											left outer join arancel on maestro.ar_impmx = arancel.ar_codigo
										where 	kap_indiced_fact =@fed_indiced and kap_indiced_ped is null
										  and (upper(maestro.ma_nombre) like 'CATETER%' or upper(maestro.ma_nombre) like 'CATÉTER%')
									 ) = (select CF_FraccionCateter from configuracion)
									 
								select @ar_codigo = ar_codigo 
								from arancel
								where ar_fraccion in
									(select max(ar_fraccion) from arancel where ar_codigo = @ar_codigo or ar_codigo=@ar_codigoMaestro)
							end
							 
					end
			end
	end
--Si es igual a cero, significa que no existen CATETERS ni tampoco la fraccion es igual que la del F6 (configuración)
if (isnull(@ar_codigo,0) = 0) 
	begin
		if (@CF_TIPOFRACCIONCATETER = 'U')
			begin
				select @ar_codigo = ar_codigo from arancel where ar_fraccion =
				(select max(arancel.ar_fraccion) ar_fraccion
				from 	kardesped
					left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
					left outer join arancel on pedimpdet.ar_expfo = arancel.ar_codigo
				where 	kap_indiced_fact =@fed_indiced)		
				--este query es usado para los Nos. de parte que no fueron descargados y la información la obtiene del catalogo maestro.
				select @ar_codigoMaestro = ar_codigo from arancel where ar_fraccion =
				(select max(arancel.ar_fraccion) ar_fraccion
				from 	kardesped
					left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
					left outer join arancel on maestro.ar_expfo = arancel.ar_codigo
				where 	kap_indiced_fact =@fed_indiced and kap_indiced_ped is null)		

				select @ar_codigo = ar_codigo 
				from arancel
				where ar_fraccion in
					(select max(ar_fraccion) from arancel where ar_codigo = @ar_codigo or ar_codigo=@ar_codigoMaestro)
				
				
			end
		else
			begin
				if (@CF_TIPOFRACCIONCATETER = 'M')
					begin
						select @ar_codigo = ar_codigo from arancel where ar_fraccion =
						(select max(arancel.ar_fraccion) ar_fraccion
						from 	kardesped
							left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
							left outer join arancel on pedimpdet.ar_impmx = arancel.ar_codigo
						where 	kap_indiced_fact =@fed_indiced)	
						--este query es usado para los nos. de parte que no fueron descargados y la informacion la obtiene del catalogo maestro
						select @ar_codigoMaestro = ar_codigo from arancel where ar_fraccion =
						(select max(arancel.ar_fraccion) ar_fraccion
						from 	kardesped
							left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
							left outer join arancel on maestro.ar_impmx = arancel.ar_codigo
						where 	kap_indiced_fact =@fed_indiced and kap_indiced_ped is null)		
						
						select @ar_codigo = ar_codigo 
						from arancel
						where ar_fraccion in
							(select max(ar_fraccion) from arancel where ar_codigo = @ar_codigo or ar_codigo=@ar_codigoMaestro)
							
					end
			end
	end
if (isnull(@pa_codigo,0) <> 0 or isnull(@ar_codigo,0) <> 0)
	begin
		--obtiene la fracción de importacion, la cual ya debera existir
		set @ar_codigoImp = 0
		if (@CF_TIPOFRACCIONCATETER = 'U')
			begin
				select @ar_codigoImp = ar_codigo
				from arancel 
				where AR_TIPO = 'I' and ar_fraccion in ( select ar_fraccion from arancel where ar_codigo = @ar_codigo)

				UPDATE FACTEXPDET set AR_impfo  = @ar_codigoImp, PA_CODIGO = @pa_codigo where fed_indiced = @fed_indiced
			end
		else
			if (@CF_TIPOFRACCIONCATETER = 'M')
				begin
					select @ar_codigoImp = ar_codigo
					from arancel 
					where ar_fraccion in ( select ar_fraccion from arancel where ar_codigo = @ar_codigo)
					
					UPDATE FACTEXPDET set AR_ExpMX = @ar_codigoImp, PA_CODIGO = @pa_codigo where fed_indiced = @fed_indiced
				end
		
		print @ar_codigoImp


		-- Si todos los paises son de MX o USA se pone MX y Es Nafta.
		if (@pa_codigo = 0)
			UPDATE FACTEXPDET set PA_CODIGO = (select pa_codigo from pais where pa_corto = 'MX'), FED_NAFTA = 'S' where fed_indiced = @fed_indiced
		
		insert FACTEXPDETPAISFRACCION (fed_indiced, pa_codigo, fpf_costo, ar_codigo, fpf_noparte, fpf_pedimento) 
		select @fed_indiced, pais.pa_codigo, kardesped.kap_cantdesc  * pedimpdet.PID_COS_UNIGEN, arancel.ar_codigo, pedimpdet.pid_noparte, pedimp.pi_folio
		from 	kardesped
			left outer join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced
			left outer join arancel on case when @CF_TIPOFRACCIONCATETER = 'M' then pedimpdet.ar_impmx else pedimpdet.ar_expfo end = arancel.ar_codigo
			left outer join pais on pedimpdet.pa_origen = pais.pa_codigo
			left outer join pedimp on pedimpdet.pi_codigo = pedimp.pi_codigo
		where 	kap_indiced_fact =@fed_indiced and pa_corto is not null and ar_fraccion is not null

		insert FACTEXPDETPAISFRACCION (fed_indiced, pa_codigo, fpf_costo, ar_codigo, fpf_noparte, fpf_pedimento) 
		select @fed_indiced, pais.pa_codigo, kardesped.Kap_CantTotADescargar  * maestroCost.ma_costo, arancel.ar_codigo, 
		maestro.ma_noparte, 'No descargado'
		from 	kardesped
			left outer join maestro on kardesped.ma_hijo = maestro.ma_codigo
			left outer join arancel on case when @CF_TIPOFRACCIONCATETER = 'M' then maestro.ar_impmx else maestro.ar_expfo end = arancel.ar_codigo
			left outer join pais on maestro.pa_origen = pais.pa_codigo
			left outer join factexp on kardesped.kap_factrans = factexp.fe_codigo
			left outer join maestrocost on maestro.ma_codigo = maestrocost.ma_codigo 
								and maestrocost.ma_perini<= factexp.fe_fecha 
								and maestrocost.ma_perfin >= factexp.fe_fecha
		where 	kap_indiced_fact =@fed_indiced and pa_corto is not null and ar_fraccion is not null and kap_indiced_ped is null
		
		insert FACTEXPDETPAISFRACCION (fed_indiced, pa_codigo, fpf_costo, ar_codigo, fpf_noparte, fpf_pedimento) 
		select @fed_indiced, maestro.pa_origen,  isnull((factexpdet.fed_cant * bom_struct.bst_incorpor) * vmaestroCost.ma_costo,0), arancel.ar_codigo,
		maestro.ma_noparte, 'Explosionado'
		from factexpdet
			left outer join bom_struct on factexpdet.ma_codigo = bom_struct.bsu_subensamble and
											  BOM_STRUCT.BST_PERINI <= fed_fecha_struct AND 
											  BOM_STRUCT.BST_PERFIN >= fed_fecha_struct
			left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
			left outer join FACTEXPDETPAISFRACCION on factexpdet.fed_indiced = FACTEXPDETPAISFRACCION.fed_indiced
												   and maestro.ma_noparte = FACTEXPDETPAISFRACCION.fpf_noparte
			left outer join vmaestrocost on maestro.ma_codigo = vmaestroCost.ma_codigo
			left outer join arancel on case when @CF_TIPOFRACCIONCATETER = 'M' then maestro.ar_impmx else maestro.ar_expfo end = arancel.ar_codigo
		where factexpdet.fed_indiced = @fed_indiced  and FACTEXPDETPAISFRACCION.fpf_codigo is null



		
	end
else
	begin
		if (isnull(@pa_codigo,0) = 0)
			UPDATE FACTEXPDET set PA_CODIGO = (select pa_codigo from pais where pa_corto = 'MX'), FED_NAFTA = 'S' where fed_indiced = @fed_indiced
	end
GO
