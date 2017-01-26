SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_FILLDECANUALPPSDET] (@DAP_CODIGO int)   as

SET NOCOUNT ON 
declare @MA_GENERICO int, @PID_NOMBRE varchar(250), 
      @AR_IMPMX int, @SE_CODIGO smallint, @ME_AR smallint, @PID_CANT decimal(38,6), @VALOR decimal(38,6),
@PID_TOTAL decimal(38,6), @DAPD_INVENTARIO decimal(38,6), @DAPD_EXPORT decimal(38,6)


 if exists (select * from decanualppsdet where DAP_CODIGO=@DAP_CODIGO)
delete from decanualppsdet where DAP_CODIGO=@DAP_CODIGO

declare cur_Bienes cursor for
	SELECT MAX(MA_GENERICO), AR_IMPMX, SE_CODIGO, ME_CODIGO, round(SUM(FED_CANT),6), round(SUM( VALOR),6)
	FROM VREPPPSTOTALPROD
	WHERE DAP_CODIGO=@DAP_CODIGO
	group by AR_IMPMX, SE_CODIGO, ME_CODIGO

open cur_Bienes

	FETCH NEXT FROM cur_Bienes INTO @MA_GENERICO, @AR_IMPMX, @SE_CODIGO, @ME_AR, @PID_TOTAL, @VALOR

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		if @MA_GENERICO > 0
		SELECT @PID_NOMBRE=isnull(MA_NOMBRE,'') FROM MAESTRO WHERE MA_CODIGO=@MA_GENERICO
		else
		set @PID_NOMBRE='SIN GRUPO GENERICO'

		insert into decanualppsdet (DAP_CODIGO, MA_GENERICO, DAPD_NOMBRE,
		AR_CODIGO, SE_CODIGO, ME_AR, DAPD_TOTALBIENES, DAPD_VALORMN)
		values (@DAP_CODIGO, @MA_GENERICO, @PID_NOMBRE, isnull(@AR_IMPMX,0), isnull(@SE_CODIGO,0), 
			isnull(@ME_AR,19), @PID_TOTAL, @VALOR)


		if exists (select   *  from VREPPPSTOTALNAC where ma_generico=@MA_GENERICO and dap_codigo=@DAP_CODIGO)
		begin
			select   @pid_cant=sum(fed_cant) 
			from VREPPPSTOTALNAC
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO

			UPDATE decanualppsdet
			set DAPD_MDONAC=@pid_cant
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO


			if @PID_TOTAL>@pid_cant
				set @DAPD_EXPORT=@PID_TOTAL-@pid_cant
			else
				set @DAPD_EXPORT=0

			UPDATE decanualppsdet
			set DAPD_EXPORT=@DAPD_EXPORT
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO

		end
		else
		begin
			UPDATE decanualppsdet
			set DAPD_MDONAC=0
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO

			if @PID_TOTAL<0
			set @PID_TOTAL=0

			UPDATE decanualppsdet
			set DAPD_EXPORT=@PID_TOTAL
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO

		end



			select   @DAPD_INVENTARIO=@PID_TOTAL-(DAPD_EXPORT+DAPD_MDONAC)
			from decanualppsdet
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO

			UPDATE decanualppsdet
			set DAPD_INVENTARIO= @DAPD_INVENTARIO
			where ma_generico=@MA_GENERICO
			and dap_codigo=@DAP_CODIGO


	FETCH NEXT FROM cur_Bienes INTO @MA_GENERICO, 
      @AR_IMPMX, @SE_CODIGO, @ME_AR, @PID_TOTAL, @VALOR


	END

CLOSE cur_Bienes
DEALLOCATE cur_Bienes






































GO
