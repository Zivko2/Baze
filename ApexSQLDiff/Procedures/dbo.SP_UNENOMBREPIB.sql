SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_UNENOMBREPIB]  (@PI_CODIGO INT)   as

SET NOCOUNT ON 
Declare @X varchar(8000),@POS int

	Select PI_CODIGO,PIB_INDICEB,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(RTRIM(PID_NOMBRE)),'O','O'),'A','A'),'','E'),'I','I'),'U','U')  AS PID_NOMBRE
	Into dbo.[#TempNombre] 
	From pedimpdet 
	where pi_codigo=@PI_CODIGO and not PID_NOMBRE is NULL and PID_NOMBRE <>''
	GROUP BY PI_CODIGO,PIB_INDICEB,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(RTRIM(PID_NOMBRE)),'O','O'),'A','A'),'','E'),'I','I'),'U','U') 
	Order by PIB_INDICEB
	
	SET @X=''
	SET @POS=0
	
	Update #TempNombre 
	SET PID_NOMBRE=@X,@X=CASE WHEN @POS = PIB_INDICEB THEN @X+', '+PID_NOMBRE ELSE PID_NOMBRE END,@POS=CASE WHEN @POS = PIB_INDICEB THEN @POS ELSE PIB_INDICEB END
	Where pi_codigo=@PI_CODIGO 
	

	Update PedImpDetb
	SET PIB_NOMBRE=left((select max(pid_nombre)
			from #TempNombre T1 where T1.pib_indiceb=PedImpDetb.pib_indiceb
			and len(T1.pid_nombre) in (select max(len(T2.pid_nombre)) from #TempNombre T2
						where T2.pib_indiceb=T1.pib_indiceb)),250)
	Where PedImpDetb.pi_codigo=@PI_CODIGO

GO
