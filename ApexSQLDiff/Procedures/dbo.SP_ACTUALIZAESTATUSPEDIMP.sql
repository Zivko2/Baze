SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSPEDIMP] (@PICODIGO INT, @cpcodigo int=0)   as

SET NOCOUNT ON 
DECLARE @saldo decimal(38,6), @cant decimal(38,6), @ccptipo varchar (5), @ccptipo2 varchar(5), @pi_no_rect int, @pi_movimiento char(1), @pedimpdescargable char(1),
@pi_tipo char(1), @afectado char(1), @PI_GENERASALDOF4 char(1), @reexpedicion char(1), @cp_codigo2 int



	if @cpcodigo=0
	select @cpcodigo=cp_codigo from pedimp where pi_codigo=@PICODIGO


	/*
	UPDATE PIDescarga
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
	AND PIDescarga.PI_CODIGO=@PICODIGO
	*/

--	ALTER TABLE [PEDIMP]  DISABLE TRIGGER [UPDATE_PEDIMP]
	SELECT @ccptipo = CCP_TIPO
	FROM CONFIGURACLAVEPED 
	where CP_CODIGO = @cpcodigo



	SELECT     @pi_no_rect = COUNT(dbo.PEDIMPRECT.PI_NO_RECT) 
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPRECT ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPRECT.PI_CODIGO
	WHERE     (dbo.PEDIMP.PI_CODIGO = @PICODIGO)

/*
	set @reexpedicion='N'

	IF EXISTS(select pi_codigo from pedimp 
		     where pi_codigo  in 
		     (select pi_codigo from pedimprect where pi_no_rect in (SELECT P2.PI_CODIGO FROM PEDIMP P2 INNER JOIN CLAVEPED ON P2.CP_CODIGO=CLAVEPED.CP_CODIGO where CP_CLAVE='P1')))
	set @reexpedicion='S'
*/


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


	update pedimp
	set pi_afectado=@afectado
	where pi_codigo =@PICODIGO



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
	if (SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='S' AND @PI_GENERASALDOF4='S' and @ccptipo in ('IE', 'RG', 'SI', 'CN', 'RP')
		SET     @pedimpdescargable='S'
	else
		SELECT     @pedimpdescargable=CLAVEPED.CP_DESCARGABLE
		FROM         CLAVEPED 
		WHERE     (CLAVEPED.CP_CODIGO = @cpcodigo)

	
	select @pi_movimiento=pi_movimiento, @pi_tipo=pi_tipo from pedimp where pi_codigo=@PICODIGO


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
						update pedimp
						set pi_estatus = 'N'				--rectificacion sin afectar
						where pi_codigo = @PICODIGO

						if @ccptipo2 = 'CN'	-- F4 no descargable
						update pedimp
						set pi_estatus = 'B'		
						where pi_codigo = @PICODIGO and @PI_GENERASALDOF4='N'

	
					end
					else
					begin
						update pedimp
						set pi_estatus = 'S'		-- Abierto - Sin Afectar
						where pi_codigo = @PICODIGO

						if @ccptipo = 'CN'	-- F4 no descargable
						update pedimp
						set pi_estatus = 'B'		
						where pi_codigo = @PICODIGO and PI_GENERASALDOF4='N'

					end
				end
				else
				begin
					if @ccptipo = 'RE'	
					begin
						update pedimp
						set pi_estatus = 'F'				--rectificacion afectada
						where pi_codigo = @PICODIGO
	
					end
					else
					begin
						update pedimp
						set pi_estatus = 'A'			-- Abierto -Afectado
						where pi_codigo = @PICODIGO
		
					end
	
				end
			end
			else 
			begin

					if @ccptipo = 'RE'	
					begin
						if @pedimpdescargable='N'
							update pedimp
							set pi_estatus = 'E'				-- Rectificaci>n que no controla saldos
							where pi_codigo = @PICODIGO
						else
							update pedimp
							set pi_estatus = 'G'				-- Rectificaci>n Cerrada
							where pi_codigo = @PICODIGO
	
					end
					else
					begin
						update pedimp
						set pi_estatus = 'C'				-- Cerrado
						where pi_codigo = @PICODIGO
		
					end
			end
	
		end
		else
			update pedimp
			set pi_estatus = 'S'		-- Abierto - Sin Afectar
			where pi_codigo = @PICODIGO
	   end
	   else
		--if @reexpedicion='N'
		  update pedimp
		  set pi_estatus = 'R'				-- Rectificado
		  where pi_codigo = @PICODIGO
		/*else
		  update pedimp
		  set pi_estatus = 'P'				-- REEXPEDITADO
		  where pi_codigo = @PICODIGO*/

	end
	else
	      update pedimp
	      set pi_estatus = 'B'				-- no descargable
	      where pi_codigo = @PICODIGO

     end
     else
     begin
	if @pi_tipo='S'
	begin
		if exists (select * from pedimpreltrans where pid_indiced in (select pid_indiced from pedimpdet where pi_codigo=@PICODIGO))
			update pedimp
			set pi_estatus = 'D'		-- Transferencia relacionada
			where pi_codigo = @PICODIGO
		else
			update pedimp
			set pi_estatus = 'T'		-- -- Transferencia sin relacion
			where pi_codigo = @PICODIGO

	end
	begin
		if @ccptipo <> 'RE'	
		begin
		     if @pi_no_rect = 0 
			update pedimp
			set pi_estatus = 'L'		-- Pedimento de salida
			where pi_codigo = @PICODIGO
		     else
			update pedimp
			set pi_estatus = 'R'		-- Pedimento rectificado
			where pi_codigo = @PICODIGO

		end
		else
			update pedimp
			set pi_estatus = 'O'		-- Rectificaci>n de salida
			where pi_codigo = @PICODIGO
	end
    end

--	ALTER TABLE [PEDIMP]  ENABLE TRIGGER [UPDATE_PEDIMP]
GO
