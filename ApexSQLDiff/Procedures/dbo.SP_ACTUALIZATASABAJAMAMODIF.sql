SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ACTUALIZATASABAJAMAMODIF] (@FECHA DATETIME,@user int=1)   as

SET NOCOUNT ON 
declare @CF_ACTTASACERTO char(1), @CF_ACTTASAPERPPS char(1), @CF_ACTTASAPER8VA char(1),
@enunciado varchar(800), @fechaactual varchar(11)


SELECT     @CF_ACTTASAPER8VA=CF_ACTTASAPER8VA, @CF_ACTTASAPERPPS=CF_ACTTASAPERPPS, @CF_ACTTASACERTO=CF_ACTTASACERTO
FROM         CONFIGURACION


-- se genera la tabla TempTasa
exec sp_droptable 'TempTasa'

exec sp_droptable 'SectoresTemp'

SELECT PERMISODET.SE_CODIGO
INTO dbo.SectoresTemp
FROM         PERMISO INNER JOIN
                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO
WHERE     (IDENTIFICA.IDE_CLAVE = 'PS') AND (PERMISO.PE_APROBADO = 'S')
GROUP BY PERMISODET.SE_CODIGO

	if (select count(*) from SectoresTemp)=1 
	update maestro set ma_sec_imp= (select se_codigo from SectoresTemp) 
	where (ma_sec_imp is null or ma_sec_imp=0) and ma_tip_ens='C' or ma_tip_ens='A'


	update CERTORIGMP
	set CMP_FECHATRANS= CMP_VFECHA
	where CMP_FECHATRANS is null

	--Yolanda A. (2009-08-12)
	--Se asigno formato de decimal a los campos que almacenan las tasas ya que almacenaban solo valores enteros
	SELECT ISNULL(AR_IMPMX,0) AS AR_IMPMX, ISNULL(PA_ORIGEN,0) AS PA_ORIGEN, ISNULL(MA_SEC_IMP,0)  AS MA_SEC_IMP, MA_CODIGO,
	TI_CODIGO , ARANCEL.AR_ADVDEF AS MA_POR_DEFNVO, 'G' AS MA_DEF_TIPNVO, ISNULL((SELECT SPI_CODIGO FROM PAIS WHERE PA_CODIGO=PA_ORIGEN),0) AS SPI_CODIGOPAIS,
	LEFT(REPLACE(AR_FRACCION,'.',''),6) AS AR_FRACCION, convert(decimal(38,6),-1.0) AS PAR_BEN, convert(decimal(38,6),-1.0) AS SA_PORCENT, convert(decimal(38,6),-1.0) AS AR_PORCENT_8VA,  0 as MA_SEC_IMPCERTDEF
	INTO dbo.TempTasa
	FROM         MAESTRO LEFT OUTER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
	WHERE MA_INV_GEN='I' AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO NOT IN ('P'))
	AND convert(varchar(11),MAESTRO.MA_ULTIMAMODIF,101)=@FECHA



	-- certificado
	if @CF_ACTTASACERTO<>'0' 
	BEGIN

		UPDATE 	TempTasa
		SET TempTasa.PAR_BEN=(SELECT PAISARA.PAR_BEN
					FROM PAISARA WHERE PAISARA.AR_CODIGO=TempTasa.AR_IMPMX 
					AND PAISARA.PA_CODIGO =TempTasa.PA_ORIGEN AND 
				               PAISARA.SPI_CODIGO = TempTasa.SPI_CODIGOPAIS)
		WHERE MA_CODIGO IN 
			(SELECT     CERTORIGMPDET.MA_CODIGO
			FROM         CERTORIGMP INNER JOIN
			                      CERTORIGMPDET ON CERTORIGMP.CMP_CODIGO = CERTORIGMPDET.CMP_CODIGO 
			WHERE     (CERTORIGMP.CMP_IFECHA <= GETDATE()) AND (CERTORIGMP.CMP_VFECHA >= GETDATE())
			AND CERTORIGMP.CMP_ESTATUS='V' AND  LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6) =TempTasa.AR_FRACCION AND CERTORIGMPDET.PA_CLASE=TempTasa.PA_ORIGEN
			GROUP BY CERTORIGMPDET.MA_CODIGO, LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6))
			AND (SELECT PAISARA.PAR_BEN
					FROM PAISARA WHERE PAISARA.AR_CODIGO=TempTasa.AR_IMPMX 
					AND PAISARA.PA_CODIGO =TempTasa.PA_ORIGEN AND 
				               PAISARA.SPI_CODIGO = TempTasa.SPI_CODIGOPAIS) IS NOT NULL
		

	END


	
	
	-- PPS 
	if @CF_ACTTASAPERPPS<>'0' 
	begin
		--<> producto terminado
		exec sp_droptable 'TempTasaSector'
		exec sp_droptable 'TempTasaSector2'

		-- Todo esto es para tomar el procentaje mas bajo de los sectores aprobados

		SELECT     SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
		INTO dbo.TempTasaSector
		FROM         SECTORARA INNER JOIN
		                      PERMISODET ON SECTORARA.SE_CODIGO = PERMISODET.SE_CODIGO INNER JOIN
		                      PERMISO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
		                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
		WHERE     (IDENTIFICA.IDE_CLAVE = 'PS') AND (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) 
			AND SECTORARA.SA_PORCENT<>-1
		GROUP BY SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
		ORDER BY SECTORARA.AR_CODIGO		

		if (select cf_pagocontribucion from configuracion)<>'E' and (select cf_cambiotasasec from configuracion)='S'
		begin

			SELECT     SP.AR_CODIGO, MIN(SP.SA_PORCENT) AS SA_PORCENT, (SELECT MIN(S2.SE_CODIGO) FROM TempTasaSector S2 where S2.AR_CODIGO=SP.AR_CODIGO
			AND S2.SA_PORCENT=MIN(SP.SA_PORCENT)) AS SE_CODIGO
			INTO dbo.TempTasaSector2
			FROM TempTasaSector SP
			GROUP BY SP.AR_CODIGO
			ORDER BY SP.AR_CODIGO

			-- hasta aqui

			UPDATE TempTasa
			SET     TempTasa.SA_PORCENT= SP.SA_PORCENT,
				TempTasa.MA_SEC_IMP= SP.SE_CODIGO
			FROM         TempTasa INNER JOIN
			                      TempTasaSector2 SP ON TempTasa.AR_IMPMX = SP.AR_CODIGO
			WHERE     (TempTasa.TI_CODIGO IN
			                          (SELECT     ti_codigo
			                            FROM          configuratipo
			                            WHERE      cft_tipo <> 'P')) AND (SP.SA_PORCENT <> -1)

			-- actualiza el sector del pt
			UPDATE MAESTRO
			SET     MAESTRO.MA_SEC_IMP= SP.SE_CODIGO
			FROM         MAESTRO INNER JOIN
			                      TempTasaSector2 SP ON MAESTRO.AR_IMPMX = SP.AR_CODIGO
			WHERE     (MAESTRO.TI_CODIGO IN
			                          (SELECT     ti_codigo
			                            FROM          configuratipo
			                            WHERE      cft_tipo = 'P')) AND (SP.SA_PORCENT <> -1)

		end
		else
		begin
			-- solo actualiza la tasa
			UPDATE TempTasa
			SET     TempTasa.SA_PORCENT= SP.SA_PORCENT
			FROM         TempTasa INNER JOIN
			                      TempTasaSector SP ON TempTasa.AR_IMPMX = SP.AR_CODIGO AND
				         TempTasa.MA_SEC_IMP = SP.SE_CODIGO
			WHERE     (TempTasa.TI_CODIGO IN
			                          (SELECT     ti_codigo
			                            FROM          configuratipo
			                            WHERE      cft_tipo <> 'P')) AND (SP.SA_PORCENT <> -1)
		end
	end

	
	-- regla octava
	if @CF_ACTTASAPER8VA<>'0' 
	begin

		IF (SELECT CONFIGURAPERMISO.CFM_PAISHIJO FROM CONFIGURAPERMISO INNER JOIN IDENTIFICA ON CONFIGURAPERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
		     WHERE IDENTIFICA.IDE_CLAVE = 'C1')='S'
		begin
	
			UPDATE TempTasa
			SET     AR_PORCENT_8VA= ARANCEL.AR_PORCENT_8VA
			FROM         TempTasa INNER JOIN
			                      ARANCEL ON TempTasa.AR_IMPMX = ARANCEL.AR_CODIGO
			WHERE     (TempTasa.MA_POR_DEFNVO <> 0)  AND (ARANCEL.AR_PORCENT_8VA <> - 1)
				AND MA_CODIGO IN
				(SELECT     TempTasa1.MA_CODIGO
				FROM         PERMISO INNER JOIN
				                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO INNER JOIN
				                      MAESTROCATEG INNER JOIN
				                      TempTasa TempTasa1 ON MAESTROCATEG.MA_CODIGO = TempTasa1.MA_CODIGO ON 
				                      PERMISODET.MA_GENERICO = MAESTROCATEG.CPE_CODIGO AND PERMISODET.AR_EXPMX = TempTasa1.AR_IMPMX INNER JOIN
				                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
				                      PERMISOPAIS ON PERMISO.PE_CODIGO = PERMISOPAIS.PE_CODIGO AND 
				                      TempTasa1.PA_ORIGEN = PERMISOPAIS.PA_CODIGO
				WHERE  PERMISO.PE_APROBADO = 'S' AND (IDENTIFICA.IDE_CLAVE = 'C1') AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PE_FECHAVENC>=GETDATE())
		end
		else
		begin
			UPDATE TempTasa
			SET     AR_PORCENT_8VA= ARANCEL.AR_PORCENT_8VA
			FROM         TempTasa INNER JOIN
			                      ARANCEL ON TempTasa.AR_IMPMX = ARANCEL.AR_CODIGO
			WHERE     (TempTasa.MA_POR_DEFNVO <> 0)  AND (ARANCEL.AR_PORCENT_8VA <> - 1)
				AND MA_CODIGO IN
				(SELECT     TempTasa1.MA_CODIGO
				FROM         PERMISO INNER JOIN
				                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO INNER JOIN
				                      MAESTROCATEG INNER JOIN
				                      TempTasa TempTasa1 ON MAESTROCATEG.MA_CODIGO = TempTasa1.MA_CODIGO ON 
				                      PERMISODET.MA_GENERICO = MAESTROCATEG.CPE_CODIGO AND PERMISODET.AR_EXPMX = TempTasa1.AR_IMPMX INNER JOIN
				                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO 
				WHERE     PERMISO.PE_APROBADO = 'S' AND (IDENTIFICA.IDE_CLAVE = 'C1') AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PE_FECHAVENC>=GETDATE())

		end
	end


	--   hasta aqui todas las tasas y estan en la tabla 


	/* para tomar el orden de las condiciones */
	exec sp_droptable 'OrdenTasa'
	CREATE TABLE [dbo].[OrdenTasa] (
		[enunciado] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		[orden] [int] NOT NULL 
	) ON [PRIMARY]
	
	
	insert into OrdenTasa(enunciado,orden)
	SELECT     'UPDATE TEMPTASA SET MA_POR_DEFNVO=PAR_BEN, MA_DEF_TIPNVO=''P'' WHERE PAR_BEN<>-1 AND (MA_POR_DEFNVO>=PAR_BEN OR MA_POR_DEFNVO=-1)',
		CF_ACTTASACERTO
	FROM         CONFIGURACION
	
	insert into OrdenTasa(enunciado,orden)
	SELECT     'UPDATE TEMPTASA SET MA_POR_DEFNVO=SA_PORCENT, MA_DEF_TIPNVO=''S'' WHERE SA_PORCENT<>-1 AND MA_POR_DEFNVO>SA_PORCENT',
	CF_ACTTASAPERPPS
	FROM         CONFIGURACION
	
	insert into OrdenTasa(enunciado,orden)
	SELECT     'UPDATE TEMPTASA SET MA_POR_DEFNVO=AR_PORCENT_8VA, MA_DEF_TIPNVO=''R'' WHERE AR_PORCENT_8VA<>-1 AND MA_POR_DEFNVO>AR_PORCENT_8VA',
	CF_ACTTASAPER8VA	FROM         CONFIGURACION
	
	
	IF (SELECT CF_ACTTASAVERR8 FROM CONFIGURACION)='S'
	begin
		select @fechaactual=convert(varchar(11),getdate(),101)

		exec SP_FILL_TempBOMNivelTodos @fechaactual

		exec sp_droptable 'TempMPSector'

		SELECT     MAESTRO.SE_CODIGO, BOM_STRUCT.BST_HIJO
		into dbo.TempMPSector
		FROM         TempBOM_NIVEL INNER JOIN
		                      BOM_STRUCT ON TempBOM_NIVEL.BST_HIJO = BOM_STRUCT.BSU_SUBENSAMBLE INNER JOIN
		                      MAESTRO ON TempBOM_NIVEL.BST_PT = MAESTRO.MA_CODIGO
		WHERE (MAESTRO.SE_CODIGO IS NOT NULL) AND MAESTRO.SE_CODIGO<>0
		GROUP BY MAESTRO.SE_CODIGO, BOM_STRUCT.BST_HIJO
		ORDER BY BOM_STRUCT.BST_HIJO

		insert into OrdenTasa(enunciado,orden)
		SELECT     'UPDATE TEMPTASA SET MA_POR_DEFNVO=AR_PORCENT_8VA, MA_DEF_TIPNVO=''R'' WHERE AR_PORCENT_8VA<>-1 AND MA_POR_DEFNVO>=AR_PORCENT_8VA
			AND MA_DEF_TIPNVO=''S'' AND MA_CODIGO IN (SELECT BST_HIJO FROM TempMPSector GROUP BY BST_HIJO HAVING COUNT(*)=1)',
		CF_ACTTASAPER8VA
		FROM         CONFIGURACION
	end

	
	declare cur_orden cursor for
		select enunciado from OrdenTasa	
		where orden<>0 order by orden
	open cur_orden
		FETCH NEXT FROM  cur_orden INTO @enunciado
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			exec(@enunciado)
	
		FETCH NEXT FROM  cur_orden INTO @enunciado
	END
	CLOSE cur_orden
	DEALLOCATE cur_orden


	begin tran
		UPDATE MAESTRO
		SET     MAESTRO.SE_CODIGO= PERMISODET.SE_CODIGO
		FROM         MAESTROCATEG INNER JOIN
		                      MAESTRO ON MAESTROCATEG.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
		                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO INNER JOIN
		                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO INNER JOIN
		                      PERMISO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
		                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
		WHERE     (IDENTIFICA.IDE_CLAVE = 'PS') AND (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) AND 
		                      (CONFIGURATIPO.CFT_TIPO = 'P' or CONFIGURATIPO.CFT_TIPO = 'S') AND (PERMISODET.SE_CODIGO IS NOT NULL) AND 
		                      (MAESTRO.SE_CODIGO <> PERMISODET.SE_CODIGO OR
		                      MAESTRO.SE_CODIGO IS NULL)
	commit tran


	-- actualiza al sector con tasa mas alta (solo para empresa certificada)
	if (select CF_CAMBIOTASASEC from configuracion)='S'
	if exists(SELECT CL_EMPCERTIFICADA FROM CLIENTE WHERE CL_EMPRESA='S' and CL_EMPCERTIFICADA is not null and CL_EMPCERTIFICADA<>'') 
	begin
		exec sp_droptable 'TempTasaSector3'

		SELECT     S3.AR_CODIGO, MAX(round(S3.SA_PORCENT,6)) AS SA_PORCENT, (SELECT MIN(S2.SE_CODIGO) FROM TempTasaSector S2 where S2.AR_CODIGO=S3.AR_CODIGO
		AND S2.SA_PORCENT=MAX(round(S3.SA_PORCENT,6))) AS SE_CODIGO
		INTO dbo.TempTasaSector3
		FROM         TempTasaSector S3
		GROUP BY S3.AR_CODIGO
		ORDER BY S3.AR_CODIGO


		UPDATE TempTasa
		SET     TempTasa.MA_SEC_IMPCERTDEF=S4.SE_CODIGO
		FROM         TempTasa INNER JOIN
		                      TempTasaSector3 S4 ON TempTasa.AR_IMPMX = S4.AR_CODIGO
		WHERE    TempTasa.MA_DEF_TIPNVO='S'

		begin tran
		-- actualiza el sector del pt
		UPDATE MAESTRO
		SET     MAESTRO.MA_SEC_IMPCERTDEF=S4.SE_CODIGO
		FROM         MAESTRO INNER JOIN
		                      TempTasaSector3 S4 ON MAESTRO.AR_IMPMX = S4.AR_CODIGO
		WHERE     (MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo
		                            FROM          configuratipo
		                            WHERE      cft_tipo = 'P')) AND (S4.SA_PORCENT <> -1)
		commit tran


	end

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.SPI_CODIGO= TempTasa.SPI_CODIGOPAIS, 
		MAESTRO.MA_SEC_IMP= TempTasa.MA_SEC_IMP,
		MAESTRO.MA_SEC_IMPCERTDEF= TempTasa.MA_SEC_IMPCERTDEF,
		MAESTRO.MA_DEF_TIP= TempTasa.MA_DEF_TIPNVO,
		MAESTRO.MA_ULTIMAMODIF=GETDATE()
	FROM         TempTasa INNER JOIN
	                      MAESTRO ON TempTasa.MA_CODIGO = MAESTRO.MA_CODIGO
	commit tran

	exec SP_CREATABLALOG 41
	insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora) 
	SELECT @user, 2, ' (Actualizacion a la tasa mas baja)',41, getdate()


	--Yolanda A. (2009-08-12)
	--Se agrego la parte del Factor conversión hacia la nueva fracc. de Regla 8va.
	UPDATE MAESTRO
	SET     AR_IMPMXR8=ISNULL((SELECT MAX(PERMISO.AR_CODIGO)
				FROM         MAESTROCATEG INNER JOIN
				                      PERMISO INNER JOIN
				                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
				                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO ON 
				                      MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO
				WHERE IDENTIFICA.IDE_CLAVE = 'C1' AND PERMISO.PE_APROBADO='S' and MAESTROCATEG.MA_CODIGO=MAESTRO.MA_CODIGO
					AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PE_FECHAVENC>=GETDATE()
					AND PERMISO.AR_CODIGO IS NOT NULL),0),
		eq_impmxR8 = dbo.eqUM_HTS(maestro.me_com, isnull((select me_codigo from arancel where arancel.ar_codigo in (
														ISNULL((SELECT MAX(PERMISO.AR_CODIGO)
															FROM         MAESTROCATEG INNER JOIN
																                      PERMISO INNER JOIN
																                      IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO INNER JOIN
																                      PERMISODET ON PERMISO.PE_CODIGO = PERMISODET.PE_CODIGO ON 
																                      MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO
															WHERE IDENTIFICA.IDE_CLAVE = 'C1' AND PERMISO.PE_APROBADO='S' and MAESTROCATEG.MA_CODIGO=MAESTRO.MA_CODIGO
															AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PE_FECHAVENC>=GETDATE()
															AND PERMISO.AR_CODIGO IS NOT NULL),0)
										)
						   ),0))




	FROM         MAESTRO
	WHERE     (MA_DEF_TIP = 'R') AND (AR_IMPMXR8 IS NULL OR AR_IMPMXR8 = 0)



 exec sp_droptable 'TempTasaSector'
 exec sp_droptable 'TempTasaSector2'
 exec sp_droptable 'TempTasaSector3'
 exec sp_droptable 'SectoresTemp'
exec sp_droptable 'OrdenTasa'
exec sp_droptable 'TempTasa'
exec sp_droptable 'TempMPSector'




GO
