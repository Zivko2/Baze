SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_tempFillPedimpdetDesc]   as

SET NOCOUNT ON 

UPDATE FACTEXP
SET FE_PREVIADESC='N'
WHERE FE_PREVIADESC IS NULL

if not exists (select * from PEDIMPDETDESC)

insert into PEDIMPDETDESC (PI_CODIGO, PI_FEC_ENT, PID_INDICED, MA_CODIGO, PID_SALDOGEN, PID_CAN_GEN)
/*El query cambio ya que el campo pid_saldogen no existe en pedimpdet 03-Dic-09 Manuel G.
SELECT     TOP 100 PERCENT dbo.PEDIMP.PI_CODIGO, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.MA_CODIGO, 
                      dbo.PEDIMPDET.PID_SALDOGEN, dbo.PEDIMPDET.PID_CAN_GEN
FROM         dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
WHERE     (dbo.PEDIMPDET.PID_SALDOGEN > 0) AND (dbo.PEDIMP.PI_ESTATUS <> 'C') AND (dbo.PEDIMP.PI_ESTATUS <> 'R') AND 
                      (dbo.PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND 
                      (dbo.PEDIMPDET.PID_DESCARGABLE = 'S')
ORDER BY dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.PI_CODIGO*/
SELECT     TOP 100 PERCENT dbo.PEDIMP.PI_CODIGO, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.MA_CODIGO, 
                      dbo.PIDescarga.PID_SALDOGEN, dbo.PEDIMPDET.PID_CAN_GEN
FROM         dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
                      dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED 
WHERE     (dbo.PIDescarga.PID_SALDOGEN > 0) AND (dbo.PEDIMP.PI_ESTATUS <> 'C') AND (dbo.PEDIMP.PI_ESTATUS <> 'R') AND 
                      (dbo.PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND 
                      (dbo.PEDIMPDET.PID_DESCARGABLE = 'S')
ORDER BY dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.PI_CODIGO

if not exists(select * from kardesprevia)
insert into kardesprevia (KAP_INDICED_PED, KAP_FECHADESC, MA_PADRE, MA_HIJO, KAP_ESTATUS, KAP_CANTDESC, KAP_SALDO_PED, 
                      KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, KAP_FISCOMP)
/* Cambiada algunos campos ya no existen 3-Dic-09 Manuel G.
SELECT     KARDESPED.KAP_INDICED_PED, KARDESPED.KAP_FECHADESC, FACTEXPDET.MA_CODIGO AS MA_PADRE, 
                      KARDESPED.MA_HIJO, KARDESPED.KAP_ESTATUS, KARDESPED.KAP_CANTDESC, KARDESPED.KAP_SALDO_PED, 
                      KARDESPED.KAP_CantTotADescargar, KARDESPED.KAP_Saldo_FED, KARDESPED.KAP_PADRESUST, KARDESPED.KAP_FISCOMP
FROM         KARDESPED INNER JOIN
                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED 
ORDER BY KARDESPED.KAP_CODIGO, KARDESPED.MA_HIJO*/

SELECT     KARDESPED.KAP_INDICED_PED, FACTEXP.FE_FECHADESCARGA AS KAP_FECHADESC, FACTEXPDET.MA_CODIGO AS MA_PADRE, 
                      KARDESPED.MA_HIJO, KARDESPED.KAP_ESTATUS, KARDESPED.KAP_CANTDESC, VKAP_SALDO_PED.KAP_SALDO_PED, 
                      KARDESPED.KAP_CantTotADescargar, KARDESPED.KAP_Saldo_FED, KARDESPED.KAP_PADRESUST, KARDESPED.KAP_FISCOMP
FROM         KARDESPED INNER JOIN
                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      VKAP_SALDO_PED ON KARDESPED.KAP_CODIGO = VKAP_SALDO_PED.KAP_CODIGO
ORDER BY KARDESPED.KAP_CODIGO, KARDESPED.MA_HIJO



























GO
