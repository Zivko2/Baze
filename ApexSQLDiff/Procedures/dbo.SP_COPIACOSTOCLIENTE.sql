SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_COPIACOSTOCLIENTE] (@MA_CODIGO INT)   as

declare @consecutivo int



if not exists (select * from maestrocliente where ma_codigo=@ma_codigo)
begin

	select @consecutivo=isnull(max(mc_codigo),0)+1 from maestrocliente


	INSERT INTO MAESTROCLIENTE (MC_CODIGO, MA_CODIGO,  MC_VTR, MC_NG_MP, MC_NG_EMP, MC_GRAV_MP, MC_GRAV_EMP, MC_GRAV_GI, MC_GRAV_GI_MX, MC_GRAV_MO, 
	                      MC_PRECIO, MC_NG_UNI, MC_GRAV_UNI)
	
	SELECT     @consecutivo, MA_CODIGO, 'S', MA_NG_MP, MA_NG_EMP, MA_GRAV_MP, MA_GRAV_EMP, MA_GRAV_GI, MA_GRAV_GI_MX, MA_GRAV_MO, 
	MA_NG_MP+MA_NG_EMP+ MA_GRAV_MP+ MA_GRAV_EMP+ MA_GRAV_GI+ MA_GRAV_GI_MX+ MA_GRAV_MO,
	MA_NG_MP+MA_NG_EMP+MA_GRAV_GI, MA_GRAV_MP+ MA_GRAV_EMP+ MA_GRAV_GI_MX+ MA_GRAV_MO
	FROM         VMAESTROCOST
	where ma_codigo=@ma_codigo


	update consecutivo
	set cv_codigo=(select isnull(max(mc_codigo),0)+1 from maestrocliente)
	where cv_tipo='MC'	

end
else
begin
	if (select cf_preciocliente from configuracion)='N'
	update MAESTROCLIENTE
	set MC_NG_MP=MA_NG_MP, MC_NG_EMP=MA_NG_EMP, MC_GRAV_MP=MA_GRAV_MP, MC_GRAV_EMP=MA_GRAV_EMP, MC_GRAV_GI=MA_GRAV_GI,
	 MC_GRAV_GI_MX=MA_GRAV_GI_MX, MC_GRAV_MO=MA_GRAV_MO, 
       	 MC_PRECIO=MA_NG_MP+MA_NG_EMP+ MA_GRAV_MP+ MA_GRAV_EMP+ MA_GRAV_GI+ MA_GRAV_GI_MX+ MA_GRAV_MO, 
	 MC_NG_UNI=MA_NG_MP+MA_NG_EMP+MA_GRAV_GI, MC_GRAV_UNI=MA_GRAV_MP+ MA_GRAV_EMP+ MA_GRAV_GI_MX+ MA_GRAV_MO
	FROM  MAESTROCLIENTE INNER JOIN VMAESTROCOST ON MAESTROCLIENTE.MA_CODIGO=VMAESTROCOST.MA_CODIGO
	where MAESTROCLIENTE.ma_codigo=@ma_codigo
end




GO
