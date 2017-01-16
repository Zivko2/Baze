SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_COPIA_REG_PEDIMP] (@FUENTE INTEGER,@DESTINO INTEGER)  as

SET NOCOUNT ON 
declare @PI_CODIGO int, @PID_INDICED int, @MA_CODIGO int, @PID_NOPARTE varchar(30), @PID_NOMBRE varchar(150), @PID_NAME varchar(150), 
@PID_COS_UNI decimal(38,6), @PID_COS_UNIGEN decimal(38,6), @PID_CANT decimal(38,6), @PID_CAN_AR decimal(38,6), @PID_CAN_GEN decimal(38,6), @PID_VAL_ADU decimal(38,6), 
@PID_CTOT_DLS decimal(38,6), @ME_CODIGO int, @ME_GENERICO int, @MA_GENERICO int, 
@EQ_GENERICO decimal(28,14), @EQ_IMPMX decimal(28,14), @AR_IMPMX int, @ME_ARIMPMX int, @AR_EXPFO int, @PID_RATEEXPFO decimal(38,6), @PID_SEC_IMP smallint, 
@PID_DEF_TIP char(1), @PID_POR_DEF decimal(38,6), @CS_CODIGO smallint, @PID_SALDOGEN decimal(38,6), @PID_KIT_POR decimal(38,6), @TI_CODIGO smallint, 
@PA_ORIGEN int, @PA_PROCEDE int, @ES_ORIGEN int, @ES_DESTINO int, @ES_COMPRADOR int, @ES_VENDEDOR int, @SPI_CODIGO smallint, 
@PR_CODIGO int, @PID_IMPRIMIR char(1), @PID_GENERA_EMP char(1), @PID_CANT_DESP decimal(38,6), @CONSECUTIVO INT, @PI_FEC_ENT DATETIME

	SELECT @PI_FEC_ENT=PI_FEC_ENT FROM PEDIMP WHERE PI_CODIGO=@DESTINO

	declare cur_pedimp cursor for
	select  PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI,
	PID_COS_UNIGEN, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS,
	ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, 
	EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF,
	CS_CODIGO, PID_KIT_POR, TI_CODIGO, PA_ORIGEN, PA_PROCEDE,
	SPI_CODIGO,  PR_CODIGO, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP
	from pedimpdet where pi_codigo =@fuente
	open cur_pedimp

	fetch next from cur_pedimp into @PID_INDICED, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, @PID_NAME, @PID_COS_UNI,
	@PID_COS_UNIGEN, @PID_CANT, @PID_CAN_AR, @PID_CAN_GEN, @PID_VAL_ADU, @PID_CTOT_DLS,
	@ME_CODIGO, @ME_GENERICO, @MA_GENERICO, @EQ_GENERICO, 
	@EQ_IMPMX, @AR_IMPMX, @ME_ARIMPMX, @AR_EXPFO, @PID_RATEEXPFO, @PID_SEC_IMP, @PID_DEF_TIP, @PID_POR_DEF,
	@CS_CODIGO,  @PID_KIT_POR, @TI_CODIGO, @PA_ORIGEN, @PA_PROCEDE,
	@SPI_CODIGO, @PR_CODIGO, @PID_IMPRIMIR, @PID_GENERA_EMP, @PID_CANT_DESP


			
		
			while (@@fetch_status = 0)
			begin
	


			SELECT @CONSECUTIVO=ISNULL(MAX(PID_INDICED),0) FROM PEDIMPDET
			
			SET @CONSECUTIVO=@CONSECUTIVO+1


				INSERT INTO PEDIMPDET (PID_INDICED, PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI,
			PID_COS_UNIGEN, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS,
			ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, 
			EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF,
			CS_CODIGO, PID_KIT_POR, TI_CODIGO, PA_ORIGEN, PA_PROCEDE,
			SPI_CODIGO, PR_CODIGO, 
			PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP)

				VALUES (@CONSECUTIVO, @DESTINO, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, @PID_NAME, @PID_COS_UNI,
			@PID_COS_UNIGEN, @PID_CANT, @PID_CAN_AR, @PID_CAN_GEN, @PID_VAL_ADU, @PID_CTOT_DLS,
			@ME_CODIGO, @ME_GENERICO, @MA_GENERICO, @EQ_GENERICO, 
			@EQ_IMPMX, @AR_IMPMX, @ME_ARIMPMX, @AR_EXPFO, @PID_RATEEXPFO, @PID_SEC_IMP, @PID_DEF_TIP, @PID_POR_DEF,
			@CS_CODIGO, @PID_KIT_POR, @TI_CODIGO, @PA_ORIGEN, @PA_PROCEDE,
			@SPI_CODIGO, @PR_CODIGO, 
			@PID_IMPRIMIR, @PID_GENERA_EMP, @PID_CANT_DESP)

				INSERT INTO PIDESCARGA (PI_CODIGO, PID_INDICED, MA_CODIGO, MA_GENERICO, PID_SALDOGEN, PI_FEC_ENT)
				VALUES (@DESTINO, @CONSECUTIVO, @MA_CODIGO, @MA_GENERICO, @PID_CAN_GEN, @PI_FEC_ENT)
				
		fetch next from cur_pedimp into @PID_INDICED, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, @PID_NAME, @PID_COS_UNI,
		@PID_COS_UNIGEN, @PID_CANT, @PID_CAN_AR, @PID_CAN_GEN, @PID_VAL_ADU, @PID_CTOT_DLS,
		@ME_CODIGO, @ME_GENERICO, @MA_GENERICO, @EQ_GENERICO, 
		@EQ_IMPMX, @AR_IMPMX, @ME_ARIMPMX, @AR_EXPFO, @PID_RATEEXPFO, @PID_SEC_IMP, @PID_DEF_TIP, @PID_POR_DEF,
		@CS_CODIGO, @PID_KIT_POR, @TI_CODIGO, @PA_ORIGEN, @PA_PROCEDE,
		@SPI_CODIGO, @PR_CODIGO, 
		@PID_IMPRIMIR, @PID_GENERA_EMP, @PID_CANT_DESP

			
			end

		
		close cur_pedimp
		deallocate cur_pedimp

		update pedimp
		set pi_cuentadet=(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
		where pi_codigo =@DESTINO



		select @PID_INDICED= max(pid_indiced) from pedimpdet

		update consecutivo
		set cv_codigo =  isnull(@pid_indiced,0) + 1
		where cv_tipo = 'PID'

GO
