SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














create trigger [dbo].[UPDATE_FACTEXP] on [dbo].[FACTEXP] for update as
   set nocount on
   declare @fe_tipo char(1),
           @CodigoFactura int,
           @fccodigo int,
           @sDischStatus char(1),
           @cancelada char(1),
           @CCP_TIPO varchar(2),
           @fe_estatus char(1),
           @fe_cancelado CHAR(1),
           @pi_rectifica int,
           @picodigo int
   
	if update (pi_codigo)
	   or update(fe_descargada)
	   or update(fe_cancelado)
	   or update(pi_rectifica) 
	   or update(di_destfin)
	begin
		declare cur_facturaexp cursor for
			select
			   fc_codigo, fe_descargada ,  fe_codigo,
			   fe_estatus, fe_cancelado
			from
			   inserted
		open cur_facturaexp
			FETCH NEXT FROM cur_facturaexp
			INTO @fccodigo, @sDischStatus, @CodigoFactura, @fe_estatus, @fe_cancelado
		
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	   
				select @pi_rectifica = pi_rectifica, @picodigo = pi_codigo
				from factexp
				where fe_codigo = @CodigoFactura

				if update (pi_codigo)
				begin


					SELECT
					   @CCP_TIPO = dbo.CONFIGURACLAVEPED.CCP_TIPO
					FROM
					   dbo.CONFIGURACLAVEPED INNER JOIN dbo.PEDIMP
					      ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
					   RIGHT OUTER JOIN dbo.FACTEXP
					      ON dbo.PEDIMP.PI_CODIGO = dbo.FACTEXP.PI_CODIGO
					WHERE
					   dbo.FACTEXP.FE_CODIGO = @CodigoFactura
					   AND dbo.PEDIMP.PI_ESTATUS <> 'R'
			
					if (select pi_codigo from factexp where fe_codigo = @CodigoFactura) <> -1
					   IF @CCP_TIPO = 'CN' and not update(fe_con_pedcr)
					      update factexp
					      set fe_con_pedcr = 'S'
					      where fe_codigo = @CodigoFactura and fe_con_pedcr <> 'S'
	
	
					if (select pi_codigo from factexp where fe_codigo = @CodigoFactura) = -1 and not update(fe_con_pedcr)
					   update factexp
					   set fe_con_pedcr = 'N'
					   where fe_codigo = @CodigoFactura and fe_con_pedcr <> 'N'
			

					if exists (select * from factexpdet where fe_codigo = @CodigoFactura) and @picodigo = -1
					   update factexpdet
					   set pid_indicedliga = -1
					   where fe_codigo = @CodigoFactura

					
				end
	         
	         
	         select
                  @sDischStatus = fe_descargada,
                  @cancelada = fe_cancelado,
                  @fe_tipo = fe_tipo
            from factexp
            where
               fe_codigo = @CodigoFactura
	         
	         
	         
				if  (update(fe_descargada)or update(pi_codigo) or update(fe_cancelado))
				begin
					--exec SP_ACTUALIZAESTATUSFACTEXP @CodigoFactura
               
               -- sustitución del procedimiento almacenado spActualizaEstatusFactExp,
               -- para evitar error con SQL Server 2005 al deshabilitarse el trigger
               -- de actualización actual en el mismo
               declare @feddescargado int,
                       @fe_con_ped char(1)
               
               
               --	SELECT     @feddescargado= COUNT(FED_DESCARGADO)
               --   FROM         FACTEXPDET
               --   WHERE      (FED_DESCARGADO = 'S') AND (FE_CODIGO = @CodigoFactura)
               
               update factexp
               set fe_fechadescarga = null
               where fe_fechadescarga = ''
               
               
               update factexp
               set fe_descargada = 'S'
               where
                  fe_codigo = @CodigoFactura
               	and fe_fechadescarga is not NULL
               
               update factexp
               set fe_descargada = 'N'
               where
                  fe_codigo = @CodigoFactura 
               	and fe_fechadescarga is NULL
               
               
               select
                  @fe_con_ped = case when pi_trans <= 0 and pi_codigo <= 0
                                   then 'N'
                                   else 'S'
                                end
               from factexp
               where
                  fe_codigo = @CodigoFactura
               
               
               if @cancelada = 'S'
                  update factexp
                  set fe_estatus = 'A'
                  where
                     fe_codigo = @CodigoFactura -- A	= Cancelada 
                     and fe_estatus <> 'A'
               else
                  if @fe_tipo = 'T'
                  begin
                     if @sDischStatus = 'S'
                        update factexp
                        set fe_estatus = 'L'
                        where
                           fe_codigo = @CodigoFactura -- T = Transformadores congelada
                           and fe_estatus <> 'L'
                     else
                        update factexp
                        set fe_estatus = 'T'
                        where
                           fe_codigo = @CodigoFactura -- T = Transformadores sin congelar saldos de pedimentos
                           and fe_estatus <> 'T'
                  end
                  else
                     if @fe_tipo = 'S'
                     begin
                        if @sDischStatus = 'S'
                           update factexp
                           set fe_estatus = 'V'
                           where
                              fe_codigo = @CodigoFactura -- V = Aviso de traslado descargado
                              and fe_estatus <> 'V'
                        else
                           update factexp
                           set fe_estatus = 'N'
                           where
                              fe_codigo = @CodigoFactura -- N = Aviso de traslado sin descargar
                              and fe_estatus <> 'N'
                     end
                     else
                        if @sDischStatus = 'S'
                        begin
                           if @fe_con_ped = 'N'
                              update factexp
                              set fe_estatus = 'S'
                              where
                                 fe_codigo = @CodigoFactura  -- S = Descargada - Sin Pedimento
                                 and fe_estatus <> 'S'
                           else
                              update factexp
                              set fe_estatus = 'C'
                              where
                                 fe_codigo = @CodigoFactura -- C	 = Descarga Con Pedimento
                                 and fe_estatus <> 'C'
                        end
                        else
                        begin
                           if @fe_con_ped = 'N'
                              update factexp
                              set fe_estatus = 'D'
                              where
                                 fe_codigo = @CodigoFactura --D	= Sin Descargar, Sin Pedimento
                                 and fe_estatus <> 'D'
                           else
                              update factexp
                              set fe_estatus = 'P'
                              where
                                 fe_codigo = @CodigoFactura -- P	= Sin Descargar, Con Pedimento 
                                 and fe_estatus <> 'P'
                        end
                     
			   end
			   
			   
			   
			   
			   
				if update(fe_tipo) and @fe_tipo = 'V' and not update(fe_footer)
				update factexp
				set fe_footer = 'Operacion efectuada al amparo de la regla 5.1.15 de la R.M.C.E.'
				where fe_codigo =@CodigoFactura
	

	
				if update(pi_rectifica) and @pi_rectifica = -1
				begin
					if exists (select fe_codigo
					           from factexp
					           where
					              pi_rectifica = @pi_rectifica
					              and fe_codigo not in
					                    (SELECT FE_CODIGO
					                     FROM dbo.FACTEXP
					                     WHERE PI_CODIGO = @picodigo))
					
					   update factexp
					   set pi_rectifica = -1
					   where
					      pi_rectifica = @pi_rectifica
					      and fe_codigo not in
					             (SELECT FE_CODIGO
					              FROM dbo.FACTEXP
					              WHERE PI_CODIGO = @picodigo)
			
					if exists (select * from factexpdet where fe_codigo = @CodigoFactura)
					update factexpdet
					set pid_indicedligar1 = -1
					where fe_codigo = @CodigoFactura
			
				end
	
			if update(DI_DESTFIN) and exists (select * from factexpdet where fe_codigo = @CodigoFactura)
			UPDATE dbo.FACTEXPDET
			SET
			   dbo.FACTEXPDET.FED_DESTNAFTA = CASE 
			                                     when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX
			                                                                        FROM CONFIGURACION)
			                                        THEN 'M'
			                                     when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA
			                                                                        FROM CONFIGURACION)
			                                          or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA
			                                                                           FROM CONFIGURACION)
			                                        then 'N'
			                                     WHEN dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO
			                                                                        FROM PAIS
			                                                                        WHERE SPI_CODIGO IN (SELECT SPI_CODIGO
			                                                                                             FROM SPI
			                                                                                             WHERE SPI_CLAVE = 'MX-UE')) 
			                                        then 'U'
			                                     when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO
			                                                                        FROM PAIS
			                                                                        WHERE SPI_CODIGO IN (SELECT SPI_CODIGO
			                                                                                             FROM SPI
			                                                                                             WHERE SPI_CLAVE = 'AELC')) 
			                                        then 'A'
			                                     else 'F'
			                                  end
			FROM
			   dbo.FACTEXPDET INNER JOIN dbo.FACTEXP
			      ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
			   LEFT OUTER JOIN dbo.DIR_CLIENTE
			      ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
			WHERE
			   dbo.FACTEXP.FE_CODIGO = @CodigoFactura
	


	
	
			FETCH NEXT FROM cur_facturaexp INTO @fccodigo, @sDischStatus, @CodigoFactura, @fe_estatus, @fe_cancelado
		END
		
		CLOSE cur_facturaexp
		DEALLOCATE cur_facturaexp
	end

GO
