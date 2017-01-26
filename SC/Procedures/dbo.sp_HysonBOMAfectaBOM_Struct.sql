SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[sp_HysonBOMAfectaBOM_Struct]  
as
    declare @PadresHijos table([BSU_NoParte] varchar(30) not null
                              , [BSU_NoParteAux] varchar(10) not null
                              , [BST_NoParte] varchar(30) not null
                              , [BST_NoParteAux] varchar(10) not null
                              , primary key clustered([BSU_NoParte]
                                                      , [BSU_NoParteAux]
                                                      , [BST_NoParte]
                                                      , [BST_NoParteAux]))
   declare @Consecutivo int
           , @NumPadre varchar(30)
           , @NumHijo varchar(30)
           , @Division varchar(5)
           , @BST_CodigoUltimo int
           , @FechaInicioUltima datetime
           , @FechaFinalUltima datetime
           , @FechaInicio datetime
           , @FechaFinal datetime
           , @Cantidad decimal(38, 6)
           , @UnidadMedida int
           , @SeDescarga char(1)
           , @InsertarRegistro bit
           , @MaxConsecutivo int
           , @BST_Codigo int
           , @CantidadUltima decimal(38, 6)
   declare @RegsUnicos table([Consecutivo] int not null primary key
                             , [BST_Codigo] int null)
   
   insert into @PadresHijos([BSU_NoParte]
                            , [BSU_NoParteAux]
                            , [BST_NoParte]
                            , [BST_NoParteAux])
   select
      ltrim(rtrim([NumPadre])) collate database_default as [BSU_NoParte]
      , ltrim(rtrim([Division])) collate database_default as [BSU_NoParteAux]
      , ltrim(rtrim([NumHijo])) collate database_default as [BST_NoParte]
      , ltrim(rtrim([Division])) collate database_default as [BST_NoParteAux]
   from
      TempBOM_HysonB
   group by
      ltrim(rtrim([NumPadre])) collate database_default
      , ltrim(rtrim([Division])) collate database_default
      , ltrim(rtrim([NumHijo])) collate database_default
      , ltrim(rtrim([Division])) collate database_default
   
   
   if exists(select
                PadresHijos.[BSU_NoParte]
             from
                @PadresHijos PadresHijos inner join
                ( 
                 select   [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 from     BOM_Struct
                 where    [BST_PerIni] > [BST_PerFin]
                 group by [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 union
                 select
                    BOM_Struct.[BSU_NoParte]
                    , BOM_Struct.[BSU_NoParteAux]
                    , BOM_Struct.[BST_NoParte]
                    , BOM_Struct.[BST_NoParteAux]
                 from
                    BOM_Struct inner join
                    (select
                        [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                     from
                        BOM_Struct
                     group by
                        [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                     having
                        count(*) > 1) BOM_StructConVersiones
                       on BOM_Struct.[BSU_NoParte] = BOM_StructConVersiones.[BSU_NoParte]
                          and BOM_Struct.[BSU_NoParteAux]
                                 = BOM_StructConVersiones.[BSU_NoParteAux]
                          and BOM_Struct.[BST_NoParte]
                                 = BOM_StructConVersiones.[BST_NoParte]
                          and BOM_Struct.[BST_NoParteAux]
                                 = BOM_StructConVersiones.[BST_NoParteAux]
                 where
                    exists(select
                              B1.[BST_Codigo]
                           from
                              BOM_Struct B1
                           where
                              B1.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                              and  B1.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                              and B1.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                              and B1.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
                              and B1.[BST_Codigo] <> BOM_Struct.[BST_Codigo]
                              and (B1.[BST_PerIni] = BOM_Struct.[BST_PerIni]
                                   or B1.[BST_PerFin] = BOM_Struct.[BST_PerFin]
                                   or (B1.[BST_PerFin] > BOM_Struct.[BST_PerIni]
                                       and B1.[BST_PerFin] < BOM_Struct.[BST_PerFin])))
                  group by
                     BOM_Struct.[BSU_NoParte]
                    , BOM_Struct.[BSU_NoParteAux]
                    , BOM_Struct.[BST_NoParte]
                    , BOM_Struct.[BST_NoParteAux]
                ) BOMInconsistencias
                   on PadresHijos.[BSU_NoParte] collate database_default
                         = BOMInconsistencias.[BSU_NoParte]
                      and PadresHijos.[BSU_NoParteAux] collate database_default
                             = BOMInconsistencias.[BSU_NoParteAux]
                      and PadresHijos.[BST_NoParte] collate database_default
                             = BOMInconsistencias.[BST_NoParte]
                      and PadresHijos.[BST_NoParteAux] collate database_default
                             = BOMInconsistencias.[BST_NoParteAux])
      begin
         insert into ImportLogErrors([IdError], [Descripcion])
         select
            1
            , 'No. de parte ' + PadresHijos.[BSU_NoParte]
              + ' con componente ' + PadresHijos.[BST_NoParte]
              + ' de la división ' + PadresHijos.[BSU_NoParteAux]
              + ' presenta inconsistencias en las fechas en la base de datos. '
              + 'Debe corregirlas antes de actualizar esta relación en BOM.'
         from
            @PadresHijos PadresHijos inner join
            (
             select   [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
             from     BOM_Struct
             where    [BST_PerIni] > [BST_PerFin]
             group by [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
             union
             select
                BOM_Struct.[BSU_NoParte]
                , BOM_Struct.[BSU_NoParteAux]
                , BOM_Struct.[BST_NoParte]
                , BOM_Struct.[BST_NoParteAux]
             from
                BOM_Struct inner join
                (select
                    [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 from
                    BOM_Struct
                 group by
                    [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 having
                    count(*) > 1) BOM_StructConVersiones
                   on BOM_Struct.[BSU_NoParte] = BOM_StructConVersiones.[BSU_NoParte]
                      and BOM_Struct.[BSU_NoParteAux]
                             = BOM_StructConVersiones.[BSU_NoParteAux]
                      and BOM_Struct.[BST_NoParte]
                             = BOM_StructConVersiones.[BST_NoParte]
                      and BOM_Struct.[BST_NoParteAux]
                             = BOM_StructConVersiones.[BST_NoParteAux]
             where
                exists(select
                          B1.[BST_Codigo]
                       from
                          BOM_Struct B1
                       where
                          B1.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                          and  B1.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                          and B1.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                          and B1.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
                          and B1.[BST_Codigo] <> BOM_Struct.[BST_Codigo]
                          and (B1.[BST_PerIni] = BOM_Struct.[BST_PerIni]
                               or B1.[BST_PerFin] = BOM_Struct.[BST_PerFin]
                               or (B1.[BST_PerFin] > BOM_Struct.[BST_PerIni]
                                   and B1.[BST_PerFin] < BOM_Struct.[BST_PerFin])))
              group by
                 BOM_Struct.[BSU_NoParte]
                 , BOM_Struct.[BSU_NoParteAux]
                 , BOM_Struct.[BST_NoParte]
                 , BOM_Struct.[BST_NoParteAux]
            ) BOMInconsistencias
                on PadresHijos.[BSU_NoParte] collate database_default
                      = BOMInconsistencias.[BSU_NoParte]
                   and PadresHijos.[BSU_NoParteAux] collate database_default
                          = BOMInconsistencias.[BSU_NoParteAux]
                   and PadresHijos.[BST_NoParte] collate database_default
                          = BOMInconsistencias.[BST_NoParte]
                   and PadresHijos.[BST_NoParteAux] collate database_default
                          = BOMInconsistencias.[BST_NoParteAux]
         
         
         delete
            @PadresHijos
         from
            @PadresHijos PadresHijos inner join
            (
             select   [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
             from     BOM_Struct
             where    [BST_PerIni] > [BST_PerFin]
             group by [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
             union
             
             select
                BOM_Struct.[BSU_NoParte]
                , BOM_Struct.[BSU_NoParteAux]
                , BOM_Struct.[BST_NoParte]
                , BOM_Struct.[BST_NoParteAux]
             from
                BOM_Struct inner join
                (select
                    [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 from
                    BOM_Struct
                 group by
                    [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 having
                    count(*) > 1) BOM_StructConVersiones
                   on BOM_Struct.[BSU_NoParte] = BOM_StructConVersiones.[BSU_NoParte]
                      and BOM_Struct.[BSU_NoParteAux]
                             = BOM_StructConVersiones.[BSU_NoParteAux]
                      and BOM_Struct.[BST_NoParte]
                             = BOM_StructConVersiones.[BST_NoParte]
                      and BOM_Struct.[BST_NoParteAux]
                             = BOM_StructConVersiones.[BST_NoParteAux]
             where
                exists(select
                          B1.[BST_Codigo]
                       from
                          BOM_Struct B1
                       where
                          B1.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                          and  B1.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                          and B1.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                          and B1.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
                          and B1.[BST_Codigo] <> BOM_Struct.[BST_Codigo]
                          and (B1.[BST_PerIni] = BOM_Struct.[BST_PerIni]
                               or B1.[BST_PerFin] = BOM_Struct.[BST_PerFin]
                               or (B1.[BST_PerFin] > BOM_Struct.[BST_PerIni]
                                   and B1.[BST_PerFin] < BOM_Struct.[BST_PerFin])))
              group by
                 BOM_Struct.[BSU_NoParte]
                 , BOM_Struct.[BSU_NoParteAux]
                 , BOM_Struct.[BST_NoParte]
                 , BOM_Struct.[BST_NoParteAux]
            ) BOMInconsistencias
               on PadresHijos.[BSU_NoParte] collate database_default
                     = BOMInconsistencias.[BSU_NoParte]
                   and PadresHijos.[BSU_NoParteAux] collate database_default
                          = BOMInconsistencias.[BSU_NoParteAux]
                   and PadresHijos.[BST_NoParte] collate database_default
                          = BOMInconsistencias.[BST_NoParte]
                   and PadresHijos.[BST_NoParteAux] collate database_default
                          = BOMInconsistencias.[BST_NoParteAux]
         
         
         delete
            TempBOM_HysonB
         from
            TempBOM_HysonB inner join
            (
             select   [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
             from     BOM_Struct
             where    [BST_PerIni] > [BST_PerFin]
             group by [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
             union
             select
                BOM_Struct.[BSU_NoParte]
                , BOM_Struct.[BSU_NoParteAux]
                , BOM_Struct.[BST_NoParte]
                , BOM_Struct.[BST_NoParteAux]
             from
                BOM_Struct inner join
                (select
                    [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 from
                    BOM_Struct
                 group by
                    [BSU_NoParte], [BSU_NoParteAux], [BST_NoParte], [BST_NoParteAux]
                 having
                    count(*) > 1) BOM_StructConVersiones
                   on BOM_Struct.[BSU_NoParte] = BOM_StructConVersiones.[BSU_NoParte]
                      and BOM_Struct.[BSU_NoParteAux]
                             = BOM_StructConVersiones.[BSU_NoParteAux]
                      and BOM_Struct.[BST_NoParte]
                             = BOM_StructConVersiones.[BST_NoParte]
                      and BOM_Struct.[BST_NoParteAux]
                             = BOM_StructConVersiones.[BST_NoParteAux]
             where
                exists(select
                          B1.[BST_Codigo]
                       from
                          BOM_Struct B1
                       where
                          B1.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                          and  B1.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                          and B1.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                          and B1.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
                          and B1.[BST_Codigo] <> BOM_Struct.[BST_Codigo]
                          and (B1.[BST_PerIni] = BOM_Struct.[BST_PerIni]
                               or B1.[BST_PerFin] = BOM_Struct.[BST_PerFin]
                               or (B1.[BST_PerFin] > BOM_Struct.[BST_PerIni]
                                   and B1.[BST_PerFin] < BOM_Struct.[BST_PerFin])))
              group by
                 BOM_Struct.[BSU_NoParte]
                 , BOM_Struct.[BSU_NoParteAux]
                 , BOM_Struct.[BST_NoParte]
                 , BOM_Struct.[BST_NoParteAux]
            ) BOMInconsistencias
               on ltrim(rtrim(TempBOM_HysonB.[NumPadre])) collate database_default
                     = BOMInconsistencias.[BSU_NoParte]
                   and ltrim(rtrim(TempBOM_HysonB.[Division])) collate database_default
                          = BOMInconsistencias.[BSU_NoParteAux]
                   and ltrim(rtrim(TempBOM_HysonB.[NumHijo])) collate database_default
                          = BOMInconsistencias.[BST_NoParte]
                   and ltrim(rtrim(TempBOM_HysonB.[Division])) collate database_default
                          = BOMInconsistencias.[BST_NoParteAux]
            
      end
   
   
   
   update
      BOM_Struct
   set
      [BST_PerFin] = dateadd(day, -1, dateadd(day, datediff(day, 0, getdate()), 0))
   where
      [BST_Codigo] in
         (select
             BOM_Struct.[BST_Codigo]
          from
             BOM_Struct inner join
             (select
                 rtrim([NumPadre])
                    + case when not (ltrim([Alterna]) like '1')
                         then case when cast([Alterna] as int) < 10
                                 then '0'
                                 else ''
                               end + cast(cast([Alterna] as int) as varchar(2))
                         else ''
                      end as [BSU_NoParte]
                 , rtrim([Division]) as [BSU_NoParteAux]
              from
                 TempBOM_Hyson
              group by
                 rtrim([NumPadre])
                    + case when not (ltrim([Alterna]) like '1')
                         then case when cast([Alterna] as int) < 10
                                 then '0'
                                 else ''
                               end + cast(cast([Alterna] as int) as varchar(2))
                         else ''
                      end
                 , rtrim([Division])
             ) PadresHijos
                on BOM_Struct.[BSU_NoParte]
                      = PadresHijos.[BSU_NoParte] collate database_default
                   and BOM_Struct.[BSU_NoParteAux]
                          = PadresHijos.[BSU_NoParteAux] collate database_default
          where
             BOM_Struct.[BST_Codigo] not in
                (select
                    B0.[BST_Codigo]
                 from
                    BOM_Struct B0 inner join @PadresHijos PadresHijos
                       on B0.[BSU_NoParte]
                             = PadresHijos.[BSU_NoParte] collate database_default
                          and B0.[BSU_NoParteAux]
                                 = PadresHijos.[BSU_NoParteAux] collate database_default
                          and B0.[BST_NoParte]
                                 = PadresHijos.[BST_NoParte] collate database_default
                          and B0.[BST_NoParteAux]
                                 = PadresHijos.[BST_NoParteAux] collate database_default)
             and BOM_Struct.[BST_PerFin] > dateadd(day, datediff(day, 0, getdate()), 0)
             and BOM_Struct.[BST_Codigo] in
                    (select
                        B0.[BST_Codigo]
                     from
                        BOM_Struct B0 inner join
                        (select
                            B1.[BSU_NoParte]
                            , B1.[BSU_NoParteAux]
                            , B1.[BST_NoParte]
                            , B1.[BST_NoParteAux]
                            , max(B1.[BST_PerIni]) as [BST_PerIni]
                            , B1.[BST_PerFin]
                         from
                            BOM_Struct B1
                         where
                            B1.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                            and B1.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                            and B1.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                            and B1.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
                         group by
                            B1.[BSU_NoParte]
                            , B1.[BSU_NoParteAux]
                            , B1.[BST_NoParte]
                            , B1.[BST_NoParteAux]
                            , B1.[BST_PerFin]
                        ) BOMStructUltimo
                           on B0.[BSU_NoParte] = BOMStructUltimo.[BSU_NoParte]
                              and B0.[BSU_NoParteAux] = BOMStructUltimo.[BSU_NoParteAux]
                              and B0.[BST_NoParte] = BOMStructUltimo.[BST_NoParte]
                              and B0.[BST_NoParteAux] = BOMStructUltimo.[BST_NoParteAux]
                              and B0.[BST_PerIni] = BOMStructUltimo.[BST_PerIni]
                              and B0.[BST_PerFin] = BOMStructUltimo.[BST_PerFin]
                              and not exists(select
                                                B0.[BST_Codigo]
                                             from
                                                BOM_Struct B0
                                             where
                                                B0.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                                                and B0.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                                                and B0.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                                                and B0.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
                                                and B0.[BST_Codigo] <> BOM_Struct.[BST_Codigo]
                                                and B0.[BST_PerFin]
                                                       >= dateadd(day, datediff(day, 0, getdate()), 0)))
         )
      and [BST_PerIni] < dateadd(day, -1, dateadd(day, datediff(day, 0, getdate()), 0))
   
   
   insert into @RegsUnicos([Consecutivo])
   select
      TempBOM_HysonB.[Consecutivo]
   from
      (select
          TempBOM.[BSU_NoParte]
          , TempBOM.[BSU_NoParteAux]
          , TempBOM.[BST_NoParte]
          , TempBOM.[BST_NoParteAux]
       from
          (select 
              ltrim(rtrim([NumPadre])) collate database_default as [BSU_NoParte]
              , ltrim(rtrim([Division])) collate database_default as [BSU_NoParteAux]
              , ltrim(rtrim([NumHijo])) collate database_default as [BST_NoParte]
              , ltrim(rtrim([Division])) collate database_default as [BST_NoParteAux]
           from
              TempBOM_HysonB
           group by
              ltrim(rtrim([NumPadre])) collate database_default
              , ltrim(rtrim([Division])) collate database_default
              , ltrim(rtrim([NumHijo])) collate database_default
              , ltrim(rtrim([Division])) collate database_default
           having
              count(*) = 1) TempBOM left outer join BOM_Struct
             on TempBOM.[BSU_NoParte] = BOM_Struct.[BSU_NoParte]
                and TempBOM.[BSU_NoParteAux] = BOM_Struct.[BSU_NoParteAux]
                and TempBOM.[BST_NoParte] = BOM_Struct.[BST_NoParte]
                and TempBOM.[BST_NoParteAux] = BOM_Struct.[BST_NoParteAux]
       where
          BOM_Struct.[BSU_NoParte] is null) TempBOM inner join TempBOM_HysonB
         on TempBOM.[BSU_NoParte] = ltrim(rtrim(TempBOM_HysonB.[NumPadre])) collate database_default
            and TempBOM.[BSU_NoParteAux] = ltrim(rtrim(TempBOM_HysonB.[Division])) collate database_default
            and TempBOM.[BST_NoParte] = ltrim(rtrim(TempBOM_HysonB.[NumHijo])) collate database_default
            and TempBOM.[BST_NoParteAux] = ltrim(rtrim(TempBOM_HysonB.[Division])) collate database_default
   
   
   if (select count(*) from @RegsUnicos) > 0
      begin
	 if exists (SELECT name FROM dbo.sysobjects WHERE dbo.sysobjects.name = N'RegsUnicos')
		drop table RegsUnicos
	 select * into RegsUnicos from @RegsUnicos

         insert into BOM_Struct
                  ([BSU_Subensamble]
                   , [BST_Hijo]
                   , [BST_Incorpor]
                   , [BST_Disch]
                   , [ME_Codigo]
                   , [FactConv]
                   , [BST_PerIni]
                   , [BST_PerFin]
                   , [ME_Gen]
                   , [BSU_NoParte]
                   , [BST_NoParte]
                   , [BST_Tip_Ens]
                   , [BST_Sec]
                   , [BSU_NoParteAux]
                   , [BST_NoParteAux])
               select
                  Maestro.[MA_Codigo]
                  , Maestro_1.[MA_Codigo]
                  , TempBOM_HysonB.[Cantidad]
                  , 
                    TempBOM_HysonB.[SeDescarga]
                  , 
                    Maestro_1.[ME_Com]
                  , isnull(Maestro_1.[EQ_Gen], 1)
                  , TempBOM_HysonB.[FechaIni]
                  , TempBOM_HysonB.[FechaFinal]
                  , isnull(Maestro_2.[ME_Com], 19)
                  , Maestro.[MA_NoParte]
                  , Maestro_1.[MA_NoParte]
                  , 
                    case when TempBOM_HysonB.[PtSub] = 'P'
                       then 'C' 
                       else 'F' 
                    end as [BST_Tip_Ens]
                  , -1
                  , Maestro.[MA_NoparteAux]
                  , Maestro_1.[MA_NoParteAux]
               from
                  TempBOM_HysonB inner join Maestro
                     on ltrim(rtrim(TempBOM_HysonB.[NumPadre]))
                           = ltrim(rtrim(Maestro.[MA_NoParte]))
                        and ltrim(rtrim(TempBOM_HysonB.[Division]))
                               = ltrim(rtrim(Maestro.[MA_NoParteAux]))
                        and Maestro.[MA_Inv_Gen] = 'I'
                  inner join Maestro Maestro_1
                     on ltrim(rtrim(TempBOM_HysonB.[NumHijo]))
                           = ltrim(rtrim(Maestro_1.[MA_NoParte]))
                        and ltrim(rtrim(TempBOM_HysonB.[Division]))
                               = ltrim(rtrim(Maestro_1.[MA_NoParteAux]))
                        and Maestro_1.[MA_Inv_Gen] = 'I'
                  left outer join Maestro Maestro_2
                     on Maestro_1.[MA_Generico] = Maestro_2.[MA_Codigo]
               where
                  TempBOM_HysonB.[Consecutivo] in (select [Consecutivo] from RegsUnicos)
         
         
         delete
            TempBOM_HysonB
         where
            [Consecutivo] in (select [Consecutivo] from @RegsUnicos)
         
         
         delete @RegsUnicos
      end
   
   
   insert into @RegsUnicos([Consecutivo], [BST_Codigo])
   select
      TempBOM_HysonB.[Consecutivo]
      , BOM_Struct.[BST_Codigo]
   from
      TempBOM_HysonB inner join BOM_Struct
         on TempBOM_HysonB.[NumPadre] = BOM_Struct.[BSU_NoParte]
            and TempBOM_HysonB.[Division] = BOM_Struct.[BSU_NoParteAux]
            and TempBOM_HysonB.[NumHijo] = BOM_Struct.[BST_NoParte]
            and TempBOM_HysonB.[Division] = BOM_Struct.[BST_NoParteAux]
            and TempBOM_HysonB.[FechaIni] = BOM_Struct.[BST_PerIni]
            and TempBOM_HysonB.[FechaFinal] = BOM_Struct.[BST_PerFin]
   
   if (select count(*) from @RegsUnicos) > 0
      begin
         update
            BOM_Struct
         set
            BOM_Struct.[BST_Incorpor] = TempBOM_HysonB.[Cantidad]
         from
            BOM_Struct inner join @RegsUnicos RegsUnicos
               on BOM_Struct.[BST_Codigo] = RegsUnicos.[BST_Codigo]
            inner join TempBOM_HysonB
               on RegsUnicos.[Consecutivo] = TempBOM_HysonB.[Consecutivo]
         
         
         delete
            TempBOM_HysonB
         where
            [Consecutivo] in (select [Consecutivo] from @RegsUnicos)
         
         delete @RegsUnicos
      end
   
   
   set @Consecutivo    = (select min([Consecutivo])
                          from   TempBOM_HysonB)
   set @MaxConsecutivo = (select max([Consecutivo])
                          from   TempBOM_HysonB)
   while @Consecutivo <= @MaxConsecutivo
   begin
      select
         @NumPadre       = [NumPadre]
         , @NumHijo      = [NumHijo]
         , @Division     = [Division]
         , @FechaInicio  = [FechaIni]
         , @FechaFinal   = [FechaFinal]
         , @Cantidad     = [Cantidad]
         , @SeDescarga   = [SeDescarga]
      from
         TempBOM_HysonB
      where
         [Consecutivo] = @Consecutivo
      
      
      set @BST_Codigo = (select
                            [BST_Codigo]
                         from
                            BOM_Struct
                         where
                            [BSU_NoParte] = @NumPadre
                            and [BSU_NoParteAux] = @Division
                            and [BST_NoParte] = @NumHijo
                            and [BST_NoParteAux] = @Division
                            and [BST_PerIni] = @FechaInicio
                            and [BST_PerFin] = @FechaFinal)
      
      
      set @BST_CodigoUltimo = (select top 1
                                  [BST_Codigo]
                               from
                                  BOM_Struct
                               where
                                  [BSU_NoParte] = @NumPadre
                                  and [BSU_NoParteAux] = @Division
                                  and [BST_NoParte] = @NumHijo
                                  and [BST_NoParteAux] = @Division
                               order by
                                  [BST_PerIni] desc, [BST_PerFin] desc)
      
      
      if @BST_CodigoUltimo is null
         begin
            set @FechaInicioUltima = null
            set @FechaFinalUltima  = null
            set @CantidadUltima    = null
         end
      else
         begin
            select
               @FechaInicioUltima   = [BST_PerIni]
               , @FechaFinalUltima  = [BST_PerFin]
               , @CantidadUltima    = [BST_Incorpor]
            from
               BOM_Struct
            where
               [BST_Codigo] = @BST_CodigoUltimo
         end
      
      set @InsertarRegistro = 0
      
      
      if @BST_Codigo is not null
         begin
            update
               BOM_Struct
            set
               [BST_Incorpor] = @Cantidad
            where
               [BST_Codigo] = @BST_Codigo

               insert into ImportLogErrors([IdError], [Descripcion],[Padre],[Hijo],[Division], [FechaInicio], [FechaFinal], [Cantidad], [Consecutivo])
               select
                  5
                  , 'Estructura repetida y actualiza la incorporación, ya que existe con mismas fechas, pero con diferente incorporación'
                 , @NumPadre
                 , @NumHijo
                 , @Division
				 , @FechaInicio  
				 , @FechaFinal 
				 , @Cantidad
				 , @Consecutivo               
         end
      else
         begin
            if @FechaInicio = @FechaInicioUltima
               and @FechaFinal = @FechaFinalUltima
               begin
                  update
                     BOM_Struct
                  set
                     BOM_Struct.[BST_Incorpor] = @Cantidad
                  where
                     BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
               end
            
            if (@FechaInicio < @FechaInicioUltima
                and @FechaFinal = @FechaFinalUltima)
               or (@FechaInicio < @FechaInicioUltima
                   and @FechaFinal < @FechaFinalUltima
                   and @FechaInicioUltima < @FechaFinal)
               begin
                  if exists(select
                               [BST_Codigo]
                            from
                               BOM_Struct
                            where
                               [BSU_NoParte] = @NumPadre
                               and [BSU_NoParteAux] = @Division
                               and [BST_NoParte] = @NumHijo
                               and [BST_NoParteAux] = @Division
                               and [BST_Codigo] <> @BST_CodigoUltimo
                               and @FechaInicio >= [BST_PerIni]
                               and @FechaInicio <= [BST_PerFin])
                     begin
                        insert into ImportLogErrors([IdError], [Descripcion])
                        select
                           2
                           , 'No. de parte ' + @NumPadre
                             + ' con componente ' + @NumHijo
                             + ' de la división ' + @Division
                             + ' presenta conflicto entre las fechas en el archivo con las'
                             + ' fechas en la base de datos. '
                             + 'No se puede subir esta relación en BOM.'
                     end
                  else
                     begin
                        update
                           BOM_Struct
                        set
                           BOM_Struct.[BST_Incorpor] = @Cantidad
                           , BOM_Struct.[BST_PerIni] = @FechaInicio
                        where
                           BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
                     end
               end
            
            if @FechaInicio < @FechaInicioUltima
               and @FechaFinal > @FechaFinalUltima
               begin
                  if exists(select
                               [BST_Codigo]
                            from
                               BOM_Struct
                            where
                               [BSU_NoParte] = @NumPadre
                               and [BSU_NoParteAux] = @Division
                               and [BST_NoParte] = @NumHijo
                               and [BST_NoParteAux] = @Division
                               and [BST_Codigo] <> @BST_CodigoUltimo
                               and @FechaInicio >= [BST_PerIni]
                               and @FechaInicio <= [BST_PerFin])
                     begin
                        insert into ImportLogErrors([IdError], [Descripcion])
                        select
                           3
                           , 'No. de parte ' + @NumPadre
                             + ' con componente ' + @NumHijo
                             + ' de la división ' + @Division
                             + ' presenta conflicto de las fechas en el archivo con las'
                             + ' fechas en la base de datos. '
                             + 'No se puede subir esta relación en BOM.'
                     end
                  else
                     begin
                        update
                           BOM_Struct
                        set
                           BOM_Struct.[BST_Incorpor] = @Cantidad
                           , BOM_Struct.[BST_PerIni] = @FechaInicio
                           , BOM_Struct.[BST_PerFin] = @FechaFinal
                        where
                           BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
                     end
               end
            
            
            if (@FechaInicio > @FechaInicioUltima
                and @FechaFinal > @FechaFinalUltima
                and @FechaInicio > @FechaFinalUltima)
               or (@FechaInicio < @FechaInicioUltima
                   and @FechaFinal < @FechaFinalUltima
                   and @FechaFinal < @FechaInicioUltima)
            begin
               if @FechaInicio < @FechaInicioUltima
                  and @FechaFinal < @FechaFinalUltima
                  and @FechaFinal < @FechaInicioUltima
                  and exists(select
                                [BST_Codigo]
                             from
                                BOM_Struct
                             where
                                [BSU_NoParte] = @NumPadre
                                and [BSU_NoParteAux] = @Division
                                and [BST_NoParte] = @NumHijo
                                and [BST_NoParteAux] = @Division
                                and [BST_Codigo] <> @BST_CodigoUltimo
                                and (([BST_PerIni] <= @FechaFinal
                                      and [BST_PerFin] >= @FechaFinal)
                                     or ([BST_PerIni] <= @FechaInicio
                                         and[BST_PerFin] >= @FechaInicio))
                            )
                  begin
                     if not exists(select
                                      [BST_Codigo]
                                   from
                                      BOM_Struct
                                   where
                                      [BSU_NoParte] = @NumPadre
                                      and [BSU_NoParteAux] = @Division
                                      and [BST_NoParte] = @NumHijo
                                      and [BST_NoParteAux] = @Division
                                      and ([BST_PerIni] <= @FechaInicio
                                           and [BST_PerFin] >= @FechaFinal)
                                      and [BST_Incorpor] = @Cantidad)
                        begin
                           insert into ImportLogErrors([IdError], [Descripcion])
                           select
                              4
                              , 'No. de parte ' + @NumPadre
                                + ' con componente ' + @NumHijo
                                + ' de la división ' + @Division
                                + ' presenta conflicto de las fechas en el archivo con las'
                                + ' fechas en la base de datos. '
                                + 'No se puede subir esta relación en BOM.'
                        end
                  end
               else
                  begin
                     if @CantidadUltima = @Cantidad and
                        abs(datediff(dd, @FechaFinalUltima, @FechaInicio)) = 1
                        begin
                           update
                              BOM_Struct
                           set
                              BOM_Struct.[BST_PerIni] = case when @FechaInicio > @FechaInicioUltima
                                                           then @FechaInicioUltima
                                                           else @FechaInicio
                                                        end
                              , BOM_Struct.[BST_PerFin] = case when @FechaFinal > @FechaFinalUltima
                                                             then @FechaFinal
                                                             else @FechaFinalUltima
                                                          end
                           where
                              BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
                        end
                     else
                        begin
                           set @InsertarRegistro = 1
                        end
                  end
            end
            
            if @BST_CodigoUltimo is null
            begin
               set @InsertarRegistro = 1
            end
            
            
            if (@FechaInicio > @FechaInicioUltima
                and @FechaFinal = @FechaFinalUltima)
               or (@FechaInicio > @FechaInicioUltima
                   and @FechaFinal > @FechaFinalUltima
                   and @FechaInicio < @FechaFinalUltima)
               or (@FechaInicio > @FechaInicioUltima
                   and @FechaFinal < @FechaFinalUltima
                   and @FechaInicio < @FechaFinalUltima)
            begin
               if @CantidadUltima = @Cantidad
                  begin
                     update
                        BOM_Struct
                     set
                        BOM_Struct.[BST_PerIni] = case when @FechaInicio > @FechaInicioUltima
                                                     then @FechaInicioUltima
                                                     else @FechaInicio
                                                  end
                        , BOM_Struct.[BST_PerFin] = case when @FechaFinal > @FechaFinalUltima
                                                       then @FechaFinal
                                                       else @FechaFinalUltima
                                                    end
                     where
                        BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
                     
                  end
               else
                  begin
                     update
                        BOM_Struct
                     set
                        [BST_PerFin]
                           = dateadd(day, -1, dateadd(day, datediff(day, 0, @FechaInicio), 0))
                     where
                        [BST_Codigo] = @BST_CodigoUltimo
                     
                     set @InsertarRegistro = 1
                  end
            end
            
            
            if @FechaInicio = @FechaInicioUltima
               and @FechaFinal <> @FechaFinalUltima
            begin
               if ((@FechaFinal < @FechaFinalUltima
                     and year(@FechaFinalUltima) >= 2099 
                   ) or @FechaFinal > @FechaFinalUltima)
                  begin
                     update
                        BOM_Struct
                     set
                        BOM_Struct.[BST_Incorpor] = @Cantidad
                        , BOM_Struct.[BST_PerFin]  = @FechaFinal
                     where
                        BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
                  end
               else
                  begin
                     update
                        BOM_Struct
                     set
                        BOM_Struct.[BST_Incorpor] = @Cantidad
                     where
                        BOM_Struct.[BST_Codigo] = @BST_CodigoUltimo
                  end
            end
            
            
            if @InsertarRegistro = 1
            begin
               insert into BOM_Struct
                  ([BSU_Subensamble]
                   , [BST_Hijo]
                   , [BST_Incorpor]
                   , [BST_Disch]
                   , [ME_Codigo]
                   , [FactConv]
                   , [BST_PerIni]
                   , [BST_PerFin]
                   , [ME_Gen]
                   , [BSU_NoParte]
                   , [BST_NoParte]
                   , [BST_Tip_Ens]
                   , [BST_Sec]
                   , [BSU_NoParteAux]
                   , [BST_NoParteAux])
               select
                  Maestro.[MA_Codigo]
                  , Maestro_1.[MA_Codigo]
                  , sum(TempBOM_HysonB.[Cantidad])
                  , 
                    TempBOM_HysonB.[SeDescarga]
                  , 
                    Maestro_1.[ME_Com]
                  , isnull(Maestro_1.[EQ_Gen], 1)
                  , TempBOM_HysonB.[FechaIni]
                  , TempBOM_HysonB.[FechaFinal]
                  , isnull(Maestro_2.[ME_Com], 19)
                  , Maestro.[MA_NoParte]
                  , Maestro_1.[MA_NoParte]
                  , 
                    case when TempBOM_HysonB.[PtSub] = 'P'
                       then 'C' 
                       else 'F' 
                    end as [BST_Tip_Ens]
                  , -1
                  , Maestro.[MA_NoparteAux]
                  , Maestro_1.[MA_NoParteAux]
               from
                  TempBOM_HysonB inner join Maestro
                     on ltrim(rtrim(TempBOM_HysonB.[NumPadre]))
                           = ltrim(rtrim(Maestro.[MA_NoParte]))
                        and ltrim(rtrim(TempBOM_HysonB.[Division]))
                               = ltrim(rtrim(Maestro.[MA_NoParteAux]))
                        and Maestro.[MA_Inv_Gen] = 'I'
                  inner join Maestro Maestro_1
                     on ltrim(rtrim(TempBOM_HysonB.[NumHijo]))
                           = ltrim(rtrim(Maestro_1.[MA_NoParte]))
                        and ltrim(rtrim(TempBOM_HysonB.[Division]))
                               = ltrim(rtrim(Maestro_1.[MA_NoParteAux]))
                        and Maestro_1.[MA_Inv_Gen] = 'I'
                  left outer join Maestro Maestro_2
                     on Maestro_1.[MA_Generico] = Maestro_2.[MA_Codigo]
               where
                  TempBOM_HysonB.[Consecutivo] = @Consecutivo
               group by
                  Maestro.[MA_Codigo]
                  , Maestro_1.[MA_Codigo]
                  , 
                    TempBOM_HysonB.[SeDescarga]
                  , Maestro_1.[ME_Com]
                  , isnull(Maestro_1.[EQ_Gen], 1)
                  , isnull(Maestro_2.[ME_Com], 19)
                  , Maestro.[MA_NoParte]
                  , Maestro_1.[MA_NoParte]
                  , Maestro.[MA_NoParteAux]
                  , Maestro_1.[MA_NoParteAux]
                  , 
                    case when TempBOM_HysonB.[PtSub] = 'P'
                       then 'C' 
                       else 'F' 
                    end
                  , TempBOM_HysonB.[FechaIni]
                  , TempBOM_HysonB.[FechaFinal]
            end
           else
			begin
               insert into ImportLogErrors([IdError], [Descripcion],[Padre],[Hijo],[Division], [FechaInicio], [FechaFinal], [Cantidad], [Consecutivo])
               select
                  5
                  , 'No. de parte ' + @NumPadre
                    + ' con componente ' + @NumHijo
                    + ' de la división ' + @Division
                    + ' presenta conflicto de las fechas en el archivo con las'
                    + ' fechas en la base de datos. '
                    + 'No se puede subir esta relación en BOM.'
                 , @NumPadre
                 , @NumHijo
                 , @Division
				 , @FechaInicio  
				 , @FechaFinal 
				 , @Cantidad
				 , @Consecutivo
                    
			end
         end
      
      
      
      set @Consecutivo = (select top 1
                             [Consecutivo]
                          from
                             TempBOM_HysonB
                          where
                             [Consecutivo] > @Consecutivo
                          order by
                             [Consecutivo])
      
   end 
   
   
   delete TempBOM_HysonB
   
GO
