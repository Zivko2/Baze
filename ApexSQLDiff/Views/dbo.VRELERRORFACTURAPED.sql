SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VRELERRORFACTURAPED
   with encryption as
   select
      FACTIMP.PI_CODIGO
      --glr (8/oct/2010)
      --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
      , case when max(isnull(FACTIMP.mo_codigo, 0)) in (select MO_CODIGO
                                                        from   MONEDA
                                                        where  MONEDA.PA_CODIGO = 154)
           then isnull(round(sum(FACTIMPDET.FID_COS_TOT / pi_tip_cam), 6), 0)
           else isnull(round(sum(FACTIMPDET.FID_COS_TOT), 6), 0)
        end as FID_COS_TOT
      , isnull(round(max(PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      FACTIMPDET inner join factimp
         on FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
      left outer join (select
                          PEDIMP.PI_CODIGO
                          , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
                          , max(PEDIMP.PI_USA_TIP_CAMFACT) as PI_USA_TIP_CAMFACT
                          --glr (8/oct/2010)
                          --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
                          , max(isnull(pi_tip_cam, 0)) as pi_tip_cam
                       from
                          CLAVEPED inner join PEDIMP
                             on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
                          left outer join PEDIMPDET
                             on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
                       where
                          PEDIMPDET.PID_IMPRIMIR = 'S'
                          and (PEDIMP.PI_MOVIMIENTO = 'E')
                          and PEDIMP.PI_TIPO in ('C', 'S')
                          and (CLAVEPED.CP_CLAVE <> 'R1')
                       group by
                          PEDIMP.PI_CODIGO) SUMPEDIMP
         on SUMPEDIMP.PI_CODIGO = FACTIMP.PI_CODIGO
   where
      (FACTIMP.PI_CODIGO <> -1)
      and (FACTIMP.PI_RECTIFICA < 0)
      and isnull(pi_tip_cam, 0) > 0
   group by
      FACTIMP.PI_CODIGO
   
   union
   
   --Salieron 3 casos (factimp.pi_rectifica = 12677,15718, 19165)
   select
      FACTIMP.PI_RECTIFICA
      --glr (8/oct/2010)
      --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
      , case when max(isnull(FACTIMP.mo_codigo, 0)) in (select MO_CODIGO
                                                        from   MONEDA
                                                        where  MONEDA.PA_CODIGO = 154)
           then isnull(round(sum(FACTIMPDET.FID_COS_TOT / pi_tip_cam), 6), 0)
           else isnull(round(sum(FACTIMPDET.FID_COS_TOT), 6), 0)
        end as FID_COS_TOT
      , isnull(round(max(PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      FACTIMPDET inner join factimp
         on FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
      left outer join (select
                          PEDIMP.PI_CODIGO
                          , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
                          , max(PEDIMP.PI_USA_TIP_CAMFACT) as PI_USA_TIP_CAMFACT
                          --glr (8/oct/2010)
                          --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
                          , max(isnull(pi_tip_cam, 0)) as pi_tip_cam
                       from
                          CLAVEPED inner join PEDIMP
                             on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
                          left outer join PEDIMPDET
                             on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
                       where
                          PEDIMPDET.PID_IMPRIMIR = 'S'
                          and (PEDIMP.PI_MOVIMIENTO = 'E')
                          and PEDIMP.PI_TIPO in ('C', 'S')
                          and (CLAVEPED.CP_CLAVE = 'R1')
                       group by
                          PEDIMP.PI_CODIGO) SUMPEDIMP
         on SUMPEDIMP.PI_CODIGO = FACTIMP.PI_RECTIFICA
   where
      (FACTIMP.PI_RECTIFICA <> -1)
      and isnull(pi_tip_cam, 0) > 0
   group by
      FACTIMP.PI_RECTIFICA
   
   union
   
   --Salieron 254 casos (factexp.pi_codigo = 12677,15718, 19165)
   select
      FACTEXP.PI_CODIGO
      --glr (8/oct/2010)
      --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
      , case when max(isnull(FACTEXP.mo_codigo, 0)) in (select MO_CODIGO
                                                       from   MONEDA
                                                       where  MONEDA.PA_CODIGO = 154)
           then isnull(round(sum(FACTEXPDET.FED_COS_TOT / pi_tip_cam), 6), 0)
           else isnull(round(sum(FACTEXPDET.FED_COS_TOT), 6), 0)
        end as FED_COS_TOT
      , isnull(round(max(PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      FACTEXPDET inner join FACTEXP
         on FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
      left outer join (select
                          PEDIMP.PI_CODIGO
                          , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
                          , max(PEDIMP.PI_USA_TIP_CAMFACT) as PI_USA_TIP_CAMFACT
                          --glr (8/oct/2010)
                          --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
                          , max(isnull(pi_tip_cam, 0)) as pi_tip_cam
                       from
                          CLAVEPED inner join PEDIMP
                             on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
                          left outer join PEDIMPDET
                             on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
                       where
                          PEDIMPDET.PID_IMPRIMIR = 'S'
                          and (PEDIMP.PI_MOVIMIENTO = 'S')
                          and PEDIMP.PI_TIPO in ('C', 'S')
                          and (CLAVEPED.CP_CLAVE <> 'R1')
                       group by
                          PEDIMP.PI_CODIGO) SUMPEDIMP
         on SUMPEDIMP.PI_CODIGO = FACTEXP.PI_CODIGO
   where
      (FACTEXP.PI_CODIGO <> -1)
      and (FACTEXP.PI_RECTIFICA < 0)
      and isnull(pi_tip_cam, 0) > 0
      and TF_CODIGO not in (select TF_CODIGO
                            from   TFACTURA
                            where  TF_NOMBRE like 'CAMBIO DE REGIMEN%'
                                   or tf_nombre like 'REGULARIZACION%')
   group by
      FACTEXP.PI_CODIGO
   
   union
   
   --Salieron 6 casos (factexp.pi_rectifica =  1312,7720,1313,1172,1171,1311)
   select
      FACTEXP.PI_RECTIFICA
      --glr (8/oct/2010)
      --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
      , case when max(isnull(FACTEXP.mo_codigo, 0)) in (select MO_CODIGO
                                                        from   MONEDA
                                                        where  MONEDA.PA_CODIGO = 154)
           then isnull(round(sum(FACTEXPDET.FED_COS_TOT / pi_tip_cam), 6), 0)
           else isnull(round(sum(FACTEXPDET.FED_COS_TOT),6),0)
        end as FED_COS_TOT
      , isnull(round(max(PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      FACTEXPDET inner join FACTEXP
         on FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
      left outer join (select
                          PEDIMP.PI_CODIGO
                          , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
                          , max(PEDIMP.PI_USA_TIP_CAMFACT) as PI_USA_TIP_CAMFACT
                          --glr (8/oct/2010)
                          --se usa isnull para evitar mensaje "Null value is eliminated by an aggregate"
                          , max(isnull(pi_tip_cam, 0)) as pi_tip_cam
                       from
                          CLAVEPED inner join PEDIMP
                             on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
                          left outer join PEDIMPDET
                             on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
                       where
                          PEDIMPDET.PID_IMPRIMIR = 'S'
                          and (PEDIMP.PI_MOVIMIENTO = 'S')
                          and PEDIMP.PI_TIPO in ('C', 'S')
                          and (CLAVEPED.CP_CLAVE = 'R1')
                       group by
                          PEDIMP.PI_CODIGO) SUMPEDIMP
         on SUMPEDIMP.PI_CODIGO = FACTEXP.PI_RECTIFICA
   where
      (FACTEXP.PI_RECTIFICA <> - 1)
      and isnull(pi_tip_cam, 0) > 0
      and TF_CODIGO not in (select TF_CODIGO
                            from   TFACTURA
                            where  TF_NOMBRE like 'CAMBIO DE REGIMEN%'
                                   or tf_nombre like 'REGULARIZACION%')
   group by
      FACTEXP.PI_RECTIFICA
   
   union
   
   --Pedimentos a de Importacion cuyos detalles NO estan asignados a una factura de importacion
   --muchos de los A3 que busco estan en esta opcion
   select
      PEDIMP.PI_CODIGO
      , 0 as FID_COS_TOT
      , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      CLAVEPED inner join PEDIMP
         on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
      left outer join PEDIMPDET
         on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
   where
      PEDIMPDET.PID_IMPRIMIR = 'S'
      and (PEDIMP.PI_MOVIMIENTO = 'E')
      and PEDIMP.PI_TIPO in ('C', 'S')
      and (CLAVEPED.CP_CLAVE not in ('R1','F4','F5','A3'))
      and PEDIMP.PI_CODIGO not in (select   PI_CODIGO
                                   from     factimp
                                   where    PI_CODIGO <> -1
                                   group by PI_CODIGO)
   group by
      PEDIMP.PI_CODIGO
   
   union
   
   --Pedimentos a de Importacion R1 cuyos detalles NO estan asignados a una factura de importacion, ni estan rectificando a un R1, F4, F5
   select
      PEDIMP.PI_CODIGO
      , 0 as FID_COS_TOT
      , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      CLAVEPED inner join PEDIMP
         on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
      left outer join PEDIMPDET
         on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
      left outer join CLAVEPED CLAVEPEDB
         on PEDIMP.CP_RECTIFICA = CLAVEPEDB.CP_CODIGO
   where
      PEDIMPDET.PID_IMPRIMIR = 'S'
      and (PEDIMP.PI_MOVIMIENTO = 'E')
      and PEDIMP.PI_TIPO in ('C', 'S')
      and (CLAVEPED.CP_CLAVE = 'R1')
      and (CLAVEPEDB.CP_CLAVE not in ('R1', 'F4', 'F5', 'A3'))
      and PEDIMP.PI_CODIGO not in (select   PI_RECTIFICA
                                   from     factimp
                                   where    PI_RECTIFICA <> -1
                                   group by PI_RECTIFICA)
   group by
      PEDIMP.PI_CODIGO
   
   union
   
   --Pedimentos  de Exportacion cuyos detalles NO estan asignados a una factura de exportacion
   select
      PEDIMP.PI_CODIGO
      , 0 as FED_COS_TOT
      , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      CLAVEPED inner join PEDIMP
         on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
      left outer join PEDIMPDET
         on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
   where
      PEDIMPDET.PID_IMPRIMIR = 'S'
      and (PEDIMP.PI_MOVIMIENTO = 'S')
      and PEDIMP.PI_TIPO in ('C', 'S')
      and (CLAVEPED.CP_CLAVE not in ('R1', 'F4', 'F5', 'A3'))
      and PEDIMP.PI_CODIGO not in (select   PI_CODIGO
                                   from     FACTEXP
                                   where    PI_CODIGO <> -1
                                   group by PI_CODIGO)
   group by
      PEDIMP.PI_CODIGO
   
   union
   
   --Pedimentos a de Exportacion R1 cuyos detalles NO estan asignados a una factura de exportacion
   select
      PEDIMP.PI_CODIGO
      , 0 as FED_COS_TOT
      , isnull(round(sum(PEDIMPDET.PID_CTOT_DLS), 6), 0) as PID_CTOT_DLS
   from
      CLAVEPED inner join PEDIMP
         on CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
      left outer join PEDIMPDET
         on PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
   where
      PEDIMPDET.PID_IMPRIMIR = 'S'
      and (PEDIMP.PI_MOVIMIENTO = 'S')
      and PEDIMP.PI_TIPO in ('C', 'S')
      and (CLAVEPED.CP_CLAVE = 'R1')
      and PEDIMP.PI_CODIGO not in (select   PI_RECTIFICA
                                   from     FACTEXP
                                   where    PI_RECTIFICA <> -1
                                   group by PI_RECTIFICA)
   group by
      PEDIMP.PI_CODIGO
   
   
GO
