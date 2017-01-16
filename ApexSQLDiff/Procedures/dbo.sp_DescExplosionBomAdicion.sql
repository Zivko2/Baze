SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















CREATE PROCEDURE [dbo].[sp_DescExplosionBomAdicion] (@CodigoFactura int)   as
     set nocount on 
    
    declare @FED_IndiceD int
            , @BST_PT int
            , @FED_Cant decimal(38, 6)
            , @FED_Fecha_Struct datetime
    
    declare @IdRegistro int
    declare @Adiciones table([IdRegistro] int identity(1, 1) not null
                             ,[FED_IndiceD] int not null
                             , [MA_Hijo] int not null
                             , [RE_Incorpor] decimal(38, 6) not null
                             , [FED_Fecha_Struct] datetime null
                             , primary key clustered ([IdRegistro]))
    
    -- (glr - 24/sep/2010)
    -- selecciona Producto Terminados o Subensambles que esten incluidos en adición
    -- a descarga, ignorándose los subensambles que tengan el tipo de adquisición Comprado
    insert into @Adiciones([FED_IndiceD],    [MA_Hijo]
                           , [RE_Incorpor],  [FED_Fecha_Struct])
    select
       dbo.FactExpDet.[FED_IndiceD]
       , dbo.Retrabajo.[MA_Hijo]
       , sum(dbo.Retrabajo.[RE_Incorpor]) as [RE_Incorpor]
       , dateadd(day, datediff(day, 0, dbo.FactExpDet.[FED_Fecha_Struct]), 0)
    from
       dbo.FactExp inner join dbo.FactExpDet
         on dbo.FactExp.[FE_Codigo] = dbo.FactExpDet.[FE_Codigo]
       right outer join dbo.Retrabajo
          on dbo.FactExpDet.[FED_IndiceD] = dbo.Retrabajo.[FETR_IndiceD]
             and dbo.Retrabajo.[Tipo_FactraNS] = 'F'
       left outer join dbo.ConfiguraTipo
          on dbo.Retrabajo.[TI_Hijo] = dbo.ConfiguraTipo.[TI_Codigo]
       inner join Maestro
          on dbo.Retrabajo.[MA_Hijo] = Maestro.[MA_Codigo]
    where
       dbo.FactExpDet.[FE_Codigo] = @CodigoFactura
       and dbo.ConfiguraTipo.[CFT_Tipo] in ('S', 'P')
       and not (dbo.ConfiguraTipo.[CFT_Tipo] = 'S' and Maestro.[MA_Tip_Ens] = 'C')
       and dbo.FactExpDet.[FED_Retrabajo] = 'A'
       and dbo.FactExpDet.[PID_IndiceD] = -1
       and (Maestro.[MA_Tip_Ens] = 'F' or Maestro.[MA_Tip_Ens] = 'A')
    group by
       dbo.FactExpDet.[FED_IndiceD],      dbo.Retrabajo.[MA_Hijo]
       , dbo.FactExpDet.[FED_Retrabajo],  dbo.FactExpDet.[PID_IndiceD]
       , dbo.FactExpDet.[FED_Fecha_Struct]
    having
       sum(dbo.Retrabajo.[RE_Incorpor]) > 0
    order by
       dbo.FactExpDet.[FED_IndiceD], dbo.Retrabajo.[MA_Hijo]
    
    
    while (select count(*) from @Adiciones) > 0
    begin
        set @IdRegistro = (select top 1 [IdRegistro]
                           from   @Adiciones)
        
        select @FED_IndiceD        = [FED_IndiceD]
               , @BST_PT           = [MA_Hijo]
               , @FED_Cant         = [RE_Incorpor]
               , @FED_Fecha_Struct = [FED_Fecha_Struct]
        from   @Adiciones
        where  [IdRegistro] = @IdRegistro
        
        
        if (select count(*)
            from   BOM_Struct
            where  [BSU_Subensamble] = @BST_PT
                   and [BST_PerIni] <= @FED_Fecha_Struct
                   and [BST_PerFin] >= @FED_Fecha_Struct
                   --and [BST_Disch] = 'S'
           ) > 0
           and @FED_Cant > 0
        begin
            exec sp_Fill_BOM_DescTemp
                @FED_IndiceD, @BST_PT, @FED_Fecha_Struct, @FED_Cant, @CodigoFactura
        end
        
        delete @Adiciones
        where  [IdRegistro] = @IdRegistro
    end


GO
