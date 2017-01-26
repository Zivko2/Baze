SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_ImportadorActCodigo] (@tabla varchar(150), @ims_codigo int, @ims_cbforma int)   as
    declare @enunciado varchar(8000)
   
   declare NoParte cursor for
      select
         'UPDATE ' + @tabla
         + ' SET ' + IMPORTFIELDS.IMF_TABLENAME + convert(varchar(100), @ims_codigo) + '#'
         + IMPORTFIELDS.IMF_FIELDNAME + ' = ISNULL((SELECT MIN(' + IMPORTFIELDS.IMF_LINKFIELD
                                               + ') FROM ' + replace(IMPORTFIELDS.IMF_DISPLAYTABLE, '-1', 'MAESTRO')
         + ' WHERE '
         + IMPORTSPECDET.IMD_CAMPOTEXTO + '=' + 'cod_' + convert(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
         + '),' + (case when IMPORTSPECDET.IMD_DEFAULT_CODE = -1
                             and IMPORTSPECDET.IMD_DEFAULT <> ''
                           then '''' + IMPORTSPECDET.IMD_DEFAULT + ''''
                        when IMPORTSPECDET.IMD_DEFAULT_CODE > -1
                           then convert(varchar(100), IMPORTSPECDET.IMD_DEFAULT_CODE)
                        else (case when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                                        or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                                 then '0'
                                 else ''''''
                              end)
                   end) + ')'
      from
         IMPORTSPECDET left outer join IMPORTFIELDS
            on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
      where
         (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
         and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
         and (IMPORTSPECDET.IMD_ESCODIGO = 'S')
         AND IMPORTFIELDS.IMF_DISPLAYTABLE = '-1'
         and IMPORTSPECDET.IMD_CALCULADO = 'N'
   open NoParte
   
   fetch next from NoParte
   into @enunciado
   
   while (@@fetch_status = 0)
      begin
         --print @enunciado
         exec(@enunciado)
         
         fetch next from NoParte
         into @enunciado
      end
   
   close NoParte
   deallocate NoParte
   
   
   IF @tabla like 'TempImport1%'
      begin
         declare A cursor for
         
         -- defaults
         select
            'UPDATE ' + @tabla
            + ' SET ' + IMPORTFIELDS.IMF_TABLENAME + convert(varchar(100), @ims_codigo)
            + '#' + IMPORTFIELDS.IMF_FIELDNAME + '='
            + case when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                        or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                      then convert(varchar(150), IMD_DEFAULT_CODE)
                   when IMPORTFIELDS.IMF_FIELDTYPE = 'CHAR'
                      then '''' + convert(varchar(150), IMD_DEFAULTCHAR) + ''''
                   when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                        and IMD_DEFAULT not like '%/%'
                        and IMD_DEFAULT not like '%GETDATE%'
                      then ''''''
                   when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                        and IMD_DEFAULT like '%/%'
                        and IMD_DEFAULT like '%''%'
                      then '' + IMD_DEFAULT + ''
                   when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                        and IMD_DEFAULT like '%/%'
                        and IMD_DEFAULT not like '%''%'
                      then '''' + IMD_DEFAULT + ''''
                   when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                        and IMD_DEFAULT like '%GETDATE%'
                      then IMD_DEFAULT
                   else (case when IMF_TYPEOBJET = 'L'
                            then '''' + replace(convert(varchar(150), IMD_DEFAULT_CODE)
                                                , '-1'
                                                , convert(varchar(150), IMD_DEFAULTCHAR))
                                 + ''''
                            else (case when IMD_DEFAULT = ''
                                     then '''' + convert(varchar(150), IMD_DEFAULTCHAR) + ''''
                                     else '''' + convert(varchar(150), IMD_DEFAULT) + ''''
                                  end)
                         end)
              end
            + + (case when IMPORTSPECDET.IMD_CAMPO_ORIGEN is not null
                           and IMPORTSPECDET.IMD_CAMPO_ORIGEN <> ''
                    then ' WHERE ' + (case when not exists(select [name]
                                                           from   syscolumns
                                                           where  [id] = (select [id]
                                                                          from   sysobjects
                                                                          where  name = @Tabla)
                                                                  and [name] = IMPORTFIELDS.IMF_FIELDNAME)
                                         then IMPORTFIELDS.IMF_TABLENAME
                                              + convert(varchar(100), @ims_codigo)
                                              + '#' + IMPORTFIELDS.IMF_FIELDNAME
                                         else IMPORTFIELDS.IMF_FIELDNAME
                                      end)
                         + ' is null '
                    else ''
                 end)
         from
            IMPORTSPECDET left outer join IMPORTFIELDS
               on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
         where
            (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
            and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
            and IMPORTFIELDS.IMF_FIELDNAME is not null
            and IMPORTSPECDET.IMD_CALCULADO = 'N'
         
         union
         
         -- lookups
         -- (glr - 5-oct-2010)
         -- para la actualización de los campos relativos a fracciones, se usa la función
         -- FiltroDePaisEnFraccionParaImportador para validar que la fracción sea del país
         -- esperado, con ello se evita el problema de fracciones mal asignadas cuando en
         -- el catálogo de Fracciones se tiene un mismo no. de fracción en diferentes países
         select
            'UPDATE ' + @tabla
            + ' SET ' + IMPORTFIELDS.IMF_TABLENAME + convert(varchar(100), @ims_codigo)
            + '#' + IMPORTFIELDS.IMF_FIELDNAME
            + ' = ISNULL((SELECT MIN(' + (case when IMPORTSPECDET.IMD_CAMPOTEXTO = 'ME_TEXTOMRP'
                                             then 'ME_INTRADE'
                                             else IMPORTFIELDS.IMF_LINKFIELD
                                          end)
            + ') FROM ' + (case when IMPORTSPECDET.IMD_CAMPOTEXTO = 'ME_TEXTOMRP'
                              then 'MEDIDAMRP'
                              else IMPORTFIELDS.IMF_DISPLAYTABLE
                           end)
            + ' WHERE '
            + IMPORTSPECDET.IMD_CAMPOTEXTO + '=' + 'cod_'
            + convert(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
            + dbo.FiltroDePaisEnFraccionParaImportador(ImportFields.[IMF_TableName]
                                                       , ImportFields.[IMF_FieldName]
                                                       , ImportFields.[IMF_DisplayTable])
            + '),'
            + (case when IMPORTSPECDET.IMD_DEFAULT_CODE = -1
                         and IMPORTSPECDET.IMD_DEFAULT <> ''
                       then '''' + IMPORTSPECDET.IMD_DEFAULT + ''''
                    when IMPORTSPECDET.IMD_DEFAULT_CODE > -1
                       then convert(varchar(100), IMPORTSPECDET.IMD_DEFAULT_CODE)
                    else (case when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                                    or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                             then '0'
                             else ''''''
                          end)
               end) + ')'
         from
            IMPORTSPECDET left outer join IMPORTFIELDS
               on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
         where
            (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
            and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
            and (IMPORTSPECDET.IMD_ESCODIGO = 'S')
            and IMPORTFIELDS.IMF_DISPLAYTABLE <> '-1'
            and IMPORTSPECDET.IMD_CALCULADO = 'N'
         
         union
         
         -- (glr - 5-oct-2010)
         -- para la actualización de los campos relativos a fracciones, aquí
         -- también se usa la función FiltroDePaisEnFraccionParaImportador
         select
            'UPDATE ' + @tabla
            + ' SET ' + IMPORTFIELDS.IMF_TABLENAME + convert(varchar(100), @ims_codigo)
            + '#' + IMPORTFIELDS.IMF_FIELDNAME
            + ' = ISNULL((SELECT MIN(COMBOBOXES.CB_KEYFIELD) FROM COMBOBOXES WHERE CB_FIELD = '''
            + IMPORTFIELDS.IMF_FIELDNAME + ''' AND '
            + IMPORTSPECDET.IMD_CAMPOTEXTO + '='
            + 'cod_' + convert(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
            + dbo.FiltroDePaisEnFraccionParaImportador(ImportFields.[IMF_TableName]
                                                       , ImportFields.[IMF_FieldName]
                                                       , ImportFields.[IMF_DisplayTable])
            + '),'
            + (case
                  when IMPORTSPECDET.IMD_DEFAULT_CODE = -1
                       and IMPORTSPECDET.IMD_DEFAULT <> ''
                     then '''' + IMPORTSPECDET.IMD_DEFAULT + ''''
                  when IMPORTSPECDET.IMD_DEFAULT_CODE > -1
                     then convert(varchar(100), IMPORTSPECDET.IMD_DEFAULT_CODE)
                  else (case when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                                  or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                                then '0'
                             else ''''''
                        end)
               end) + ')'
         from
            IMPORTSPECDET left outer join IMPORTFIELDS
               on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
         where
            (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
            and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
            and (IMPORTSPECDET.IMD_ESCODIGO = 'S')
            and IMPORTFIELDS.IMF_TYPEOBJET = 'C'
            and IMPORTSPECDET.IMD_CALCULADO = 'N'
      
      end
   else
      --@tabla not like 'TempImport1%'
      begin
         declare A cursor for
            select
               'UPDATE ' + @tabla
               + ' SET ' + IMPORTFIELDS.IMF_FIELDNAME + '='
               + case
                    when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                         or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                       -- Se agrego case de IMD_DEFAULT ya que si este trae valor debera poner dicho valor y no el IMD_DEFAULT_CODE  
                       then case when IMD_DEFAULT = '' then convert(varchar(150),IMD_DEFAULT_CODE) else convert(varchar(150),IMD_DEFAULT) end
                    when IMPORTFIELDS.IMF_FIELDTYPE = 'CHAR'
                       then '''' + convert(varchar(150), IMD_DEFAULTCHAR) + ''''
                    when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                         and IMD_DEFAULT not like '%/%'
                         and IMD_DEFAULT not like '%GETDATE%'
                       then ''''''
                    when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                         and IMD_DEFAULT like '%/%'
                         and IMD_DEFAULT like '%''%'
                       then '' + IMD_DEFAULT + ''
                    when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                         and IMD_DEFAULT like '%/%'
                         and IMD_DEFAULT not like '%''%'
                       then '''' + IMD_DEFAULT + ''''
                    when IMPORTFIELDS.IMF_FIELDTYPE = 'DATETIME'
                         and IMD_DEFAULT like '%GETDATE%'
                       then IMD_DEFAULT
                    else (case when IMF_TYPEOBJET = 'L'
                             then '''' + replace(convert(varchar(150), IMD_DEFAULT_CODE)
                                                 , '-1'
                                                 , convert(varchar(150), IMD_DEFAULTCHAR))
                                  + ''''
                             else (case when IMD_DEFAULT = ''
                                      then '''' + convert(varchar(150), IMD_DEFAULTCHAR) + ''''
                                      else '''' + convert(varchar(150), IMD_DEFAULT) + ''''
                                   end)
                          end)
                 end
               + + (case when IMPORTSPECDET.IMD_CAMPO_ORIGEN is not null
                              and IMPORTSPECDET.IMD_CAMPO_ORIGEN <> ''
                       then ' WHERE ' + IMPORTFIELDS.IMF_FIELDNAME + ' is null '
                       else ''
                    end)
            from
               IMPORTSPECDET left outer join IMPORTFIELDS
                  on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
            where
               (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
               and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
               and IMPORTFIELDS.IMF_FIELDNAME is not null
               and IMPORTSPECDET.IMD_CALCULADO = 'N'
            
            union
            -- lookups
            select
               'UPDATE ' + @tabla
               + ' SET ' + IMPORTFIELDS.IMF_FIELDNAME
               + ' = ISNULL((SELECT MIN(' + IMPORTFIELDS.IMF_LINKFIELD
               + ') FROM ' + IMPORTFIELDS.IMF_DISPLAYTABLE
               + ' WHERE ' + IMPORTSPECDET.IMD_CAMPOTEXTO
               + '=' + 'cod_' + convert(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA) + '),'
               + (case
                     when IMPORTSPECDET.IMD_DEFAULT_CODE = -1
                          and IMPORTSPECDET.IMD_DEFAULT <> ''
                        then '''' + IMPORTSPECDET.IMD_DEFAULT + ''''
                     when IMPORTSPECDET.IMD_DEFAULT_CODE > -1
                        then convert(varchar(100), IMPORTSPECDET.IMD_DEFAULT_CODE)
                     else (case when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                                     or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                              then '0'
                              else ''''''
                           end)
                  end) + ')'
            from
               IMPORTSPECDET left outer join IMPORTFIELDS
                  on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
            where
               (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
               and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
               and (IMPORTSPECDET.IMD_ESCODIGO = 'S')
               and IMPORTFIELDS.IMF_DISPLAYTABLE <> '-1'
               and IMPORTSPECDET.IMD_CALCULADO = 'N'
            
            union
            
            select
               'UPDATE ' + @tabla
               + ' SET ' + IMPORTFIELDS.IMF_FIELDNAME
               + ' = ISNULL((SELECT MIN(COMBOBOXES.CB_KEYFIELD) FROM COMBOBOXES WHERE CB_FIELD='''
               + IMPORTFIELDS.IMF_FIELDNAME + ''' AND ' + IMPORTSPECDET.IMD_CAMPOTEXTO
               + '=' + 'cod_' + convert(varchar(100), IMPORTSPECDET.IMD_NUMCOLUMNA)
               + '),'
               + (case
                     when IMPORTSPECDET.IMD_DEFAULT_CODE = -1
                          and IMPORTSPECDET.IMD_DEFAULT <> ''
                        then '''' + IMPORTSPECDET.IMD_DEFAULT + ''''
                     when IMPORTSPECDET.IMD_DEFAULT_CODE > -1
                        then convert(varchar(100), IMPORTSPECDET.IMD_DEFAULT_CODE)
                     else (case when IMPORTFIELDS.IMF_FIELDTYPE = 'SMALLINT'
                                     or IMPORTFIELDS.IMF_FIELDTYPE = 'INT'
                              then '0'
                              else ''''''
                           end)
                  end) + ')'
            from
               IMPORTSPECDET left outer join IMPORTFIELDS
                  on IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
            where
               (IMPORTSPECDET.IMS_CODIGO = @ims_codigo)
               and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma)
               and (IMPORTSPECDET.IMD_ESCODIGO = 'S')
               and IMPORTFIELDS.IMF_TYPEOBJET = 'C'
               and IMPORTSPECDET.IMD_CALCULADO = 'N'
      end
   
   open A
   
   fetch next from A
   into @enunciado
   
   
   while (@@fetch_status = 0)
      begin
         if right(rtrim(@enunciado), 1) <> '='
            exec(@enunciado)
         
         
         fetch next from A
         into @enunciado
      end
   
   close A
   deallocate A
   
   
   delete
   from  Maestro
   where MA_NoParte = ''
   
   
   exec sp_ImportadorRevisaCodigo @tabla, @ims_codigo, @ims_cbforma
   
   
   if @tabla like 'TempImport1%'
      exec sp_ImportadorSelectMaster @tabla, @ims_codigo, @ims_cbforma

GO
