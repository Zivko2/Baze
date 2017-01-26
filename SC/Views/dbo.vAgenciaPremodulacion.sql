SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


create view dbo.vAgenciaPremodulacion as
select agenciapatente.agt_patente+'-'+factcons.fc_folio [AGENCIA_PREMODULACION], factcons.FC_CODIGO, factcons.FC_FOLIO,factcons.FC_TIPO,factcons.AGT_CODIGO
from factcons
	left outer join agenciaPatente on factcons.agt_codigo = agenciapatente.agt_codigo


GO
