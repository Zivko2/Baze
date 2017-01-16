SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_IMPORTBOM] (@TipoActualizacion char(1), @BorraBomAnterior char(1), @ActualizaTipo char(1), @sumaIncorpor char(1), @USER INT)   as

DECLARE @BST_HIJO int, @BSU_SUBENSAMBLE int, @TI_CODIGO int, @ME_CODIGO int, 
@Factconv decimal(28,14), @BST_PERINI datetime, @BST_PERFIN datetime, @ME_GEN int, @BST_TRANS char(1), @BSU_NOPARTE varchar(30), 
@BST_NOPARTE varchar(30),  @PA_CODIGO int, @BST_PERCAMBIO char(1), @BSU_NOPARTEAUX varchar(10), @BST_NOPARTEAUX varchar(10),
@BST_DISCH CHAR(1), @BST_INCORPOR decimal(38,6), @BST_TIP_ENS char(1), @AR_IMPFO INT, @MA_PESO_KG decimal(38,6),
@maximo int
--Yolanda Avila
--2011-05-16
,@fechaFinal datetime
--@countbom int

declare @valor int, @valorini int, @contador smallint, @valorfin int
--no debe borrar todos los registros, solo los que pertenecen al usuario activo Manuel G. 02-Mar-11
--TRUNCATE TABLE REGISTROSIMPORTADOS 
delete from REGISTROSIMPORTADOS where RI_UserId = @user

UPDATE IMPORTTEMPBOM
SET BST_PERINI='01/01/1990'
WHERE BST_PERINI IS NULL

UPDATE IMPORTTEMPBOM
SET BST_PERFIN='01/01/9999'
WHERE BST_PERFIN IS NULL

UPDATE IMPORTTEMPBOM
SET BST_SEC=-1
WHERE BST_SEC IS NULL


	if @TipoActualizacion='H' -- con historial 
	begin
		update IMPORTTEMPBOM
		set BST_PERCAMBIO='N'
	end
	else -- 'C' -- solo cambios
	begin
		update IMPORTTEMPBOM
		set BST_PERCAMBIO='S'
	end




if not exists (select * from bom_struct)
dbcc checkident (BOM_STRUCT,reseed,0) WITH NO_INFOMSGS

	--print 'genera la vista con suma de incorporacion o no'
	exec SP_CREAVIMPORTTEMPBOM @sumaIncorpor, @TipoActualizacion


	if (select count(*) from VIMPORTTEMPBOM)>0 
	begin

		if @BorraBomAnterior='S' 
		begin
				-- la diferencia de @BorraBomAnterior a sin historial, es que el borra bom anterior borra toda la estructura del producto incluido en el archivo y el
				-- sin historial borra solo los componentes incluidos en el archivo a importar
			alter table BOM_STRUCT disable trigger [DELETE_BOM_STRUCT]
	
				delete from bom_struct where bsu_subensamble in (SELECT MA_CODIGO FROM MAESTRO RIGHT OUTER JOIN 
			                                           VIMPORTTEMPBOM ON BSU_NOPARTE=MA_NOPARTE AND BSU_NOPARTEAUX=MA_NOPARTEAUX)
	
	
				Delete from bom where ma_subensamble not in (select bsu_subensamble from bom_struct group by bsu_subensamble)
	
			alter table BOM_STRUCT enable trigger [DELETE_BOM_STRUCT]
	
	
			
		end
	

		print 'Inserta en la tabla registros importados'
	       	 INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO,RI_TIPO, RI_CBFORMA, RI_USERID) 
		SELECT 'BOM (ESTRUCTURA) DEL NO. PARTE = '+BSU_NOPARTE, 'A', 18, @USER
		FROM VIMPORTTEMPBOM GROUP BY BSU_NOPARTE

            if exists (select * from sysobjects where name='sysusrlog64')                
 		BEGIN 
                	insert into sysusrlog64 (user_id, mov_id, referencia, frmtag, fechahora) 
   			SELECT @USER,1,' IMPORTADOR - BOM (ESTRUCTURA) DEL NO. PARTE = '+BSU_NOPARTE, 64, getDate()
			FROM VIMPORTTEMPBOM GROUP BY BSU_NOPARTE
		END

		print 'generando tabla maximo'
		exec sp_droptable 'maximo'

		select max(bst_codigo) as bst_codigo, bst_hijo, bsu_subensamble, bst_sec
		into dbo.maximo
		from bom_struct 
		group by bst_hijo, bsu_subensamble, bst_sec

	


		/* ======================================== solo Cambios sin Secuencia ===============================================*/		
		if(SELECT CF_USABOMSEC FROM CONFIGURACION)<>'S'
		begin
		-- actualiza antes los registros que no vienen en el archivo y que estan en la tabla
		-- para que se vuelvan obsoletos, si lo hiciera despues dele procedimiento de borrado podrian tambien
		--obsoletos los que no sufrieron cambios


			if (select CF_BOMBORRANOINCLUIDO from configuracion)='S'
			begin
				print 'actualiza la fecha final de los registros no incluidos en el archivo'
				--Yolanda Avila
				--2011-05-16
				--Aqui debe modificarse para que en el registro del BOM_struct asigne como fecha final un dia antes de la fecha inicial del archivo temporal
				set @fechaFinal = 	case when (select count(*) from (select bst_perini from ImportTempBom group by bst_perini) temp) > 1 then convert(varchar(10),getdate()-1,101)
										else
											(select bst_perini-1 from ImportTempBom group by bst_perini)
									end				


				--Yolanda Avila
				--2011-05-16
				update bom_struct



				--set bst_perfin=convert(varchar(10),getdate()-1,101)--(select min(ImportTempBom1.bst_perini-1) from ImportTempBom as ImportTempBom1 where ImportTempBom1.bsu_noparte =bom_struct.bsu_noparte)
				set bst_perfin = @fechaFinal
				from bom_struct
				where bst_noparte+'-'+bst_noparteaux not in (select vImportTempBom.bst_noparte+'-'+vImportTempBom.bst_noparteaux from vImportTempBom where vImportTempBom.bsu_noparte=bom_struct.bsu_noparte and vImportTempBom.bsu_noparteaux=bom_struct.bsu_noparteaux)
				and bsu_noparte+'-'+bsu_noparteaux in (select vImportTempBom1.bsu_noparte+'-'+vImportTempBom1.bsu_noparteaux from vImportTempBom vImportTempBom1 group by vImportTempBom1.bsu_noparte, vImportTempBom1.bsu_noparteaux)
		  		and bst_codigo in (select bom_struct1.bst_codigo
		 		         from maximo bom_struct1 where bom_struct1.bst_hijo=bom_struct.bst_hijo and bom_struct1.bsu_subensamble=bom_struct.bsu_subensamble)
				--Yolanda Avila
				--2011-05-16
				--and bst_perini<=getdate() and bst_perfin>=getdate()
				and bst_perini<=dateadd(day, 1,@fechaFinal) and bst_perfin>=dateadd(day, 1,@fechaFinal)
	
			end
		
		
			print 'borra los registros que vienen en el archivo y que ya estan en la tabla de bom_struct'	
			DELETE     VIMPORTTEMPBOM
			FROM         VIMPORTTEMPBOM INNER JOIN
			                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
			                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
			                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
			                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR 
	
		
			print ' actualiza la ultima fecha de modificacion'
			UPDATE MAESTRO
			SET MA_ULTIMAMODIF=GETDATE()
			WHERE MA_NOPARTE+'-'+MA_NOPARTEAUX IN (SELECT BSU_NOPARTE+'-'+BSU_NOPARTEAUX FROM VIMPORTTEMPBOM GROUP BY BSU_NOPARTE+'-'+BSU_NOPARTEAUX)
		
		
			ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [INSERT_BOM_STRUCT]
			ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [UPDATE_BOM_STRUCT]
		
		
	
			if (select count(*) from VIMPORTTEMPBOM)>0 
			if (select count(*) from VIMPORTTEMPBOM where VIMPORTTEMPBOM.bsu_noparte+VIMPORTTEMPBOM.bsu_noparteaux+VIMPORTTEMPBOM.bst_noparte+VIMPORTTEMPBOM.bst_noparteaux
			     not in (select bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux from bom_struct 
				     where bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux is not null
				     group by bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux))>0
			begin 
			
				print 'inserta si no existe la relacion padre hijo hace la insercion'
				insert bom_struct (BST_HIJO, BSU_SUBENSAMBLE, ME_CODIGO, FACTCONV, BST_PERINI, 
					BST_PERFIN, ME_GEN, BST_TRANS, BSU_NOPARTE, 
				        BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_DISCH,
				BST_INCORPOR, BST_TIP_ENS,  BST_SEC)
			
				SELECT     BST_HIJO, BSU_SUBENSAMBLE, ME_CODIGO, FACTCONV, BST_PERINI, 
					BST_PERFIN, ME_GEN, BST_TRANS, BSU_NOPARTE, 
				        BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_DISCH,
				MAX(BST_INCORPOR), BST_TIP_ENS, 0
				FROM         dbo.VIMPORTTEMPBOM
				WHERE BST_INCORPOR>0  and VIMPORTTEMPBOM.BSU_NOPARTE+VIMPORTTEMPBOM.BSU_NOPARTEAUX+VIMPORTTEMPBOM.BST_NOPARTE+VIMPORTTEMPBOM.BST_NOPARTEAUX not in
				(select bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux from bom_struct 
				 where bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux is not null
				 group by bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux)
				GROUP BY   BST_HIJO, BSU_SUBENSAMBLE, ME_CODIGO, FACTCONV, BST_PERINI, 
					BST_PERFIN, ME_GEN, BST_TRANS, BSU_NOPARTE, 
				        BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_DISCH,
				BST_TIP_ENS
				ORDER BY BST_PERINI, BST_PERFIN
		
		
				print 'borra los registros que vienen en el archivo y que ya estan en la tabla de bom_struct'
				DELETE     VIMPORTTEMPBOM
				FROM         VIMPORTTEMPBOM INNER JOIN
				                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERINI >= BOM_STRUCT.BST_PERINI AND 
				                      VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
				                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
				                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
				                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR
				
			end
		
		

			if (select count(*) from VIMPORTTEMPBOM)>0 	
			if @TipoActualizacion='C' -- solo cambios
			begin
	
				print 'generando tabla maximo2'
				exec sp_droptable 'maximo'
		
				select max(bst_codigo) as bst_codigo, bst_hijo, bsu_subensamble, max(bst_sec) as bst_sec
				into dbo.maximo
				from bom_struct 
				where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux in
					    (select bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux 
					     from VIMPORTTEMPBOM
					     where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux is not null)
				group by bst_hijo, bsu_subensamble
	
	
				-- se toma la fecha inicial de los maximos (relacion pt-componente de la tabla bom_struct union con la tabla VIMPORTTEMPBOM)
				exec sp_droptable 'Tempfechafin'
				select bst_codigo, (select bst_perini from vimporttempbom where vimporttempbom.bst_noparte+vimporttempbom.bst_noparteaux=bom_struct.bst_noparte+bom_struct.bst_noparteaux and vimporttempbom.bsu_noparte+vimporttempbom.bsu_noparteaux=bom_struct.bsu_noparte+bom_struct.bsu_noparteaux) as bst_perini
				into dbo.Tempfechafin
				from bom_struct
				where bst_codigo in (select bom_struct1.bst_codigo
		 		         from maximo bom_struct1 where bom_struct1.bst_hijo=bom_struct.bst_hijo and bom_struct1.bsu_subensamble=bom_struct.bsu_subensamble
					and bom_struct1.bst_codigo is not null
					/*and bst_perfin >= getdate()*/)
	
	
				update	Tempfechafin
				set bst_perini=getdate()
				where bst_perini='01/01/1999'
				
				-- se actualiza a la fecha de ayer 
				if (select count(*) from Tempfechafin)>500
				begin
					select @valor= round((max(bst_codigo)/20),0)+1 from Tempfechafin
					set @contador=1
					select @valorini =min(bst_codigo) from Tempfechafin			
				
					WHILE (@contador<=20) 
					BEGIN				
						set @valorfin=@valorini+@valor
				
						update bom_struct
						set bom_struct.bst_perfin=Tempfechafin.bst_perini-1
						from bom_struct inner join Tempfechafin on bom_struct.bst_codigo=Tempfechafin.bst_codigo
						where bom_struct.bst_codigo>=@valorini and bom_struct.bst_codigo<=@valorfin
						--Yolanda Avila
						--2011-05-16
						--Solo debe cerrar las fecha siempre y cuando esten en el rango del nuevo registro
						and bom_struct.bst_perfin>=Tempfechafin.bst_perini

						set @contador=@contador+1
						set @valorini=@valorfin+1
				
					END				
				
				end
				else
					update bom_struct
					set bom_struct.bst_perfin=Tempfechafin.bst_perini-1
					from bom_struct inner join Tempfechafin on bom_struct.bst_codigo=Tempfechafin.bst_codigo
					--Yolanda Avila
					--2011-05-16
					--Solo debe cerrar las fecha siempre y cuando esten en el rango del nuevo registro
					where bom_struct.bst_perfin>=Tempfechafin.bst_perini
	
				exec sp_droptable 'Tempfechafin'
	
					print 'si la fecha final viene menor que la fecha que tiene significa que quieren borrarlo (actualizarle la fecha final)'
					update bom_struct
					set bom_struct.bst_perfin=VIMPORTTEMPBOM.bst_perfin
					from bom_struct inner join VIMPORTTEMPBOM on
						bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
						bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
						bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini 
					where bom_struct.bst_perfin>VIMPORTTEMPBOM.bst_perfin 
					and bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux+convert(varchar(10),bom_struct.bst_perini,101)+ convert(varchar(10),VIMPORTTEMPBOM.bst_perfin,101)
					not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101) 
						from bom_struct bom_struct1
						where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101) is not null)
			
					print 'actualiza todos los campos de los registros cuyas fechas coninciden'		
					update bom_struct
					SET bom_struct.BST_INCORPOR = VIMPORTTEMPBOM.BST_INCORPOR,
					    bom_struct.ME_GEN = VIMPORTTEMPBOM.ME_GEN, 
					    bom_struct.BST_TRANS = VIMPORTTEMPBOM.BST_TRANS,
					    bom_struct.ME_CODIGO =VIMPORTTEMPBOM.ME_CODIGO, 
					    bom_struct.FACTCONV =VIMPORTTEMPBOM.FACTCONV,
					    bom_struct.BST_TIP_ENS =VIMPORTTEMPBOM.BST_TIP_ENS
					from bom_struct inner join VIMPORTTEMPBOM on
						bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
						bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
						bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini and
						bom_struct.bst_perfin=VIMPORTTEMPBOM.bst_perfin 
					where bom_struct.bst_codigo=(select bom_struct1.bst_codigo
			 		         from maximo bom_struct1 
						 where bom_struct1.bst_hijo=bom_struct.bst_hijo and bom_struct1.bsu_subensamble=bom_struct.bsu_subensamble
						 and bom_struct1.bst_codigo is not null)
			
			
				if (select count(*) from VIMPORTTEMPBOM)>500
				begin
					--select @valor= round(count(*)/20,0)+1 from VIMPORTTEMPBOM	
					select @valor= round((max(consecutivo)/20),0)+1 from VIMPORTTEMPBOM
					set @contador=1
					select @valorini =min(consecutivo) from VIMPORTTEMPBOM			
				
					WHILE (@contador<=20) 
					BEGIN				
						set @valorfin=@valorini+@valor
	
	
					 	        INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
							BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
						        ME_GEN, BST_INCORPOR,BST_TIP_ENS)
							select BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
								BST_NOPARTE,BST_NOPARTEAUX, 'BST_PerINI'=case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						 		         from bom_struct bom_struct1 where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble)
							       then convert(varchar(10),getdate()-1,101) else BST_PerINI end,
							       BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
							        ME_GEN, BST_INCORPOR, BST_TIP_ENS
							from VIMPORTTEMPBOM
							where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(10),(case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						 		         from bom_struct bom_struct1 where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble)
							       then convert(varchar(10),getdate()-1,101) else BST_PerINI end),101)+ convert(varchar(10),bst_perfin,101)
							not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101) 
							from bom_struct bom_struct1
							where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101) is not null)
							and VIMPORTTEMPBOM.consecutivo>=@valorini and  VIMPORTTEMPBOM.consecutivo<=@valorfin
								
		
						set @contador=@contador+1
						set @valorini=@valorfin+1
				
					END				
				
				end
				else
					INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
					BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
					ME_GEN, BST_INCORPOR, BST_TIP_ENS)
					select BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
						BST_NOPARTE,BST_NOPARTEAUX, 'BST_PerINI'=case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						from bom_struct bom_struct1 where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble)
						then convert(varchar(10),getdate()-1,101) else BST_PerINI end,
						BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
						ME_GEN, BST_INCORPOR, BST_TIP_ENS
					from VIMPORTTEMPBOM
					where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(10),(case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						from bom_struct bom_struct1 where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble)
						then convert(varchar(10),getdate()-1,101) else BST_PerINI end),101)+ convert(varchar(10),bst_perfin,101)
					not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101) 
						from bom_struct bom_struct1
						where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101) is not null)
			
			
		
			end
		
		end	


		/* ======================================== solo Cambios con Secuencia ===============================================*/		
		if(SELECT CF_USABOMSEC FROM CONFIGURACION)='S'
		begin
		-- actualiza antes los registros que no vienen en el archivo y que estan en la tabla
		-- para que se vuelvan obsoletos, si lo hiciera despues dele procedimiento de borrado podrian tambien
		--obsoletos los que no sufrieron cambios


			if (select CF_BOMBORRANOINCLUIDO from configuracion)='S'
			begin
				print 'actualiza la fecha final de los registros no incluidos en el archivo'
				--Yolanda Avila
				--2011-05-16
				--Aqui debe modificarse para que en el registro del BOM_struct asigne como fecha final un dia antes de la fecha inicial del archivo temporal
				set @fechaFinal = 	case when (select count(*) from (select bst_perini from ImportTempBom group by bst_perini) temp) > 1 then convert(varchar(10),getdate()-1,101)
										else
											(select bst_perini-1 from ImportTempBom group by bst_perini)
									end				


				--Yolanda Avila
				--2011-05-16
				update bom_struct


				--set bst_perfin=convert(varchar(10),getdate()-1,101)--(select min(ImportTempBom1.bst_perini-1) from ImportTempBom as ImportTempBom1 where ImportTempBom1.bsu_noparte =bom_struct.bsu_noparte)
				set bst_perfin = @fechaFinal
				from bom_struct
				where bst_noparte+bst_noparteaux not in (select vImportTempBom.bst_noparte+vImportTempBom.bst_noparteaux from vImportTempBom where vImportTempBom.bsu_noparte+vImportTempBom.bsu_noparteaux=bom_struct.bsu_noparte+bom_struct.bsu_noparteaux and vImportTempBom.bst_sec=bom_struct.bst_sec and vImportTempBom.bst_noparte+vImportTempBom.bst_noparteaux is not null)
				and bsu_noparte in (select vImportTempBom1.bsu_noparte from vImportTempBom vImportTempBom1 where vImportTempBom1.bsu_noparte is not null group by vImportTempBom1.bsu_noparte)
		  		and bst_codigo=(select bom_struct1.bst_codigo
		 		         from maximo bom_struct1 where bom_struct1.bst_hijo=bom_struct.bst_hijo and bom_struct1.bsu_subensamble=bom_struct.bsu_subensamble and bom_struct1.bst_sec=bom_struct.bst_sec)
				--Yolanda Avila
				--2011-05-16						 		         
				--and bst_perini<=getdate() and bst_perfin>=getdate()
				and bst_perini<=dateadd(day, 1,@fechaFinal) and bst_perfin>=dateadd(day, 1,@fechaFinal)

			end
		
		
			print 'borra los registros que vienen en el archivo y que ya estan en la tabla de bom_struct'	
			DELETE     VIMPORTTEMPBOM
			FROM         VIMPORTTEMPBOM INNER JOIN
			                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
				         VIMPORTTEMPBOM.BST_SEC = BOM_STRUCT.BST_SEC AND 
			                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
			                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
			                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR
	
		
			print ' actualiza la ultima fecha de modificacion'
			UPDATE MAESTRO
			SET MA_ULTIMAMODIF=GETDATE()
			WHERE MA_NOPARTE+MA_NOPARTEAUX IN (SELECT BSU_NOPARTE+BSU_NOPARTEAUX FROM VIMPORTTEMPBOM WHERE BSU_NOPARTE+BSU_NOPARTEAUX IS NOT NULL GROUP BY BSU_NOPARTE+BSU_NOPARTEAUX)
		
		
			ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [INSERT_BOM_STRUCT]
			ALTER TABLE [BOM_STRUCT] DISABLE TRIGGER [UPDATE_BOM_STRUCT]
		
		
	
			if (select count(*) from VIMPORTTEMPBOM)>0 
			if (select count(*) from VIMPORTTEMPBOM where VIMPORTTEMPBOM.bsu_noparte+VIMPORTTEMPBOM.bsu_noparteaux+VIMPORTTEMPBOM.bst_noparte+VIMPORTTEMPBOM.bst_noparteaux+convert(varchar(50),VIMPORTTEMPBOM.bst_sec)
		  	   not in (select bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux+convert(varchar(50),bom_struct.bst_sec)
			   from bom_struct 
			   where bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux+convert(varchar(50),bom_struct.bst_sec) is not null
			   group by bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux+convert(varchar(50),bom_struct.bst_sec)))>0
			begin 
			
				print 'inserta si no existe la relacion padre hijo hace la insercion'
				insert bom_struct (BST_HIJO, BSU_SUBENSAMBLE, ME_CODIGO, FACTCONV, BST_PERINI, 
					BST_PERFIN, ME_GEN, BST_TRANS, BSU_NOPARTE, 
				        BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_DISCH,
				BST_INCORPOR, BST_TIP_ENS, BST_SEC)
			
				SELECT     BST_HIJO, BSU_SUBENSAMBLE, ME_CODIGO, FACTCONV, BST_PERINI, 
					BST_PERFIN, ME_GEN, BST_TRANS, BSU_NOPARTE, 
				        BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_DISCH,
				MAX(BST_INCORPOR), BST_TIP_ENS, BST_SEC
				FROM         dbo.VIMPORTTEMPBOM
				WHERE BST_INCORPOR>0  and VIMPORTTEMPBOM.BSU_NOPARTE+VIMPORTTEMPBOM.BSU_NOPARTEAUX+VIMPORTTEMPBOM.BST_NOPARTE+VIMPORTTEMPBOM.BST_NOPARTEAUX not in
					(select bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux 
					from bom_struct 
					where bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux is not null
					group by bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux)
				GROUP BY   BST_HIJO, BSU_SUBENSAMBLE, ME_CODIGO, FACTCONV, BST_PERINI, 
					BST_PERFIN, ME_GEN, BST_TRANS, BSU_NOPARTE, 
				        BST_NOPARTE, PA_CODIGO, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_DISCH,
				BST_TIP_ENS, MA_PESO_KG, AR_IMPFO, BST_SEC
				ORDER BY BST_PERINI, BST_PERFIN
		
		
				print 'borra los registros que vienen en el archivo y que ya estan en la tabla de bom_struct'
				DELETE     VIMPORTTEMPBOM
				FROM         VIMPORTTEMPBOM INNER JOIN
				                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERINI >= BOM_STRUCT.BST_PERINI AND 
				                      VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
				                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
				                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
				                      VIMPORTTEMPBOM.BST_SEC = BOM_STRUCT.BST_SEC AND 
				                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR
				
			end
		
		

			if (select count(*) from VIMPORTTEMPBOM)>0 	
			if @TipoActualizacion='C' -- solo cambios
			begin
	
				print 'generando tabla maximo2'
				exec sp_droptable 'maximo'
		
				select max(bst_codigo) as bst_codigo, bst_hijo, bsu_subensamble, bst_sec
				into dbo.maximo
				from bom_struct 
				where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(50),bst_sec) in
					    (select bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(50),bst_sec) 
					     from VIMPORTTEMPBOM
					     where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(50),bst_sec) is not null)
				group by bst_hijo, bsu_subensamble, bst_sec

				
					-- se toma la fecha inicial de los maximos (relacion pt-componente de la tabla bom_struct union con la tabla VIMPORTTEMPBOM)
				exec sp_droptable 'Tempfechafin'
				select bst_codigo, (select bst_perini from vimporttempbom where vimporttempbom.bst_noparte+vimporttempbom.bst_noparteaux=bom_struct.bst_noparte+bom_struct.bst_noparteaux and vimporttempbom.bsu_noparte+vimporttempbom.bsu_noparteaux=bom_struct.bsu_noparte+bom_struct.bsu_noparteaux and vimporttempbom.bst_sec=bom_struct.bst_sec) as bst_perini
				into dbo.Tempfechafin
				from bom_struct
				where bst_codigo in (select bom_struct1.bst_codigo
		 		         from maximo bom_struct1 where bom_struct1.bst_hijo=bom_struct.bst_hijo and bom_struct1.bsu_subensamble=bom_struct.bsu_subensamble and bom_struct1.bst_sec=bom_struct.bst_sec
					and bom_struct1.bst_codigo is not null and bst_perfin >= getdate())
	
	
				update	Tempfechafin
				set bst_perini=getdate()
				where bst_perini='01/01/1999'
				
				-- se actualiza a la fecha de ayer 
				if (select count(*) from Tempfechafin)>500
				begin
					select @valor= round((max(bst_codigo)/20),0)+1 from Tempfechafin
					set @contador=1
					select @valorini =min(bst_codigo) from Tempfechafin			
				
					WHILE (@contador<=20) 
					BEGIN				
						set @valorfin=@valorini+@valor
			
						update bom_struct
						set bom_struct.bst_perfin=Tempfechafin.bst_perini-1
						from bom_struct inner join Tempfechafin on bom_struct.bst_codigo=Tempfechafin.bst_codigo
						where bom_struct.bst_codigo>=@valorini and bom_struct.bst_codigo<=@valorfin
						--Yolanda Avila
						--2011-05-16
						--Solo debe cerrar las fecha siempre y cuando esten en el rango del nuevo registro
						and bom_struct.bst_perfin>=Tempfechafin.bst_perini
		
						set @contador=@contador+1
						set @valorini=@valorfin+1
				
					END				
				
				end
				else
					update bom_struct
					set bom_struct.bst_perfin=Tempfechafin.bst_perini-1
					from bom_struct inner join Tempfechafin on bom_struct.bst_codigo=Tempfechafin.bst_codigo
					--Yolanda Avila
					--2011-05-16
					--Solo debe cerrar las fecha siempre y cuando esten en el rango del nuevo registro
					where bom_struct.bst_perfin>=Tempfechafin.bst_perini					
	
				exec sp_droptable 'Tempfechafin'
	
					print 'si la fecha final viene menor que la fecha que tiene significa que quieren borrarlo (actualizarle la fecha final)'
					update bom_struct
					set bom_struct.bst_perfin=VIMPORTTEMPBOM.bst_perfin
					from bom_struct inner join VIMPORTTEMPBOM on
						bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
						bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
						bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini and
						bom_struct.bst_sec=VIMPORTTEMPBOM.bst_sec 
					where bom_struct.bst_perfin>VIMPORTTEMPBOM.bst_perfin 
					and bom_struct.bsu_noparte+bom_struct.bsu_noparteaux+bom_struct.bst_noparte+bom_struct.bst_noparteaux+convert(varchar(10),bom_struct.bst_perini,101)+ convert(varchar(10),VIMPORTTEMPBOM.bst_perfin,101)+ convert(varchar(50),VIMPORTTEMPBOM.bst_sec)
					not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+ convert(varchar(50),VIMPORTTEMPBOM.bst_sec) 
						from bom_struct bom_struct1 
						where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux=VIMPORTTEMPBOM.bsu_noparte+VIMPORTTEMPBOM.bsu_noparteaux and
						bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+ convert(varchar(50),VIMPORTTEMPBOM.bst_sec) is not null)
			
					print 'actualiza todos los campos de los registros cuyas fechas coninciden'		
					update bom_struct
					SET bom_struct.BST_INCORPOR = VIMPORTTEMPBOM.BST_INCORPOR,
					    bom_struct.ME_GEN = VIMPORTTEMPBOM.ME_GEN, 
					    bom_struct.BST_TRANS = VIMPORTTEMPBOM.BST_TRANS,
					    bom_struct.ME_CODIGO =VIMPORTTEMPBOM.ME_CODIGO, 
					    bom_struct.FACTCONV =VIMPORTTEMPBOM.FACTCONV,
					    bom_struct.BST_TIP_ENS =VIMPORTTEMPBOM.BST_TIP_ENS
					from bom_struct inner join VIMPORTTEMPBOM on
						bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
						bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
						bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini and
						bom_struct.bst_sec=VIMPORTTEMPBOM.bst_sec and
						bom_struct.bst_perfin=VIMPORTTEMPBOM.bst_perfin 
					where bom_struct.bst_codigo=(select bom_struct1.bst_codigo
			 		         from maximo bom_struct1 
						where bom_struct1.bst_hijo=bom_struct.bst_hijo and bom_struct1.bsu_subensamble=bom_struct.bsu_subensamble and bom_struct1.bst_sec=bom_struct.bst_sec and
						bom_struct1.bst_codigo is not null)
			/*
			
				if (select count(*) from VIMPORTTEMPBOM)>500
				begin
					--select @valor= round(count(*)/20,0)+1 from VIMPORTTEMPBOM	
					select @valor= round((max(consecutivo)/20),0)+1 from VIMPORTTEMPBOM
					set @contador=1
					select @valorini =min(consecutivo) from VIMPORTTEMPBOM			
				
					WHILE (@contador<=20) 
					BEGIN				
						set @valorfin=@valorini+@valor
	
	
					 	        INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
							BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
						        ME_GEN, PA_CODIGO,BST_INCORPOR,BST_MERMA,BST_DESP,BST_TIP_ENS,AR_CODIGO, BST_PESO_KG)
							select BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
								BST_NOPARTE,BST_NOPARTEAUX, 'BST_PerINI'=case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						 		         from bom_struct bom_struct1 where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble and bom_struct1.bst_sec=VIMPORTTEMPBOM.bst_sec)
							       then convert(varchar(10),getdate()-1,101) else BST_PerINI end,
							       BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
							        ME_GEN, PA_CODIGO,BST_INCORPOR,BST_MERMA,BST_DESP,BST_TIP_ENS, AR_IMPFO, MA_PESO_KG
							from VIMPORTTEMPBOM
							where bsu_noparte+bst_noparte+convert(varchar(10),bst_perini,101)+ convert(varchar(10),bst_perfin,101)+ convert(varchar(50),bst_sec)
							not in (select bom_struct1.bsu_noparte+bom_struct1.bst_noparte+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+ convert(varchar(50),bst_sec) from bom_struct bom_struct1)
							and VIMPORTTEMPBOM.consecutivo>=@valorini and  VIMPORTTEMPBOM.consecutivo<=@valorfin
								
		
						set @contador=@contador+1
						set @valorini=@valorfin+1
				
					END				
				
				end
				else*/
					INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
					BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
					ME_GEN, BST_INCORPOR, BST_TIP_ENS, BST_SEC)
					select BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
						BST_NOPARTE,BST_NOPARTEAUX, 'BST_PerINI'=case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						from bom_struct bom_struct1 
						where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble and bom_struct1.bst_sec=VIMPORTTEMPBOM.bst_sec)
						then convert(varchar(10),getdate()-1,101) else BST_PerINI end,
						BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
						ME_GEN, BST_INCORPOR,BST_TIP_ENS, BST_SEC
					from VIMPORTTEMPBOM
					where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(10),(case when BST_PerINI='01/01/1999' and exists (select bom_struct1.bst_codigo
						from bom_struct bom_struct1 
						where bom_struct1.bst_hijo=VIMPORTTEMPBOM.bst_hijo and bom_struct1.bsu_subensamble=VIMPORTTEMPBOM.bsu_subensamble and bom_struct1.bst_sec=VIMPORTTEMPBOM.bst_sec)
						then convert(varchar(10),getdate()-1,101) else BST_PerINI end),101)+ convert(varchar(10),bst_perfin,101)+ convert(varchar(50),bst_sec)
					not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+ convert(varchar(50),bst_sec) 
						from bom_struct bom_struct1 
						where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux=VIMPORTTEMPBOM.bsu_noparte+VIMPORTTEMPBOM.bsu_noparteaux
						and bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+ convert(varchar(50),bst_sec) is not null)
			
			
		
			end
		
		end	



		/* ======================================== historico ===============================================*/

		if (select count(*) from vIMPORTTEMPBOM)>0 		
		if @TipoActualizacion='H' -- historico
		begin
	
			update bom_struct
			SET bom_struct.BST_INCORPOR = VIMPORTTEMPBOM.BST_INCORPOR,
			    bom_struct.ME_GEN = VIMPORTTEMPBOM.ME_GEN, 
			    bom_struct.BST_TRANS = VIMPORTTEMPBOM.BST_TRANS,
			    bom_struct.ME_CODIGO =VIMPORTTEMPBOM.ME_CODIGO, 
			    bom_struct.FACTCONV =VIMPORTTEMPBOM.FACTCONV,
			    bom_struct.BST_TIP_ENS =VIMPORTTEMPBOM.BST_TIP_ENS
			from bom_struct inner join VIMPORTTEMPBOM on
				bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
				bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
				bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini and
				bom_struct.bst_perfin=VIMPORTTEMPBOM.bst_perfin and
				bom_struct.bst_sec=VIMPORTTEMPBOM.bst_sec 	
	
	
			-- borra los registros que vienen en el archivo y que ya estan en la tabla de bom_struct esto por la actualizacion anterior
			DELETE     VIMPORTTEMPBOM
			FROM         VIMPORTTEMPBOM INNER JOIN
			                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERINI >= BOM_STRUCT.BST_PERINI AND 
			                      VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
			                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
			                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
			                      VIMPORTTEMPBOM.BST_SEC = BOM_STRUCT.BST_SEC AND 
			                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR
	
	
	
			-- si la fecha final viene menor que la fecha que tiene significa que quieren borrarlo
			UPDATE BOM_STRUCT
			SET bst_perfin = VIMPORTTEMPBOM.BST_PERFIN
			from bom_struct inner join VIMPORTTEMPBOM on
				bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
				bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
				bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini and
				bom_struct.bst_sec=VIMPORTTEMPBOM.bst_sec and
				bom_struct.bst_perfin>VIMPORTTEMPBOM.bst_perfin 
	

			update bom_struct
			SET bom_struct.BST_INCORPOR = VIMPORTTEMPBOM.BST_INCORPOR,		
			    bom_struct.ME_GEN = VIMPORTTEMPBOM.ME_GEN, 
			    bom_struct.BST_TRANS = VIMPORTTEMPBOM.BST_TRANS,
			    bom_struct.ME_CODIGO =VIMPORTTEMPBOM.ME_CODIGO, 
			    bom_struct.FACTCONV =VIMPORTTEMPBOM.FACTCONV,
			    bom_struct.BST_TIP_ENS =VIMPORTTEMPBOM.BST_TIP_ENS
			from bom_struct inner join VIMPORTTEMPBOM on
				bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
				bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
				bom_struct.bst_perini=VIMPORTTEMPBOM.bst_perini and
				bom_struct.bst_sec=VIMPORTTEMPBOM.bst_sec and
				bom_struct.bst_perfin<=VIMPORTTEMPBOM.bst_perfin 
	
	
			-- borra los registros que vienen en el archivo y que ya estan en la tabla de bom_struct esto por la actualizacion anterior
			DELETE     VIMPORTTEMPBOM
			FROM         VIMPORTTEMPBOM INNER JOIN
			                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERINI >= BOM_STRUCT.BST_PERINI AND 
			                      VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
			                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
			                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
			                      VIMPORTTEMPBOM.BST_SEC = BOM_STRUCT.BST_SEC AND 
			                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR

	
	
			-- si la fecha inicial es diferente pero la final es igual (al cambiar la fecha final puedo insertar el nuevo)
			--================================================
				update bom_struct
				SET bst_perfin = VIMPORTTEMPBOM.bst_perini-1
				from bom_struct inner join VIMPORTTEMPBOM on
					bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
					bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
					bom_struct.bst_perini<VIMPORTTEMPBOM.bst_perini and
					bom_struct.bst_perfin=VIMPORTTEMPBOM.bst_perfin and
					bom_struct.bst_sec=VIMPORTTEMPBOM.bst_sec 


			if (select count(*) from VIMPORTTEMPBOM)>500
			begin
				--select @valor= round(count(*)/20,0)+1 from VIMPORTTEMPBOM	
				select @valor= round((max(consecutivo)/20),0)+1 from VIMPORTTEMPBOM
				set @contador=1
				select @valorini =min(consecutivo) from VIMPORTTEMPBOM			
			
				WHILE (@contador<=20) 
				BEGIN				
					set @valorfin=@valorini+@valor

					INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
						BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
						ME_GEN, BST_INCORPOR,BST_TIP_ENS,BST_SEC)
					select BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
					BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
					ME_GEN, BST_INCORPOR,BST_TIP_ENS, BST_SEC
					from VIMPORTTEMPBOM
					where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(10),bst_perini,101)+ convert(varchar(10),bst_perfin,101)+convert(varchar(50),bst_sec)
					not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+convert(varchar(50),bst_sec) 
						from bom_struct bom_struct1 
						where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux=VIMPORTTEMPBOM.bsu_noparte+VIMPORTTEMPBOM.bsu_noparteaux
						and bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+convert(varchar(50),bst_sec) is not null)
					and VIMPORTTEMPBOM.consecutivo>=@valorini and  VIMPORTTEMPBOM.consecutivo<=@valorfin
							
					set @contador=@contador+1
					set @valorini=@valorfin+1
			
				END				
			
			end
			else
				INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
					BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
					ME_GEN, BST_INCORPOR, BST_TIP_ENS, BST_SEC)
				select BSU_SUBENSAMBLE,  BST_HIJO, BSU_NOPARTE, BSU_NOPARTEAUX,					        	
				BST_NOPARTE,BST_NOPARTEAUX,BST_PerINI, BST_PerFIN, FACTCONV, BST_DISCH, ME_CODIGO,
				ME_GEN, BST_INCORPOR, BST_TIP_ENS, BST_SEC
				from VIMPORTTEMPBOM
				where bsu_noparte+bsu_noparteaux+bst_noparte+bst_noparteaux+convert(varchar(10),bst_perini,101)+ convert(varchar(10),bst_perfin,101)+convert(varchar(50),bst_sec)
				not in (select bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+convert(varchar(50),bst_sec) 
					from bom_struct bom_struct1 
					where bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux=VIMPORTTEMPBOM.bsu_noparte+VIMPORTTEMPBOM.bsu_noparteaux
					and bom_struct1.bsu_noparte+bom_struct1.bsu_noparteaux+bom_struct1.bst_noparte+bom_struct1.bst_noparteaux+convert(varchar(10),bom_struct1.bst_perini,101)+ convert(varchar(10),bom_struct1.bst_perfin,101)+convert(varchar(50),bst_sec) is not null)
				
	
			DELETE     VIMPORTTEMPBOM
			FROM         VIMPORTTEMPBOM INNER JOIN
			                      BOM_STRUCT ON VIMPORTTEMPBOM.BST_PERINI >= BOM_STRUCT.BST_PERINI AND 
			                      VIMPORTTEMPBOM.BST_PERFIN = BOM_STRUCT.BST_PERFIN AND 
			                      VIMPORTTEMPBOM.BSU_SUBENSAMBLE = BOM_STRUCT.BSU_SUBENSAMBLE AND 
			                      VIMPORTTEMPBOM.BST_HIJO = BOM_STRUCT.BST_HIJO AND 
			                      VIMPORTTEMPBOM.BST_SEC = BOM_STRUCT.BST_SEC AND 
			                      VIMPORTTEMPBOM.BST_INCORPOR = BOM_STRUCT.BST_INCORPOR
	
	
			--================================================
	
			-- en caso de que en archivo venga una ewtructura cuya fecha sea menor que la fecha en bomstruct solo se actualiza en el sistema
	
			update bom_struct
			SET bom_struct.BST_INCORPOR = VIMPORTTEMPBOM.BST_INCORPOR,
			    bom_struct.ME_GEN = VIMPORTTEMPBOM.ME_GEN, 
			    bom_struct.BST_TRANS = VIMPORTTEMPBOM.BST_TRANS,
			    bom_struct.ME_CODIGO =VIMPORTTEMPBOM.ME_CODIGO, 
			    bom_struct.FACTCONV =VIMPORTTEMPBOM.FACTCONV,
			    bom_struct.BST_TIP_ENS =VIMPORTTEMPBOM.BST_TIP_ENS
			from bom_struct inner join VIMPORTTEMPBOM on
				bom_struct.bst_hijo=VIMPORTTEMPBOM.BST_HIJO and
				bom_struct.bsu_subensamble=VIMPORTTEMPBOM.BSU_SUBENSAMBLE and
				bom_struct.bst_perini>=VIMPORTTEMPBOM.bst_perini and
				bom_struct.bst_sec = VIMPORTTEMPBOM.bst_sec and
				bom_struct.bst_perfin = VIMPORTTEMPBOM.bst_perfin 
	
	
	
	
		end
	
	
	
	
		if @ActualizaTipo='S'
		begin
			begin tran
			UPDATE MAESTRO
			SET TI_CODIGO=14
			WHERE MA_CODIGO NOT IN (SELECT BST_HIJO FROM BOM_STRUCT)
			AND MA_CODIGO IN
			(SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT)
			AND TI_CODIGO<>14 AND TI_CODIGO<>16
			commit tran
		
			begin tran
			UPDATE MAESTRO
			SET TI_CODIGO=16
			WHERE MA_CODIGO IN
			(SELECT BST_HIJO FROM BOM_STRUCT)
			AND MA_CODIGO IN
			(SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT)
			commit tran
	
		end
	
		/*begin tran
		UPDATE BOM_STRUCT
		SET     BOM_STRUCT.TI_CODIGO=MAESTRO.TI_CODIGO
		FROM         BOM_STRUCT INNER JOIN
		                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO
		WHERE  BOM_STRUCT.TI_CODIGO<>MAESTRO.TI_CODIGO OR (BOM_STRUCT.TI_CODIGO IS NULL)
		commit tran
		*/

		begin tran
		UPDATE  BOM_STRUCT
		SET     BOM_STRUCT.ME_CODIGO= MAESTRO.ME_COM
		FROM         BOM_STRUCT INNER JOIN
		                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO
		WHERE     (BOM_STRUCT.ME_CODIGO = 0) AND MAESTRO.ME_COM<>0
		commit tran

		begin tran
		UPDATE BOM_STRUCT
		SET     BOM_STRUCT.ME_GEN= MAESTRO_1.ME_COM
		FROM         BOM_STRUCT INNER JOIN
		                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN
		                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO AND BOM_STRUCT.ME_GEN <> MAESTRO_1.ME_COM
		commit tran


		begin tran
		UPDATE BOM_STRUCT
		SET     BOM_STRUCT.FACTCONV= MAESTRO.EQ_GEN
		FROM         BOM_STRUCT INNER JOIN
		                     MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO AND BOM_STRUCT.ME_CODIGO = MAESTRO.ME_COM AND 
		                      BOM_STRUCT.FACTCONV <> MAESTRO.EQ_GEN
		commit tran
	
		insert into bom (MA_SUBENSAMBLE)
		SELECT     BSU_SUBENSAMBLE
		FROM         BOM_STRUCT
		GROUP BY BSU_SUBENSAMBLE
		HAVING      (BSU_SUBENSAMBLE NOT IN
		                          (SELECT     ma_subensamble
		                            FROM          bom))
	
		/*begin tran
		UPDATE dbo.BOM_STRUCT
		SET     dbo.BOM_STRUCT.BST_PESO_KG= round(dbo.MAESTRO.MA_PESO_KG,6)	
		FROM         dbo.BOM_STRUCT INNER JOIN
	             dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO AND dbo.BOM_STRUCT.ME_CODIGO = dbo.MAESTRO.ME_COM
		WHERE  dbo.MAESTRO.MA_PESO_KG>0 and (dbo.BOM_STRUCT.BST_PESO_KG=0 or dbo.BOM_STRUCT.BST_PESO_KG is null)
		commit tran*/
	
		UPDATE BOM_STRUCT
		SET BST_DISCH='N'
		FROM  dbo.BOM_STRUCT INNER JOIN
	             dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO 	
		WHERE BST_TIP_ENS='F' AND (TI_CODIGO=16 OR TI_CODIGO=14) AND (BST_DISCH='S' OR BST_DISCH IS NULL)


		UPDATE MAESTRO
		SET     MA_DISCHARGE='N'
		WHERE MA_TIP_ENS='F' AND (MA_DISCHARGE='S' OR MA_DISCHARGE IS NULL)


		if (select CF_BOMFECHAINIMAYOR from configuracion)<>'S'
		DELETE FROM BOM_STRUCT
		WHERE BST_PERFIN < BST_PERINI
	
		EXEC SP_ACTUALIZAEQBOM
	
	
		ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [INSERT_BOM_STRUCT]
		ALTER TABLE [BOM_STRUCT] ENABLE TRIGGER [UPDATE_BOM_STRUCT]
	

	end


	exec sp_droptable 'maximo'
	exec sp_droptable 'Tempfechafin'
	exec SP_CREAIMPORTTEMPBOM
	exec sp_droptable 'VIMPORTTEMPBOM'

GO
