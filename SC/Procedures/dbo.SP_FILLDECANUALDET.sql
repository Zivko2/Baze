SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_FILLDECANUALDET] (@dan_codigo int)   as

SET NOCOUNT ON 
declare @MA_GENERICO int, @PID_NOMBRE varchar(250), 
      @AR_IMPMX int, @SE_CODIGO smallint, @ME_AR smallint, @PID_CANT decimal(38,6), @VALOR decimal(38,6),
@PID_TOTAL decimal(38,6), @DAND_INVENTARIO decimal(38,6), @DAND_EXPORT decimal(38,6)




 if exists (select * from decanualnvadet where dan_codigo=@dan_codigo)
delete from decanualnvadet where dan_codigo=@dan_codigo

	if (SELECT  CF_DECANUALGEN FROM CONFIGURACION)='S'
	begin
		if (SELECT CF_USASUBDECANUAL FROM CONFIGURACION)='S'
		begin
			insert into decanualnvadet (dan_codigo, MA_GENERICO, DAND_NOMBRE,
			AR_CODIGO, SE_CODIGO, ME_AR, DAND_TOTALBIENES)
	
			SELECT @dan_codigo, isnull(MA_GENERICO,0), 'SIN GRUPO GENERICO', isnull(AR_IMPMX,0), isnull(SE_CODIGO,0), isnull(ME_CODIGO,0), round(SUM(FED_CANT),6)
			FROM VREPANUALTOTALPROD
			WHERE dan_codigo=@dan_codigo
			group by SE_CODIGO, ME_CODIGO, AR_IMPMX, isnull(MA_GENERICO,0)


		end
		else
		begin
			insert into decanualnvadet (dan_codigo, MA_GENERICO, DAND_NOMBRE,
			AR_CODIGO, SE_CODIGO, ME_AR, DAND_TOTALBIENES)
	
			SELECT @dan_codigo, isnull(MA_GENERICO,0), 'SIN GRUPO GENERICO', isnull(AR_IMPMX,0), isnull(SE_CODIGO,0), isnull(ME_CODIGO,0), round(SUM(FED_CANT),6)
			FROM VREPANUALTOTALPRODWOSUB
			WHERE dan_codigo=@dan_codigo
			group by SE_CODIGO, ME_CODIGO, AR_IMPMX, isnull(MA_GENERICO,0)


		end


			UPDATE decanualnvadet
			set DAND_MDONAC=isnull((select sum(fed_cant) from VREPANUALTOTALNAC where ma_generico = decanualnvadet.ma_generico
							and ME_AREXPMX=decanualnvadet.me_ar and SE_CODIGO=decanualnvadet.se_codigo and AR_EXPMX=decanualnvadet.ar_codigo 
							and dan_codigo=@dan_codigo),0), 
			DAND_EXPORT=(case when isnull(DAND_TOTALBIENES,0) > isnull((select sum(fed_cant) from VREPANUALTOTALNAC where ma_generico = decanualnvadet.ma_generico
							and ME_AREXPMX=decanualnvadet.me_ar and SE_CODIGO=decanualnvadet.se_codigo and AR_EXPMX=decanualnvadet.ar_codigo 
							and dan_codigo=@dan_codigo),0) then isnull(DAND_TOTALBIENES,0) - isnull((select sum(fed_cant) from VREPANUALTOTALNAC where ma_generico = decanualnvadet.ma_generico
							and ME_AREXPMX=decanualnvadet.me_ar and SE_CODIGO=decanualnvadet.se_codigo and AR_EXPMX=decanualnvadet.ar_codigo 
							and dan_codigo=@dan_codigo),0) else isnull(DAND_TOTALBIENES,0) end)
			where dan_codigo=@dan_codigo


	end
	else
	begin
		if (SELECT CF_USASUBDECANUAL FROM CONFIGURACION)='S'
		begin
			insert into decanualnvadet (dan_codigo, MA_GENERICO, DAND_NOMBRE,
			AR_CODIGO, SE_CODIGO, ME_AR, DAND_TOTALBIENES)
	
			SELECT @dan_codigo, isnull(MAX(MA_GENERICO),0), 'SIN GRUPO GENERICO', isnull(AR_IMPMX,0), isnull(SE_CODIGO,0), isnull(ME_CODIGO,0), round(SUM(FED_CANT),6)
			FROM VREPANUALTOTALPROD
			WHERE dan_codigo=@dan_codigo
			group by SE_CODIGO, ME_CODIGO, AR_IMPMX


		end
		else
		begin
			insert into decanualnvadet (dan_codigo, MA_GENERICO, DAND_NOMBRE,
			AR_CODIGO, SE_CODIGO, ME_AR, DAND_TOTALBIENES)
	
			SELECT @dan_codigo, isnull(MAX(MA_GENERICO),0), 'SIN GRUPO GENERICO', isnull(AR_IMPMX,0), isnull(SE_CODIGO,0), isnull(ME_CODIGO,0), round(SUM(FED_CANT),6)
			FROM VREPANUALTOTALPRODWOSUB
			WHERE dan_codigo=@dan_codigo
			group by SE_CODIGO, ME_CODIGO, AR_IMPMX

		end


		UPDATE decanualnvadet
		set DAND_MDONAC=isnull((select sum(fed_cant) from VREPANUALTOTALNAC where 
						ME_AREXPMX=decanualnvadet.me_ar and SE_CODIGO=decanualnvadet.se_codigo and AR_EXPMX=decanualnvadet.ar_codigo 
						and dan_codigo=@dan_codigo),0), 
		DAND_EXPORT=(case when isnull(DAND_TOTALBIENES,0) > isnull((select sum(fed_cant) from VREPANUALTOTALNAC where 
						ME_AREXPMX=decanualnvadet.me_ar and SE_CODIGO=decanualnvadet.se_codigo and AR_EXPMX=decanualnvadet.ar_codigo 
						and dan_codigo=@dan_codigo),0) then isnull(DAND_TOTALBIENES,0) - isnull((select sum(fed_cant) from VREPANUALTOTALNAC where 
						ME_AREXPMX=decanualnvadet.me_ar and SE_CODIGO=decanualnvadet.se_codigo and AR_EXPMX=decanualnvadet.ar_codigo 
						and dan_codigo=@dan_codigo),0) else isnull(DAND_TOTALBIENES,0) end)
		where dan_codigo=@dan_codigo

	end
		
		update decanualnvadet	
		set DAND_NOMBRE =(select isnull(MA_NOMBRE,'')  FROM MAESTRO WHERE MA_CODIGO=decanualnvadet.ma_generico)
		WHERE  (select isnull(MA_NOMBRE,'')  FROM MAESTRO WHERE MA_CODIGO=decanualnvadet.ma_generico) <>''

GO
