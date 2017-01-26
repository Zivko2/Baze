SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER DEL_KARDESPED ON dbo.KARDESPED 
FOR DELETE 
AS
        SET NOCOUNT ON
        declare @cp_codigo int, @pi_codigo int, @CFQ_TIPO char(1), @FE_Codigo int

        select @cp_codigo = cp_codigo, @pi_codigo = pi_codigo
        from pedimp
        where
           pi_codigo in
              (select pi_codigo
               from pedimpdet
               where pid_indiced in (select kap_indiced_ped from deleted))

	exec SP_ACTUALIZAESTATUSPEDIMP @pi_codigo,  @cp_codigo

	
        select @CFQ_TIPO=CFQ_TIPO
        from configuratembarque
        where
           tq_codigo in 
              (select tq_codigo
               from factexp
               where fe_codigo in (select kap_factrans from deleted))

        delete
        from kardespedpps
        where kap_codigo in (select kap_codigo from deleted)

        select @FE_Codigo = kap_factrans
        from deleted

--	 delete from kardespedF4 where kap_codigo in (select kap_codigo from deleted)

	if @CFQ_TIPO='D'
	begin
		if exists (select * from almacendesp WHERE fetr_CODIGO IN (SELECT kap_factrans FROM DELETED))
		DELETE FROM almacendesp WHERE fetr_CODIGO IN (SELECT kap_factrans FROM DELETED)

	end
	else
	begin
		UPDATE dbo.ALMACENDESP
		SET     dbo.ALMACENDESP.PI_CODIGO=0, dbo.ALMACENDESP.PID_INDICED=0
		FROM         dbo.KARDESPED LEFT OUTER JOIN
		                      dbo.ALMACENDESP ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.ALMACENDESP.FETR_INDICED LEFT OUTER JOIN
		                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO
		WHERE     (dbo.KARDESPED.KAP_ESTATUS = 'T') AND (dbo.CONFIGURATEMBARQUE.CFQ_TIPO = 'D' OR
		                      dbo.CONFIGURATEMBARQUE.CFQ_TIPO = 'T') AND (dbo.ALMACENDESP.FETR_TIPO = 'F' OR
		                      dbo.ALMACENDESP.FETR_TIPO = 'V') AND (dbo.ALMACENDESP.ADE_GENERADOPOR = 'R') 
		AND (dbo.KARDESPED.KAP_CODIGO in (select kap_codigo from deleted))

	end


        declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO),0)+1 FROM KARDESPED 

	
	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS


        -- guardar relación de desviaciones a afectar, para luego determinar si quedaron registros adicionales de
        -- dichas desviaciones en la tabla KarDesDesv
        
        declare @Desviaciones table(DEV_Codigo int not null)
        
        insert into @Desviaciones
        select distinct
           KarDesDesv.DEV_Codigo
        from
           KarDesDesv
        where
           KarDesDesv.FE_Codigo = @FE_Codigo
        
        -- regresar saldos a desviaciones
        update Desviacion
        set Desviacion.DEV_Saldo = Desviacion.DEV_Saldo + KarDesDesv.KAD_Cantidad
        from
           Desviacion inner join
              KarDesDesv on Desviacion.DEV_Codigo = KarDesDesv.DEV_Codigo
        where
           KarDesDesv.FE_Codigo = @FE_Codigo

        -- borrar de KarDesDesv la información de la factura
        delete
        from KarDesDesv
        where
           KarDesDesv.FE_Codigo = @FE_Codigo

        -- si ya no existen registros de descargas hechas para una desviación, el saldo ya no se considera en uso
        update Desviacion
        set Desviacion.DEV_Uso_Saldo = 'N'
        from
           Desviacion left outer join
              KarDesDesv on Desviacion.DEV_Codigo = KarDesDesv.DEV_Codigo
        where
           Desviacion.DEV_Codigo in (select DEV_Codigo
                                     from @Desviaciones)
           and KarDesDesv.DEV_Codigo is null
        
        
        -- borrar afectaciones de desviaciones cuyas descargas ya fueron borradas
        if exists(select KarDesDesv.FE_Codigo
                  from   KarDesDesv left outer join KarDesPed
                            on KarDesDesv.FE_Codigo = KarDesPed.KAP_FACTRANS
                  where  KarDesPed.KAP_FACTRANS is null)
        begin
           delete KarDesDesv
           where
              KarDesDesv.FE_Codigo in (select KarDesDesv.FE_Codigo
                  from   KarDesDesv left outer join KarDesPed
                            on KarDesDesv.FE_Codigo = KarDesPed.KAP_FACTRANS
                  where  KarDesPed.KAP_FACTRANS is null)
        end
        
        -- reestablecer saldos para desviaciones que por alguna razón quedaron
        -- con saldo afectado cuando no hay registros de dichas afectaciones
        if exists(select Desviacion.DEV_Codigo
                  from
                     Desviacion left outer join KarDesDesv
                        on Desviacion.DEV_Codigo = KarDesDesv.DEV_Codigo
                  where
                     KarDesDesv.DEV_Codigo is null
                     and Desviacion.DEV_Cantidad <> Desviacion.DEV_Saldo)
           update Desviacion
           set Desviacion.DEV_Saldo = Desviacion.DEV_Cantidad
           from
              Desviacion left outer join KarDesDesv
                 on Desviacion.DEV_Codigo = KarDesDesv.DEV_Codigo
           where
              KarDesDesv.DEV_Codigo is null
              and Desviacion.DEV_Cantidad <> Desviacion.DEV_Saldo
        





























GO
