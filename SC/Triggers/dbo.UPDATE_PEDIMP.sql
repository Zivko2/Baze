SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















CREATE TRIGGER [UPDATE_PEDIMP] ON dbo.PEDIMP 
FOR UPDATE
AS
SET NOCOUNT ON
	DECLARE @picodigo int, @cpcodigo int, @pi_no_rect int, @codigo int, @pi_estatus char(1), @pi_rectifica int, @cp_codigo int, @pi_codigorect int


/* actualizamos Estatus del pedimento de importacion */
	if (update(PI_AFECTADO)  or update (pi_tip_cam) or update (pi_ft_adu) or update(PI_MOVIMIENTO) or update(pi_fec_ent) or update(pi_rectifica))
	begin
		declare curPedImpUpdate1 cursor for
			select  pi_codigo, cp_codigo from inserted
		open curPedImpUpdate1
		fetch next from curPedImpUpdate1 into @picodigo, @cpcodigo
			WHILE (@@FETCH_STATUS = 0) 
		
			BEGIN
				
				if (update(PI_AFECTADO) or update(PI_MOVIMIENTO)) and not update(pi_rectifica)
				begin
					exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cpcodigo
				end
				

				select @pi_estatus=pi_estatus, @pi_rectifica= pi_rectifica from pedimp where pi_codigo=@picodigo
		
				/* cursor para actualizar costos del detalle del pedimento */
				if (update (pi_tip_cam) or update (pi_ft_adu) or update(pi_estatus)) and (select pi_cuentadet from pedimp where pi_codigo =@picodigo)>0
				begin
			
					declare crPedImpDetUpd cursor for
						select pid_indiced from pedimpdet
						where pi_codigo =@picodigo
					open crPedImpDetUpd
					fetch next from crPedImpDetUpd into @codigo
						WHILE (@@FETCH_STATUS = 0) 
			
						BEGIN
							update pedimpdet
							set PID_CTOT_DLS = PID_CTOT_DLS
							 where pid_indiced = @codigo		

							update pedimpdet
							set PID_COS_UNIGEN = PID_COS_UNIGEN
							 where pid_indiced = @codigo

							if update(pi_estatus) and @pi_estatus='B'
							begin
								update pedimpdet
								set PID_DESCARGABLE = 'N'
								where pid_indiced = @codigo

								update pidescarga
								set PID_SALDOGEN = 0
								where pid_indiced = @codigo

							end

							
							/* --se comento por revision en SQL2005
							if update(pi_estatus)
							begin
								if @pi_estatus='R'
								begin
									 if exists (select * from PEDIMPDETDESC where PID_INDICED = @codigo) 
									delete from pedfimpdetdesc where PID_INDICED = @codigo						
								end
								else
								begin
									 if not exists (select * from PEDIMPDETDESC where PID_INDICED = @codigo) 

									insert into PEDIMPDETDESC (PI_CODIGO, PI_FEC_ENT, PID_INDICED, PID_CAN_GEN, PID_SALDOGEN, MA_CODIGO)								

									SELECT     PEDIMPDET.PI_CODIGO, PEDIMP.PI_FEC_ENT, PEDIMPDET.PID_INDICED, isnull(PID_CANT,0) * isnull(EQ_GENERICO,1), isnull(PID_CANT,0) * isnull(EQ_GENERICO,1), PEDIMPDET.MA_CODIGO
									FROM         PEDIMP LEFT OUTER JOIN
									                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
									                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
									WHERE     (PEDIMPDET.PID_SALDOGEN > 0) AND (PEDIMP.PI_ESTATUS <> 'C') AND (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') 
									                      AND (CLAVEPED.CP_DESCARGABLE = 'S') AND (PEDIMP.PI_MOVIMIENTO = 'E') AND (PEDIMPDET.PID_DESCARGABLE = 'S')
										AND PID_INDICED= @codigo
								end
							end
							*/
						
						fetch next from crPedImpDetUpd into @codigo
						END
			
					CLOSE crPedImpDetUpd
					DEALLOCATE crPedImpDetUpd
				end

				if (update(pi_fec_ent) or update(cp_codigo))and exists(select * from pedimpdet where pi_codigo =@picodigo)			
				exec sp_actualizapedimpvencimiento @picodigo, 1

				--en este caso el pi_no_rect es el r1 y el pi_codigo el que esta siendo rectificado (pedimprect.pi_no_rect)
				if update(pi_rectifica) and @pi_rectifica=0 and exists (select * from pedimprect where pi_no_rect=@picodigo)
				begin

					select @pi_codigorect=pi_codigo from pedimprect where pi_no_rect=@picodigo
					select @cp_codigo=cp_codigo from pedimp where pi_codigo=@pi_codigorect

					exec SP_ACTUALIZAESTATUSPEDIMP @pi_codigorect, @cp_codigo

					delete from pedimprect where pi_no_rect=@picodigo
					/*if exists (select * from pidescarga where pi_rectificado<>'N' and pi_codigo in (select pi_codigo from pedimprect where pi_no_rect=@picodigo))
					update pidescarga
					set pi_rectificado='N'
					where pi_codigo in (select pi_codigo from pedimprect where pi_no_rect=@picodigo)*/

				end

				--el pi_rectifica es el que esta siendo rectificado 
				if update(pi_rectifica) and @pi_rectifica>0 
				begin
					
					if exists (select * from pidescarga where pi_codigo=@pi_rectifica)
					delete from pidescarga where pi_codigo=@pi_rectifica
			

				end

		
			fetch next from curPedImpUpdate1 into @picodigo, @cpcodigo
			END
		
		CLOSE curPedImpUpdate1
		DEALLOCATE curPedImpUpdate1
	
	end


















GO
