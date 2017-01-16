SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_CREAPIDescarga_Temp] @FE_FECHA varchar(11), @ME_COM varchar(50), @CF_DESCARGAVENCIDOS varchar(1), 
    @DEFINITIVA varchar(1), @CUENTAEQ varchar(50), @CED_FARANCELARIA varchar(1), @AR_IMPMX varchar(50), @CED_GRUPOGEN varchar(1), @MA_GENERICO varchar(50), 
    @CED_ORIGEN varchar(1), @PA_ORIGEN varchar(50), @CED_DESCRIPCION varchar(1), @MA_NOMBRE varchar(150) AS

declare @Ejecucion varchar(8000)

if exists (select * from sysobjects where id = object_id('[PIDescarga_Temp]') and OBJECTPROPERTY(id, 'IsTable') = 1) 
     drop table [PIDescarga_Temp]


set @Ejecucion ='SELECT TOP 100 PERCENT PIDescarga.PID_INDICED, PIDescarga.PID_SALDOGEN - ISNULL(PIDescarga.PID_CONGELASUBMAQ,0) 
                  AS PID_SALDOGEN, PEDIMPDET.PID_NOPARTE, PEDIMPDET.PID_NOMBRE, MAESTROGEN.MA_NOPARTE, 
                  ARANCEL.AR_FRACCION, PAIS.PA_CORTO, CASE WHEN PEDIMP.PI_TIPO IN (''C'', ''A'')  then isnull(AGENCIAPATENTE.AGT_PATENTE, '''') 
                  + ''-'' + PEDIMP.PI_FOLIO ELSE PEDIMP.PI_FOLIO END AS PATENTE_FOLIO, PIDescarga.PI_FEC_ENT, PIDescarga.PID_FECHAVENCE, 
                  PIDescarga.MA_CODIGO, PIDescarga.PI_CODIGO, PIDescarga.DI_DEST_ORIGEN 
                  INTO dbo.PIDescarga_Temp 
                  FROM PIDescarga INNER JOIN 
                       PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN 
                       (SELECT MA_CODIGO, MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN=''G'') MAESTROGEN ON PIDescarga.MA_GENERICO = MAESTROGEN.MA_CODIGO INNER JOIN 
                       PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO INNER JOIN 
                       PAIS ON PIDescarga.PA_ORIGEN = PAIS.PA_CODIGO LEFT OUTER JOIN 
                       ARANCEL ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO LEFT OUTER JOIN 
                       AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO 
                  WHERE PEDIMP.PI_MOVIMIENTO = ''E'' AND PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)>0 
                  AND PIDescarga.PID_SALDOGEN > 0 AND PIDescarga.PI_FEC_ENT<='''+@FE_FECHA+''' 
                  AND PEDIMPDET.ME_GENERICO =0'+@ME_COM

  if @CF_DESCARGAVENCIDOS <> 'S' 
      set @Ejecucion =  @Ejecucion+' and PIDescarga.pid_fechavence>='''+@FE_FECHA+''''

  if (@DEFINITIVA ='S')
    set @Ejecucion= @Ejecucion+' AND (PI_DEFINITIVO =''S'') '
  else
    set @Ejecucion =  @Ejecucion+' AND (PI_DEFINITIVO =''N'') '


  if (select convert(smallint,@CUENTAEQ)) >0
    set @Ejecucion =  @Ejecucion+' AND (PI_ACTIVOFIJO = ''S'') '
  else
    set @Ejecucion =  @Ejecucion+' AND (PI_ACTIVOFIJO = ''N'') '


  if @CED_FARANCELARIA = 'S'
     set @Ejecucion =  @Ejecucion+' AND PEDIMPDET.AR_IMPMX =0'+@AR_IMPMX+' '

  if @CED_GRUPOGEN = 'S'
     set @Ejecucion =  @Ejecucion+' AND PIDESCARGA.MA_GENERICO =0'+@MA_GENERICO+' '

  if @CED_ORIGEN = 'S'
     set @Ejecucion =  @Ejecucion+' AND PIDESCARGA.PA_ORIGEN =0'+@PA_ORIGEN+' '

  if @CED_DESCRIPCION = 'S'
     set @Ejecucion =  @Ejecucion+' AND PEDIMPDET.PID_NOMBRE ='''+@MA_NOMBRE+''' '

  set @Ejecucion =  @Ejecucion+' ORDER BY PIDescarga.PI_FEC_ENT, PIDescarga.PID_FECHAVENCE'


exec(@Ejecucion)








GO
