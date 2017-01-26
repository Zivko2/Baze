SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE ActualizarTReporte_Original   as

declare @Tre_Codigo int,@Tre_Nombre sysname,@Tre_Ruta sysname,@Tre_Nombre_RTM sysname, @Tre_FRMTAG sysname, @Tre_Lookupfld sysname, @Tre_LookupFldDt sysname, @Tre_LookupTBL sysname,@Tre_Field2Relate sysname, @Tre_Field2Show sysname, @Tre_Fld2ShowDType sysname,
        @Tre_Field2ShowTbl sysname, @Tre_LabelField sysname, @Tre_CampoEtiqueta sysname, @Tre_ReporteClasif sysname, @Tre_Orden sysname, @Tre_Parametro sysname, @Consecutivo int, @trecodigo int, @Tre_QryParamSQL varchar(8000), @TRE_MASUSADO char(1), @TRE_PROCANTES varchar(1100), @TRE_MULTIPLEVALOR CHAR(1)


exec sp_droptable 'treporterespaldo'

select   TREPORTE.TRE_NOMBRE_RTM, TRE_MASUSADO
into treporterespaldo
FROM         TREPORTE 
where TREPORTE.TRE_NOMBRE_RTM in (SELECT TRE_NOMBRE_RTM COLLATE SQL_Latin1_General_CP1_CI_AS FROM Original.dbo.TREPORTE) 
and TRE_MASUSADO='S'


DELETE     TREPORTE
FROM         TREPORTE 
where TREPORTE.TRE_NOMBRE_RTM in (SELECT TRE_NOMBRE_RTM COLLATE SQL_Latin1_General_CP1_CI_AS FROM Original.dbo.TREPORTE) 


declare cur_reporte cursor for
select Tre_Codigo, Tre_Nombre, Tre_Ruta, Tre_Nombre_RTM, Tre_FRMTAG, Tre_Lookupfld, Tre_LookupFldDt, Tre_LookupTBL, Tre_Field2Relate, Tre_Field2Show, Tre_Fld2ShowDType,
       Tre_Field2ShowTbl, Tre_LabelField, Tre_CampoEtiqueta, Tre_ReporteClasif, Tre_Orden, Tre_Parametro, Tre_QryParamSQL, TRE_MASUSADO, TRE_PROCANTES, TRE_MULTIPLEVALOR
from Original.dbo.treporte
order by tre_codigo


Open cur_reporte 
fetch next from Cur_Reporte into @Tre_Codigo, @Tre_Nombre, @Tre_Ruta, @Tre_Nombre_RTM, @Tre_FRMTAG, @Tre_Lookupfld, @Tre_LookupFldDt, @Tre_LookupTBL, @Tre_Field2Relate, @Tre_Field2Show, @Tre_Fld2ShowDType,
                                 @Tre_Field2ShowTbl, @Tre_LabelField, @Tre_CampoEtiqueta, @Tre_ReporteClasif, @Tre_Orden, @Tre_Parametro, @Tre_QryParamSQL, @TRE_MASUSADO, @TRE_PROCANTES, @TRE_MULTIPLEVALOR
WHILE (@@FETCH_STATUS <> -1) 
 BEGIN 
      --obtiene consecutivo
      select @Consecutivo=isnull(max(Tre_Codigo),0) from treporte
      set @Consecutivo=@Consecutivo+1

      INSERT INTO TReporte(Tre_Codigo, Tre_Nombre, Tre_Ruta, Tre_Nombre_RTM, Tre_FRMTAG, Tre_Lookupfld, Tre_LookupFldDt, Tre_LookupTBL, Tre_Field2Relate, Tre_Field2Show, Tre_Fld2ShowDType,
                           Tre_Field2ShowTbl, Tre_LabelField, Tre_CampoEtiqueta, Tre_ReporteClasif, Tre_Orden, Tre_Parametro, Tre_QryParamSQL, TRE_MASUSADO, TRE_PROCANTES, TRE_MULTIPLEVALOR) 
      VALUES (@Consecutivo, @Tre_Nombre, @Tre_Ruta, @Tre_Nombre_RTM, @Tre_FRMTAG, @Tre_Lookupfld, @Tre_LookupFldDt, @Tre_LookupTBL, @Tre_Field2Relate, @Tre_Field2Show, @Tre_Fld2ShowDType,
                           @Tre_Field2ShowTbl, @Tre_LabelField, @Tre_CampoEtiqueta, @Tre_ReporteClasif, @Tre_Orden, @Tre_Parametro, @Tre_QryParamSQL, @TRE_MASUSADO, @TRE_PROCANTES, @TRE_MULTIPLEVALOR)

      --actualizar consecutivo
      select @trecodigo=max(Tre_Codigo) from treporte
      Update consecutivo 
      set CV_CODIGO=@trecodigo+1 
      where CV_TABLA='TREPORTE'
      
fetch next from Cur_Reporte into @Tre_Codigo, @Tre_Nombre, @Tre_Ruta, @Tre_Nombre_RTM, @Tre_FRMTAG, @Tre_Lookupfld, @Tre_LookupFldDt, @Tre_LookupTBL, @Tre_Field2Relate, @Tre_Field2Show, @Tre_Fld2ShowDType,
                                 @Tre_Field2ShowTbl, @Tre_LabelField, @Tre_CampoEtiqueta, @Tre_ReporteClasif, @Tre_Orden, @Tre_Parametro, @Tre_QryParamSQL, @TRE_MASUSADO, @TRE_PROCANTES, @TRE_MULTIPLEVALOR
 END 
CLOSE cur_Reporte
DEALLOCATE cur_Reporte


	DELETE dbo.TREPORTE 
	FROM         dbo.TREPORTE INNER JOIN
                      dbo.TREPORTEDEL ON dbo.TREPORTE.TRE_NOMBRE_RTM = dbo.TREPORTEDEL.TRE_NOMBRE_RTM COLLATE SQL_Latin1_General_CP1_CI_AS


	update treporte
	set treporte.TRE_MASUSADO= 'S'
	from treporte inner join treporterespaldo on
	treporte.tre_nombre_rtm = treporterespaldo.tre_nombre_rtm

exec sp_droptable 'treporterespaldo'
GO
