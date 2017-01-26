SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_IMPORTACTUALIZATASABAJAFACTIMP]  (@user1 int=1)   as

SET NOCOUNT ON 
declare @CF_ACTTASACERTO char(1), @CF_ACTTASAPERPPS char(1), @CF_ACTTASAPER8VA char(1),
@user varchar(25)--, @fi_codigo varchar(50), @fi_fecha varchar(11)
, @CF_ACTTASAGENERAL char(1), @CF_ACTTASAREGLA16 char(1), @CF_ACTTASACOMPARATIVO char(1)

SELECT		@CF_ACTTASAPER8VA=CF_ACTTASAPER8VA, @CF_ACTTASAPERPPS=CF_ACTTASAPERPPS, @CF_ACTTASACERTO=CF_ACTTASACERTO,
			@CF_ACTTASAGENERAL=CF_ACTTASAGENERAL , @CF_ACTTASAREGLA16=CF_ACTTASAREGLA16, @CF_ACTTASACOMPARATIVO=CF_ACTTASACOMPARATIVO
FROM         CONFIGURACION


select @user=convert(varchar(25),@user1)



		-- se genera la tabla TempTasa
		 exec('exec sp_droptable '''+@user+'TempTasaSector''
			exec sp_droptable '''+@user+'TempTasaSector2''
			exec sp_droptable '''+@user+'TempTasaSector3''
			exec sp_droptable '''+@user+'SectoresTemp''
			exec sp_droptable '''+@user+'OrdenTasa''
			exec sp_droptable '''+@user+'TempMPSector''
			exec sp_droptable '''+@user+'TempTasa''')
		
		
		
			update CERTORIGMP
			set CMP_FECHATRANS= CMP_VFECHA
			where CMP_FECHATRANS is null
		
--		set @fi_codigo= convert(varchar(50),@fi_codigo1)
		
		
--		select @fi_fecha=convert(varchar(11),fi_fecha,101) from factimp where fi_codigo=@fi_codigo
		
	
		exec('SELECT PERMISODET.SE_CODIGO
		INTO dbo.['+@user+'SectoresTemp]
		FROM         PERMISO INNER JOIN
		                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
		                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO
		WHERE     (IDENTIFICA.IDE_CLAVE = ''PS'') AND (PERMISO.PE_APROBADO = ''S'')
		GROUP BY PERMISODET.SE_CODIGO')
		

		exec('if (select count(*) from ['+@user+'SectoresTemp])=1 update maestro set ma_sec_imp= (select se_codigo from ['+@user+'SectoresTemp]) where (ma_sec_imp is null or ma_sec_imp=0) and ma_tip_ens=''C'' or ma_tip_ens=''A''')
		
		--Yolanda A. (2009-08-12)
		--Se asigno formato de decimal a los campos que almacenan las tasas ya que almacenaban solo valores enteros
		exec ('SELECT    FACTIMPDET.FID_INDICED, ''AR_IMPMX''=CASE WHEN FACTIMPDET.AR_IMPMX in (select ar_codigo from arancel where pa_codigo=154 and
		ar_fraccion like ''9802%'') then MAESTRO.AR_IMPMX else FACTIMPDET.AR_IMPMX end, 
		FACTIMPDET.PA_CODIGO as PA_ORIGEN, MAESTRO.MA_SEC_IMP,
		convert(varchar(10),FI_FECHA, 101) as FI_FECHA, FACTIMPDET.MA_CODIGO,
		FACTIMPDET.TI_CODIGO,convert(decimal(38,6),-1.0) AS MA_POR_DEFNVO, ''G'' AS MA_DEF_TIPNVO, ISNULL((SELECT SPI_CODIGO FROM PAIS WHERE PA_CODIGO=FACTIMPDET.PA_CODIGO),0) AS SPI_CODIGOPAIS,
			999999 AS AR_FRACCION, convert(decimal(38,6),-1.0) AS PAR_BEN, convert(decimal(38,6),-1.0) AS SA_PORCENT, convert(decimal(38,6),-1.0) AS AR_PORCENT_8VA, FACTIMPDET.PR_CODIGO, convert(decimal(38,6),-1.0) AS AR_PORCENT_GENERAL, convert(decimal(38,6),-1.0) AS AR_PORCENT_16VA 
		INTO dbo.['+@user+'TempTasa]
		FROM FACTIMPDET INNER JOIN
	             FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO LEFT OUTER JOIN
	             MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
		     TFACTURA ON FACTIMP.TF_CODIGO = TFACTURA.TF_CODIGO 
		WHERE     FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX('','',RI_REGISTRO)-1),''FI_FOLIO = '','''') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE ''FI_FOLIO%'' AND RI_TIPO=''I'')')
		
		
		/*
		exec('UPDATE ['+@user+'TempTasa]
		SET     ['+@user+'TempTasa].AR_FRACCION= LEFT(ARANCEL.AR_FRACCION, 6), ['+@user+'TempTasa].MA_POR_DEFNVO= ARANCEL.AR_ADVDEF
		FROM  ['+@user+'TempTasa]  INNER JOIN
		                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
		WHERE LEFT(ARANCEL.AR_FRACCION, 6)<>''SINFRA'' AND LEFT(ARANCEL.AR_FRACCION, 6)<>''SIN FR''')
		*/
		exec('UPDATE ['+@user+'TempTasa]
		SET     ['+@user+'TempTasa].AR_FRACCION= LEFT(ARANCEL.AR_FRACCION, 6)
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
						AND CERTORIGMPDET.PR_CODIGO= ['+@user+'TempTasa].PR_CODIGO
						GROUP BY CERTORIGMPDET.MA_CODIGO, LEFT(CERTORIGMPDET.CMP_FRACCION, 6))
						
						AND (SELECT PAISARA.PAR_BEN
								FROM PAISARA WHERE PAISARA.AR_CODIGO=['+@user+'TempTasa].AR_IMPMX 
								AND PAISARA.PA_CODIGO = ['+@user+'TempTasa].PA_ORIGEN AND PAISARA.SPI_CODIGO = ['+@user+'TempTasa].SPI_CODIGOPAIS) IS NOT NULL')
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
						GROUP BY CERTORIGMPDET.MA_CODIGO, LEFT(CERTORIGMPDET.CMP_FRACCION, 6))
						
						AND (SELECT PAISARA.PAR_BEN
								FROM PAISARA WHERE PAISARA.AR_CODIGO=['+@user+'TempTasa].AR_IMPMX 
								AND PAISARA.PA_CODIGO = ['+@user+'TempTasa].PA_ORIGEN AND PAISARA.SPI_CODIGO = ['+@user+'TempTasa].SPI_CODIGOPAIS) IS NOT NULL')
							
				end		


			END
		
		
			
			
			-- PPS aqui valida tomando en cuenta que el porcentaje sea <> de -1 es decir >= 0
			if @CF_ACTTASAPERPPS<>'0' and (select CF_ACTTASACOMPARATIVO from configuracion)='N'
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
					--28-abril-06
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
					exec ('UPDATE ['+@user+'TempTasa] 
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


			-- PPS aqui valida tomando en cuenta que el porcentaje sea = 0
			if @CF_ACTTASAPERPPS<>'0' and (select CF_ACTTASACOMPARATIVO from configuracion)='S'
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
						AND SECTORARA.SA_PORCENT = 0
					GROUP BY SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
					ORDER BY SECTORARA.AR_CODIGO')
		
				if (select cf_pagocontribucion from configuracion)<>'E' and (select cf_cambiotasasec from configuracion)='S'
				begin
					--28-abril-06
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
					exec ('UPDATE ['+@user+'TempTasa] 
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
						WHERE     IDENTIFICA.IDE_CLAVE = ''C1'' AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PERMISO.PE_FECHAVENC>=['+@user+'TempTasa].FI_FECHA)')
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
						WHERE     IDENTIFICA.IDE_CLAVE = ''C1'' AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PERMISO.PE_FECHAVENC>=['+@user+'TempTasa].FI_FECHA)')
						
				end
			end

			-- regla general
			if @CF_ACTTASAGENERAL <> '0'
			begin
					exec('UPDATE ['+@user+'TempTasa]
					SET     AR_PORCENT_GENERAL= ARANCEL.AR_ADVDEF
					FROM         ['+@user+'TempTasa]  INNER JOIN
					                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
					WHERE   (ARANCEL.AR_ADVDEF = 0)')
				
			end		
			-- Regla 16
			if @CF_ACTTASAREGLA16 <> '0'
			begin
					exec('UPDATE ['+@user+'TempTasa]
					SET     AR_PORCENT_16VA= ARANCEL.AR_ADVDEF
					FROM         ['+@user+'TempTasa]  INNER JOIN
					                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
					              LEFT OUTER JOIN MAESTRO on ['+@user+'TempTasa].MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE   MAESTRO.MA_SERVICIO = ''S'' ')
		
			end
		
		
			--   hasta aqui todas las tasas y estan en la tabla 
		
		
			-- para tomar el orden de las condiciones 
			exec('exec sp_droptable '''+@user+'OrdenTasa''')
			exec('CREATE TABLE [dbo].['+@user+'OrdenTasa] ([enunciado] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[orden] [int] NOT NULL) ON [PRIMARY]')
			
			
			exec('insert into ['+@user+'OrdenTasa](enunciado,orden)
			SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=PAR_BEN, MA_DEF_TIPNVO=''''P'''' WHERE PAR_BEN<>-1 AND (MA_POR_DEFNVO>PAR_BEN OR MA_POR_DEFNVO=-1)'',
				CF_ACTTASACERTO
			FROM         CONFIGURACION
			
			insert into ['+@user+'OrdenTasa](enunciado,orden)
			SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=SA_PORCENT, MA_DEF_TIPNVO=''''S'''' WHERE SA_PORCENT<>-1 AND (MA_POR_DEFNVO>SA_PORCENT OR MA_POR_DEFNVO=-1)'',
			CF_ACTTASAPERPPS
			FROM         CONFIGURACION
			
			insert into ['+@user+'OrdenTasa](enunciado,orden)
			SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=AR_PORCENT_8VA, MA_DEF_TIPNVO=''''R'''' WHERE AR_PORCENT_8VA<>-1 AND (MA_POR_DEFNVO>AR_PORCENT_8VA OR MA_POR_DEFNVO=-1)'',
			CF_ACTTASAPER8VA
			FROM         CONFIGURACION

			insert into ['+@user+'OrdenTasa](enunciado,orden)
			SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=AR_PORCENT_GENERAL, MA_DEF_TIPNVO=''''G'''' WHERE AR_PORCENT_GENERAL<>-1 AND (MA_POR_DEFNVO>AR_PORCENT_GENERAL OR MA_POR_DEFNVO=-1)'',
			CF_ACTTASAGENERAL
			FROM         CONFIGURACION

			insert into ['+@user+'OrdenTasa](enunciado,orden)
			SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=AR_PORCENT_16VA, MA_DEF_TIPNVO=''''E'''' WHERE AR_PORCENT_16VA<>-1 AND (MA_POR_DEFNVO>AR_PORCENT_16VA OR MA_POR_DEFNVO=-1)'',
			CF_ACTTASAREGLA16
			FROM         CONFIGURACION

		
			IF (SELECT CF_ACTTASAVERR8 FROM CONFIGURACION)=''S''
			begin
				declare @fechaactual varchar(11)
		
				select @fechaactual=convert(varchar(11),getdate(),101)
		
				exec SP_FILL_TempBOMNivelTodos @fechaactual
		
				exec sp_droptable '''+@user+'TempMPSector''
		
				SELECT     MAESTRO.SE_CODIGO, BOM_STRUCT.BST_HIJO
				into dbo.['+@user+'TempMPSector]
				FROM         TempBOM_NIVEL INNER JOIN
				                      BOM_STRUCT ON TempBOM_NIVEL.BST_HIJO = BOM_STRUCT.BSU_SUBENSAMBLE INNER JOIN
				                      MAESTRO ON TempBOM_NIVEL.BST_PT = MAESTRO.MA_CODIGO
				WHERE (MAESTRO.SE_CODIGO IS NOT NULL) AND MAESTRO.SE_CODIGO<>0
				GROUP BY MAESTRO.SE_CODIGO, BOM_STRUCT.BST_HIJO
				ORDER BY BOM_STRUCT.BST_HIJO
		
		
				insert into ['+@user+'OrdenTasa](enunciado,orden)
				SELECT     ''UPDATE ['+@user+'TEMPTASA] SET MA_POR_DEFNVO=AR_PORCENT_8VA, MA_DEF_TIPNVO=''''R'''' WHERE AR_PORCENT_8VA<>-1 AND MA_POR_DEFNVO>=AR_PORCENT_8VA
						AND MA_DEF_TIPNVO=''''S'''' AND MA_CODIGO IN (SELECT BST_HIJO FROM ['+@user+'TempMPSector] GROUP BY BST_HIJO HAVING COUNT(*)=1)'',
				CF_ACTTASAPER8VA
				FROM         CONFIGURACION
			end
		
				
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
		

			--Actualiza tasa mas baja comparativo PPS vs General, esta actualizacion se hara siempre y cuando 
			--No haya aplicado ninguna tasa y se tenga la opcion en configuracion de realizar comparativo
			if (select CF_ACTTASACOMPARATIVO from configuracion)='S'
			begin
				--<> producto terminado
					exec('exec sp_droptable '''+@user+'TempTasaSector''')
					exec('exec sp_droptable '''+@user+'TempTasaGeneral''')
					      
		
					--Obtiene las tasas PPS de las fracciones 
					/*
					exec('SELECT     SECTORARA.AR_CODIGO, min(SECTORARA.SA_PORCENT) SA_PORCENT, ['+@user+'TempTasa].FID_INDICED
					INTO dbo.['+@user+'TempTasaSector]
					FROM         SECTORARA INNER JOIN
					                      PERMISODET ON SECTORARA.SE_CODIGO = PERMISODET.SE_CODIGO INNER JOIN
					                      PERMISO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
					                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
					                      ['+@user+'TempTasa] ON SECTORARA.AR_CODIGO = ['+@user+'TempTasa].AR_IMPMX
					WHERE     (IDENTIFICA.IDE_CLAVE = ''PS'') AND (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) 
						AND SECTORARA.SA_PORCENT <> -1 and ['+@user+'TempTasa].MA_POR_DEFNVO  = -1
					GROUP BY SECTORARA.AR_CODIGO, ['+@user+'TempTasa].FID_INDICED
					ORDER BY SECTORARA.AR_CODIGO')*/
					
					exec('select SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, ['+@user+'TempTasa].FID_INDICED
					INTO dbo.['+@user+'TempTasaSector]
					from maestro
						inner join maestrocateg on MAESTRO.MA_CODIGO = MAESTROCATEG.MA_CODIGO
						inner join CATEGPERMISO on MAESTROCATEG.CPE_CODIGO = CATEGPERMISO.CPE_CODIGO
						inner join PERMISODET on CATEGPERMISO.CPE_CORTO = PERMISODET.MA_NOPARTE
						inner join permiso on PERMISODET.PE_CODIGO = permiso.PE_CODIGO
						inner join ARANCEL on maestro.AR_IMPMX = ARANCEL.AR_CODIGO
						inner join SECTORARA on ARANCEL.AR_CODIGO = SECTORARA.AR_CODIGO and PERMISODET.SE_CODIGO = SECTORARA.SE_CODIGO
						inner join IDENTIFICA on permiso.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
						inner join ['+@user+'TempTasa] on MAESTRO.MA_CODIGO = ['+@user+'TempTasa].MA_CODIGO
					where IDENTIFICA.IDE_CLAVE = ''PS'' AND (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) 
					AND SECTORARA.SA_PORCENT <> -1')
					
					
					
					--Obtiene las tasas generales de las fracciones
					exec('SELECT ARANCEL.AR_CODIGO, ARANCEL.AR_ADVDEF, ['+@user+'TempTasa].FID_INDICED   
						  INTO dbo.['+@user+'TempTasaGeneral]
						  FROM ['+@user+'TempTasa] 
							INNER JOIN ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
							WHERE ['+@user+'TempTasa].MA_POR_DEFNVO = -1')
							
					
					exec('	declare @ar_impmx int, @sa_porcent decimal(38,6), @ar_advdef decimal(38,6), @ma_sec_imp int, @fid_indiced int
							declare cur_comparativo cursor for
							select fid_indiced from ['+@user+'TempTasa] where MA_POR_DEFNVO = -1 
							open cur_comparativo
							FETCH NEXT FROM cur_comparativo into @fid_indiced
							WHILE (@@FETCH_STATUS = 0)
								begin
									select @sa_porcent = sa_porcent from dbo.['+@user+'TempTasaSector] where fid_indiced = @fid_indiced
									select @ar_advdef = ar_advdef from dbo.['+@user+'TempTasaGeneral] where fid_indiced = @fid_indiced
									if @sa_porcent < @ar_advdef
										begin
											UPDATE ['+@user+'TempTasa]
											SET     MA_POR_DEFNVO= @sa_porcent, MA_DEF_TIPNVO = ''S''
											where   fid_indiced = @fid_indiced
										end
									else
										begin
											UPDATE ['+@user+'TempTasa]
											SET     MA_POR_DEFNVO= @ar_advdef, MA_DEF_TIPNVO = ''G''
											where   fid_indiced = @fid_indiced
										end
									FETCH NEXT FROM cur_comparativo into @fid_indiced
								end
							close cur_comparativo
							deallocate cur_comparativo 
						')	
					exec('exec sp_droptable '''+@user+'TempTasaGeneral''')
			end
			else
			begin
				exec('UPDATE ['+@user+'TempTasa]
				SET     ['+@user+'TempTasa].AR_FRACCION= LEFT(ARANCEL.AR_FRACCION, 6), ['+@user+'TempTasa].MA_POR_DEFNVO= ARANCEL.AR_ADVDEF
				FROM  ['+@user+'TempTasa]  INNER JOIN
									  ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
				WHERE LEFT(ARANCEL.AR_FRACCION, 6)<>''SINFRA'' AND LEFT(ARANCEL.AR_FRACCION, 6)<>''SIN FR'' and MA_POR_DEFNVO = -1 ')
			end
		
		
		
			-- actualiza al sector con tasa mas alta (solo para empresa certificada)
/*			if (select CF_CAMBIOTASASEC from configuracion)='S'
			if exists(SELECT CL_EMPCERTIFICADA FROM CLIENTE WHERE CL_EMPRESA='S' and CL_EMPCERTIFICADA is not null and CL_EMPCERTIFICADA<>'') 
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
				WHERE    ['+@user+'TempTasa].MA_DEF_TIPNVO=''S''
				AND ['+@user+'TempTasa].DEFINITIVA=''N''')
		
		
			end*/
		
			begin tran
			exec('UPDATE FACTIMPDET
			SET     FACTIMPDET.SPI_CODIGO=0, 
				FACTIMPDET.FID_SEC_IMP= isnull(['+@user+'TempTasa].MA_SEC_IMP,0),
				FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
			FROM    ['+@user+'TempTasa] INNER JOIN
			        FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
				LEFT OUTER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
			WHERE   ['+@user+'TempTasa].MA_DEF_TIPNVO=''S'' AND FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX('','',RI_REGISTRO)-1),''FI_FOLIO = '','''') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE ''FI_FOLIO%'' AND RI_TIPO=''I'')')



			commit tran
		
			begin tran
			exec('UPDATE FACTIMPDET
			SET     FACTIMPDET.SPI_CODIGO= isnull(['+@user+'TempTasa].SPI_CODIGOPAIS,0), 
				FACTIMPDET.FID_SEC_IMP= 0,
				FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
			FROM    ['+@user+'TempTasa] INNER JOIN
			        FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
				LEFT OUTER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
			WHERE  ['+@user+'TempTasa].MA_DEF_TIPNVO=''P'' AND FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX('','',RI_REGISTRO)-1),''FI_FOLIO = '','''') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE ''FI_FOLIO%'' AND RI_TIPO=''I'')')

			commit tran
		
			begin tran				
			exec('UPDATE FACTIMPDET
			SET     FACTIMPDET.SPI_CODIGO= 0, 
				FACTIMPDET.FID_SEC_IMP= 0,
				FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
			FROM         ['+@user+'TempTasa] INNER JOIN
			                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
				LEFT OUTER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
			WHERE  ['+@user+'TempTasa].MA_DEF_TIPNVO<>''P''  AND ['+@user+'TempTasa].MA_DEF_TIPNVO<>''S'' 
				AND FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX('','',RI_REGISTRO)-1),''FI_FOLIO = '','''') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE ''FI_FOLIO%'' AND RI_TIPO=''I'')')


			commit tran
		
		 exec('exec sp_droptable '''+@user+'TempTasaSector''
			exec sp_droptable '''+@user+'TempTasaSector2''
			exec sp_droptable '''+@user+'TempTasaSector3''
			exec sp_droptable '''+@user+'SectoresTemp''
			exec sp_droptable '''+@user+'OrdenTasa''
			exec sp_droptable '''+@user+'TempMPSector''
			exec sp_droptable '''+@user+'TempTasa''')
		
		
			/*UPDATE FACTIMPDET
			SET FID_POR_DEF=dbo.GetAdvalorem(FACTIMPDET.AR_IMPMX, FACTIMPDET.PA_CODIGO, FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.SPI_CODIGO)
			FROM FACTIMPDET INNER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO=FACTIMP.FI_CODIGO
			WHERE FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FI_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FI_FOLIO%' AND RI_TIPO='I')*/
					
					--Yolanda A. (2009-08-12)
					--Se agrego la parte para que cambie la fracción ImpMx, el factor de conversión, la UM de la fracción de acuerdo a la fracción de Regla 8va en caso de que esa sea la Tasa Mas Baja.
					--Se cambio también de donde debe tomar (del maestro ó de la factura) la % de tasa a aplicar si tiene asignada una fracción 9802
					UPDATE FACTIMPDET
					--SET FID_POR_DEF=dbo.GetAdvalorem(FACTIMPDET.AR_IMPMX, FACTIMPDET.PA_CODIGO, FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.SPI_CODIGO),										
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
		     	    INNER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO=FACTIMP.FI_CODIGO
					LEFT OUTER JOIN MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO 	
			WHERE FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FI_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FI_FOLIO%' AND RI_TIPO='I')
									

GO
