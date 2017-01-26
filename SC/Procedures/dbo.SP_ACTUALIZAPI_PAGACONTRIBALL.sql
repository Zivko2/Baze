SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ACTUALIZAPI_PAGACONTRIBALL]   as

SET NOCOUNT ON 
declare @cf_servicios char(1), @cf_pagocontribucion char(1)

select @cf_servicios=cf_servicios, @cf_pagocontribucion=cf_pagocontribucion from configuracion

	ALTER TABLE PEDIMPDET DISABLE TRIGGER [insert_pedimpdet] 

	update pedimpdet
	set  pid_pagacontrib='S'
	--where pid_pagacontrib is null


	if @cf_servicios='S'
	begin
		update pedimpdet
		set  pid_pagacontrib='N'
		where pid_pagacontrib='S'

		update pedimpdetb
		set  pib_pagacontrib='N'
		where pib_pagacontrib='S'
	end
	else
	begin

		update pedimpdet
		set  pid_pagacontrib='N'
		where (pi_codigo in (select pi_codigo from pedimp where PI_FEC_ENT <= '11/20/2000')) or
		(pi_codigo in (select pi_codigo from pedimp where cp_codigo IN (select cp_codigo 
						from configuraclaveped where ccp_tipo='VT' or ccp_tipo='IV'))
						and pr_codigo in (select  cl_codigo from cliente where CL_VIRTPAGACONTRIB='S'))
						and pi_codigo in (select pi_codigo from pedimp where pi_movimiento='E')


		update pedimpdet
		set  pid_pagacontrib='N'
		where ((pa_origen in (SELECT CF_PAIS_MX FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
		(pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
		(pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
		ti_codigo in (SELECT TI_CODIGO FROM TIPO WHERE TI_PAGACONTRIB='N') or
		(pi_codigo in (select pi_codigo from pedimp where pi_pagado='S')
		and @cf_pagocontribucion<>'E'))
		and pi_codigo in (select pi_codigo from pedimp where pi_movimiento='E')

	
		update pedimpdet
		set  pid_pagacontrib='N'
		where (pa_origen not in (SELECT CF_PAIS_MX FROM CONFIGURACION) and PID_DEF_TIP = 'P') and
		(pa_origen not in (SELECT CF_PAIS_CA FROM CONFIGURACION) and PID_DEF_TIP = 'P') and
		(pa_origen not in (SELECT CF_PAIS_USA FROM CONFIGURACION) and PID_DEF_TIP = 'P') and
		ti_codigo not in (SELECT TI_CODIGO FROM TIPO WHERE TI_PAGACONTRIB='N')
		and pi_codigo in (select pi_codigo from pedimp where pi_movimiento='S')
	
		update pedimpdetb
		set  pib_pagacontrib='N'
		where pib_indiceb in
		(select pib_indiceb from pedimpdet where pid_pagacontrib='N')
		and pi_codigo in (select pi_codigo from pedimp where pi_movimiento='E')
	
		update pedimpdetb
		set  pib_pagacontrib='N'
		where pib_destnafta='N'
		and pi_codigo in (select pi_codigo from pedimp where pi_movimiento='S')

		update pedimpdetb
		set  pib_pagacontrib='N'
		where pi_codigo in (select pi_codigo from pedimp where pi_pagado='S' and @cf_pagocontribucion<>'E' and pi_movimiento='E')

	end


	ALTER TABLE PEDIMPDET ENABLE TRIGGER [insert_pedimpdet]

GO
