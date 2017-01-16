SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE PROCEDURE [dbo].[SP_ACTUALIZARELFACTRANS]  (@pi_exportacion int)   as

SET NOCOUNT ON 

declare @PI_FEC_ENT datetime, @MA_CODIGO int, @PID_CAN_GEN decimal(38,6), @SaldoDescargar decimal(38,6), @QtyTotDesc decimal(38,6),
@FED_SALDOTRANS decimal(38,6), @SaldoFactura decimal(38,6), @FED_INDICED int, @FE_CODIGO int, @PR_CODIGO int, @PID_INDICED INT

declare Cur_PedimentoTrans cursor for
	SELECT     dbo.VPEDEXP.PI_FEC_ENT, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_CAN_GEN, dbo.VPEDEXP.PR_CODIGO,
		dbo.PEDIMPDET.PID_INDICED
	FROM         dbo.PEDIMPDET INNER JOIN
	                      dbo.VPEDEXP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO
	WHERE     (dbo.VPEDEXP.PI_CODIGO = @pi_exportacion)


open Cur_PedimentoTrans


	FETCH NEXT FROM Cur_PedimentoTrans INTO @PI_FEC_ENT, @MA_CODIGO, @PID_CAN_GEN, @PR_CODIGO, @PID_INDICED

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		if exists (SELECT     dbo.FACTEXPDET.FED_INDICED
		FROM         dbo.FACTEXP INNER JOIN
		                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
		WHERE     (dbo.FACTEXP.FE_TIPO = 'C') AND (dbo.FACTEXP.FE_FECHA <= @PI_FEC_ENT) AND 
		                      (dbo.FACTEXPDET.MA_CODIGO = @MA_CODIGO) AND (dbo.FACTEXPDET.FED_SALDOTRANS > 0)
			and dbo.FACTEXP.CL_DESTINI=@PR_CODIGO)
		begin		


			SET @QtyTotDesc = @PID_CAN_GEN
			SET @SaldoDescargar = @QtyTotDesc

			declare cur_facturastrans cursor for
				SELECT     TOP 100 PERCENT dbo.FACTEXPDET.FED_SALDOTRANS, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FE_CODIGO
				FROM         dbo.FACTEXP INNER JOIN
				                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
				WHERE     (dbo.FACTEXP.FE_TIPO = 'C') AND (dbo.FACTEXP.FE_FECHA <= @PI_FEC_ENT) AND 
				                      (dbo.FACTEXPDET.MA_CODIGO = @MA_CODIGO) AND (dbo.FACTEXPDET.FED_SALDOTRANS > 0)
				and dbo.FACTEXP.CL_DESTINI=@PR_CODIGO
				ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
						
			
			open cur_facturastrans
			
			
				FETCH NEXT FROM cur_facturastrans INTO @FED_SALDOTRANS, @FED_INDICED, @FE_CODIGO
			
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN


					SET @PID_CAN_GEN = @SaldoDescargar   --Cantidad a descargar (o descargada)  = saldo por descargar
					SET @SaldoFactura = ROUND(@FED_SALDOTRANS - @PID_CAN_GEN,6) -- saldo posterior de la factura = saldo actual menos cantidad a descargar
						
					
					IF(@SaldoFactura < 0)  -- si saldo posterior es negativo
					BEGIN --7
						SET @SaldoDescargar = ABS(@SaldoFactura) -- cantidad que queda a descargar = al saldo negativo (absoluto)
						SET @PID_CAN_GEN =  @FED_SALDOTRANS -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
						SET @SaldoFactura = 0 --saldo de la factura =0
					END --7
					ELSE
					BEGIN --8
						SET @SaldoDescargar = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
					END --8
	

					UPDATE FACTEXP
					SET PI_TRANS=@pi_exportacion
					WHERE FE_CODIGO=@FE_CODIGO

					update factexpdet
					set fed_saldotrans=@SaldoFactura, fed_usotrans='S'
					where fed_indiced=@FED_INDICED
									

					update factexpdet
					set pid_indicedliga=@PID_INDICED
					where fed_indiced=@FED_INDICED					
	
				



					INSERT INTO PEDIMPRELTRANS (PID_INDICED, FED_INDICED, RET_CANTDESC, RET_ESTATUS)
					VALUES (@PID_INDICED, @FED_INDICED, @PID_CAN_GEN, 'D')


				EXEC SP_ACTUALIZAESTATUSFACTEXP @FE_CODIGO

		
				FETCH NEXT FROM cur_facturastrans INTO @FED_SALDOTRANS, @FED_INDICED, @FE_CODIGO
			
			END
			
			CLOSE cur_facturastrans
			DEALLOCATE cur_facturastrans
		end
		else
		begin
					INSERT INTO PEDIMPRELTRANS (PID_INDICED, FED_INDICED, RET_CANTDESC, RET_ESTATUS)
					VALUES (@PID_INDICED, 0, @PID_CAN_GEN, 'N')


		end		





	FETCH NEXT FROM Cur_PedimentoTrans INTO @PI_FEC_ENT, @MA_CODIGO, @PID_CAN_GEN, @PR_CODIGO, @PID_INDICED

END

CLOSE Cur_PedimentoTrans
DEALLOCATE Cur_PedimentoTrans


	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.FED_DESTNAFTA = dbo.PEDIMPDET.PID_REGIONFIN
	FROM         dbo.PEDIMPDET LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA
	WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_exportacion) AND (dbo.FACTEXPDET.FED_DESTNAFTA <> dbo.PEDIMPDET.PID_REGIONFIN)



/*	insert into PEDIMPFACT(PI_CODIGO, FI_CODIGO, FI_FOLIO, FI_FECHA, IT_CODIGO,
	 MO_CODIGO, PIF_VALMONEXT, PIF_FACTORMONEXT, PIF_VALDLLS, PR_CODIGO, DI_CODIGO)

	SELECT     dbo.FACTEXP.PI_CODIGO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.IT_COMPANY1, 
	                      dbo.FACTEXP.MO_CODIGO, SUM(dbo.FACTEXPDET.FED_COS_TOT) AS PIF_VALMONEXT, 1, SUM(dbo.FACTEXPDET.FED_COS_TOT) AS PIF_VALDLLS, 
	                      dbo.FACTEXP.CL_DESTINI, dbo.FACTEXP.DI_DESTINI
	FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
	WHERE     (dbo.FACTEXP.PI_CODIGO = @pi_exportacion) and dbo.FACTEXP.FE_CODIGO  not in (select fi_codigo from pedimpfact where pi_codigo=@pi_exportacion)
	GROUP BY dbo.FACTEXP.PI_CODIGO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.IT_COMPANY1, 
	                      dbo.FACTEXP.MO_CODIGO, dbo.FACTEXP.CL_DESTINI, dbo.FACTEXP.DI_DESTINI*/

--	if exists (select * from pedimpfact where pi_codigo=@pi_exportacion)
	update pedimp
	set pi_estatus='D'
	where pi_codigo=@pi_exportacion



































GO
