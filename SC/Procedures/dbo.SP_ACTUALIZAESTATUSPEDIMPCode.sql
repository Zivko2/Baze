SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSPEDIMPCode] (@PICODIGO INT, @pi_movimiento char(1), @pi_tipo char(1), @cpcodigo INT, @PI_GENERASALDOF4 CHAR(1), @pi_estatus char(1) output)   as

SET NOCOUNT ON 
DECLARE @saldo decimal(38,6), @cant decimal(38,6), @ccptipo varchar (5), @ccptipo2 varchar(5), @pi_no_rect int, @pedimpdescargable char(1),
@afectado char(1), @PI_GENERASALDOF42 char(1), @cp_clave VARCHAR(5), @cp_codigo2 int


	IF @PI_GENERASALDOF4='' 
	set @PI_GENERASALDOF4='N'

	/*UPDATE PIDescarga
	SET     PIDescarga.PID_USO_SALDO='S'
	FROM         PIDescarga INNER JOIN
	                      PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED AND PIDescarga.PID_SALDOGEN < PEDIMPDET.PID_CAN_GEN
	WHERE PEDIMPDET.PID_DESCARGABLE='S'
	AND PIDescarga.PI_CODIGO=@PICODIGO
	
	
	UPDATE PIDescarga
	SET     PIDescarga.PID_USO_SALDO='N'
	FROM         PIDescarga INNER JOIN
	                      PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED AND PIDescarga.PID_SALDOGEN = PEDIMPDET.PID_CAN_GEN
	WHERE PEDIMPDET.PID_DESCARGABLE='S'
	AND PIDescarga.PI_CODIGO=@PICODIGO*/

--	ALTER TABLE [PEDIMP]  DISABLE TRIGGER [UPDATE_PEDIMP]
	SELECT @ccptipo = CCP_TIPO
	FROM CONFIGURACLAVEPED 
	where CP_CODIGO = @cpcodigo



	SELECT     @pi_no_rect = COUNT(dbo.PEDIMPRECT.PI_NO_RECT) 
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPRECT ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPRECT.PI_CODIGO
	WHERE     (dbo.PEDIMP.PI_CODIGO = @PICODIGO)


	select @ccptipo2=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@PICODIGO))

	select @cp_codigo2=cp_codigo from pedimp where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@PICODIGO)

	if (SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='N' and (@ccptipo='CN' or @ccptipo2='CN')

		SELECT   @saldo = 1, @cant = 1

	else
		SELECT   @saldo = round(SUM(PIDESCARGA.PID_SALDOGEN),2), @cant = round(SUM(PEDIMPDET.PID_CAN_GEN),2)
		FROM PEDIMPDET LEFT OUTER JOIN PIDESCARGA ON PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
		WHERE PEDIMPDET.pid_descargable='S'
		GROUP BY PEDIMPDET.PI_CODIGO
		HAVING PEDIMPDET.PI_CODIGO = @PICODIGO  


	if @cant>@saldo
		   set @afectado = 'S'
		else
		   set @afectado = 'N'



	if  @ccptipo in ('RE')
		select @PI_GENERASALDOF4=PI_GENERASALDOF4 from pedimp where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@PICODIGO)
	else
		select @PI_GENERASALDOF4=PI_GENERASALDOF4 from pedimp where pi_codigo=@PICODIGO


	SET     @pedimpdescargable='N'


	if  @ccptipo in ('RE')
	begin
		if (SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='S' AND @PI_GENERASALDOF4='S' and @ccptipo2 in ('IE', 'RG', 'SI', 'CN', 'RP')
			SET     @pedimpdescargable='S'
		else
			SELECT     @pedimpdescargable=CLAVEPED.CP_DESCARGABLE
			FROM         CLAVEPED 
			WHERE     (CLAVEPED.CP_CODIGO = @cp_codigo2)

	end
	else
	if /*(SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='S' AND*/ @PI_GENERASALDOF4='S' and @ccptipo in ('IE', 'RG', 'SI', 'CN', 'RP')
	SET     @pedimpdescargable='S'
	else
	SELECT     @pedimpdescargable=CLAVEPED.CP_DESCARGABLE
	FROM         CLAVEPED 
	WHERE     (CLAVEPED.CP_CODIGO = @cpcodigo)



	SELECT     @cp_clave=CLAVEPED.CP_CLAVE
	FROM         CLAVEPED 
	WHERE     (CLAVEPED.CP_CODIGO = @cpcodigo)

	if @cp_clave<>'R1' 
	begin
		DELETE FROM         PEDIMPR1HIST
		WHERE     (PI_CODIGO = @PICODIGO)	
	end

/* actualizamos Estatus del pedimento de importacion */
      if @pi_movimiento='E'
       begin
          if @pedimpdescargable='S'
	begin
	   if @pi_no_rect = 0 
	   begin
		if @cant >0
		begin
			if @saldo >0 
			begin
				if @cant = @saldo
				begin
					if @ccptipo = 'RE'	/*es rectificacion */
					begin					
						set @pi_estatus = 'N'				--rectificacion sin afectar
						

						if @ccptipo2 = 'CN' and @PI_GENERASALDOF42='N'	-- F4 no descargable					
						set @pi_estatus = 'B'		
						 

	
					end
					else
					begin
						set @pi_estatus = 'S'		-- Abierto - Sin Afectar						

						if @ccptipo = 'CN'  and @PI_GENERASALDOF4='N'-- F4 no descargable
						set @pi_estatus = 'B'		
						

					end
				end
				else
				begin
					if @ccptipo = 'RE'	
					begin						
						set @pi_estatus = 'F'				--rectificacion afectada						
	
					end
					else
					begin
						set @pi_estatus = 'A'			-- Abierto -Afectado						
		
					end
	
				end
			end
			else 
			begin
	
					if @ccptipo = 'RE'	
					begin
						if @pedimpdescargable='N'
						set @pi_estatus = 'E'				-- Rectificaci>n que no controla saldos
						else
						set @pi_estatus = 'G'				-- Rectificaci>n Cerrada
						
	
					end
					else
					begin
						set @pi_estatus = 'C'				-- Cerrado
		
					end
			end
	
		end
		else	
			set @pi_estatus = 'S'		-- Abierto - Sin Afectar
			
	   end
	   else
		set @pi_estatus = 'R'				-- Rectificado
		
	end
	else	      
	      set @pi_estatus = 'B'				-- no descargable
	      

     end
     else
     begin
	if @pi_tipo='S'
	begin
		if exists (select * from pedimpreltrans where pid_indiced in (select pid_indiced from pedimpdet where pi_codigo=@PICODIGO))
			
			set @pi_estatus = 'D'		-- Transferencia relacionada			
		else
			set @pi_estatus = 'T'		-- -- Transferencia sin relacion
			

	end
	begin
		if @ccptipo <> 'RE'	
		begin
		     if @pi_no_rect = 0 			
			set @pi_estatus = 'L'		-- Pedimento de salida
			
		     else			
			set @pi_estatus = 'R'		-- Pedimento rectificado
			

		end
		else		
			set @pi_estatus = 'O'		-- Rectificaci>n de salida
			
	end
    end
GO
