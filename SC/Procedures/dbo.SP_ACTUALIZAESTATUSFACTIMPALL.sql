SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSFACTIMPALL]   as

SET NOCOUNT ON 

	ALTER TABLE [FACTIMP]  DISABLE TRIGGER [UPDATE_FACTIMP]


	UPDATE FACTIMP
	SET PI_CODIGO=-1 WHERE
	PI_CODIGO NOT IN (SELECT PI_CODIGO FROM PEDIMP)



			update factimp 
			set fi_estatus = 'A' 
			where fi_cancelado='S' -- A	= Cancelada 
			and fi_estatus <> 'A' 

			update factimp 
			set fi_estatus = 'T' 
			where fi_cancelado='N' and fi_tipo='T' -- T = Transformadores
			and fi_estatus <> 'T'

			update factimp 
			set fi_estatus = 'S' 
			where pi_codigo < 0 and fi_cancelado='N' -- S = Sin Pedimento 
			and fi_tipo<>'T' and fi_estatus <> 'S' 


			update factimp 
			set fi_estatus = 'C' 
			where pi_codigo > 0 and fi_cancelado='N' --- C	 = Con Pedimento
			and fi_tipo<>'T' and fi_estatus <> 'C'


			update factimp 
			set fi_estatus = 'C' 
			where pi_rectifica > 0 and fi_cancelado='N' --- C	 = Con Pedimento
			and fi_tipo<>'T' and fi_estatus <> 'C'

	ALTER TABLE [FACTIMP]  ENABLE TRIGGER [UPDATE_FACTIMP]


GO
