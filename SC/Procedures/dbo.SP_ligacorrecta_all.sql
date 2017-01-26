SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ligacorrecta_all]  (@user int=1)    as

SET NOCOUNT ON 
declare @owner varchar(150), @cuenta int


	if (SELECT CF_PEDSALDOINC FROM CONFIGURACION)<>'S' 
	exec sp_ligacorrectaall @user

	alter table factimp disable trigger UPDATE_FACTIMP

		update factimp
		set pi_codigo=-1
		where pi_codigo<>-1 and pi_codigo<0
		
		update factimp
		set si_codigo=-1
		where si_codigo<>-1 and si_codigo<0
		
		update factimp
		set pi_rectifica=-1
		where pi_rectifica<>-1 and pi_rectifica<0

	alter table factimp enable trigger UPDATE_FACTIMP

	alter table factexp disable trigger UPDATE_FACTEXP
		update factexp
		set pi_codigo=-1
		where pi_codigo<>-1 and pi_codigo<0
	
		update factexp
		set et_codigo=-1
		where et_codigo<>-1 and et_codigo<0

		update factexp
		set pi_rectifica=-1
		where pi_rectifica<>-1 and pi_rectifica<0
	
	alter table factexp enable trigger UPDATE_FACTEXP


	if (SELECT CF_TIEMPOUSO FROM CONFIGURACION)>-1
	begin
		UPDATE MAESTRO
		SET MA_ENUSO='N'
		FROM MAESTRO LEFT OUTER JOIN
		CONFIGURATIPO  ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE MA_INV_GEN='I' AND CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T', 'P') 
		    AND MA_CODIGO NOT IN (SELECT     MA_CODIGO FROM  VENUSO GROUP BY MA_CODIGO)
		    --2010-03-08
		    --AND MA_CODIGO not in (select ma_codigo from MAESTROALM WHERE MAA_FECHAREVISION>=convert(VARCHAR(10),getdate()-7,101))
		AND MA_ENUSO<>'N'
	end



























GO
