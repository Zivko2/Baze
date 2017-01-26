SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZATASABAJAFACTIMPSINPERMISO]  (@fi_codigo1 int, @user1 int=1)   as

SET NOCOUNT ON 

declare @CF_ACTTASACERTO char(1), @CF_ACTTASAPERPPS char(1), @CF_ACTTASAPER8VA char(1),
@user varchar(25), @fi_codigo varchar(50), @fi_fecha varchar(11), @CF_ACTTASAGENERAL char(1), @CF_ACTTASAREGLA16 char(1), @CF_ACTTASACOMPARATIVO char(1)


SELECT		@CF_ACTTASAPER8VA=CF_ACTTASAPER8VA, @CF_ACTTASAPERPPS=CF_ACTTASAPERPPS, @CF_ACTTASACERTO=CF_ACTTASACERTO,
			@CF_ACTTASAGENERAL=CF_ACTTASAGENERAL , @CF_ACTTASAREGLA16=CF_ACTTASAREGLA16, @CF_ACTTASACOMPARATIVO=CF_ACTTASACOMPARATIVO
FROM         CONFIGURACION

select @user=convert(varchar(25),@user1)

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

set @fi_codigo= convert(varchar(50),@fi_codigo1)


select @fi_fecha=convert(varchar(11),fi_fecha,101) from factimp where fi_codigo=@fi_codigo


--Información del catalogo maestro que contienen los detalles
exec ('SELECT    FACTIMPDET.FID_INDICED, ''AR_IMPMX''= FACTIMPDET.AR_IMPMX, 
FACTIMPDET.PA_CODIGO as PA_ORIGEN, MAESTRO.MA_SEC_IMP,
convert(varchar(10),FI_FECHA, 101) as FI_FECHA, FACTIMPDET.MA_CODIGO,
FACTIMPDET.TI_CODIGO,convert(decimal(38,6),-1.0) AS MA_POR_DEFNVO, ''G'' AS MA_DEF_TIPNVO, ISNULL((SELECT SPI_CODIGO FROM PAIS WHERE PA_CODIGO=FACTIMPDET.PA_CODIGO),0) AS SPI_CODIGOPAIS,
	''999999'' AS AR_FRACCION, convert(decimal(38,6),-1.0) AS PAR_BEN, convert(decimal(38,6),-1.0) AS SA_PORCENT, convert(decimal(38,6),-1.0) AS AR_PORCENT_8VA, FACTIMPDET.PR_CODIGO, convert(decimal(38,6),-1.0) AS AR_PORCENT_GENERAL, convert(decimal(38,6),-1.0) AS AR_PORCENT_16VA 
INTO dbo.['+@user+'TempTasa]
FROM         FACTIMPDET LEFT OUTER JOIN
                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO LEFT OUTER JOIN
                      MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO 
WHERE     FACTIMPDET.FI_CODIGO ='+ @fi_codigo)


exec('UPDATE ['+@user+'TempTasa]
SET     ['+@user+'TempTasa].AR_FRACCION= LEFT(ARANCEL.AR_FRACCION, 6)
FROM  ['+@user+'TempTasa]  INNER JOIN
                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO
WHERE LEFT(ARANCEL.AR_FRACCION, 6)<>''SINFRA'' AND LEFT(ARANCEL.AR_FRACCION, 6)<>''SIN FR''')


-- certificado
if @CF_ACTTASACERTO<>'0' 
BEGIN
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
				
END

-- PPS aqui valida tomando en cuenta que el porcentaje sea <> de -1 es decir >= 0
if @CF_ACTTASAPERPPS<>'0' 
begin

	--<> producto terminado
		exec('exec sp_droptable '''+@user+'TempTasaSector''
		      exec sp_droptable '''+@user+'TempTasaSector2''')

		-- Todo esto es para tomar el procentaje mas bajo de los sectores aprobados

		exec('SELECT     SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
		INTO dbo.['+@user+'TempTasaSector]
		FROM         SECTORARA 
			INNER JOIN ['+@user+'TempTasa] ON SECTORARA.AR_CODIGO = ['+@user+'TempTasa].AR_IMPMX
		WHERE  SECTORARA.SA_PORCENT<>-1
		GROUP BY SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
		ORDER BY SECTORARA.AR_CODIGO')
		
		exec ('UPDATE ['+@user+'TempTasa] 
		SET     ['+@user+'TempTasa].SA_PORCENT= SP.SA_PORCENT
		FROM         ['+@user+'TempTasa] 
			INNER JOIN  ['+@user+'TempTasaSector] SP ON ['+@user+'TempTasa].AR_IMPMX = SP.AR_CODIGO 
													AND ['+@user+'TempTasa].MA_SEC_IMP = SP.SE_CODIGO')


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

-- regla general
if @CF_ACTTASAGENERAL <> '0'
begin
		exec('UPDATE ['+@user+'TempTasa]
		SET     AR_PORCENT_GENERAL= ARANCEL.AR_ADVDEF
		FROM         ['+@user+'TempTasa]  INNER JOIN
		                      ARANCEL ON ['+@user+'TempTasa].AR_IMPMX = ARANCEL.AR_CODIGO')
	
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


	begin tran
	exec('UPDATE FACTIMPDET
	SET     FACTIMPDET.SPI_CODIGO=0, 
		FACTIMPDET.FID_SEC_IMP= isnull(['+@user+'TempTasa].MA_SEC_IMP,0),
		FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
	FROM         ['+@user+'TempTasa] INNER JOIN
	                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
	WHERE   ['+@user+'TempTasa].MA_DEF_TIPNVO=''S'' and  FACTIMPDET.FI_CODIGO ='+@fi_codigo)
	commit tran

	begin tran
	exec('UPDATE FACTIMPDET
	SET     FACTIMPDET.SPI_CODIGO= isnull(['+@user+'TempTasa].SPI_CODIGOPAIS,0), 
		FACTIMPDET.FID_SEC_IMP= 0,
		FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
	FROM         ['+@user+'TempTasa] INNER JOIN
	                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
	WHERE  ['+@user+'TempTasa].MA_DEF_TIPNVO=''P''  AND FACTIMPDET.FI_CODIGO ='+@fi_codigo)
	commit tran

	begin tran				
	exec('UPDATE FACTIMPDET
	SET     FACTIMPDET.SPI_CODIGO= 0, 
		FACTIMPDET.FID_SEC_IMP= 0,
		FACTIMPDET.FID_DEF_TIP= ['+@user+'TempTasa].MA_DEF_TIPNVO
	FROM         ['+@user+'TempTasa] INNER JOIN
	                      FACTIMPDET ON ['+@user+'TempTasa].FID_INDICED = FACTIMPDET.FID_INDICED
	WHERE  ['+@user+'TempTasa].MA_DEF_TIPNVO<>''P''  AND ['+@user+'TempTasa].MA_DEF_TIPNVO<>''S'' AND FACTIMPDET.FI_CODIGO ='+@fi_codigo)
	commit tran

 exec('exec sp_droptable '''+@user+'TempTasaSector''
	exec sp_droptable '''+@user+'TempTasaSector2''
	exec sp_droptable '''+@user+'TempTasaSector3''
	exec sp_droptable '''+@user+'SectoresTemp''
	exec sp_droptable '''+@user+'OrdenTasa''
	exec sp_droptable '''+@user+'TempMPSector''
	exec sp_droptable '''+@user+'TempTasa''')


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
LEFT OUTER JOIN MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO 
WHERE FACTIMPDET.FI_CODIGO = @fi_codigo1


exec sp_actualizaReferencia @fi_codigo1

GO
