SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_FillDetalle] (@picodigo int, @maximo int, @user int)   as

declare 	@contador int, @valorini int, @valor int, @valorfin int, @hora varchar(15), @FechaActual varchar(10), @em_codigo int


	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))


select @FechaActual = convert(varchar(10), getdate(),101)


if (select count(*) from TempPedImpDet)>500
begin
	select @valor= round(count(*)/20,0)+1 from TempPedImpDet

	set @contador=1

	select @valorini =min(pid_indiced) from TempPedImpDet


	WHILE (@contador<=20) 
	BEGIN

		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
		values (@user, 2, 'Llenando detalle Pedimento, Parte:'+convert(varchar(5), @contador), 'Filling Detail Pedimento, Part:'+convert(varchar(5), @contador), convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

		set @valorfin=@valorini+@valor

		
		begin tran
		INSERT INTO PEDIMPDET(PI_CODIGO, PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
		                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
		                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, PID_REGIONFIN, SE_CODIGO,
		                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE,  SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
			         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PES_UNIKG, PID_SERVICIO, PG_CODIGO, PID_GENERA_EMPDET, PID_SECUENCIA)
		
		SELECT     PI_CODIGO, PID_INDICED+@maximo, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
		                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
		                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, PID_REGIONFIN, SE_CODIGO,
		                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE, SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
			         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PES_UNIKG, isnull(PID_SERVICIO,'N'), PG_CODIGO,
				isnull(PID_GENERA_EMPDET,'D'), PID_SECUENCIA
		FROM         TempPedImpDet
		where pi_codigo=@picodigo  and PID_INDICED>=@valorini and PID_INDICED<=@valorfin
		ORDER BY pid_indiced
		commit tran

		delete from TempPedImpDet where pi_codigo=@picodigo  and PID_INDICED>=@valorini and PID_INDICED<=@valorfin

		set @contador=@contador+1
		set @valorini=@valorfin+1

	END		


end
else
begin
	begin tran
	INSERT INTO PEDIMPDET(PI_CODIGO, PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
	                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, PID_REGIONFIN, SE_CODIGO,
	                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE,  SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
		         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PES_UNIKG, PID_SERVICIO, PG_CODIGO, PID_GENERA_EMPDET, PID_SECUENCIA)
	
	SELECT     PI_CODIGO, PID_INDICED+@maximo, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
	                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, PID_REGIONFIN, SE_CODIGO,
	                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE, SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
		         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PES_UNIKG, isnull(PID_SERVICIO,'N'), PG_CODIGO, isnull(PID_GENERA_EMPDET,'D'), PID_SECUENCIA
	FROM         TempPedImpDet
	where pi_codigo=@picodigo  
	ORDER BY pid_indiced
	commit tran
	

end
GO
