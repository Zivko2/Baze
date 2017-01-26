SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSPEDIMPALL]    as

SET NOCOUNT ON 

	DELETE FROM pedimprect WHERE PI_NO_RECT NOT IN
	(SELECT PI_CODIGO FROM PEDIMP)


	UPDATE PEDIMP
	SET PI_RECTESTATUS='S'
	WHERE PI_CODIGO NOT IN
	(SELECT PI_CODIGO FROM pedimprect)


	
	ALTER TABLE [PEDIMP]  DISABLE TRIGGER [UPDATE_PEDIMP]


	-- campo afectado
		UPDATE PEDIMP
		SET PI_AFECTADO='N'
		WHERE PI_AFECTADO='S' OR PI_AFECTADO IS NULL

		UPDATE PEDIMP
		SET PI_AFECTADO='S'
		FROM PEDIMP WHERE PI_CODIGO IN (SELECT PIDescarga.PI_CODIGO FROM PIDescarga INNER JOIN
		                      PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED AND PIDescarga.PID_SALDOGEN < PEDIMPDET.PID_CAN_GEN
				GROUP BY PIDescarga.PI_CODIGO)


/* actualizamos Estatus del pedimento de importacion */
		update pedimp
		set pi_estatus = 'N'				--rectificacion sin afectar
		where pi_movimiento='E' and pi_afectado='N' and cp_codigo in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')
	

		update pedimp
		set pi_estatus = 'S'		-- Abierto - Sin Afectar
		where pi_movimiento='E' and pi_afectado='N' and cp_codigo not in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE' or ccp_tipo='CN')


		update pedimp
		set pi_estatus = 'F'				--rectificacion afectada
		where pi_movimiento='E' and pi_afectado='S' and cp_codigo in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')

	
		update pedimp
		set pi_estatus = 'A'			-- Abierto -Afectado
		where pi_movimiento='E' and pi_afectado='S' and cp_codigo not in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')

		
		update pedimp
		set pi_estatus = 'G'				-- Rectificaci>n Cerrada
		where pi_movimiento='E' and cp_codigo in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')
			and pi_codigo in (select pi_codigo from pidescarga group by pi_codigo having sum(pid_saldogen)<=0)
	

		update pedimp
		set pi_estatus = 'E'				-- Rectificaci>n que no controla saldos
		where pi_movimiento='E' and pedimp.cp_codigo in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE') and pi_rectifica in (select p2.pi_codigo from pedimp p2 where p2.pi_codigo=pedimp.pi_rectifica and p2.PI_GENERASALDOF4<>'S' 
							    and p2.cp_codigo in (select claveped.cp_codigo from claveped inner join configuraclaveped on claveped.cp_codigo=configuraclaveped.cp_codigo where ccp_tipo in ('IE', 'RG', 'SI', 'CN', 'RP')))



		update pedimp
		set pi_estatus = 'C'				-- Cerrado
		where pi_movimiento='E' and cp_codigo not in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE') and pi_afectado='S'
			and pi_codigo in (select pi_codigo from pidescarga group by pi_codigo having sum(pid_saldogen)<=0)

		
	if (SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='S' 
	begin
		      update pedimp
		      set pi_estatus = 'B'				-- no descargable
		      from pedimp inner join claveped on pedimp.cp_codigo=claveped.cp_codigo inner join configuraclaveped on
			configuraclaveped.cp_codigo=pedimp.cp_codigo
		      where  pi_movimiento='E' and cp_descargable='N' and ccp_tipo not in ('IE', 'RG', 'SI')
			
	


	end
	else
	begin 
		      update pedimp
		      set pi_estatus = 'B'				-- no descargable
		      from pedimp inner join claveped on pedimp.cp_codigo=claveped.cp_codigo 
		      where  pi_movimiento='E' and cp_descargable='N'  
	
	end




--		 IF (SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='S'
		begin
			update pedimp
			set pi_estatus = 'S'		-- Abierto - Sin Afectar
			where pi_movimiento='E' and pi_afectado='N' and cp_codigo in 
				(select cp_codigo from configuraclaveped
				where ccp_tipo IN ('CN','IE', 'RG', 'SI')) and PI_GENERASALDOF4='S'


			
			update pedimp
			set pi_estatus = 'A'			-- Abierto -Afectado
			where pi_movimiento='E' and pi_afectado='S' and cp_codigo not in 
				(select cp_codigo from configuraclaveped
				where ccp_tipo IN ('CN','IE', 'RG', 'SI')) and PI_GENERASALDOF4='S'
				and pi_codigo in (select pi_codigo from pidescarga group by pi_codigo having sum(pid_saldogen)>0)
				and pi_estatus <> 'A'			
			

		end


		update pedimp
		set pi_estatus = 'D'		-- Transferencia relacionada
		where pi_tipo='S' and pi_movimiento='S' and 
		pi_codigo in (select pi_codigo from pedimpdet where pid_indiced in (select pid_indiced from pedimpreltrans))
		

		update pedimp
		set pi_estatus = 'T'		-- -- Transferencia sin relacion
		where pi_tipo='S' and pi_movimiento='S' and 
		pi_codigo not in (select pi_codigo from pedimpdet where pid_indiced in (select pid_indiced from pedimpreltrans))


		update pedimp
		set pi_estatus = 'L'		-- Pedimento de salida
		where pi_movimiento='S' and cp_codigo not in 
		(select cp_codigo from configuraclaveped
		where ccp_tipo='RE')

		update pedimp
		set pi_estatus = 'O'		-- Rectificaci>n de salida
		where pi_movimiento='S' and cp_codigo in 
		(select cp_codigo from configuraclaveped
		where ccp_tipo='RE')


		update pedimp
		set pi_estatus = 'R'				-- Rectificado
		where pi_codigo  in 
		(select pi_codigo from pedimprect)


		update pedimp
		set pi_estatus = 'B'				-- F4 no descargable
		where CP_CODIGO IN
			(SELECT CP_CODIGO FROM CONFIGURACLAVEPED WHERE CCP_TIPO='CN' or CCP_TIPO='RG')
		and pi_codigo  not in 
				(select pi_codigo from pedimprect)
		 and PI_GENERASALDOF4='N'



	ALTER TABLE [PEDIMP]  ENABLE TRIGGER [UPDATE_PEDIMP]
GO
