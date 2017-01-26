SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSREQUISICION] (@req_codigo int)   as

SET NOCOUNT ON 
DECLARE @cant decimal(38,6), @saldo decimal(38,6)

		SELECT     @CANT=SUM(REQD_CANT_ST), @SALDO=SUM(REQD_SALDO) 
		FROM         dbo.REQUISICIONDET
		WHERE     (REQ_CODIGO = @req_codigo)


	if (select req_cancelado from Requisicion where REQ_CODIGO = @req_codigo)='N'
	begin
		IF EXISTS (SELECT * FROM RequisicionDet
		   WHERE req_codigo = @req_codigo and reqd_enuso = 'S' ) 
		begin
		      if @cant = @saldo
			begin
			         UPDATE Requisicion 
			         SET Requisicion.req_estatus = 'E'  -- nueva orden
			          WHERE Requisicion.req_codigo = @req_codigo
             		                    if (select req_listaaproba from Requisicion where REQ_CODIGO = @req_codigo)='S'
				         UPDATE Requisicion 
				         SET Requisicion.req_estatus = 'R'  -- Requisicion para aprobar
				          WHERE Requisicion.req_codigo = @req_codigo
			      if (select count(AP_APROBADA)as NoAprobadas from aprobacion where req_codigo=@req_codigo and ap_aprobada='S') =(select count(AP_APROBADA) as NoPersonas from aprobacion where REQ_CODIGO=@req_codigo)
				         UPDATE Requisicion 
				         SET Requisicion.req_estatus = 'A'  -- Aprobada para orden compra
				          WHERE Requisicion.req_codigo = @req_codigo

			end
		        else	
			if @saldo>0
			begin
			         UPDATE Requisicion 
			         SET Requisicion.req_estatus = 'P'  -- en proceso
			          WHERE Requisicion.req_codigo = @req_codigo
			end
			else
			begin
			         UPDATE Requisicion 
			         SET Requisicion.req_estatus = 'C'  -- totalmente cumplida
			          WHERE Requisicion.req_codigo = @req_codigo
			end
		end
		else
                              begin
		         UPDATE Requisicion 
		         SET Requisicion.req_estatus = 'E'  -- nueva orden
		          WHERE Requisicion.req_codigo = @req_codigo
           		           if (select req_listaaproba from Requisicion where REQ_CODIGO = @req_codigo)='S'
			         UPDATE Requisicion 
			         SET Requisicion.req_estatus = 'R'  -- Requisicion para aprobar
			          WHERE Requisicion.req_codigo = @req_codigo
		            if (select count(AP_APROBADA)as NoAprobadas from aprobacion where req_codigo=@req_codigo and ap_aprobada='S') =(select count(AP_APROBADA) as NoPersonas from aprobacion where REQ_CODIGO=@req_codigo)
			         UPDATE Requisicion 
			         SET Requisicion.req_estatus = 'A'  -- Aprobada para orden compra
			          WHERE Requisicion.req_codigo = @req_codigo

                              end
	end
	else
	         UPDATE Requisicion 
	         SET Requisicion.req_estatus = 'K'  -- cancelada
	          WHERE Requisicion.req_codigo = @req_codigo
















































GO
