SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SaldoIncorrecto]   as     declare @saldo_incorrecto table(PID_INDICED int not null,  primary key (PID_INDICED)) insert into @saldo_incorrecto SELECT     PEDIMPDET.PID_INDICED FROM         PEDIMPDET INNER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PIDescarga ON PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED LEFT OUTER JOIN (SELECT     SUM(KAP_CANTDESC) AS KAP_CANTDESC, KAP_INDICED_PED FROM         KARDESPED WHERE     KAP_INDICED_PED IS NOT NULL /*glr (8/oct/2010) para evitar mensaje "Null value is eliminated by an aggregate"*/ and KAP_CantDesc is not null GROUP BY KAP_INDICED_PED) CANTDESC ON PEDIMPDET.PID_INDICED=CANTDESC.KAP_INDICED_PED LEFT OUTER JOIN (SELECT     SUM(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) CANTLIGA, factexpdet.pid_indiced FROM         factexpdet INNER JOIN factexp ON factexpdet.fe_codigo = factexp.fe_codigo WHERE     factexp.fe_estatus IN ('D', 'P') AND factexpdet.pid_indiced<>-1 GROUP BY factexpdet.pid_indiced)  CANTLIGADA ON PEDIMPDET.PID_INDICED=CANTLIGADA.pid_indiced WHERE     (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_MOVIMIENTO = 'E') AND (PIDescarga.PID_INDICED IS NOT NULL) AND ( ((PIDescarga.PID_SALDOGEN - PIDescarga.pid_congelasubMaq)<> round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0) + isnull(PIDescarga.pid_congelasubMaq,0)) ,6) and round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)+ isnull(pidescarga.pid_congelasubmaq,0)) ,6) > 0.0 and pedimp.pi_fec_ent < (select max(fechaact) from versioninfo) - (18 *30.416)) or ((PIDescarga.PID_SALDOGEN - PIDescarga.pid_congelasubMaq) <> round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)+ isnull(pidescarga.pid_congelasubmaq,0)) ,6) and pedimp.pi_fec_ent >= (select max(fechaact) from versioninfo) - (18 *30.416)) ) and (pedimpdet.pid_cos_uni <> 0 and pedimpdet.pid_cant <> 0 and pedimpdet.pid_can_gen <> 0) UPDATE PIDESCARGA SET PID_SALDOINCORRECTO='S' WHERE PID_INDICED IN (SELECT PID_INDICED FROM @saldo_incorrecto) AND PID_SALDOINCORRECTO='N' AND PID_INDICED NOT IN (SELECT PID_INDICED FROM FACTEXPDET WHERE PID_INDICED<>-1 GROUP BY PID_INDICED) UPDATE PIDESCARGA SET PID_SALDOINCORRECTO='N' WHERE PID_INDICED NOT IN (SELECT PID_INDICED FROM @saldo_incorrecto) AND PID_SALDOINCORRECTO='S' 
GO