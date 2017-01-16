SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZATASABAJAFID] (@fid_indiced1 int, @user1 int=1, @ActualizaPR char(1)='N')   as

SET NOCOUNT ON 
declare @CF_ACTTASACERTO char(1), @CF_ACTTASAPERPPS char(1), @CF_ACTTASAPER8VA char(1),
@user varchar(25), @fid_indiced varchar(50), @fi_codigo int, @fi_fecha varchar(11)


SELECT     @CF_ACTTASAPER8VA=CF_ACTTASAPER8VA, @CF_ACTTASAPERPPS=CF_ACTTASAPERPPS, @CF_ACTTASACERTO=CF_ACTTASACERTO
FROM         CONFIGURACION


select @user=convert(varchar(25),@user1)

if (select CF_USAPROVEECERTORIG from configuracion)='S'  -- verificando proveedor
	if @ActualizaPR='S'
	UPDATE dbo.FACTIMPDET
	SET     dbo.FACTIMPDET.PR_CODIGO= dbo.CERTORIGMPDET.PR_CODIGO 
	FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.CERTORIGMPDET ON dbo.FACTIMPDET.MA_CODIGO = dbo.CERTORIGMPDET.MA_CODIGO AND 
	                      dbo.FACTIMPDET.PA_CODIGO = dbo.CERTORIGMPDET.PA_CLASE INNER JOIN
	                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO AND LEFT(dbo.CERTORIGMPDET.CMP_FRACCION, 6) 
	                      = LEFT(dbo.ARANCEL.AR_FRACCION, 6) INNER JOIN
	                      dbo.CERTORIGMP ON dbo.CERTORIGMPDET.CMP_CODIGO = dbo.CERTORIGMP.CMP_CODIGO INNER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO AND dbo.CERTORIGMP.CMP_IFECHA <= dbo.FACTIMP.FI_FECHA AND 
	                      dbo.CERTORIGMP.CMP_FECHATRANS >= dbo.FACTIMP.FI_FECHA
	WHERE     (dbo.CERTORIGMPDET.PR_CODIGO IS NOT NULL) AND  (dbo.FACTIMPDET.FID_INDICED = @fid_indiced1)

-- se genera la tabla TempTasa
 exec('exec sp_droptable '''+@user+'TempTasaSector''
	exec sp_droptable '''+@user+'TempTasaSector2''
	exec sp_droptable '''+@user+'TempTasaSector3''
	exec sp_droptable '''+@user+'SectoresTemp''
	exec sp_droptable '''+@user+'OrdenTasa''
	exec sp_droptable '''+@user+'TempTasa''')



	update CERTORIGMP
	set CMP_FECHATRANS= CMP_VFECHA
	where CMP_FECHATRANS is null

select @fi_codigo=fi_codigo from factimpdet where fid_indiced=@fid_indiced1

select @fi_fecha=convert(varchar(11),fi_fecha,101) from factimp where fi_codigo=@fi_codigo

set @fid_indiced= convert(varchar(50),@fid_indiced1)

exec('exec sp_droptable '''+@user+'SectoresTemp''')

exec('SELECT PERMISODET.SE_CODIGO
INTO dbo.['+@user+'SectoresTemp]
FROM         PERMISO INNER JOIN
                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO
WHERE     (IDENTIFICA.IDE_CLAVE = ''PS'') AND (PERMISO.PE_APROBADO = ''S'')
GROUP BY PERMISODET.SE_CODIGO')

exec('if (select count(*) from ['+@user+'SectoresTemp])=1 update maestro set ma_sec_imp= (select se_codigo from ['+@user+'SectoresTemp]) where (ma_sec_imp is null or ma_sec_imp=0)  and ma_tip_ens=''C'' or ma_tip_ens=''A''')

--Yolanda A. (2009-08-12)
--Se asigno formato de decimal a los campos que almacenan las tasas ya que almacenaban solo valores enteros
exec('SELECT    FACTIMPDET.FID_INDICED, ''AR_IMPMX''=CASE WHEN FACTIMPDET.AR_IMPMX in (select ar_codigo from arancel where pa_codigo=154 and
ar_fraccion like ''9802%'') then MAESTRO.AR_IMPMX else FACTIMPDET.AR_IMPMX end, 
FACTIMPDET.PA_CODIGO as PA_ORIGEN, MAESTRO.MA_SEC_IMP,
convert(varchar(10),FI_FECHA, 101) as FI_FECHA, FACTIMPDET.MA_CODIGO,
FACTIMPDET.TI_CODIGO,convert(decimal(38,6),-1.0) AS MA_POR_DEFNVO, ''G'' AS MA_DEF_TIPNVO, ISNULL((SELECT SPI_CODIGO FROM PAIS WHERE PA_CODIGO=FACTIMPDET.PA_CODIGO),0) AS SPI_CODIGOPAIS,
	999999 AS AR_FRACCION, convert(decimal(38,6),-1.0) AS PAR_BEN, convert(decimal(38,6),-1.0) AS SA_PORCENT, convert(decimal(38,6),-1.0) AS AR_PORCENT_8VA, FACTIMPDET.PR_CODIGO 
INTO dbo.['+@user+'TempTasa]
FROM         FACTIMPDET LEFT OUTER JOIN
                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO LEFT OUTER JOIN
                      MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO 
WHERE     FACTIMPDET.FID_INDICED ='+ @fid_indiced)


exec('UPDATE ['+@user+'TempTasa]
SET     ['+@user+'TempTasa].AR_FRACCION= LEFT(ARANCEL.AR_FRACCION, 6), ['+@user+'TempTasa].MA_POR_DEFNVO= ARANCEL.AR_ADVDEF
FROM  ['+@user+'TempTasa]  INNER JOIN
                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
WHERE LEFT(ARANCEL.AR_FRACCION, 6)<>''SINFRA'' AND LEFT(ARANCEL.AR_FRACCION, 6)<>''SIN FR''')



	-- certificado
	if @CF_ACTTASACERTO<>'0' 
	BEGIN
		if (select CF_USAPROVEECERTORIG from configuracion)='S'  -- verificando proveedor
		begin
			exec('UPDATE 	['+@user+'TempTasa] 
			SET ['+@user+'TempTasa].PAR_BEN=(SELECT PAISARA.PAR_BEN
						FROM PAISARA WHERE PAISARA.AR_CODIGO = ['+@user+'TempTasa].AR_IMPMX 
						AND PAISARA.PA_CODIGO = ['+@user+'TempTasa].PA_ORIGEN AND 
					               PAISARA.SPI_CODIGO = ['+@user+'TempTasa].SPI_CODIGOPAIS)
			WHERE MA_CODIGO IN 
				(SELECT     CERTORIGMPDET.MA_CODIGO
				FROM         CERTORIGMP INNER JOIN
				                      CERTORIGMPDET ON CERTORIGMP.CMP_CODIGO = CERTORIGMPDET.CMP_CODIGO 
				WHERE     (CERTORIGMP.CMP_IFECHA <= ['+@user+'TempTasa].FI_FECHA) AND (CERTORIGMP.CMP_VFECHA >= ['+@user+'TempTasa].FI_FECHA)
				AND CERTORIGMP.CMP_ESTATUS=''V'' AND  LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6) = ['+@user+'TempTasa].AR_FRACCION AND CERTORIGMPDET.PA_CLASE= ['+@user+'TempTasa].PA_ORIGEN
				AND CERTORIGMPDET.PR_CODIGO = ['+@user+'TempTasa].PR_CODIGO
				GROUP BY CERTORIGMPDET.MA_CODIGO, LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6)) 
				AND (SELECT PAISARA.PAR_BEN
						FROM PAISARA WHERE PAISARA.AR_CODIGO=['+@user+'TempTasa].AR_IMPMX 
						AND PAISARA.PA_CODIGO = ['+@user+'TempTasa].PA_ORIGEN AND 
					               PAISARA.SPI_CODIGO = ['+@user+'TempTasa].SPI_CODIGOPAIS) IS NOT NULL')
		
		end
		else
		begin
			exec('UPDATE 	['+@user+'TempTasa] 
			SET ['+@user+'TempTasa].PAR_BEN=(SELECT PAISARA.PAR_BEN
						FROM PAISARA WHERE PAISARA.AR_CODIGO = ['+@user+'TempTasa].AR_IMPMX 
						AND PAISARA.PA_CODIGO = ['+@user+'TempTasa].PA_ORIGEN AND 
					               PAISARA.SPI_CODIGO = ['+@user+'TempTasa].SPI_CODIGOPAIS)
			WHERE MA_CODIGO IN 
				(SELECT     CERTORIGMPDET.MA_CODIGO
				FROM         CERTORIGMP INNER JOIN
				                      CERTORIGMPDET ON CERTORIGMP.CMP_CODIGO = CERTORIGMPDET.CMP_CODIGO 
				WHERE     (CERTORIGMP.CMP_IFECHA <= ['+@user+'TempTasa].FI_FECHA) AND (CERTORIGMP.CMP_VFECHA >= ['+@user+'TempTasa].FI_FECHA)
				AND CERTORIGMP.CMP_ESTATUS=''V'' AND  LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6) = ['+@user+'TempTasa].AR_FRACCION AND CERTORIGMPDET.PA_CLASE= ['+@user+'TempTasa].PA_ORIGEN
				GROUP BY CERTORIGMPDET.MA_CODIGO, LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6))			
				AND (SELECT PAISARA.PAR_BEN
						FROM PAISARA WHERE PAISARA.AR_CODIGO=['+@user+'TempTasa].AR_IMPMX 
						AND PAISARA.PA_CODIGO = ['+@user+'TempTasa].PA_ORIGEN AND 
					               PAISARA.SPI_CODIGO = ['+@user+'TempTasa].SPI_CODIGOPAIS) IS NOT NULL')

		end
	END


	
	
	-- PPS 
	if @CF_ACTTASAPERPPS<>'0' 
	begin

		--<> producto terminado
		exec('exec sp_droptable '''+@user+'TempTasaSector''
		      exec sp_droptable '''+@user+'TempTasaSector2''')

		-- Todo esto es para tomar el procentaje mas bajo de los sectores aprobados

		exec('SELECT     SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
		INTO dbo.['+@user+'TempTasaSector]
		FROM         SECTORARA INNER JOIN
		                      PERMISODET ON SECTORARA.SE_CODIGO = PERMISODET.SE_CODIGO INNER JOIN
		                      PERMISO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
		                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
		WHERE     (IDENTIFICA.IDE_CLAVE = ''PS'') AND (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) 
			AND SECTORARA.SA_PORCENT<>-1
		GROUP BY SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
		ORDER BY SECTORARA.AR_CODIGO')

		if (select cf_pagocontribucion from configuracion)<>'E' and (select cf_cambiotasasec from configuracion)='S'
		begin

			exec('SELECT     SP.AR_CODIGO, MIN(SP.SA_PORCENT) AS SA_PORCENT, (SELECT MIN(S2.SE_CODIGO) FROM ['+@user+'TempTasaSector] S2 where S2.AR_CODIGO=SP.AR_CODIGO
			AND S2.SA_PORCENT=MIN(SP.SA_PORCENT)) AS SE_CODIGO
			INTO dbo.['+@user+'TempTasaSector2]
			FROM ['+@user+'TempTasaSector] SP
			GROUP BY SP.AR_CODIGO
			ORDER BY SP.AR_CODIGO')

			-- hasta aqui

			exec('UPDATE ['+@user+'TempTasa]
			SET     ['+@user+'TempTasa].SA_PORCENT= SP.SA_PORCENT,
				['+@user+'TempTasa].MA_SEC_IMP= SP.SE_CODIGO
			FROM    ['+@user+'TempTasa] INNER JOIN
			        ['+@user+'TempTasaSector2] SP ON ['+@user+'TempTasa].AR_IMPMX = SP.AR_CODIGO
			WHERE     (['+@user+'TempTasa].TI_CODIGO IN
			                          (SELECT     ti_codigo
			                            FROM          configuratipo
			                            WHERE      cft_tipo <> ''P'')) AND (SP.SA_PORCENT <> -1)')



		end
		else
		begin
			-- solo actualiza la tasa
			exec('UPDATE ['+@user+'TempTasa] 
			SET     ['+@user+'TempTasa].SA_PORCENT= SP.SA_PORCENT
			FROM         ['+@user+'TempTasa] INNER JOIN
			                      ['+@user+'TempTasaSector] SP ON ['+@user+'TempTasa].AR_IMPMX = SP.AR_CODIGO AND
				         ['+@user+'TempTasa].MA_SEC_IMP = SP.SE_CODIGO
			WHERE     (['+@user+'TempTasa].TI_CODIGO IN
			                          (SELECT     ti_codigo
			                            FROM          configuratipo
			                            WHERE      cft_tipo <> ''P'')) AND (SP.SA_PORCENT <> -1)')
		end


	end

	
	-- regla octava
	if @CF_ACTTASAPER8VA<>'0' 
	begin

		IF (SELECT CONFIGURAPERMISO.CFM_PAISHIJO FROM CONFIGURAPERMISO INNER JOIN IDENTIFICA ON CONFIGURAPERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
		     WHERE IDENTIFICA.IDE_CLAVE = 'C1')='S'
		begin

			exec('UPDATE ['+@user+'TempTasa]
			SET     AR_PORCENT_8VA= ARANCEL.AR_PORCENT_8VA
			FROM         ['+@user+'TempTasa]  INNER JOIN
			                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
			WHERE   (ARANCEL.AR_PORCENT_8VA <> - 1)
				AND MA_CODIGO IN
				(SELECT     TT1.MA_CODIGO
				FROM         PERMISO INNER JOIN
			                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO INNER JOIN
			                      MAESTROCATEG INNER JOIN
			                      ['+@user+'TempTasa] TT1 ON MAESTROCATEG.MA_CODIGO = TT1.MA_CODIGO ON PERMISODET.MA_GENERICO = MAESTROCATEG.CPE_CODIGO AND 
			                      PERMISODET.AR_EXPMX = TT1.AR_IMPMX INNER JOIN
			                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
				         PERMISOPAIS ON PERMISO.PE_CODIGO = PERMISOPAIS.PE_CODIGO AND 
				         TT1.PA_ORIGEN = PERMISOPAIS.PA_CODIGO
				WHERE     IDENTIFICA.IDE_CLAVE = ''C1'' AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PERMISO.PE_FECHAVENC>='''+@fi_fecha+''')')
		end
		else
		begin
			exec('UPDATE ['+@user+'TempTasa]
			SET     AR_PORCENT_8VA= ARANCEL.AR_PORCENT_8VA
			FROM         ['+@user+'TempTasa]  INNER JOIN
			                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
			WHERE   (ARANCEL.AR_PORCENT_8VA <> - 1)
				AND MA_CODIGO IN
				(SELECT     TT1.MA_CODIGO
				FROM         PERMISO INNER JOIN
			                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO INNER JOIN
			                      MAESTROCATEG INNER JOIN
			                      ['+@user+'TempTasa] TT1 ON MAESTROCATEG.MA_CODIGO = TT1.MA_CODIGO ON PERMISODET.MA_GENERICO = MAESTROCATEG.CPE_CODIGO AND 
			                      PERMISODET.AR_EXPMX = TT1.AR_IMPMX INNER JOIN
			                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
				WHERE     IDENTIFICA.IDE_CLAVE = ''C1'' AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PERMISO.PE_FECHAVENC>='''+@fi_fecha+''')')
		end
	end


	--   hasta aqui todas las tasas y estan en la tabla 


	-- para tomar el orden de las condiciones 
	exec('exec sp_droptable '''+@user+'OrdenTasa''')
	exec('CREATE TABLE [dbo].['+@user+'OrdenTasa] ([enunciado] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		[orden] [int] NOT NULL) ON [PRIMARY]')
	
	
	exec('insert into ['+@user+'OrdenTasa](enunciado,orden)
	SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=PAR_BEN, MA_DEF_TIPNVO=''''P'''' WHERE PAR_BEN<>-1 AND (MA_POR_DEFNVO>=PAR_BEN OR MA_POR_DEFNVO=-1)'',
		CF_ACTTASACERTO
	FROM         CONFIGURACION
	
	insert into ['+@user+'OrdenTasa](enunciado,orden)
	SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=SA_PORCENT, MA_DEF_TIPNVO=''''S'''' WHERE SA_PORCENT<>-1 AND MA_POR_DEFNVO>SA_PORCENT'',
	CF_ACTTASAPERPPS
	FROM         CONFIGURACION
	
	insert into ['+@user+'OrdenTasa](enunciado,orden)
	SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=AR_PORCENT_8VA, MA_DEF_TIPNVO=''''R'''' WHERE AR_PORCENT_8VA<>-1 AND MA_POR_DEFNVO>AR_PORCENT_8VA'',
	CF_ACTTASAPER8VA
	FROM         CONFIGURACION
		
	declare @enunciado varchar(800)

	declare cur_orden cursor for
		select enunciado from ['+@user+'OrdenTasa]	
		where orden<>0 order by orden
	open cur_orden
		FETCH NEXT FROM  cur_orden INTO @enunciado
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			exec(@enunciado)
	
		FETCH NEXT FROM  cur_orden INTO @enunciado
	END
	CLOSE cur_orden
	DEALLOCATE cur_orden')




	-- actualiza al sector con tasa mas alta (solo para empresa certificada)
	if (select CF_CAMBIOTASASEC from configuracion)='S'
	if exists(SELECT CL_EMPCERTIFICADA FROM CLIENTE WHERE CL_EMPRESA='S' and CL_EMPCERTIFICADA is not null and CL_EMPCERTIFICADA<>'')  and
 	not exists(select tf_nombre from tfactura where tf_nombre like '%definitiva%' and tf_codigo in (select tf_codigo from factimp where fi_codigo=@fi_codigo)) 
	begin
		exec('exec sp_droptable ''['+@user+'TempTasaSector3]''')

		exec('SELECT     S3.AR_CODIGO, MAX(round(S3.SA_PORCENT,6)) AS SA_PORCENT, (SELECT MIN(S2.SE_CODIGO) FROM ['+@user+'TempTasaSector] S2 where S2.AR_CODIGO=S3.AR_CODIGO
		AND S2.SA_PORCENT=MAX(round(S3.SA_PORCENT,6))) AS SE_CODIGO
		INTO dbo.['+@user+'TempTasaSector3]
		FROM         ['+@user+'TempTasaSector] S3
		GROUP BY S3.AR_CODIGO
		ORDER BY S3.AR_CODIGO


		UPDATE ['+@user+'TempTasa]
		SET   ['+@user+'TempTasa].MA_SEC_IMP=S4.SE_CODIGO
		FROM  ['+@user+'TempTasa] INNER JOIN
                      ['+@user+'TempTasaSector3] S4 ON ['+@user+'TempTasa].AR_IMPMX = S4.AR_CODIGO
		WHERE    ['+@user+'TempTasa].MA_DEF_TIPNVO=''S''')


	end


	exec('UPDATE FACTIMPDET
	SET     FACTIMPDET.SPI_CODIGO= 0,
		FACTIMPDET.FID_SEC_IMP= isnull(['+@user+'TempTasa].MA_SEC_IMP,0),
		FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
	FROM         ['+@user+'TempTasa] INNER JOIN
	                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
	WHERE     ['+@user+'TempTasa].MA_DEF_TIPNVO=''S'' and FACTIMPDET.FID_INDICED ='+ @fid_indiced)

	exec('UPDATE FACTIMPDET
	SET     FACTIMPDET.SPI_CODIGO= isnull(['+@user+'TempTasa].SPI_CODIGOPAIS,0), 
		FACTIMPDET.FID_SEC_IMP=0,
		FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
	FROM         ['+@user+'TempTasa] INNER JOIN	                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
	WHERE     ['+@user+'TempTasa].MA_DEF_TIPNVO=''P'' and FACTIMPDET.FID_INDICED ='+ @fid_indiced)

exec('UPDATE FACTIMPDET
	SET     FACTIMPDET.SPI_CODIGO= 0, 
		FACTIMPDET.FID_SEC_IMP=0,
		FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
	FROM         ['+@user+'TempTasa] INNER JOIN
	                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
	WHERE     ['+@user+'TempTasa].MA_DEF_TIPNVO<>''P'' and ['+@user+'TempTasa].MA_DEF_TIPNVO<>''S'' and FACTIMPDET.FID_INDICED ='+ @fid_indiced)


 exec('exec sp_droptable '''+@user+'TempTasaSector''
	exec sp_droptable '''+@user+'TempTasaSector2''
	exec sp_droptable '''+@user+'TempTasaSector3''
	exec sp_droptable '''+@user+'SectoresTemp''
	exec sp_droptable '''+@user+'OrdenTasa''
	exec sp_droptable '''+@user+'TempTasa''')




		
					--Yolanda A. (2009-08-12)
					--Se agrego la parte para que cambie la fracción ImpMx, el factor de conversión, la UM de la fracción de acuerdo a la fracción de Regla 8va en caso de que esa sea la Tasa Mas Baja.
					--Se cambio también de donde debe tomar (del maestro ó de la factura) la % de tasa a aplicar si tiene asignada una fracción 9802
					/*UPDATE FACTIMPDET
					SET FID_POR_DEF=dbo.GetAdvalorem(FACTIMPDET.AR_IMPMX, FACTIMPDET.PA_CODIGO, FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.SPI_CODIGO)
					WHERE FACTIMPDET.FID_INDICED =  @fid_indiced*/
					UPDATE FACTIMPDET
     					SET FID_POR_DEF=(CASE WHEN FACTIMPDET.AR_IMPMX in (select ar_codigo from arancel where pa_codigo=154 and ar_fraccion like '9802%') then
								  dbo.GetAdvalorem(MAESTRO.AR_IMPMX, FACTIMPDET.PA_CODIGO, FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.SPI_CODIGO)
                                                         else
								    dbo.GetAdvalorem(FACTIMPDET.AR_IMPMX, FACTIMPDET.PA_CODIGO, FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.SPI_CODIGO)
						         end) , 
				    		    ar_impmx = case when FACTIMPDET.FID_DEF_TIP = 'R' and 
							             isnull((select ar_impmxR8 from maestro inner join arancel on maestro.ar_impmxR8 = arancel.ar_codigo  where maestro.ma_codigo = factimpdet.ma_codigo and arancel.ar_fraccion like '9802%' ),-100) <>-100 then   
								   (select ar_impmxR8 from maestro where maestro.ma_codigo = factimpdet.ma_codigo)
			  			               else 
						 	            factimpdet.ar_impmx 	
							       end,
						    eq_impmx = case when FACTIMPDET.FID_DEF_TIP = 'R' and 
							             isnull((select eq_impmxR8 from maestro inner join arancel on maestro.ar_impmxR8 = arancel.ar_codigo  where maestro.ma_codigo = factimpdet.ma_codigo and arancel.ar_fraccion like '9802%' ),-100) <>-100 then   
								  (select eq_impmxR8 from maestro where maestro.ma_codigo = factimpdet.ma_codigo)
							       else 
							 	  factimpdet.eq_impmx 	
								end,
						    me_arimpmx = case when FACTIMPDET.FID_DEF_TIP = 'R' and 
							             isnull(
										(select arancel.me_codigo from maestro inner join arancel on maestro.ar_impmxR8 = arancel.ar_codigo  where maestro.ma_codigo = factimpdet.ma_codigo and arancel.ar_fraccion like '9802%' )
									    ,-100) <>-100 then   
								  (select arancel.me_codigo from maestro inner join arancel on maestro.ar_impmxR8 = arancel.ar_codigo  where maestro.ma_codigo = factimpdet.ma_codigo and arancel.ar_fraccion like '9802%' )
							       else 
							 	  factimpdet.me_arimpmx 	
			                			end
		     	                from   FACTIMPDET         
					LEFT OUTER JOIN MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO 
					WHERE FACTIMPDET.FID_INDICED =  @fid_indiced



GO
