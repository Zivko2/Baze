SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ACTUALIZATASABAJAMAPROVEE] (@user varchar(20)='1',@ma_codigo int, @pa_codigo int, @mv_codigo int output, @porcentaje decimal(38,6) output)   as

SET NOCOUNT ON 
declare @CF_ACTTASACERTO char(1), @CF_ACTTASAPERPPS char(1), @CF_ACTTASAPER8VA char(1),
 @ma_codigo1 varchar(50), @pa_codigo1 varchar(50), @ar_impmx varchar(30)


SELECT     @CF_ACTTASAPER8VA=CF_ACTTASAPER8VA, @CF_ACTTASAPERPPS=CF_ACTTASAPERPPS, @CF_ACTTASACERTO=CF_ACTTASACERTO
FROM         CONFIGURACION


                                  select @ar_impmx=convert(varchar(30),ar_impmx) from maestro where ma_codigo=@ma_codigo

-- se genera la tabla TempTasaProvee
exec('exec sp_droptable ''TempTasaProvee'+@user+'''')

select @ma_codigo1=convert(varchar(50),@ma_codigo), @pa_codigo1=convert(varchar(50),@pa_codigo)

                                  update CERTORIGMP
                                  set CMP_FECHATRANS= CMP_VFECHA
                                  where CMP_FECHATRANS is null

				--Yolanda A. (2009-08-12)
				--Se asigno formato de decimal a los campos que almacenan las tasas ya que almacenaban solo valores enteros
                                  exec('SELECT     dbo.MAESTRO.ma_codigo, ISNULL(max(AR_IMPMX),0) AS AR_IMPMX, ISNULL(max(dbo.MAESTROPROVEE.PA_CODIGO),0) AS PA_ORIGEN,  
                                                                    ISNULL(max(dbo.MAESTROPROVEE.SE_CODIGO),0)  AS MA_SEC_IMP, max(dbo.MAESTRO.TI_CODIGO) as TI_CODIGO, max(ARANCEL.AR_ADVDEF) AS MA_POR_DEFNVO, 
                                                                    ISNULL((SELECT SPI_CODIGO FROM PAIS WHERE PA_CODIGO=max(dbo.MAESTROPROVEE.PA_CODIGO)),0) AS SPI_CODIGOPAIS,
                                                                    LEFT(REPLACE(AR_FRACCION,''.'',''''),6) AS AR_FRACCION,convert(decimal(38,6),-1.0) AS PAR_BEN, convert(decimal(38,6),-1.0) AS SA_PORCENT, convert(decimal(38,6),-1.0) AS AR_PORCENT_8VA, ''G'' as MA_DEF_TIPNVO
                                  INTO dbo.TempTasaProvee'+@user+' FROM         dbo.MAESTROPROVEE INNER JOIN
                                                        dbo.MAESTRO ON dbo.MAESTROPROVEE.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
                                                        dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
                                  where  (MAESTROPROVEE.MA_CODIGO ='+@ma_codigo1+') and (dbo.MAESTROPROVEE.PA_CODIGO = '+@pa_codigo1+')
                                  group by LEFT(REPLACE(AR_FRACCION,''.'',''''),6), dbo.MAESTRO.ma_codigo')



                                  -- certificado
                                  if @CF_ACTTASACERTO<>'0' and (select count(*) from MAESTROPROVEE where ma_codigo=@ma_codigo and PA_CODIGO = @pa_codigo and MV_DEF_TIP='P')>0
                                  BEGIN

                                                                    exec('UPDATE TempTasaProvee'+@user+' SET TempTasaProvee'+@user+'.PAR_BEN=(SELECT PAISARA.PAR_BEN
                                                                                                                                                                          FROM PAISARA WHERE PAISARA.AR_CODIGO=TempTasaProvee'+@user+'.AR_IMPMX 
                                                                                                                                                                          AND PAISARA.PA_CODIGO =TempTasaProvee'+@user+'.PA_ORIGEN AND 
                                                                                                                                                       PAISARA.SPI_CODIGO = TempTasaProvee'+@user+'.SPI_CODIGOPAIS)
                                                                    WHERE MA_CODIGO IN 
                                                                                                      (SELECT     dbo.CERTORIGMPDET.MA_CODIGO
                                                                                                      FROM         dbo.CERTORIGMP INNER JOIN
                                                                                                                            dbo.CERTORIGMPDET ON dbo.CERTORIGMP.CMP_CODIGO = dbo.CERTORIGMPDET.CMP_CODIGO 
                                                                                                      WHERE     (dbo.CERTORIGMP.CMP_IFECHA <= GETDATE()) AND (dbo.CERTORIGMP.CMP_VFECHA >= GETDATE())
                                                                                                      AND dbo.CERTORIGMP.CMP_ESTATUS=''V'' AND  LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6) =TempTasaProvee'+@user+'.AR_FRACCION AND dbo.CERTORIGMPDET.PA_CLASE=TempTasaProvee'+@user+'.PA_ORIGEN
                                                                                                      GROUP BY dbo.CERTORIGMPDET.MA_CODIGO, LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6))
                                                                                                      AND (SELECT PAISARA.PAR_BEN
                                                                                                                                                                          FROM PAISARA WHERE PAISARA.AR_CODIGO=TempTasaProvee'+@user+'.AR_IMPMX 
                                                                                                                                                                          AND PAISARA.PA_CODIGO =TempTasaProvee'+@user+'.PA_ORIGEN AND 
                                                                                                                                                       PAISARA.SPI_CODIGO = TempTasaProvee'+@user+'.SPI_CODIGOPAIS) IS NOT NULL')
                                                                    
                                  END


                                  
                                  
                                  -- PPS 
                                  if @CF_ACTTASAPERPPS<>'0' and (select count(*) from MAESTROPROVEE where ma_codigo=@ma_codigo and PA_CODIGO = @pa_codigo and MV_DEF_TIP='S')>0
                                  begin

                                                                    --<> producto terminado
                                                                                                      exec('exec sp_droptable ''TempTasaProveeSector'+@user+'''')
                                                                                                      exec('exec sp_droptable ''TempTasaProveeSector2'+@user+'''')


                                                                                                      -- Todo esto es para tomar el procentaje mas bajo de los sectores aprobados

                                                                                                      exec('SELECT     SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
                                                                                                      INTO dbo.TempTasaProveeSector'+@user+' 
                                                                                                      FROM         SECTORARA INNER JOIN
                                                                                                                            PERMISODET ON SECTORARA.SE_CODIGO = PERMISODET.SE_CODIGO INNER JOIN
                                                                                                                            PERMISO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
                                                                                                                            IDENTIFICA ON PERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
                                                                                                      WHERE     (IDENTIFICA.IDE_CLAVE = ''PS'') AND (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) 
                                                                                                                                        AND SECTORARA.SA_PORCENT<>-1 and SECTORARA.ar_codigo='+@ar_impmx+' 
                                                                                                      GROUP BY SECTORARA.AR_CODIGO, SECTORARA.SA_PORCENT, SECTORARA.SE_CODIGO
                                                                                                      ORDER BY SECTORARA.AR_CODIGO                                                                    


                                                                                                      SELECT     SP.AR_CODIGO, MIN(SP.SA_PORCENT) AS SA_PORCENT, (SELECT MIN(S2.SE_CODIGO) FROM TempTasaProveeSector'+@user+' S2 where S2.AR_CODIGO=SP.AR_CODIGO
                                                                                                      AND S2.SA_PORCENT=MIN(SP.SA_PORCENT)) AS SE_CODIGO
                                                                                                      INTO dbo.TempTasaProveeSector2'+@user+' 
                                                                                                      FROM TempTasaProveeSector'+@user+' SP
                                                                                                      GROUP BY SP.AR_CODIGO
                                                                                                      ORDER BY SP.AR_CODIGO


                                                                                                      UPDATE TempTasaProvee'+@user+' 
                                                                                                      SET     TempTasaProvee'+@user+'.SA_PORCENT= SP.SA_PORCENT,
                                                                                                                                        TempTasaProvee'+@user+'.MA_SEC_IMP= SP.SE_CODIGO
                                                                                                      FROM         TempTasaProvee'+@user+'  INNER JOIN
                                                                                                                            TempTasaProveeSector2'+@user+'  SP ON TempTasaProvee'+@user+'.AR_IMPMX = SP.AR_CODIGO
                                                                                                      WHERE     (SP.SA_PORCENT <> -1)')



                                  end

                                  
                                  -- regla octava
                                  if @CF_ACTTASAPER8VA<>'0' and (select count(*) from MAESTROPROVEE where ma_codigo=@ma_codigo and PA_CODIGO = @pa_codigo and MV_DEF_TIP='R')>0
                                  begin


					IF (SELECT CONFIGURAPERMISO.CFM_PAISHIJO FROM CONFIGURAPERMISO INNER JOIN IDENTIFICA ON CONFIGURAPERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
					     WHERE IDENTIFICA.IDE_CLAVE = 'C1')='S'
					begin
		                                                                    exec('UPDATE TempTasaProvee'+@user+' 
		                                                                    SET     AR_PORCENT_8VA= ARANCEL.AR_PORCENT_8VA
		                                                                    FROM         TempTasaProvee'+@user+' INNER JOIN
		                                                                                          ARANCEL ON TempTasaProvee'+@user+'.AR_IMPMX = ARANCEL.AR_CODIGO
		                                                                    WHERE     (TempTasaProvee'+@user+'.MA_POR_DEFNVO <> 0)  AND (ARANCEL.AR_PORCENT_8VA <> - 1)
		                                                                                                      AND MA_CODIGO IN
		                                                                                                      (SELECT     TempTasaProvee1.MA_CODIGO
		                                                                                                      FROM         dbo.PERMISO INNER JOIN
		                                                                                                                            dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO INNER JOIN
		                                                                                                                            dbo.MAESTROCATEG INNER JOIN
		                                                                                                                            dbo.TempTasaProvee'+@user+' TempTasaProvee1 ON dbo.MAESTROCATEG.MA_CODIGO = TempTasaProvee1.MA_CODIGO ON 
		                                                                                                                            dbo.PERMISODET.MA_GENERICO = dbo.MAESTROCATEG.CPE_CODIGO AND dbo.PERMISODET.AR_EXPMX = TempTasaProvee1.AR_IMPMX INNER JOIN
		                                                                                                                            dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO INNER JOIN
		                                                                                                                            dbo.PERMISOPAIS ON dbo.PERMISO.PE_CODIGO = dbo.PERMISOPAIS.PE_CODIGO AND 
		                                                                                                                            TempTasaProvee1.PA_ORIGEN = dbo.PERMISOPAIS.PA_CODIGO
		                                                                                                      WHERE     (dbo.IDENTIFICA.IDE_CLAVE = ''C1'') AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PE_FECHAVENC>=GETDATE())')
					end
					else
					begin
		                                                                    exec('UPDATE TempTasaProvee'+@user+' 
		                                                                    SET     AR_PORCENT_8VA= ARANCEL.AR_PORCENT_8VA
		                                                                    FROM         TempTasaProvee'+@user+' INNER JOIN
		                                                                                          ARANCEL ON TempTasaProvee'+@user+'.AR_IMPMX = ARANCEL.AR_CODIGO
		                                                                    WHERE     (TempTasaProvee'+@user+'.MA_POR_DEFNVO <> 0)  AND (ARANCEL.AR_PORCENT_8VA <> - 1)
		                                                                                                      AND MA_CODIGO IN
		                                                                                                      (SELECT     TempTasaProvee1.MA_CODIGO
		                                                                                                      FROM         dbo.PERMISO INNER JOIN
		                                                                                                                            dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO INNER JOIN
		                                                                                                                            dbo.MAESTROCATEG INNER JOIN
		                                                                                                                            dbo.TempTasaProvee'+@user+' TempTasaProvee1 ON dbo.MAESTROCATEG.MA_CODIGO = TempTasaProvee1.MA_CODIGO ON 
		                                                                                                                            dbo.PERMISODET.MA_GENERICO = dbo.MAESTROCATEG.CPE_CODIGO AND dbo.PERMISODET.AR_EXPMX = TempTasaProvee1.AR_IMPMX INNER JOIN
		                                                                                                                            dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO 
		                                                                                                      WHERE     (dbo.IDENTIFICA.IDE_CLAVE = ''C1'') AND (PERMISO.PE_SALDO>0 OR PERMISO.PE_SALDOCOSTOT>0) AND PE_FECHAVENC>=GETDATE())')
		
					end
		
                                  end


                                  --   hasta aqui todas las tasas y estan en la tabla 


                                  -- para tomar el orden de las condiciones 
			          exec('exec sp_droptable ''OrdenTasa'+@user+'''')
                                  exec('CREATE TABLE [dbo].[OrdenTasa'+@user+'] (
                                                                    [enunciado] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
                                                                    [orden] [int] NOT NULL 
                                  ) ON [PRIMARY]')
                                  
			       -- esta a cero lo actualiza a TL por lo del pago del DTA
                                  exec('insert into OrdenTasa'+@user+'(enunciado,orden)
                                  SELECT     ''UPDATE TempTasaProvee'+@user+' SET MA_POR_DEFNVO=PAR_BEN, MA_DEF_TIPNVO=''''P'''' WHERE PAR_BEN<>-1 AND (MA_POR_DEFNVO>=PAR_BEN OR MA_POR_DEFNVO=-1)'',
                                                                    CF_ACTTASACERTO
                                  FROM         CONFIGURACION')
                                  
                                  exec('insert into OrdenTasa'+@user+'(enunciado,orden)
                                  SELECT    ''UPDATE TempTasaProvee'+@user+' SET MA_POR_DEFNVO=SA_PORCENT, MA_DEF_TIPNVO=''''S'''' WHERE SA_PORCENT<>-1 AND MA_POR_DEFNVO>SA_PORCENT'',
                                  CF_ACTTASAPERPPS
                                  FROM         CONFIGURACION')
                                  
                                  exec('insert into OrdenTasa'+@user+'(enunciado,orden)
                                  SELECT    ''UPDATE TempTasaProvee'+@user+' SET MA_POR_DEFNVO=AR_PORCENT_8VA, MA_DEF_TIPNVO=''''R'''' WHERE AR_PORCENT_8VA<>-1 AND MA_POR_DEFNVO>AR_PORCENT_8VA'',
                                  CF_ACTTASAPER8VA
                                  FROM         CONFIGURACION')
                                  
                                  
                                  
                                  exec('declare @enunciado varchar(800)
                                  declare cur_orden cursor for
                                                                    select enunciado from OrdenTasa'+@user+' 
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


                                  update maestroprovee
                                  set mv_principal='N'
                                  where ma_codigo=@ma_codigo
                                  and mv_principal='S'


                                  exec('declare @MV_CODIGO int
                                                                    if (select count(*) from TempTasaProvee'+@user+' where MA_DEF_TIPNVO=''G'')>0 and (select count(*) from maestroprovee where MA_CODIGO = '+@ma_codigo1+' AND PA_CODIGO='+@pa_codigo1+' and mv_def_tip=''G'')=0
                                                                    begin
                                                                                                      EXEC  SP_GETCONSECUTIVO ''MV'', @VALUE = @MV_CODIGO OUTPUT
                                  
                                                                                                      insert into maestroprovee(mv_codigo, pa_codigo, mv_def_tip, ma_codigo)
                                                                                                      values(@MV_CODIGO, '+@pa_codigo1+',''G'', '+@ma_codigo1+')

                                                                    end') 
                                                                                                                                        

                                  begin tran
                                                                    exec('UPDATE MAESTROPROVEE
                                                                    SET     MV_PRINCIPAL=''S'', MV_MINCANT=ROUND(MA_POR_DEFNVO,2)
                                                                    FROM         MAESTROPROVEE INNER JOIN
                                                                                                                            TempTasaProvee'+@user+' ON MAESTROPROVEE.MV_DEF_TIP= TempTasaProvee'+@user+'.MA_DEF_TIPNVO 
                                                                    AND MAESTROPROVEE.PA_CODIGO='+@pa_codigo1+' 
                                                                    WHERE     (MAESTROPROVEE.MA_CODIGO = '+@ma_codigo1+') AND (MAESTROPROVEE.PA_CODIGO='+@pa_codigo1+')')
                                  commit tran

                                  select @porcentaje=MV_MINCANT, @mv_codigo=MV_CODIGO from maestroprovee where ma_codigo=@ma_codigo and mv_principal='S'


exec('exec sp_droptable ''TempTasaProveeSector'+@user+'''')
exec('exec sp_droptable ''TempTasaProveeSector2'+@user+'''')
exec('exec sp_droptable ''OrdenTasa'+@user+'''')
exec('exec sp_droptable ''TempTasaProvee'+@user+'''')












GO
