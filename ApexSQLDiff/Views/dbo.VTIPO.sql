SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VTIPO
with encryption as
select tipo.ti_codigo, tipo.ti_nombre, tipo.ti_name, 
configuratipo.cft_tipo
from tipo
left outer join
configuratipo on
tipo.ti_codigo = configuratipo.ti_codigo







































































GO
