SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_ACTUALIZAPID_PAGACONTRIB2] (@pid_indiced int,  @pagacontrib char(1) output)   as

SET NOCOUNT ON 
declare @pa_origen  int, @ti_codigo int, @pi_codigo int, @CCP_TIPO varchar(5), @CL_VIRTPAGACONTRIB char(1), @PI_FEC_ENT datetime, 
@PID_DEF_TIP char(1), @cp_codigo int, @pr_codigo int, @pi_rectifica int, @cf_servicios char(1), @ma_codigo int, @pi_pagado char(1), @pid_imprimir char(1),
@cf_pagocontribucion CHAR(1)

select @pa_origen=pa_origen, @ti_codigo=ti_codigo, @pi_codigo=pi_codigo,  @pid_imprimir=pid_imprimir,
@PID_DEF_TIP=PID_DEF_TIP, @ma_codigo=ma_codigo from pedimpdet where pid_indiced=@pid_indiced

select @cf_servicios=cf_servicios, @cf_pagocontribucion=cf_pagocontribucion from configuracion

select @cp_codigo=cp_codigo, @pi_fec_ent=pi_fec_ent, @pr_codigo=pr_codigo,
@pi_rectifica=pi_rectifica, @pi_pagado=pi_pagado
from pedimp where pi_codigo=@pi_codigo

select @CL_VIRTPAGACONTRIB=CL_VIRTPAGACONTRIB from cliente where cl_codigo=@pr_codigo

select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo=@cp_codigo

	if @ccp_tipo='RE'
	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@pi_rectifica)
	


	if @cf_servicios='S' or @pid_imprimir='N'
	begin
		set  @pagacontrib='N'
	end
	else
	begin
		IF (@CCP_TIPO IN ('VT', 'IV') and @CL_VIRTPAGACONTRIB='S') or
		(@pa_origen in (SELECT CF_PAIS_MX FROM CONFIGURACION) and @PID_DEF_TIP = 'P') or
		(@pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION) and @PID_DEF_TIP = 'P') or
		(@pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) and @PID_DEF_TIP = 'P') or
		@ti_codigo in (SELECT TI_CODIGO FROM TIPO WHERE TI_PAGACONTRIB='N') or
		@PI_FEC_ENT <= '11/20/2000' or
		@ma_codigo in (SELECT MA_CODIGO FROM MAESTRO WHERE MA_SERVICIO='S') or
		(@pi_pagado='S' AND @cf_pagocontribucion<>'E')
		set  @pagacontrib='N'
		else 
		set @pagacontrib='S'
	end



GO
