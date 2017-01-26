SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_HysonBOM]  
as
    if exists (select *
              from   sysobjects
              where  [id] = object_id(N'[TempBOM_HysonB]')
                     and objectproperty([id], N'IsTable') = 1)
      drop table TempBOM_HysonB
   
   
   
   select
      [Consecutivo]
      , 
        ltrim(rtrim([NumPadre])) + case when not (ltrim(rtrim([Alterna])) like '1')
                               then case when cast([Alterna] as int) < 10
                                       then '$0'
                                       else ''
                                    end + cast(cast([Alterna] as int) as varchar(2))
                               else ''
                            end as [NumPadre]
      , ltrim(rtrim([NumHijo])) as [NumHijo]
      , [Cantidad]
      , [PtSub]
      , ltrim(rtrim([Division])) as [Division]
      , cast(substring([FechaIni], 1, 4)
                + substring([FechaIni], 6, 2)
                + substring([FechaIni], 9, 2) as datetime) as [FechaIni]
      , cast(substring([FechaFinal], 1, 4)
                + substring([FechaFinal], 6, 2)
                + substring([FechaFinal], 9, 2) as datetime) as [FechaFinal]
      , [Alterna]
      , 'S' as [SeDescarga]
      , [ExtractDate]
      , [ProcessInstance]
   into
      TempBOM_HysonB
   from
      TempBOM_Hyson
   where
      isdate(substring([FechaIni], 1, 4)
                + substring([FechaIni], 6, 2)
                + substring([FechaIni], 9, 2)) = 1
      and isdate(substring([FechaFinal], 1, 4)
                + substring([FechaFinal], 6, 2)
                + substring([FechaFinal], 9, 2)) = 1
   
   
   alter table dbo.TempBOM_HysonB add constraint
      PK_TempBOM_HysonB primary key clustered
   (
      [Consecutivo]
   )
   
   
   
   if exists(select
                [Consecutivo]
             from
                TempBOM_Hyson
             where
                isdate(substring([FechaIni], 1, 4)
                       + substring([FechaIni], 6, 2)
                       + substring([FechaIni], 9, 2)) = 0
                or isdate(substring([FechaFinal], 1, 4)
                          + substring([FechaFinal], 6, 2)
                          + substring([FechaFinal], 9, 2)) = 0)
   begin
      insert into ImportLogErrors([IdError], [Descripcion])
      select
         1
         , 'No. de parte ' + ltrim(rtrim([NumPadre]))
              + ' con componente ' + ltrim(rtrim([NumHijo]))
              + ' de la división ' +  ltrim(rtrim([Division]))
              + ' presenta fechas incorrectas en el archivo fuente. '
              + 'No se puede subir esta relación en BOM.'
      from
         TempBOM_Hyson
      where
         isdate(substring([FechaIni], 1, 4)
                + substring([FechaIni], 6, 2)
                + substring([FechaIni], 9, 2)) = 0
         or isdate(substring([FechaFinal], 1, 4)
                   + substring([FechaFinal], 6, 2)
                   + substring([FechaFinal], 9, 2)) = 0
   end
   
   
   if exists(select [Consecutivo]
             from   TempBOM_HysonB
             where  [FechaIni] > [FechaFinal])
   begin
      insert into ImportLogErrors([IdError], [Descripcion])
      select
         2
         , 'No. de parte ' + ltrim(rtrim([NumPadre]))
              + ' con componente ' + ltrim(rtrim([NumHijo]))
              + ' de la división ' +  ltrim(rtrim([Division]))
              + ' presenta inconsistencias en las fechas en el archivo fuente. '
              + 'No se puede subir esta relación en BOM.'
      from
         TempBOM_HysonB
      where
         [FechaIni] > [FechaFinal]
      
      
      delete TempBOM_HysonB
      where  [FechaIni] > [FechaFinal]
   end
   
  
   
   exec sp_GeneraTablaTemp 'MAESTRO'
   
   declare @Consecutivo int
   
   set @Consecutivo = isnull((select isnull([CV_Codigo], 0) + 1
                              from   Consecutivo
                              where  [CV_Tabla] = 'Maestro'), 1)
   
   dbcc checkident(TempImportMaestro, reseed, @Consecutivo) with no_infomsgs
   
   insert into TempImportMaestro
      ([MA_Inv_Gen]
       , [MA_Tip_Ens]
       , [MA_NoParte]
       , [TI_Codigo]
       , [MA_Name]
       , [MA_Nombre]
       , [ME_Com]
       , [PA_Origen]
       , [PA_Procede]
       , [AR_ImpMx]
       , [AR_ExpMx]
       , [MA_Discharge]
       , [MA_NoParteAux])
   select
      'I' as [MA_Inv_Gen]
      , case when exists(select
                            tbh.[NumPadre]
                         from
                            TempBOM_HysonB tbh
                         where
                            tbh.[NumPadre] = ltrim(rtrim(TempBOM_HysonB.[NumPadre]))
                            and tbh.[PtSub] = 'P') 
           then 'A'
           else 'F'
        end as [MA_Tip_Ens]
      , ltrim(rtrim([NumPadre])) as [MA_NoParte]
      , 16 as [TI_Codigo]
      , 'TEMP' as [MA_Name]
      , 'TEMP (SUBENSAMBLE EN BOM)' as [MA_Nombre]
      , 19 as [ME_Com]
      , 154 as [PA_Origen]
      , 154 as [PA_Procede]
      , isnull((select [AR_Codigo]
                from   Arancel
                where  [AR_Fraccion] = 'SINFRACCION'), 0) as [AR_ImpMx]
      , isnull((select [AR_Codigo]
                from   Arancel
                where  [AR_Fraccion] = 'SINFRACCION'), 0) as [AR_ExpMx]
      , 'N' as [MA_Discharge]
      , rtrim(ltrim([Division])) as [MA_NoParteAux]
   from
      TempBOM_HysonB left outer join (select
                                         [MA_NoParte]
                                         , [MA_NoParteAux]
                                      from
                                         Maestro
                                      where
                                         [MA_Inv_Gen] = 'I') Maestro
         on rtrim(ltrim(TempBOM_HysonB.[NumPadre])) = Maestro.[MA_NoParte]
            and rtrim(ltrim(TempBOM_HysonB.[Division])) = Maestro.[MA_NoParteAux]
   where
      Maestro.[MA_NoParte] is null
   group  by
      ltrim(rtrim([NumPadre]))
      , rtrim(ltrim([Division]))
   
   
   insert into TempImportMaestro
      ([MA_Inv_Gen]
       , [MA_Tip_Ens]
       , [MA_NoParte]
       , [TI_Codigo]
       , [MA_Name]
       , [MA_Nombre]
       , [ME_Com]
       , [PA_Origen]
       , [PA_Procede]
       , [AR_ImpMx]
       , [AR_ExpMx]
       , [MA_Discharge]
       , [MA_NoParteAux])
   select
      'I' as [MA_Inv_Gen]
      , case when exists(select tbh.[PTSub]
                         from   TempBOM_HysonB tbh
                         where  
                                tbh.[NumPadre] = TempBOM_HysonB.[NumHijo]
                                and tbh.[PTSub] = 'P') 
            then 'A'
            else 'F'
         end as [MA_Tip_Ens]
       , ltrim(rtrim([NumHijo])) as [MA_NoParte]
       , 16 as [TI_Codigo]
       , 'TEMP' as [MA_Name]
       , 'TEMP (SUBENSAMBLE EN BOM)' as [MA_Nombre]
       , 
         19 as [ME_Com]
       , 154 as [PA_Origen]
       , 154 as [PA_Procede]
       , isnull((select [AR_Codigo]
                 from   Arancel
                 where  [AR_Fraccion] = 'SINFRACCION'), 0) as [AR_ImpMx]
       , isnull((select [AR_Codigo]
                 from   Arancel
                 where  [AR_Fraccion] = 'SINFRACCION'), 0) as [AR_ExpMx]
       , 
         TempBOM_HysonB.[SeDescarga] as [MA_Discharge]
       , 
         rtrim(ltrim([Division])) as [MA_NoParteAux]
   from
      TempBOM_HysonB left outer join (select
                                         [MA_NoParte]
                                         , [MA_NoParteAux]
                                      from
                                         Maestro
                                      where
                                         [MA_Inv_Gen] = 'I') Maestro
         on rtrim(ltrim(TempBOM_HysonB.[NumHijo])) = Maestro.[MA_NoParte]
            and rtrim(ltrim(TempBOM_HysonB.[Division])) = Maestro.[MA_NoParteAux]
      left outer join (select
                          ltrim(rtrim([MA_NoParte])) as [MA_NoParte]
                          , ltrim(rtrim([MA_NoParteAux])) as [MA_NoParteAux]
                       from
                          TempImportMaestro) TempImportMaestro
         on rtrim(ltrim(TempBOM_HysonB.[NumHijo])) = TempImportMaestro.[MA_NoParte]
            and rtrim(ltrim(TempBOM_HysonB.[Division])) = TempImportMaestro.[MA_NoParteAux]
   where
      Maestro.[MA_NoParte] is null
      and TempImportMaestro.[MA_NoParte] is null
      and exists(select tbh.[PTSub]
                 from   TempBOM_HysonB tbh
                 where  tbh.[NumPadre] = TempBOM_HysonB.[NumHijo])
  group by
     [NumHijo]
     , [Division]
     , TempBOM_HysonB.[SeDescarga]
  
  insert into TempImportMaestro
     ([MA_Inv_Gen]
      , [MA_Tip_Ens]
      , [MA_NoParte]
      , [TI_Codigo]
      , [MA_Name]
      , [MA_Nombre]
      , [ME_Com]
      , [PA_Origen]
      , [PA_Procede]
      , [AR_ImpMx]
      , [AR_ExpMx]
      , [MA_Discharge]
      , [MA_NoParteAux])
  select
     'I' as [MA_Inv_Gen]
     , 'C' as [MA_Tip_Ens]
     , ltrim(rtrim([NumHijo])) as [MA_NoParte]
     , 10 as [TI_Codigo]
     , 'TEMP' as [MA_Name]
     , 'TEMP (COMPONENTE EN BOM)' as [MA_Nombre]
     , 
       19 as [ME_Com]
     , 233 as [PA_Origen]
     , 233 as [PA_Procede]
     , isnull((select [AR_Codigo]
               from   Arancel
               where  [AR_Fraccion] = 'SINFRACCION'), 0) as [AR_ImpMx]
     , isnull((select [AR_Codigo]
               from   Arancel
               where  [AR_Fraccion] = 'SINFRACCION'), 0) as [AR_ExpMx]
     , 
       TempBOM_HysonB.[SeDescarga] as [MA_Discharge]
     , rtrim(ltrim([Division])) as [MA_NoParteAux]
  from
     TempBOM_HysonB left outer join (select
                                        [MA_NoParte]
                                        , [MA_NoParteAux]
                                     from
                                        Maestro
                                     where
                                        [MA_Inv_Gen] = 'I') Maestro
        on rtrim(ltrim(TempBOM_HysonB.[NumHijo])) = Maestro.[MA_NoParte]
           and rtrim(ltrim(TempBOM_HysonB.[Division])) = Maestro.[MA_NoParteAux]
     left outer join (select
                         ltrim(rtrim([MA_NoParte])) as [MA_NoParte]
                         , ltrim(rtrim([MA_NoParteAux])) as [MA_NoParteAux]
                      from
                         TempImportMaestro) TempImportMaestro
        on ltrim(rtrim(TempBOM_HysonB.[NumHijo])) = TempImportMaestro.[MA_NoParte]
           and rtrim(ltrim([Division])) = TempImportMaestro.[MA_NoParteAux]
  where
     Maestro.[MA_NoParte] is null
     and TempImportMaestro.[MA_NoParte] is null
  group  by
     [NumHijo]
     , [Division]
     , TempBOM_HysonB.[SeDescarga]
  
  
  insert into Maestro
     ([MA_Codigo]
      , [MA_Inv_Gen]
      , [MA_Tip_Ens]
      , [MA_NoParte]
      , [TI_Codigo]
      , [MA_Name]
      , [MA_Nombre]
      , [ME_Com]
      , [PA_Origen]
      , [PA_Procede]
      , [AR_ImpMx]
      , [AR_ExpMx]
      , [MA_UltimaModif]
      , [MA_Discharge]
      , [MA_NoParteAux])
  select
     [MA_Codigo]
     , [MA_Inv_Gen]
     , [MA_Tip_Ens]
     , ltrim(rtrim([MA_NoParte])) as [MA_NoParte]
     , [TI_Codigo]
     , [MA_Name]
     , [MA_Nombre]
     , [ME_Com]
     , [PA_Origen]
     , [PA_Procede]
     , [AR_ImpMx]
     , [AR_ExpMx]
     , getdate() as [MA_UltimaModif]
     , [MA_Discharge]
     , [MA_NoParteAux]
  from
     TempImportMaestro
  
  
  declare @Maximo int
  
  set @Maximo = isnull((select max([MA_Codigo])
                        from   Maestro), 0)
  
  if exists(select *
            from   MaestroRefer)
     and (isnull((select max([MA_Codigo])
                  from   MaestroRefer), 0)) > @Maximo
     begin
        set @Maximo = isnull((select max([MA_Codigo])
                      from   MaestroRefer), 0)
     end

  update Consecutivo
  set    [CV_Codigo] = @Maximo + 1
  where  [CV_Tipo] = 'MA'

  ---------------------------------------------
  alter table [BOM_Struct] disable trigger [Delete_BOM_Struct] 

  alter table [BOM_Struct] disable trigger [Insert_BOM_Struct]

  alter table [BOM_Struct] disable trigger [Update_BOM_Struct]

  
   
   exec [dbo].[sp_HysonBOMAfectaBOM_Struct]
   
   alter table [BOM_Struct] enable trigger [Delete_BOM_Struct]
   
   alter table [BOM_Struct] enable trigger [Insert_BOM_Struct]
   
   alter table [BOM_Struct] enable trigger [Update_BOM_Struct]
   

GO
