SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_ACTUALIZAPI_PAGACONTRIB] (@pi_codigo int, @TablaTemp char(1)='S')   as

SET NOCOUNT ON 
declare @CCP_TIPO varchar(5), @CL_VIRTPAGACONTRIB char(1), @PI_FEC_ENT datetime, @pi_rectifica int,
@pr_codigo int, @cp_codigo int, @cf_servicios char(1), @pi_pagado char(1), @cf_pagocontribucion char(1)


select @cp_codigo=cp_codigo, @pi_fec_ent=pi_fec_ent, @pr_codigo=pr_codigo,
@pi_rectifica=pi_rectifica, @pi_pagado=pi_pagado 
from pedimp where pi_codigo=@pi_codigo


select @cf_pagocontribucion=cf_pagocontribucion from configuracion


	ALTER TABLE PEDIMPDET DISABLE TRIGGER [insert_pedimpdet] 


	if @TablaTemp='S'
	begin
		update Temppedimpdet
		set  pid_pagacontrib='S'
		where pid_pagacontrib is null or pid_pagacontrib='N'
		and pi_codigo=@pi_codigo
	end
	else
	begin
		update pedimpdet
		set  pid_pagacontrib='S'
		where pid_pagacontrib is null or pid_pagacontrib='N'
		and pi_codigo=@pi_codigo
	end

select @cf_servicios=cf_servicios from configuracion
select @CL_VIRTPAGACONTRIB=CL_VIRTPAGACONTRIB from cliente where cl_codigo=@pr_codigo
select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo=@cp_codigo


	if @ccp_tipo='RE'
	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@pi_rectifica)
	
	
--	print @CCP_TIPO
--	print @CL_VIRTPAGACONTRIB
	
	if @cf_servicios='S'
	begin
		if @TablaTemp='S'
		begin
			update Temppedimpdet
			set  pid_pagacontrib='N'
			where pi_codigo=@pi_codigo
		end
		else
		begin
			update pedimpdet
			set  pid_pagacontrib='N'
			where pi_codigo=@pi_codigo

		end

	end
	else
	begin
		IF (@CCP_TIPO IN ('VT', 'IV') and @CL_VIRTPAGACONTRIB='S')  or (@PI_FEC_ENT <= '11/20/2000')
		begin
			if @TablaTemp='S'
			begin
				update Temppedimpdet
				set  pid_pagacontrib='N'
				where pi_codigo=@pi_codigo
			end
			else
			begin
				update pedimpdet
				set  pid_pagacontrib='N'
				where pi_codigo=@pi_codigo

			end
		end
			

		if @TablaTemp='S'
		begin
			update Temppedimpdet
			set  pid_pagacontrib='N'
			where ((pa_origen in (SELECT CF_PAIS_MX FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
			(pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
			(pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
			ti_codigo in (SELECT TI_CODIGO FROM TIPO WHERE TI_PAGACONTRIB='N') or
			ma_codigo in (SELECT MA_CODIGO FROM MAESTRO WHERE MA_SERVICIO='S') or (@pi_pagado='S' and @cf_pagocontribucion<>'E')
			or pid_imprimir='N')
			and pi_codigo=@pi_codigo
		end
		else
		begin
			update pedimpdet
			set  pid_pagacontrib='N'
			where ((pa_origen in (SELECT CF_PAIS_MX FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
			(pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
			(pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
			ti_codigo in (SELECT TI_CODIGO FROM TIPO WHERE TI_PAGACONTRIB='N') or
			ma_codigo in (SELECT MA_CODIGO FROM MAESTRO WHERE MA_SERVICIO='S') or (@pi_pagado='S' and @cf_pagocontribucion<>'E')
			or pid_imprimir='N')
			and pi_codigo=@pi_codigo
		end
	end




	ALTER TABLE PEDIMPDET ENABLE TRIGGER [insert_pedimpdet]


GO
