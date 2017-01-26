SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE PROCEDURE [dbo].[SP_fillpedimpactualizaincrementa] (@picodigo int, @concilia char(1)='N')   as

SET NOCOUNT ON 
declare @fi_flete decimal(38,6), @fi_seguro decimal(38,6), @fi_embalaje decimal(38,6), @incrementa decimal(38,6), @countregistros int,
@pi_tip_cam decimal(38,6), @incrementamn float, @costototaldls decimal(38,6)


	select @pi_tip_cam=pi_tip_cam from pedimp where pi_codigo=@picodigo

	select @costototaldls= sum(PID_CTOT_DLS) from pedimpdet where pi_codigo=@picodigo
	select @incrementa= sum(PII_VALOR) from pedimpincrementa where pi_codigo=@picodigo



	set @incrementamn= @incrementa*@pi_tip_cam

	if (@costototaldls*@pi_tip_cam >0)
	begin
		update pedimp
		set pi_ft_adu = isnull(round(((@costototaldls*@pi_tip_cam)+@incrementamn)/(@costototaldls*@pi_tip_cam),9),1)
		where pi_codigo= @picodigo

	end		
	else
		update pedimp
		set pi_ft_adu=1
		where pi_codigo= @picodigo

	update pedimpdet
	set PEDIMPDET.PID_VAL_ADU =  round(isnull(PEDIMPDET.PID_CAN_GEN,0) * isnull(PEDIMPDET.PID_COS_UNIgen,0) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0),0)
     		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
	where pedimpdet.pi_codigo=@picodigo

	if @concilia='N'
	begin
		if (select cf_pedimpdetb from configuracion)='S' and (select pi_cuentadet from pedimp where pi_codigo=@picodigo)>0
		begin
			exec sp_fillpedimpdetB @picodigo, 1
		end
	end

























GO
