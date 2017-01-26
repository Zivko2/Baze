SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE trigger Del_FactExpDet on dbo.FACTEXPDET for delete as
begin
   set nocount on
   declare --@ListaExpCant decimal(38,6)
           --, @FactCant decimal(38,6)
           @AlmacenCant decimal(38,6)
           --, @ListaExpSaldo decimal(38,6)
           , @AlmacenSaldo decimal(38,6)
           , @FED_Cant decimal(38,6)
           , @PID_IndiceD int
           , @FED_IndiceD int
           --, @FED_Retrabajo char(1)
           , @EntSalAlmSaldo  decimal(38,6)
           , @AlmDetCant decimal(38,6)
           , @PesoUnit decimal(38,6)
           , @ADE_Codigo int
           , @FE_Codigo int
           , @FED_Pes_Net decimal(38,6)
           , @FactCantGen decimal(38,6)
   declare @FED_IndiceDs table([FED_IndiceD] int not null
                               primary key clustered ([FED_IndiceD]))
   declare @Indice int
   declare @IndiceUltimo int
   declare @ADE_Codigos table([FED_IndiceD] int
                              , primary key clustered([FED_IndiceD]))
   
   --select
   --   @FactCant = [FED_Cant]
   --from
   --   deleted
   
   
   -- glr (12-nov-2010)
   -- el proceso asumía que se estaba borrando solo un registro de la tabla
   -- cuando pueden ser muchos
   
   insert into @FED_IndiceDs([FED_IndiceD])
   select [FED_IndiceD]
   from   deleted
   
   set @Indice       = (select min([FED_IndiceD]) from @FED_IndiceDs)
   set @IndiceUltimo = (select max([FED_IndiceD]) from @FED_IndiceDs)
   
   while @Indice <= @IndiceUltimo
   begin
      if exists(select PIC_IndiceC
                from   FactExpCont
                where  [FED_IndiceD] = @Indice
                       and [PIC_IndiceC] > 0)
         exec sp_ActualizaPedimpCont @Indice
      
      set @Indice = (select top 1
                        [FED_IndiceD]
                     from
                        @FED_IndiceDs
                     where
                        [FED_IndiceD] > @Indice
                     order by
                        [FED_IndiceD])
   end
   
   
   if exists(select [FED_IndiceD]
             from   FactExpCont
             where  [FED_IndiceD] in (select [FED_IndiceD] from deleted))
      delete FactExpCont
      where  [FED_IndiceD] in (select [FED_IndiceD] from deleted)
   
   
   if exists(select [FED_IndiceD]
             from   FactExpEnt
             where  [FED_IndiceD] in (select [FED_IndiceD] from deleted))
      delete FactExpEnt
      where  [FED_IndiceD] in (select [FED_IndiceD] from deleted)
   
   
   if exists(select [FED_IndiceD]
             from   FactExpBom_Arancel
             where  [FED_IndiceD] in (select [FED_IndiceD] from deleted))
      delete FactExpBom_Arancel
      where  [FED_IndiceD] in (select [FED_IndiceD] from deleted)
   
   
   if exists(select [FED_IndiceD]
             from   FactExpDetIdentifica
             where  [FED_IndiceD] in (select [FED_IndiceD] from deleted))
      delete FactExpDetIdentifica
      where  [FED_IndiceD] in (select [FED_IndiceD] from deleted)
   
   
   if exists(select [FED_IndiceD]
             from   FactExpDetDef
             where  [FED_IndiceD] in (select [FED_IndiceD] from deleted))
      delete FactExpDetDef
      where  [FED_IndiceD] in (select [FED_IndiceD] from deleted)
   
   
   if exists(select [FED_IndiceD]
             from   FactExpDetCargo
             where  [FED_IndiceD] in (select [FED_IndiceD] from deleted))
      delete FactExpDetCargo
      where  [FED_IndiceD] in (select [FED_IndiceD] from deleted)
   
   
   select
      @FED_Cant = [FED_Cant]
      , @PID_IndiceD = [PID_IndiceD]
   from
      deleted
   
   
   
   /* Se Actualiza el saldo de ListaExpDet */
   if exists(select ListaExpDet.[LE_Codigo]
             from   ListaExpDet inner join deleted
                       on ListaExpDet.[LE_Codigo] = deleted.[LE_Codigo]
                          and ListaExpDet.[LED_IndiceD] = deleted.[LED_IndiceD])
      begin
         /*
         select
            @ListaExpCant = ListaExpDet.[LED_Cant]
            , @ListaExpSaldo = ListaExpDet.[LED_Saldo]
            , @FactCant = deleted.[FED_Cant]
         from
            ListaExpDet inner join deleted
               on ListaExpDet.[LE_Codigo] = deleted.[LE_Codigo]
                  and ListaExpDet.[LED_IndiceD] = deleted.[LED_IndiceD]
         
         if @ListaExpCant = @FactCant
            update ListaExpDet
            set    ListaExpDet.[LED_Saldo]   = @FactCant
                   , ListaExpDet.[LED_EnUso] = 'N'
            from   ListaExpDet inner join deleted
                      on ListaExpDet.[LE_Codigo] = deleted.[LE_Codigo]
                         and ListaExpDet.[LED_IndiceD] = deleted.[LED_IndiceD]
         else
            if @ListaExpCant > @FactCant
               update ListaExpDet
               set    ListaExpDet.[LED_Saldo] = @ListaExpSaldo + @FactCant
               from   ListaExpDet inner join deleted
                         on ListaExpDet.[LE_Codigo] = deleted.[LE_Codigo]
                            and ListaExpDet.[LED_IndiceD] = deleted.[LED_IndiceD]
         */
         update
           ListaExpDet
        set
           [LED_Saldo] = [LED_Cant] - isnull((select
                                                 sum(FactExpDet.[FED_Cant])
                                              from
                                                 FactExpDet
                                              where
                                                 FactExpDet.[LE_Codigo] = ListaExpDet.[LE_Codigo]
                                                 and FactExpDet.[LED_IndiceD] = ListaExpDet.[LED_IndiceD])
                                             , 0)
        where
           [LED_IndiceD] in (select [LED_IndiceD]
                             from   deleted)
        
        
        update
           ListaExpDet
        set
           [LED_EnUso] = 'N'
        where
           [LED_IndiceD] in (select [LED_IndiceD]
                             from   deleted)
           and [LED_EnUso] = 'S'
           and isnull((select sum(FactExpDet.[FED_Cant])
                       from   FactExpDet
                       where  FactExpDet.[LE_Codigo] = ListaExpDet.[LE_Codigo]
                              and FactExpDet.[LED_IndiceD] = ListaExpDet.[LED_IndiceD]), 0) = 0
         
         
         /* se actualiza el estatus de ListaExp */
         if not exists(select *
                       from   ListaExpDet inner join deleted 
                                 on ListaExpDet.[LE_Codigo] = deleted.[LE_Codigo]
                                    and ListaExpDet.[LED_EnUso] = 'S')
            update ListaExp
            set    ListaExp.[LE_Estatus] = 'A'
            where  [LE_Codigo] in (select   [LE_Codigo]
                                   from     deleted
                                   group by [LE_Codigo])
                   and ListaExp.[LE_Estatus] <> 'A'
      end
   
   
   /* se actualiza el saldo de AlmacenDesp */
   if exists(select [ADE_Codigo]
             from   AlmacenDesp
             where  [ADE_Codigo] --= @ADE_Codigo
                                 in (select [ADE_Codigo]
                                     from   deleted
                                     where  [ADE_Codigo] is not null))
      begin
         insert into @ADE_Codigos([FED_IndiceD])
         select
            [FED_IndiceD]
         from
            deleted
         where
            [ADE_Codigo] is not null
         group by
            [FED_IndiceD]
         
         while (select count(*) from @ADE_Codigos) > 0
         begin
            set @FED_IndiceD = (select top 1
                                  [FED_IndiceD]
                               from
                                  @ADE_Codigos)
            
            set @ADE_Codigo = (select [ADE_Codigo]
                               from   deleted
                               where  [FED_IndiceD] = @FED_IndiceD)
            
            set @FED_Pes_Net = (select [FED_Pes_Net]
                                from   deleted
                                where  [FED_IndiceD] = @FED_IndiceD)
            
            select
               @AlmacenCant    = [ADE_Cant]
               , @AlmacenSaldo = isnull([ADE_Saldo], 0)
               , @PesoUnit     = [ADE_Peso_UniKg]
            from
               AlmacenDesp
            where
               [ADE_Codigo] = @ADE_Codigo
            
            
            if (@AlmacenCant * @PesoUnit) = @FED_Pes_Net
            -- if (@AlmacenCant*@PesoUnit) = @FactCant
               update
                  AlmacenDesp
               set
                  [ADE_Saldo]   = @AlmacenCant * @PesoUnit
                  , [ADE_EnUso] = 'N'
               from
                  AlmacenDesp
               where
                  [ADE_Codigo] = @ADE_Codigo
            else
               if (@AlmacenCant * @PesoUnit) > @FED_Pes_Net
                  update AlmacenDesp 
                  set    [ADE_Saldo] = @AlmacenSaldo + (@FED_Pes_Net)
                  where  [ADE_Codigo] = @ADE_Codigo
            
            
            delete @ADE_Codigos
            where  [FED_IndiceD] = @FED_IndiceD
         end
      end
   
   
   /*
   if @FED_Cant > 0
      and @PID_IndiceD <> -1
      and exists(select *
                 from   PedimpDet
                 where  [PID_IndiceD] = @PID_IndiceD)
      update PIDescarga
      set    [PID_SaldoGen] =  [pid_saldogen] + @FactCantGen
      where  [PID_IndiceD] = @PID_IndiceD
   */
   
   
   if exists(select *
             from   Retrabajo
             where  [FETR_IndiceD] in (select [FED_IndiceD]
                                       from   deleted)
                    --and [Tipo_FactraNS] = 'F'
            ) 
      delete Retrabajo
      where  [FETR_IndiceD] in (select [FED_IndiceD]
                                from   deleted)
             --and [Tipo_FactraNS] = 'F'
   
   
   declare curFeSaldoPid cursor for
      select
         sum(round([FED_Cant] * [EQ_Gen], 6))
         , [PID_IndiceD]
      from
         FactExpDet
      where
         [FE_Codigo] --= @FE_Codigo
                     in (select   [FE_Codigo]
                         from     deleted
                         group by [FE_Codigo])
         and [FED_Cant] > 0
         and [PID_IndiceD] <> -1
         and [PID_IndiceD] is not null
      group by
         [PID_IndiceD]
   
   
   open curFeSaldoPid fetch next
   from curFeSaldoPid
   into @FactCantGen, @PID_IndiceD
   
   while (@@fetch_status = 0)
   begin
      update PIDescarga
      set    [PID_SaldoGen] =  [PID_SaldoGen] + @FactCantGen
      where  [PID_IndiceD] = @PID_IndiceD
      
      
      fetch next
      from  curFeSaldoPid
      into  @FactCantGen, @PID_IndiceD
   end
   
   close curFeSaldoPid
   deallocate curFeSaldoPid


end







GO
