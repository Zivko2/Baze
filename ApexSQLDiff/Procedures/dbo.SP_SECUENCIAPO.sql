SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_SECUENCIAPO]  (@PI_CODIGO INT)   as

SET NOCOUNT ON 
Declare @X Int,@POS Varchar(100)

	if (SELECT PICF_SAAIDETDIVPO FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@PI_CODIGO)='S'
	begin

		Select PID_INDICED,PI_CODIGO,PID_ORD_COMP,PID_POSECUENCIA 
		Into dbo.[#TempX] 
		From pedimpdet 
		where pi_codigo=@PI_CODIGO and not PID_ORD_COMP is NULL
		Order by PID_ORD_COMP,PID_INDICED
		
		SET @X=0
		SET @POS=''
		
		Update #Tempx 
		SET PID_POSECUENCIA=@X,@X=CASE WHEN @POS = PID_ORD_COMP THEN @X+1 ELSE 1 END,@POS=CASE WHEN @POS = PID_ORD_COMP THEN @POS ELSE PID_ORD_COMP END
		Where pi_codigo=@PI_CODIGO 
		
		
		Update PedImpDet 
		SET PID_POSECUENCIA=T.PID_POSECUENCIA 
		From #Tempx T inner join pedimpdet on T.Pid_indiced=pedimpdet.pid_indiced
		Where PedImpDet.pi_codigo=@PI_CODIGO 

	end




GO
