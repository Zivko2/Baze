SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ligacorrectaall]  (@user int, @ejecutar char(1)='N')   as

SET NOCOUNT ON 
declare @owner varchar(150), @cuenta int

	exec SP_CREATABLALOG 60

	--Yolanda Avila
	--2010-05-06
	--Revisa los movimientos del día y un día antes.
	/*
	if exists (SELECT  *  FROM sysusrlog60
	WHERE     mov_id = 2 AND CONVERT(varchar(10), fechahora, 101) = CONVERT(varchar(10), GETDATE(), 101) AND 
	                 user_id = @user) and @ejecutar='S'
	*/
	if exists (SELECT * FROM sysusrlog60
	WHERE (mov_id = 2 and user_id = @user
		and (CONVERT(varchar(10), fechahora, 101) = CONVERT(varchar(10), GETDATE(), 101) or CONVERT(varchar(10), fechahora, 101) = CONVERT(varchar(10), GETDATE()-1, 101))
	       )
        and @ejecutar='S')

	begin

		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pi_codigo_temp'  AND  type = 'U')
		begin
			drop table ##pi_codigo_temp
		end
			
		
		
			create table ##pi_codigo_temp (codigo integer)
		
			  insert into ##pi_codigo_temp 
			             SELECT     dbo.FACTIMP.PI_CODIGO
				FROM         dbo.FACTIMP INNER JOIN
				                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO INNER JOIN
				                      dbo.PEDIMP ON dbo.FACTIMP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     (dbo.FACTIMPDET.PID_INDICEDLIGA = - 1 OR
				                      dbo.FACTIMPDET.PID_INDICEDLIGA IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('S', 'B')) 
				GROUP BY dbo.FACTIMP.PI_CODIGO
				UNION
				SELECT     dbo.FACTIMP.PI_RECTIFICA
				FROM         dbo.FACTIMP INNER JOIN
				                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO INNER JOIN
				                      dbo.PEDIMP ON dbo.FACTIMP.PI_RECTIFICA = dbo.PEDIMP.PI_CODIGO
				WHERE     (dbo.FACTIMPDET.PID_INDICEDLIGAR1 = - 1 OR
				                      dbo.FACTIMPDET.PID_INDICEDLIGAR1 IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('N', 'T')) 
					AND (dbo.FACTIMP.PI_CODIGO is not null and dbo.FACTIMP.PI_CODIGO<>-1)
				GROUP BY dbo.FACTIMP.PI_RECTIFICA
				UNION
		
					SELECT     dbo.FACTEXP.PI_CODIGO
					FROM         dbo.FACTEXP INNER JOIN
					                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
					                      dbo.PEDIMP ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
					WHERE     (dbo.FACTEXPDET.PID_INDICEDLIGA = - 1 OR
					                      dbo.FACTEXPDET.PID_INDICEDLIGA IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('L')) 
			
						AND dbo.FACTEXP.PI_CODIGO NOT IN 
							(SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO ='CN'
								or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S')))
					GROUP BY dbo.FACTEXP.PI_CODIGO
			
					UNION
			
					SELECT     dbo.FACTEXP.PI_RECTIFICA
					FROM         dbo.FACTEXP INNER JOIN
					                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
					                      dbo.PEDIMP ON dbo.FACTEXP.PI_RECTIFICA = dbo.PEDIMP.PI_CODIGO
					WHERE     (dbo.FACTEXPDET.PID_INDICEDLIGAR1 = - 1 OR
					                      dbo.FACTEXPDET.PID_INDICEDLIGAR1 IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('O', 'N')) 
					AND (dbo.FACTEXP.PI_CODIGO is not null and dbo.FACTEXP.PI_CODIGO<>-1) AND
			
						dbo.FACTEXP.PI_RECTIFICA NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
						FROM         dbo.CONFIGURACLAVEPED INNER JOIN
						                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
						WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
					GROUP BY dbo.FACTEXP.PI_RECTIFICA
				union
					select pi_codigo from pedimp where pi_codigo not in (select pi_codigo from pedimpdet) 
					and pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'TS') or (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
				union
					select pedimpdet.pi_codigo from pedimpdet inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
					where pi_movimiento='E' and pid_indiced not in (select pid_indicedliga from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo where factimp.pi_codigo=pedimpdet.pi_codigo) 
					and pedimp.pi_estatus<>'R'
					and pedimpdet.pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO ='TS') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO ='CN') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
					and pedimpdet.pid_imprimir='S' and pedimp.pi_tipo ='C'
					group by pedimpdet.pi_codigo
		
				union
					select pedimpdet.pi_codigo from pedimpdet inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
					where pi_movimiento='E' and pid_indiced not in (select pid_indicedligar1 from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo where factimp.pi_rectifica=pedimpdet.pi_codigo) 
					and pedimpdet.pi_codigo IN (SELECT     dbo.PEDIMP.PI_CODIGO
								FROM         dbo.CONFIGURACLAVEPED INNER JOIN
								                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO LEFT OUTER JOIN
								                      dbo.CONFIGURACLAVEPED CONFIGURACLAVEPED_1 ON dbo.PEDIMP.CP_RECTIFICA = CONFIGURACLAVEPED_1.CP_CODIGO
								WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') AND ((CONFIGURACLAVEPED_1.CCP_TIPO <> 'CN') and (CONFIGURACLAVEPED_1.CCP_TIPO <> 'TS') and
									      ((CONFIGURACLAVEPED.CCP_TIPO = 'RG' OR CONFIGURACLAVEPED_1.CCP_TIPO = 'RG') AND dbo.PEDIMP.PI_DESP_EQUIPO<>'S')))
					and pedimpdet.pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'TS') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
					and pedimpdet.pid_imprimir='S'
					group by pedimpdet.pi_codigo
				union
					select pedimpdet.pi_codigo from pedimpdet inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
					where pi_movimiento='S' and pid_indiced not in (select pid_indicedliga from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo where factexp.pi_codigo=pedimpdet.pi_codigo) 
					and pedimp.pi_estatus<>'R'
					and pedimpdet.pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO ='TS') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO ='CN') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
					and pedimpdet.pid_imprimir='S' and pedimp.pi_tipo ='C'
					group by pedimpdet.pi_codigo
		
				union
					select pedimpdet.pi_codigo from pedimpdet inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
					where pi_movimiento='S' and pid_indiced not in (select pid_indicedligar1 from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo where factexp.pi_rectifica=pedimpdet.pi_codigo) 
					and pedimpdet.pi_codigo IN (SELECT     dbo.PEDIMP.PI_CODIGO
								FROM         dbo.CONFIGURACLAVEPED INNER JOIN
								                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO LEFT OUTER JOIN
								                      dbo.CONFIGURACLAVEPED CONFIGURACLAVEPED_1 ON dbo.PEDIMP.CP_RECTIFICA = CONFIGURACLAVEPED_1.CP_CODIGO
								WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') AND ((CONFIGURACLAVEPED_1.CCP_TIPO <> 'CN') and (CONFIGURACLAVEPED_1.CCP_TIPO <> 'TS') and
									      ((CONFIGURACLAVEPED.CCP_TIPO = 'RG' OR CONFIGURACLAVEPED_1.CCP_TIPO = 'RG') AND dbo.PEDIMP.PI_DESP_EQUIPO<>'S')))
					and pedimpdet.pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'TS') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
					and pedimpdet.pid_imprimir='S'
					group by pedimpdet.pi_codigo
				
			
		
			
		update pedimp 
		set pi_ligacorrecta='S' 
		where pi_tipo='C' and (pi_ligacorrecta<>'S'  or pi_ligacorrecta is null)
	
	
		update pedimp
		set pi_ligacorrecta = 'N' where pi_tipo not in ('A', 'T', 'N') 
		and pi_cuentadet=0
	
		update pedimp set pi_ligacorrecta = 'N' where pi_tipo not in ('A', 'T', 'N') 
		           and pi_codigo in (select codigo from ##pi_codigo_temp group by codigo)
		           and pi_estatus not in ('A', 'B', 'F', 'G', 'C')
		          and pi_codigo not in (select pi_codigo from pedimp where pi_ediciondet='S')
	
				
		--select * from ##pi_codigo_temp where codigo=4266
	
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pi_codigo_temp'  AND  type = 'U')
		begin
			drop table ##pi_codigo_temp
		end





	
		--en este caso el pi_no_rect es el r1 y el pi_codigo el que esta siendo rectificado (pedimprect.pi_no_rect)
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##PENDR1'  AND  type = 'U')
		begin
			drop table ##PENDR1
		end
	
	
		SELECT     dbo.PEDIMP.PI_RECTIFICA, dbo.PEDIMP.PI_CODIGO
		INTO ##PENDR1
		FROM         dbo.PEDIMP INNER JOIN
		                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
		WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') AND dbo.PEDIMP.PI_RECTIFICA NOT
		IN (SELECT  PEDIMPRECT.PI_CODIGO FROM PEDIMPRECT WHERE PEDIMPRECT.PI_NO_RECT=dbo.PEDIMP.PI_CODIGO)
		   and pi_estatus not in ('A', 'B', 'F', 'G', 'C') AND
		(dbo.PEDIMP.PI_CODIGO NOT IN (SELECT PI_NO_RECT FROM PEDIMPRECT) OR 
		dbo.PEDIMP.PI_CODIGO IN (SELECT PI_NO_RECT FROM PEDIMPRECT WHERE PI_CODIGO=0))
	
		if exists (select * from ##PENDR1)
		begin
		
			DELETE FROM PEDIMPRECT WHERE PI_CODIGO=0
		
			INSERT INTO PEDIMPRECT(PI_CODIGO, PI_NO_RECT)
			SELECT     dbo.PEDIMP.PI_RECTIFICA, dbo.PEDIMP.PI_CODIGO
			FROM         dbo.PEDIMP INNER JOIN
			                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
			WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') AND dbo.PEDIMP.PI_RECTIFICA NOT
			IN (SELECT  PEDIMPRECT.PI_CODIGO FROM PEDIMPRECT WHERE PEDIMPRECT.PI_NO_RECT=dbo.PEDIMP.PI_CODIGO)
			and pi_estatus not in ('A', 'B', 'F', 'G', 'C') AND
			dbo.PEDIMP.PI_CODIGO IN (SELECT PI_CODIGO FROM ##PENDR1)
		
			begin tran
			UPDATE dbo.PEDIMP
			SET     dbo.PEDIMP.PI_LIGACORRECTA='N'
			FROM         dbo.PEDIMP INNER JOIN
			                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
			WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') AND dbo.PEDIMP.PI_RECTIFICA NOT
			IN (SELECT  PEDIMPRECT.PI_CODIGO FROM PEDIMPRECT WHERE PEDIMPRECT.PI_NO_RECT=dbo.PEDIMP.PI_CODIGO)
	 	           and pi_estatus not in ('A', 'B', 'F', 'G', 'C')
		          and pi_codigo not in (select pi_codigo from pedimp where pi_ediciondet='S')
			commit tran
		
		end
		
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##PENDR1'  AND  type = 'U')
		begin
			drop table ##PENDR1
		end
	
	



		-- actualiza relacion con pedimentos
	
/*		alter table factimp disable trigger UPDATE_FACTIMP
	
			update factimp
			set pi_codigo=-1
			where pi_codigo<>-1 and pi_codigo<0
			
			update factimp
			set si_codigo=-1
			where si_codigo<>-1 and si_codigo<0
			
			update factimp
			set pi_rectifica=-1
			where pi_rectifica<>-1 and pi_rectifica<0
	
		alter table factimp enable trigger UPDATE_FACTIMP
	
		alter table factexp disable trigger UPDATE_FACTEXP
			update factexp
			set pi_codigo=-1
			where pi_codigo<>-1 and pi_codigo<0
		
			update factexp
			set et_codigo=-1
			where et_codigo<>-1 and et_codigo<0
	
			update factexp
			set pi_rectifica=-1
			where pi_rectifica<>-1 and pi_rectifica<0
		
		alter table factexp enable trigger UPDATE_FACTEXP*/

	
	end
	


	if (SELECT CF_TIEMPOUSO FROM CONFIGURACION)>-1
	begin
		UPDATE MAESTRO
		SET MA_ENUSO='N'
		FROM MAESTRO LEFT OUTER JOIN
		CONFIGURATIPO  ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE MA_INV_GEN='I' AND CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T', 'P') 
		    AND MA_CODIGO NOT IN (SELECT     MA_CODIGO FROM  VENUSO GROUP BY MA_CODIGO)
		    --2010-03-08
		    --AND MA_CODIGO not in (select ma_codigo from MAESTROALM WHERE MAA_FECHAREVISION>=convert(VARCHAR(10),getdate()-7,101))
		AND MA_ENUSO<>'N'
	end


	-- revisa si existen saldos incorrectos
	--Yolanda Avila
	--2010-04-01
	--Siempre debe de ejecutar esta parte
	--if (SELECT CF_PEDSALDOINC FROM CONFIGURACION)='S' 
	exec sp_SaldoIncorrecto

	-- revisa si existen pedimentos que su valor total no coincida con las facturas
	exec SP_REVISAVALPEDFACT


GO
