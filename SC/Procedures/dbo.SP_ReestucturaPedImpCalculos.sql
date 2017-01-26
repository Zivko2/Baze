SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ReestucturaPedImpCalculos]   as


		ALTER TABLE PEDIMPDET DISABLE TRIGGER insert_pedimpdet

		update pedimpdet
		set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6),
		PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6),
		PID_COS_UNIADU= round(round(((PID_CTOT_DLS/PID_CANT) / isnull(EQ_GENERICO,1)),6) * PI_TIP_CAM * pi_ft_adu,6),
		PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
		PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
		PID_VAL_ADU= round(PID_CTOT_DLS * PI_TIP_CAM * pi_ft_adu,6)
		from pedimpdet left outer join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
		where pi_movimiento='e' and PID_CANT >0 and pid_imprimir='S'
	
	
		update pedimpdet
		set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6),
		PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6),
		PID_COS_UNIADU= round(round(((PID_CTOT_DLS/PID_CANT) / isnull(EQ_GENERICO,1)),6) * PI_TIP_CAM,6),
		PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
		PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
		PID_VAL_ADU= round(PID_CTOT_DLS * PI_TIP_CAM,6)
		from pedimpdet left outer join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
		where  pi_movimiento='e' and PID_CANT >0 and pid_imprimir<>'S'
	
	
		/*actualizando saldo */
		update pidescarga  
		set pid_saldogen = PID_CAN_GEN
		from pidescarga inner join pedimpdet on pidescarga.pid_indiced=pedimpdet.pid_indiced 
		inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
		where  pi_movimiento='e' and pid_descargable<>'N'
	
		update pidescarga  
		set pid_saldogen = 0
		from pidescarga inner join pedimpdet on pidescarga.pid_indiced=pedimpdet.pid_indiced 
		inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
		where pi_movimiento='e' and pid_descargable='N'	
	
		update pedimpdet
		set PID_COS_UNI=PID_CTOT_DLS,
		PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6),
		PID_COS_UNIADU= round(((PID_CTOT_DLS) / EQ_GENERICO) * PI_TIP_CAM * pi_ft_adu,6),
		PID_CAN_GEN = 0,
		PID_CAN_AR =0,
		PID_VAL_ADU= round(PID_CTOT_DLS* PI_TIP_CAM * pi_ft_adu,6)
		from pedimpdet left outer join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
		where pi_movimiento='e' and PID_CANT =0 and pid_imprimir='S'
	
	
		update pedimpdet
		set PID_COS_UNI=round(PID_CTOT_DLS,6),
		PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6),
		PID_COS_UNIADU= round(((PID_CTOT_DLS) / EQ_GENERICO) * PI_TIP_CAM,6),
		PID_CAN_GEN = 0,
		PID_CAN_AR =0,
		PID_VAL_ADU= round(PID_CTOT_DLS* PI_TIP_CAM,6)
		from pedimpdet left outer join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
		where pi_movimiento='e' and PID_CANT =0 and pid_imprimir<>'S'
	
	
		EXEC sp_reestructuradescargas 1

	ALTER TABLE PEDIMPDET ENABLE TRIGGER insert_pedimpdet



























GO
