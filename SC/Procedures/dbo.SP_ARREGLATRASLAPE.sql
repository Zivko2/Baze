SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* no es definitivo que se arreglen todos los registros con fechas traslapadas, se debe de ejecutar el query comentado
para verificacion */
CREATE PROCEDURE [dbo].[SP_ARREGLATRASLAPE]   as

declare @bst_codigo int, @bsu_subensamble int, @bst_hijo int, @perini datetime, @perfin datetime, @PADREHIJO varchar(100)



declare @bstcodigoanterior int, @bstcodigoposterior int, @bmperfinanterior datetime, @bmperinianterior datetime, @entravigor1 datetime, @entravigorantes datetime,
 @bmperfin1 datetime, @bmentravigorposterior datetime, @bmperfinposterior datetime, @incorpor decimal(38,6), @bmincorporposterior decimal(38,6)

/* query que saca los traslapados
	SELECT BST_CODIGO, CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) grupo
	FROM BOM_STRUCT
	WHERE CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) 
		IN (SELECT CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) FROM BOM_STRUCT
		   GROUP BY CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)
		   HAVING COUNT(*)>1) AND

	(CASE WHEN EXISTS(SELECT B1.BST_CODIGO FROM BOM_STRUCT B1 WHERE 
		CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) =
		CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO)
	   AND b1.BST_CODIGO<>BOM_STRUCT.BST_CODIGO AND 
	((B1.BST_PERINI=BOM_STRUCT.BST_PERINI) OR
	 (B1.BST_PERFIN=BOM_STRUCT.BST_PERFIN) OR
	 (B1.BST_PERFIN>BOM_STRUCT.BST_PERINI AND B1.BST_PERFIN<BOM_STRUCT.BST_PERFIN))) THEN 'TRASLAPE' ELSE 'NO' END)='TRASLAPE'

	GROUP BY BST_CODIGO,CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)
	order by CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) 
*/
	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##REPETIDOS'  AND  type = 'U')
	begin
		drop table ##REPETIDOS
	end
	
	SELECT     CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_PERINI) AS GRUPO, CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) as padrehijo
	INTO ##REPETIDOS
	FROM         BOM_STRUCT B2
	GROUP BY CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_PERINI), CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO)
	HAVING      (COUNT(*) > 1)


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##ABORRAR'  AND  type = 'U')
	begin
		drop table ##ABORRAR
	end


	SELECT BST_CODIGO, 'LETRA'=CASE WHEN EXISTS(SELECT B1.BST_CODIGO FROM BOM_STRUCT B1 WHERE 
		CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B1.BST_PERINI)
		+ '-' + CONVERT(VARCHAR(50), B1.BST_INCORPOR)+ '-'+ CONVERT(VARCHAR(50), B1.ME_CODIGO)=
		CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_PERINI)
		+ '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR) + '-'+ CONVERT(VARCHAR(50), BOM_STRUCT.ME_CODIGO)
	   AND B1.BST_PERFIN<BOM_STRUCT.BST_PERFIN) THEN 'B' ELSE 'N' END, BST_PERFIN,
	   CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) grupo
	INTO ##ABORRAR
	FROM BOM_STRUCT
	WHERE CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) + '-' + CONVERT(VARCHAR(50), BST_PERINI)
		IN (SELECT GRUPO FROM ##REPETIDOS)
	order by CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) + '-' + CONVERT(VARCHAR(50), BST_PERINI)


	delete from bom_struct where bst_codigo in (select bst_codigo from ##ABORRAR where letra='b')


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##nvafecha'  AND  type = 'U')
	begin
		drop table ##nvafecha
	end


	select bom.bst_codigo, perfinnvo, bom.bst_perfin
	into ##nvafecha
	from bom_struct bom,
		(select max(bom_struct.bst_perfin) perfin1, max(b1.bst_perfin) perfinnvo, b1.grupo
		from bom_struct inner join ##ABORRAR b1 on
			b1.grupo = CONVERT(VARCHAR(50), bom_struct.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), bom_struct.BST_HIJO)
		where letra='b'
		group by b1.grupo
		having max(b1.bst_perfin) > max(bom_struct.bst_perfin)) tabla
	where CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)=tabla.grupo		
	and bom.bst_perfin=perfin1 and perfinnvo<> bom.bst_perfin
	
	update bom_struct
	set bst_perfin=b1.perfinnvo
	from bom_struct, ##nvafecha b1
	where bom_struct.bst_codigo=b1.bst_codigo


/*====    fecha fin ===== */

IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##REPETIDOSFIN'  AND  type = 'U')
	begin
		drop table ##REPETIDOSFIN
	end
	
	SELECT     CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_PERFIN) AS GRUPO, CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) as padrehijo
	INTO ##REPETIDOSFIN
	FROM         BOM_STRUCT B2
	GROUP BY CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_PERFIN), CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO)
	HAVING      (COUNT(*) > 1)






	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##ABORRARFIN'  AND  type = 'U')
	begin
		drop table ##ABORRARFIN
	end


	SELECT BST_CODIGO, 'LETRA'=CASE WHEN EXISTS(SELECT B1.BST_CODIGO FROM BOM_STRUCT B1 WHERE 
		CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B1.BST_PERFIN)
		+ '-' + CONVERT(VARCHAR(50), B1.BST_INCORPOR)+ '-'+ CONVERT(VARCHAR(50), B1.ME_CODIGO)=
		CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_PERFIN)
		+ '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR) + '-'+ CONVERT(VARCHAR(50), BOM_STRUCT.ME_CODIGO)
	   AND B1.BST_PERINI<BOM_STRUCT.BST_PERINI) THEN 'B' ELSE 'N' END, BST_PERINI,
	   CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) grupo
	INTO ##ABORRARFIN
	FROM BOM_STRUCT
	WHERE CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) + '-' + CONVERT(VARCHAR(50), BST_PERFIN)
		IN (SELECT GRUPO FROM ##REPETIDOSFIN)
	order by CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) + '-' + CONVERT(VARCHAR(50), BST_PERFIN)



	delete from bom_struct where bst_codigo in (select bst_codigo from ##ABORRARFIN where letra='b')


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##nvafechafin'  AND  type = 'U')
	begin
		drop table ##nvafechafin
	end



	select bom.bst_codigo, perininvo, bom.BST_PERINI
	into ##nvafechafin
	from bom_struct bom,
		(select min(bom_struct.BST_PERINI) perini1, max(b1.BST_PERINI) perininvo, b1.grupo
		from bom_struct inner join ##ABORRARFIN b1 on
			b1.grupo = CONVERT(VARCHAR(50), bom_struct.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), bom_struct.BST_HIJO)
		where letra='b'
		group by b1.grupo
		having min(b1.BST_PERINI) < min(bom_struct.BST_PERINI)) tabla
	where CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)=tabla.grupo		
	and bom.BST_PERINI=perini1 and perininvo<> bom.BST_PERINI
	

	update bom_struct
	set BST_PERINI=b1.perininvo
	from bom_struct, ##nvafechafin b1
	where bom_struct.bst_codigo=b1.bst_codigo



/*========*/

	delete from bom_struct
	where CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) +CONVERT(VARCHAR(50), BST_PERINI)
	IN (SELECT CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) +CONVERT(VARCHAR(50), B1.BST_PERINI) FROM BOM_STRUCT B1
		WHERE B1.BST_CODIGO<>BOM_STRUCT.BST_CODIGO)
	AND CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) +CONVERT(VARCHAR(50), BST_PERFIN)
	IN (SELECT CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) +CONVERT(VARCHAR(50), B2.BST_PERFIN) FROM BOM_STRUCT B2
		WHERE B2.BST_CODIGO<>BOM_STRUCT.BST_CODIGO)


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##MAXIMO'  AND  type = 'U')
	begin
		drop table ##MAXIMO
	end



	select max(b1.bst_perini) bst_perini, CONVERT(VARCHAR(50), b1.BSU_SUBENSAMBLE)+ '-' + CONVERT(VARCHAR(50), b1.BST_HIJO) GRUPO
	INTO ##MAXIMO
	from bom_struct b1
	GROUP BY CONVERT(VARCHAR(50), b1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), b1.BST_HIJO)
	
	DELETE
	from bom_struct
	where bst_perfin<>'01/01/9999'
		and bst_perini in
		(select max(b1.bst_perini) from ##MAXIMO b1
		where b1.GRUPO =
		CONVERT(VARCHAR(50), bom_struct.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), bom_struct.BST_HIJO)) and
	
		CONVERT(VARCHAR(50), bom_struct.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), bom_struct.BST_HIJO)+ '-' + CONVERT(VARCHAR(50), bom_struct.BST_INCORPOR) in
		(select CONVERT(VARCHAR(50), b2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), b2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), b2.BST_INCORPOR)
		from bom_struct b2 where b2.bst_perfin='01/01/9999')


	DELETE
	from bom_struct
	where bst_perfin='01/01/9999' 
		and bst_perini not in
		(select max(b1.bst_perini) from ##MAXIMO b1
		where b1.GRUPO =
		CONVERT(VARCHAR(50), bom_struct.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), bom_struct.BST_HIJO)) and
		CONVERT(VARCHAR(50), bom_struct.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), bom_struct.BST_HIJO)+ '-' + CONVERT(VARCHAR(50), bom_struct.BST_INCORPOR) in
		(select CONVERT(VARCHAR(50), b2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), b2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), b2.BST_INCORPOR)
		from bom_struct b2 where b2.bst_codigo<>bom_struct.bst_codigo and b2.bst_perfin='01/01/9999')


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##MAXIMO'  AND  type = 'U')
	begin
		drop table ##MAXIMO
	end


	DELETE FROM BOM_STRUCT WHERE BST_PERINI IN
		(SELECT B1.BST_PERINI FROM BOM_STRUCT B1 WHERE CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B1.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B1.BST_CODIGO <> BOM_STRUCT.BST_CODIGO AND B1.BST_PERINI = BOM_STRUCT.BST_PERINI)
		AND BST_PERFIN NOT IN
		(SELECT MAX(B2.BST_PERFIN) FROM BOM_STRUCT B2 WHERE CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B2.BST_PERINI = BOM_STRUCT.BST_PERINI)


	DELETE FROM BOM_STRUCT WHERE BST_PERFIN IN
		(SELECT B1.BST_PERFIN FROM BOM_STRUCT B1 WHERE CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B1.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B1.BST_CODIGO <> BOM_STRUCT.BST_CODIGO AND B1.BST_PERFIN = BOM_STRUCT.BST_PERFIN)
		AND BST_PERINI NOT IN
		(SELECT MIN(B2.BST_PERINI) FROM BOM_STRUCT B2 WHERE CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B2.BST_PERFIN = BOM_STRUCT.BST_PERFIN)


declare cur_traslapefinal cursor for
	/*SELECT     BST_CODIGO, bsu_subensamble, bst_hijo, convert(varchar(10),bst_perini,101), convert(varchar(10),bst_perfin,101)
	FROM         BOM_STRUCT
	WHERE CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) 
		IN (SELECT padrehijo FROM ##REPETIDOS)
		or 
		 CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) 
		IN (SELECT padrehijo FROM ##REPETIDOSFIN)
	ORDER BY BST_PERINI, BST_PERFIN, BST_HIJO, BSU_SUBENSAMBLE*/

	SELECT CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)
		FROM BOM_STRUCT
		WHERE CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) 
			IN (SELECT CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO) FROM BOM_STRUCT
			   GROUP BY CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)
			   HAVING COUNT(*)>1) AND
	
		(CASE WHEN EXISTS(SELECT B1.BST_CODIGO FROM BOM_STRUCT B1 WHERE 
			CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) =
			CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO)
		   AND b1.BST_CODIGO<>BOM_STRUCT.BST_CODIGO AND 
		((B1.BST_PERINI=BOM_STRUCT.BST_PERINI) OR
		 (B1.BST_PERFIN=BOM_STRUCT.BST_PERFIN) OR
		 (B1.BST_PERFIN>BOM_STRUCT.BST_PERINI AND B1.BST_PERFIN<BOM_STRUCT.BST_PERFIN))) THEN 'TRASLAPE' ELSE 'NO' END)='TRASLAPE'
	--and CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)='11297-2836'

	GROUP BY CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)
	order by CONVERT(VARCHAR(50), BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BST_HIJO)
open cur_traslapefinal


	FETCH NEXT FROM cur_traslapefinal INTO @PADREHIJO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


		
		declare cur_traslapefinal2 cursor for
		
			SELECT BZ.BST_CODIGO, BZ.bsu_subensamble, BZ.bst_hijo, convert(varchar(10),BZ.bst_perini,101), convert(varchar(10),BZ.bst_perfin,101), BZ.bst_incorpor
			FROM BOM_STRUCT BZ
			WHERE CONVERT(VARCHAR(50), BZ.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BZ.BST_HIJO)=@PADREHIJO
			order by CONVERT(VARCHAR(50), BZ.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BZ.BST_HIJO) , BZ.bst_perini, BZ.bst_perfin
		open cur_traslapefinal2
		
		
			FETCH NEXT FROM cur_traslapefinal2 INTO @bst_codigo, @bsu_subensamble, @bst_hijo, @perini, @perfin, @incorpor
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN



			SELECT @bstcodigoposterior = min(bst_codigo) FROM bom_struct WHERE bsu_subensamble =@bsu_subensamble
			and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo and
			bst_perini in (SELECT min(bst_perini) FROM bom_struct WHERE bsu_subensamble =@bsu_subensamble
				and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo and bst_perini >=@perini)


			if @bstcodigoposterior is not null
			begin
			--actualiza la fecha inicial del bom posterior al que se esta insertando si se traslapa

				select @bmentravigorposterior=bst_perini, @bmperfinposterior=bst_perfin, @bmincorporposterior=bst_incorpor from bom_struct where bst_codigo = @bstcodigoposterior

				set @bmperfin1=@perfin+1

				/*print @bst_codigo
				print @bmentravigorposterior
				print @perfin
				print @bstcodigoposterior
				print '----'*/

				if @perfin='01/01/9999'
				begin

					if @bmentravigorposterior>@perini and @incorpor=@bmincorporposterior
						delete from bom_struct where bst_codigo=@bstcodigoposterior
					else
					begin
						if not exists (select * from bom_struct where bst_perini = @perini and bsu_subensamble = @bsu_subensamble
								and bst_hijo=@bst_hijo and bst_perfin=@bmentravigorposterior-1)

						update bom_struct
						set bst_perfin=@bmentravigorposterior-1
						where bst_codigo=@bst_codigo



						if not exists (select * from bom_struct where bst_perini = @bmentravigorposterior and bsu_subensamble = @bsu_subensamble
								and bst_hijo=@bst_hijo and bst_perfin='01/01/9999')
						update bom_struct
						set bst_perfin='01/01/9999'
						where bst_codigo=@bstcodigoposterior

					end

				end
				else
				if @bmentravigorposterior<@perfin
				begin
					--PRINT 'ENTRA'
					
					if not exists (select * from bom_struct where bst_perini = @bmperfinposterior+1 and bsu_subensamble = @bsu_subensamble
							and bst_hijo=@bst_hijo and bst_perfin=@perfin)

						INSERT INTO BOM_STRUCT(BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, 
				                    	  BSU_NOPARTE, BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_TIP_ENS, BST_SEC)
				
						SELECT     BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, ME_CODIGO, FACTCONV, @bmperfinposterior+1, BST_PERFIN, ME_GEN, BST_TRANS, 
						                      BSU_NOPARTE, BST_NOPARTE, BSU_NOPARTEAUX, BST_NOPARTEAUX, BST_TIP_ENS, BST_SEC
						FROM         BOM_STRUCT
						where bst_codigo=@bst_codigo	
			
			
	
					if not exists (select * from bom_struct where bst_perini = @perini and bsu_subensamble = @bsu_subensamble
							and bst_hijo=@bst_hijo and bst_perfin=@bmentravigorposterior-1)

					update bom_struct
					set bst_perfin=@bmentravigorposterior-1
					where bst_codigo=@bst_codigo
									
				end
				else
				if @bmentravigorposterior-1=@perfin and @incorpor=@bmincorporposterior
				begin
					--PRINT 'ENTRA'
					
					if not exists (select * from bom_struct where bst_perini = @perini and bsu_subensamble = @bsu_subensamble
							and bst_hijo=@bst_hijo and bst_perfin=@bmperfinposterior)
					begin
						update bom_struct
						set bst_perfin=@bmperfinposterior
						where bst_codigo=@bst_codigo
					end

					delete from bom_struct
					where bst_codigo=@bstcodigoposterior
									
				end


			end


		FETCH NEXT FROM cur_traslapefinal2 INTO @bst_codigo, @bsu_subensamble, @bst_hijo, @perini, @perfin, @incorpor
	
	END
	
	CLOSE cur_traslapefinal2
	DEALLOCATE cur_traslapefinal2



	FETCH NEXT FROM cur_traslapefinal INTO @PADREHIJO

END

CLOSE cur_traslapefinal
DEALLOCATE cur_traslapefinal



	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##REPETIDOS'  AND  type = 'U')
	begin
		drop table ##REPETIDOS
	end


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##ABORRAR'  AND  type = 'U')
	begin
		drop table ##ABORRAR
	end




	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##nvafecha'  AND  type = 'U')
	begin
		drop table ##nvafecha
	end



	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##REPETIDOSFIN'  AND  type = 'U')
	begin
		drop table ##REPETIDOSFIN
	end




	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##ABORRARFIN'  AND  type = 'U')
	begin
		drop table ##ABORRARFIN
	end

	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##nvafechafin'  AND  type = 'U')
	begin
		drop table ##nvafechafin
	end



	DELETE FROM BOM_STRUCT WHERE BST_PERINI IN
		(SELECT B1.BST_PERINI FROM BOM_STRUCT B1 WHERE CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B1.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B1.BST_CODIGO <> BOM_STRUCT.BST_CODIGO AND B1.BST_PERINI = BOM_STRUCT.BST_PERINI)
		AND BST_PERFIN NOT IN
		(SELECT MAX(B2.BST_PERFIN) FROM BOM_STRUCT B2 WHERE CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B2.BST_PERINI = BOM_STRUCT.BST_PERINI)


	DELETE FROM BOM_STRUCT WHERE BST_PERFIN IN
		(SELECT B1.BST_PERFIN FROM BOM_STRUCT B1 WHERE CONVERT(VARCHAR(50), B1.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B1.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B1.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B1.BST_CODIGO <> BOM_STRUCT.BST_CODIGO AND B1.BST_PERFIN = BOM_STRUCT.BST_PERFIN)
		AND BST_PERINI NOT IN
		(SELECT MIN(B2.BST_PERINI) FROM BOM_STRUCT B2 WHERE CONVERT(VARCHAR(50), B2.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), B2.BST_HIJO) + '-' + CONVERT(VARCHAR(50), B2.BST_INCORPOR)
		=CONVERT(VARCHAR(50), BOM_STRUCT.BSU_SUBENSAMBLE) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_HIJO) + '-' + CONVERT(VARCHAR(50), BOM_STRUCT.BST_INCORPOR)AND
		B2.BST_PERFIN = BOM_STRUCT.BST_PERFIN)




	delete from bom_struct where bst_perfin<bst_perini
GO
