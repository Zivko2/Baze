SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSPEDIMPDesc] (@fe_codigo INT)   as

SET NOCOUNT ON 


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##VerificaEstatusPedImp'  AND  type = 'U')
	begin
		drop table ##VerificaEstatusPedImp
	end
	
	CREATE TABLE ##VerificaEstatusPedImp (
		[pi_codigo] [int] NULL 
	) ON [PRIMARY]


	INSERT INTO ##VerificaEstatusPedImp(pi_codigo)
	SELECT     PIDescarga.PI_CODIGO
	FROM         KARDESPED INNER JOIN
	                      PIDescarga ON KARDESPED.KAP_INDICED_PED = PIDescarga.PID_INDICED
	WHERE     (KARDESPED.KAP_FACTRANS = @fe_codigo)
	GROUP BY PIDescarga.PI_CODIGO


	
	ALTER TABLE [PEDIMP]  DISABLE TRIGGER [UPDATE_PEDIMP]


	-- campo afectado
		UPDATE PEDIMP
		SET PI_AFECTADO='S'
		FROM PEDIMP 
		WHERE PI_CODIGO IN (SELECT PIDescarga.PI_CODIGO FROM PIDescarga INNER JOIN
		                      PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED AND PIDescarga.PID_SALDOGEN < PEDIMPDET.PID_CAN_GEN
				GROUP BY PIDescarga.PI_CODIGO)
		AND pi_codigo IN (SELECT pi_codigo FROM ##VerificaEstatusPedImp)

/* actualizamos Estatus del pedimento de importacion */

		update pedimp
		set pi_estatus = 'F'		--rectificacion afectada
		where pi_movimiento='E' and pi_afectado='S' and cp_codigo in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')
		AND pi_codigo IN (SELECT pi_codigo FROM ##VerificaEstatusPedImp)

	
		update pedimp
		set pi_estatus = 'A'			-- Abierto -Afectado
		where pi_movimiento='E' and pi_afectado='S' and cp_codigo not in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')
		AND pi_codigo IN (SELECT pi_codigo FROM ##VerificaEstatusPedImp)

		
		update pedimp
		set pi_estatus = 'G'				-- Rectificaci>n Cerrada
		where pi_movimiento='E' and cp_codigo in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE')
			and pi_codigo in (select pi_codigo from pidescarga group by pi_codigo having sum(pid_saldogen)<=0)
		AND pi_codigo IN (SELECT pi_codigo FROM ##VerificaEstatusPedImp)	


		update pedimp
		set pi_estatus = 'C'				-- Cerrado
		where pi_movimiento='E' and cp_codigo not in 
			(select cp_codigo from configuraclaveped
			where ccp_tipo='RE') and pi_afectado='S'
			and pi_codigo in (select pi_codigo from pidescarga group by pi_codigo having sum(pid_saldogen)<=0)
		AND pi_codigo IN (SELECT pi_codigo FROM ##VerificaEstatusPedImp)
		
	






	ALTER TABLE [PEDIMP]  ENABLE TRIGGER [UPDATE_PEDIMP]



	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##VerificaEstatusPedImp'  AND  type = 'U')
	begin
		drop table ##VerificaEstatusPedImp
	end
GO
