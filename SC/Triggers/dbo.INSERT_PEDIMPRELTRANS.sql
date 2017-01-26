SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE TRIGGER [INSERT_PEDIMPRELTRANS] ON dbo.PEDIMPRELTRANS 
FOR INSERT
AS
declare @RET_CANTDESC decimal(38,6), @PID_CAN_GEN decimal(38,6)


		SELECT     @RET_CANTDESC= SUM(dbo.PEDIMPRELTRANS.RET_CANTDESC), @PID_CAN_GEN=dbo.PEDIMPDET.PID_CAN_GEN
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.PEDIMPRELTRANS ON dbo.PEDIMPDET.PID_INDICED = dbo.PEDIMPRELTRANS.PID_INDICED
		WHERE     dbo.PEDIMPDET.PID_INDICED in (select pid_indiced from inserted)
		GROUP BY dbo.PEDIMPDET.PID_CAN_GEN, dbo.PEDIMPRELTRANS.RET_ESTATUS


		if @RET_CANTDESC < @PID_CAN_GEN 
		update PEDIMPRELTRANS
		set ret_estatus='P'
		WHERE     PID_INDICED in (select pid_indiced from inserted)



































GO
