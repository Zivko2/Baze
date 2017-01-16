SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


create function [dbo].[FiltroDePaisEnFraccionParaImportador](@TableName varchar(50), @FieldName varchar(100), @DisplayTable varchar(50))
returns varchar(120) as
begin
   declare @ValidarFraccionMex varchar(120)
   declare @ValidarFraccionFo varchar(120)
   declare @ValidarTipo varchar(40)
   
   set @ValidarTipo = case @TableName + '.' + @FieldName
                         when 'ANEXO24.AR_IMPFOFIS'    then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'ENTRYSUMARA.AR_CODIGO'  then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'ENTRYSUMARA.AR_NG_EMP'  then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'FACTEXPDET.AR_IMPFO'    then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'FACTEXPDET.AR_NG_EMP'   then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'FACTIMPDET.AR_EXPFO'    then ' and ' + @DisplayTable + '.[AR_Tipo] = ''E'''
                         when 'LISTAEXPDET.AR_IMPFO'   then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'LISTAEXPDET.AR_NG_EMP'  then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'MAESTRO.AR_DESP'        then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'MAESTRO.AR_EXPFO'       then ' and ' + @DisplayTable + '.[AR_Tipo] = ''E'''
                         when 'MAESTRO.AR_IMPFO'       then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'MAESTRO.AR_IMPFOUSA'    then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'MAESTRO.AR_RETRA'       then ' and ' + @DisplayTable + '.[AR_Tipo] = ''I'''
                         when 'PCKLISTDET.AR_EXPFO'    then ' and ' + @DisplayTable + '.[AR_Tipo] = ''E'''
                         when 'PEDIMPDET.AR_EXPFO'     then ' and ' + @DisplayTable + '.[AR_Tipo] = ''E'''
                         when 'PEDIMPDETB.AR_EXPFO'    then ' and ' + @DisplayTable + '.[AR_Tipo] = ''E'''
                         else ''
                      end
   
   set @ValidarFraccionFo  = @ValidarTipo + ' and ' + @DisplayTable + '.PA_Codigo <> 154 '
   set @ValidarFraccionMex = ' and ' + @DisplayTable + '.PA_Codigo = 154 '
   
   
   return case @TableName + '.' + @FieldName
             when 'ANEXO24.AR_IMPFOFIS'    then @ValidarFraccionFo
             when 'ENTRYSUMARA.AR_CODIGO'  then @ValidarFraccionFo
             when 'ENTRYSUMARA.AR_NG_EMP'  then @ValidarFraccionFo
             when 'FACTEXPDET.AR_IMPFO'    then @ValidarFraccionFo
             when 'FACTEXPDET.AR_NG_EMP'   then @ValidarFraccionFo
             when 'FACTIMPDET.AR_EXPFO'    then @ValidarFraccionFo
             when 'LISTAEXPDET.AR_IMPFO'   then @ValidarFraccionFo
             when 'LISTAEXPDET.AR_NG_EMP'  then @ValidarFraccionFo
             when 'MAESTRO.AR_DESP'        then @ValidarFraccionFo
             when 'MAESTRO.AR_EXPFO'       then @ValidarFraccionFo
             when 'MAESTRO.AR_IMPFO'       then @ValidarFraccionFo
             when 'MAESTRO.AR_IMPFOUSA'    then @ValidarFraccionFo
             when 'MAESTRO.AR_RETRA'       then @ValidarFraccionFo
             when 'PCKLISTDET.AR_EXPFO'    then @ValidarFraccionFo
             when 'PEDIMPDET.AR_EXPFO'     then @ValidarFraccionFo
             when 'PEDIMPDETB.AR_EXPFO'    then @ValidarFraccionFo
             when 'ANEXO24.AR_EXPMXFIS'    then @ValidarFraccionMex
             when 'CATEGPERMISO.AR_CODIGO' then @ValidarFraccionMex
             when 'FACTEXPDET.AR_EXPMX'    then @ValidarFraccionMex
             when 'FACTEXPDET.AR_IMPMX'    then @ValidarFraccionMex
             when 'FACTIMPDET.AR_IMPMX'    then @ValidarFraccionMex
             when 'LISTAEXPDET.AR_EXPMX'   then @ValidarFraccionMex
             when 'LISTAEXPDET.AR_IMPMX'   then @ValidarFraccionMex
             when 'MAESTRO.AR_DESPMX'      then @ValidarFraccionMex
             when 'MAESTRO.AR_EXPMX'       then @ValidarFraccionMex
             when 'MAESTRO.AR_IMPMX'       then @ValidarFraccionMex
             when 'MAESTRO.AR_IMPMXR8'     then @ValidarFraccionMex
             when 'PCKLISTDET.AR_IMPMX'    then @ValidarFraccionMex
             when 'PEDIMPDET.AR_IMPMX'     then @ValidarFraccionMex
             when 'PEDIMPDETB.AR_IMPMX'    then @ValidarFraccionMex
             when 'PERMISO.AR_CODIGO'      then @ValidarFraccionMex
             when 'PERMISODET.AR_EXPMX'    then @ValidarFraccionMex
             when 'PERMISODET.AR_IMPMX'    then @ValidarFraccionMex
             when 'PERMISOPT.AR_CODIGO'    then @ValidarFraccionMex
             else ''
          end
end

GO
