SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[sp_DescExplosion_Retrabajo](@CodigoFactura Int) --with encryption as
as
   set nocount on
   
   declare @CF_ExplosDescAdd char(1)
           , @TEmbarque char(1)
           , @BST_TipoDesc char(1)
           , @IdRegistro int
           , @FED_IndiceD int
           , @BST_PT int
           , @FED_Cant decimal(38, 6)
           , @FED_Fecha_Struct datetime
           , @CountBOM int
   declare @Indices table([IdRegistro] int identity(1, 1) not null
                          , [FED_IndiceD] int not null
                          , [BST_PT] int not null
                          , [RE_Incorpor] decimal(38, 6)
                          , [FED_Fecha_Struct] datetime null
                          , [ME_Gen] int null
                          , primary key clustered ([IdRegistro]))
   declare @VPIDescarga table([MA_Codigo] int not null
                              , [PID_SaldoGen] decimal(38, 6) not null
                              , primary key clustered ([MA_Codigo]))
   declare @TempFiscComp table([BSU_Subensamble] int null
                               , [BST_CantidadUsoFinal] decimal(38, 6) null)
   declare @SumCantidadUsoFinal decimal(38, 6)
           , @UsoFinal decimal(38,6)
           , @UsoFinalIncluido decimal(38,6)
           , @SaldoActual decimal(38,6)
           , @ME_Gen int
           , @SaldoUsable decimal(38,6)
           , @CantAlcanza decimal(38,6)
           , @CantAExplosionar decimal(38,6)
   
   select @CF_ExplosDescAdd = [CF_ExplosDescAdd]
   from   Configuracion 
   
   exec sp_CreaVDescRetrabajo @CodigoFactura
   
   
   select @TEmbarque = [CFQ_Tipo]
   from   ConfiguraTEmbarque 
   where  [TQ_Codigo] in (select [TQ_Codigo]
                          from   FactExp
                          where [FE_Codigo] = @CodigoFactura)
   
   
   if @TEmbarque = 'D'
         set @BST_TipoDesc = 'D'
      else
         set @BST_TipoDesc = 'N'
   
   
   -- se insertan los consumibles en produccion como merma	
   insert into BOM_DescTemp([FE_Codigo],      [BST_PT],       [BST_Hijo],    [FED_Cant]
                            , [BST_Disch],    [TI_Codigo],    [ME_Codigo],   [FactConv]
                            , [ME_Gen],       [BST_Incorpor], [FED_IndiceD], [MA_Tip_Ens]
                            , [BST_TipoDesc], [BST_Nivel])
   select
      [FE_Codigo],      [MA_Codigo],   [MA_Hijo],                  1
      , [MA_Discharge], [CFT_Tipo],    isnull([ME_Com], [ME_Gen]), [FactConv]
      , [ME_Gen],       [RE_Incorpor], [FED_IndiceD],              [MA_Tip_Ens]
      , 'M',            'RC'
   from
      VDescRetrabajo
   where
      [FED_Retrabajo] = 'C'
      and [FE_Codigo] = @CodigoFactura
      and [RE_Incorpor] > 0
    
    
    -- la vista VDescRetrabajo ya trae integrado el producto terminado en caso de
    -- FED_Retrabajo = 'R'
    
    
    if @CF_ExplosDescAdd = 'S'
    begin
        -- se insertan los diferentes de consumibles en produccion, diferentes de
        -- estructura dinamica y diferentes de adicion a descarga, o sea los que tienen
        -- el tipo de descarga Retrabajo
        insert into BOM_DescTemp([FE_Codigo],      [BST_PT],       [BST_Hijo]
                                 , [FED_Cant],     [BST_Disch],    [TI_Codigo]
                                 , [ME_Codigo],    [FactConv],     [ME_Gen]
                                 , [BST_Incorpor], [FED_IndiceD],  [MA_Tip_Ens]
                                 , [BST_TipoDesc], [BST_Nivel])
        
        select
           [FE_Codigo],                  [MA_Codigo],      [MA_Hijo]
           , 1,                          [MA_Discharge],   [CFT_Tipo]
           , isnull([ME_Com], [ME_Gen]), [FactConv],       [ME_Gen]
           , [RE_Incorpor],              [FED_IndiceD],    [MA_Tip_Ens]
           , @BST_TipoDesc,              'RR'
        from
           VDescRetrabajo
        where
           [FED_Retrabajo] <> 'C'
           and [FED_Retrabajo] <> 'D'
           and [FED_Retrabajo] <> 'E'
           and [FED_Retrabajo] <> 'A'
           and [FE_Codigo] = @CodigoFactura
           --and [RE_Incorpor] > 0
        
        
        -- se insertan los de adición a descarga pero que sean diferentes de productos
        -- terminados y subensambles
        insert into BOM_DescTemp([FE_Codigo],       [BST_PT],       [BST_Hijo]
                                 , [FED_Cant],      [BST_Disch],    [TI_Codigo]
                                 , [ME_Codigo],     [FactConv],     [ME_Gen]
                                 , [BST_Incorpor],  [FED_IndiceD],  [MA_Tip_Ens]
                                 , [BST_TipoDesc],  [BST_Nivel])
        
        select
           [FE_Codigo],                   [MA_Codigo],      [MA_Hijo]
           , 1,                           [MA_Discharge],   [CFT_Tipo]
           , isnull([ME_Com], [ME_Gen]),  [FactConv],       [ME_Gen]
           , [RE_Incorpor],               [FED_IndiceD],    [MA_Tip_Ens]
           , @BST_TipoDesc,               'RR'
        from
           VDescRetrabajo
        where
           [FED_Retrabajo] = 'A'
           and (--excluir subensambles y productos terminados
                [CFT_Tipo] not in ('S', 'P')
                --o incluir subensambles, solo si el tipo de adquisición es comprado
                or ([CFT_Tipo] = 'S' and [MA_Tip_Ens] = 'C')
               )
           and [FE_Codigo] = @CodigoFactura
        
        
        -- para adiciones a descarga, se incluyen los productos terminados que están
        -- incluidos en la lista y son el mismo numero de parte del detalle
        insert into BOM_DescTemp ([FE_Codigo],       [BST_PT],       [BST_Hijo]
                                  , [FED_Cant],      [BST_Disch],    [TI_Codigo]
                                  , [ME_Codigo],     [FactConv],     [ME_Gen]
                                  , [BST_Incorpor],  [FED_IndiceD],  [MA_Tip_Ens]
                                  , [BST_TipoDesc],  [BST_Nivel])
        
        select
           [FE_Codigo],                   [MA_Codigo],      [MA_Hijo]
           , 1,                           [MA_Discharge],   [CFT_Tipo]
           , isnull([ME_Com], [ME_Gen]),  [FactConv],       [ME_Gen]
           , [RE_Incorpor],               [FED_IndiceD],    [MA_Tip_Ens]
           , @BST_TipoDesc,               'RR'
        from
           VDescRetrabajo
        where
           [FED_Retrabajo] = 'A'
           and [CFT_Tipo] in ('S', 'P')
           and [FE_Codigo] = @CodigoFactura
           and [MA_Codigo] in (select [MA_Hijo]
                               from   Retrabajo R
                               where  R.[Tipo_FactraNS] = 'F'
                                      and R.[FETR_IndiceD] = VDescRetrabajo.[FED_IndiceD])
        
        
        -- explosiona los subensambles y productos que estan en la adicion a descarga
        if exists (select *
                   from   FactExpDet
                   where  [FE_Codigo] = @CodigoFactura
                          and [FED_Retrabajo] = 'A')
           exec sp_DescExplosionBomAdicion @CodigoFactura
    
    end
    else
    begin
        -- se insertan los diferentes de consumibles en producción y diferentes
        -- de estructura dinámica como normal
        insert into BOM_DescTemp([FE_Codigo],       [BST_PT],       [BST_Hijo]
                                 , [FED_Cant],      [BST_Disch],    [TI_Codigo]
                                 , [ME_Codigo],     [FactConv],     [ME_Gen]
                                 , [BST_Incorpor],  [FED_IndiceD],  [MA_Tip_Ens]
                                 , [BST_TipoDesc],  [BST_Nivel])
        
        select
           [FE_Codigo],                   [MA_Codigo],     [MA_Hijo]
           , 1,                           [MA_Discharge],  [CFT_Tipo]
           , isnull([ME_Com], [ME_Gen]),  [FactConv],      [ME_Gen]
           , [RE_Incorpor],               [FED_IndiceD],   [MA_Tip_Ens]
           , @BST_TipoDesc,               'RR'
        from
           VDescRetrabajo
        where
           [FED_Retrabajo] <> 'C'
           and [FED_Retrabajo] <> 'D'
           and [FED_Retrabajo] <> 'E'
           and [FE_Codigo] = @CodigoFactura
           --and [RE_Incorpor] > 0
    end
    
    
    -- se insertan los de estructura dinamica para que sea multiplicado por la cantidad
    insert into BOM_DescTemp([FE_Codigo],       [BST_PT],       [BST_Hijo]
                             , [FED_Cant],      [BST_Disch],    [TI_Codigo]
                             , [ME_Codigo],     [FactConv],     [ME_Gen]
                             , [BST_Incorpor],  [FED_IndiceD],  [MA_Tip_Ens]
                             , [BST_TipoDesc],  [BST_Nivel])
    
    select
       [FE_Codigo],                   [MA_Codigo],       [MA_Hijo]
       , [FED_Cant],                  [MA_Discharge],    [CFT_Tipo]
       , isnull([ME_Com], [ME_Gen]),  [FactConv],        [ME_Gen]
       , [RE_Incorpor],               [FED_IndiceD],     [MA_Tip_Ens]
       , @BST_TipoDesc,               'RD'
    from
       VDescRetrabajo
    where
       [FED_Retrabajo] in ('D', 'E')
       and [FE_Codigo] = @CodigoFactura
       and [RE_Incorpor] > 0
       and [MA_Tip_Ens] = 'C'
    
    
    
    
    
    -- obtener Productos Terminados o Subensambles que estén incluidos en
    -- estructuras dinámicas
    insert into @Indices([FED_IndiceD], [BST_PT], [RE_Incorpor], [FED_Fecha_Struct], [ME_Gen])
    select
       dbo.FactExpDet.[FED_IndiceD]
       , dbo.Retrabajo.[MA_Hijo]
       , sum(dbo.Retrabajo.[RE_Incorpor] * FactExpDet.[FED_Cant]) as [RE_Incorpor]
       , dateadd(day, datediff(day, 0, dbo.FactExpDet.[FED_Fecha_Struct]), 0)
       , dbo.Retrabajo.[ME_Gen]
    from
       dbo.FactExp inner join dbo.FactExpDet
          on dbo.FactExp.[FE_Codigo] = dbo.FactExpDet.[FE_Codigo]
       right outer join dbo.Retrabajo
          on dbo.FactExpDet.[FED_IndiceD] = dbo.Retrabajo.[FETR_IndiceD]
             and dbo.Retrabajo.[Tipo_FactraNS] = 'F'
       left outer join dbo.ConfiguraTipo
          on dbo.Retrabajo.[TI_Hijo] = dbo.ConfiguraTipo.[TI_Codigo]
    where
       dbo.FactExpDet.[FE_Codigo] = @CodigoFactura
       and dbo.ConfiguraTipo.[CFT_Tipo] in ('S', 'P')
       and dbo.FactExpDet.[FED_Retrabajo] in ('D', 'E')
       and dbo.Retrabajo.[MA_Tip_Ens] in ('F', 'A') -- físicos, físicos-comprados
       and dbo.FactExpDet.[PID_IndiceD] = -1
    group by
       dbo.FactExpDet.[FED_IndiceD]
       , dbo.Retrabajo.[MA_Hijo]
       , dbo.FactExpDet.[FED_Retrabajo]
       ,  dbo.FactExpDet.[PID_IndiceD]
       , dateadd(day, datediff(day, 0, dbo.FactExpDet.[FED_Fecha_Struct]), 0)
       , dbo.Retrabajo.[ME_Gen]
    having
       sum(dbo.Retrabajo.[RE_Incorpor]) > 0
    order by
       dbo.FactExpDet.[FED_IndiceD], dbo.Retrabajo.[MA_Hijo]
    
    
    -- si no está activada la opción de descarga Comprados-Físicos, explosionar los
    -- subensambles con tipo de adquisición físico para estructuras dinámicas
    if (select [CF_FisComp_ExpDesc] from Configuracion) <> 'S'
       and (select count(*) from @Indices) > 0
       begin
          while (select count(*) from @Indices) > 0
          begin
             set @IdRegistro = (select top 1 [IdRegistro]
                                from   @Indices)
             
             select
                @FED_IndiceD        = [FED_IndiceD]
                , @BST_PT           = [BST_PT]
                , @FED_Cant         = [RE_Incorpor]
                , @FED_Fecha_Struct = [FED_Fecha_Struct]
             from
                @Indices
             where
                [IdRegistro] = @IdRegistro
             
             set @CountBOM = (select count(*)
                              from   BOM_Struct
                              where  [BSU_Subensamble] = @BST_PT
                                     and [BST_PerIni] <= @FED_Fecha_Struct
                                     and [BST_PerFin] >= @FED_Fecha_Struct
                                     --and [BST_Disch] = 'S'
                             )
             
             if @CountBOM > 0 and @FED_Cant > 0
                exec sp_Fill_BOM_DescTemp
                   @FED_IndiceD, @BST_PT, @FED_Fecha_Struct, @FED_Cant, @CodigoFactura
             
             
             delete @Indices
             where  [IdRegistro] = @IdRegistro
          end
       end
    
    
    -- si está activada la opción de descarga Comprados-Físicos, intentar descargar
    -- directamente los subensambles, si no hay saldo suficiente se explosionan los
    -- subensambles con tipo de adquisición físico para estructuras dinámicas
    if (select [CF_FisComp_ExpDesc] from Configuracion) = 'S'
       and (select count(*) from @Indices) > 0
       begin
          insert into @VPIDescarga([MA_Codigo], [PID_SaldoGen])
          select
             [MA_Codigo]
             , sum([PID_SaldoGen])
          from
             VPIDescarga
          group by
             [MA_Codigo]
          order by
             [MA_Codigo]
          
          while (select count(*) from @Indices) > 0
          begin
             set @IdRegistro = (select top 1 [IdRegistro]
                                from   @Indices)
             
             select
                @FED_IndiceD        = [FED_IndiceD]
                , @BST_PT           = [BST_PT]
                , @FED_Cant         = [RE_Incorpor]
                , @FED_Fecha_Struct = [FED_Fecha_Struct]
                , @ME_Gen           = [ME_Gen]
             from
                @Indices
             where
                [IdRegistro] = @IdRegistro
             
             
             -- si no hay saldo del producto, se explosiona
             if not exists(select [MA_Codigo]
                           from   @VPIDescarga
                           where  [MA_Codigo] = @BST_PT) -- or @FED_Tip_Ens <> 'A'
                begin
                   set @CountBOM = (select count(*)
                                    from   BOM_Struct
                                    where  [BSU_Subensamble] = @BST_PT
                                           and [BST_PerIni] <= @FED_Fecha_Struct
                                           and [BST_PerFin] >= @FED_Fecha_Struct
                                           --and [BST_Disch] = 'S'
                                   )
                   
                   if @CountBOM > 0 and @FED_Cant > 0
                      exec sp_Fill_BOM_DescTemp
                              @FED_IndiceD, @BST_PT, @FED_Fecha_Struct, @FED_Cant, @CodigoFactura
                end
             else
                begin
                   -- hay saldo del producto, ver si se va a descargar por la cantidad completa o se
                   -- hará parcialmente
                   
                   set @SumCantidadUsoFinal = isnull((select
                                                         round(sum(isnull([BST_CantidadUsoFinal], 0))
                                                               , 6)
                                                      from
                                                         @TempFiscComp
                                                      where
                                                         [BSU_Subensamble] = @BST_PT), 0)
                   
                   set @UsoFinal = round(@FED_Cant, 6)
                   
                   set @UsoFinalIncluido = @SumCantidadUsoFinal + @UsoFinal
                   
                   set @SaldoActual = isnull((select
                                                 round(sum([PID_SaldoGen]), 6)
                                              from
                                                 @VPIDescarga
                                              where
                                                 [MA_Codigo] = @BST_PT), 0)
                   
                   if @SaldoActual = @UsoFinalIncluido
                      begin
                         --
                         insert into BOM_DescTemp
                         ([BST_Hijo],      [BST_Incorpor], [BST_Disch],    [TI_Codigo]
                          , [FactConv],    [ME_Gen],       [MA_Tip_Ens],   [FED_Cant]
                          , [FE_Codigo],   [BST_Nivel],    [BST_TipoDesc], [BST_Pertenece]
                          , [FED_IndiceD], [BST_PT],       [BST_EntraVigor])
                         values(@BST_PT,           1,        'S',               'S'
                                , 1,               @ME_Gen,  'C',               @FED_Cant
                                , @CodigoFactura,  1,        @BST_TipoDesc,     0
                                , @FED_IndiceD,    @BST_PT,  @FED_Fecha_Struct)
                         
                         insert into @TempFiscComp
                            ([BSU_Subensamble], [BST_CantidadUsoFinal])
                         values(@BST_PT, @UsoFinal)
                      end
                   else
                      begin
                         
                         if @UsoFinalIncluido <= @SaldoActual
                            begin
                               insert into BOM_DescTemp
                               ([BST_Hijo],       [BST_Incorpor],  [BST_Disch]
                                , [TI_Codigo],    [FactConv],      [ME_Gen]
                                , [MA_Tip_Ens],   [FED_Cant],      [FE_Codigo]
                                , [BST_Nivel],    [BST_TipoDesc],  [BST_Pertenece]
                                , [FED_IndiceD],  [BST_PT],        [BST_EntraVigor])
                               values(@BST_PT,         1,              'S'
                                      , 'S',           1,              @ME_Gen
                                      , 'C',           @FED_Cant,      @CodigoFactura
                                      , 1,             @BST_TipoDesc,  0
                                      , @FED_IndiceD,  @BST_PT,        @FED_Fecha_Struct)
                               
                               
                               insert into @TempFiscComp
                                  ([BSU_Subensamble], [BST_CantidadUsoFinal])
                               values(@BST_PT, @UsoFinal)
                            end
                         else
                            begin
                               
                               select @SaldoUsable = round(@SaldoActual -
                                                           @SumCantidadUsoFinal, 6)
                               
                               select @CantAlcanza = round(@SaldoUsable, 6)
                               
                               select @CantAExplosionar = round((@FED_Cant) - @CantAlcanza
                                                                , 6)
                               
                               insert into BOM_DescTemp
                               ([BST_Hijo],       [BST_Incorpor],  [BST_Disch]
                                , [TI_Codigo],    [FactConv],      [ME_Gen]
                                , [MA_Tip_Ens],   [FED_Cant],      [FE_Codigo]
                                , [BST_Nivel],    [BST_TipoDesc],  [BST_Pertenece]
                                , [FED_IndiceD],  [BST_PT],        [BST_EntraVigor])
                               values(@BST_PT,         1,              'S'
                                      , 'S',           1,              @ME_Gen
                                      , 'C',           @CantAlcanza,   @CodigoFactura
                                      , 1,             @BST_TipoDesc,  0
                                      , @FED_IndiceD,  @BST_PT,        @FED_Fecha_Struct)
                                
                                
                                insert into @TempFiscComp
                                   ([BSU_Subensamble], [BST_CantidadUsoFinal])
                                values(@BST_PT, @SaldoUsable)
                                
                                
                                -- se explosiona para la cantidad faltante del producto
                                exec sp_Fill_BOM_DescTemp
                                        @FED_IndiceD, @BST_PT,         @FED_Fecha_Struct
                                        , @CantAExplosionar,  @CodigoFactura
                                
                            end
                        
                      end
                   
                end
             
             delete @Indices
             where  [IdRegistro] = @IdRegistro
          end
       end
    
    /* insertamos en almacen desperdicio el desperdicio que genero el retrabajo */
    
    -- exec sp_DescRetrabajoDesp @CodigoFactura



GO
