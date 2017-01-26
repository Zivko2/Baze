SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CONGELASUB] (@FE_CODIGO INT, @USER INT=1)   as

DECLARE @fefecha DATETIME, @fed_indiced int, @RestaDescargar decimal(38,6), @MA_HIJO int, @PIDINDICED int, @PIDSALDOGEN decimal(38,6),
@QtyADescargar decimal(38,6), @SaldoPedimento decimal(38,6), @fe_fecha varchar(11), @DI_PROD INT

  SELECT @fefecha=FE_FECHA, @fe_fecha=convert(varchar(11),fe_fecha,101), @DI_PROD=DI_PROD FROM FACTEXP WHERE FE_CODIGO=@FE_CODIGO
  EXEC SP_CreaVPIDescarga 'M', @fe_fecha, @DI_PROD

  DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-62
	
  if (select count(*)
  from (select sum(fed_cant*eq_gen) as CantExp, ma_codigo, fe_fecha
	from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo
	where factexpdet.fe_codigo=@FE_CODIGO
	group by fed_noparte, ma_codigo, fe_fecha, factexp.fe_codigo) feInfo
  where CantExp> ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)
			FROM VPIDescarga inner join pedimp on VPIDescarga.pi_codigo=pedimp.pi_codigo
			WHERE PID_SALDOGEN > 0 AND MA_CODIGO = feInfo.MA_CODIGO
			AND VPIDescarga.PI_FEC_ENT <= feInfo.fe_fecha) ,0))=0
  begin
 
	  DECLARE curCongelaMP CURSOR FOR
			select fed_indiced, fed_cant*eq_gen, ma_codigo
			from factexpdet
			where fe_codigo=@FE_CODIGO
			ORDER BY ma_codigo
	
	  OPEN curCongelaMP
	  FETCH NEXT FROM curCongelaMP INTO @fed_indiced, @RestaDescargar, @MA_HIJO
	  WHILE (@@fetch_status <> -1) 
	  BEGIN  --1
	    IF(@@fetch_status <> -2)
	    BEGIN --2
	
			DECLARE curPedimentos CURSOR FOR 
				SELECT PID_INDICED, PID_SALDOGEN
				FROM VPIDescarga 
				WHERE (PID_SALDOGEN > 0) AND(MA_CODIGO = @MA_HIJO) 
					AND (PI_FEC_ENT <= @fefecha) 
				ORDER BY PI_FEC_ENT ASC, PI_CODIGO ASC
	
		      OPEN curPedimentos
		      FETCH NEXT FROM curPedimentos INTO @PIDINDICED, @PIDSALDOGEN
		
		      WHILE (@@fetch_status <> -1)
		      BEGIN  --5
	
	
	
						if @RestaDescargar>0
						begin
							/*Aqui manipulamos las cantidades*/
							SET @QtyADescargar = ROUND(@RestaDescargar,6)   --Cantidad a descargar (o descargada)  = salod por descargar
							SET @SaldoPedimento = ROUND(ROUND(@PIDSALDOGEN,6) - round(@QtyADescargar,6),6) -- saldo posterior del ped = saldo actual menos cantidad a descargar
			
							
							IF(@SaldoPedimento < 0)  -- si saldo posterior es negativo
							BEGIN --7
								SET @RestaDescargar = ABS(@SaldoPedimento) -- cantidad que queda a descargar = al saldo negativo (absoluto)
								SET @QtyADescargar =  ROUND(@PIDSALDOGEN,6) -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
							END --7
							ELSE
							BEGIN --8
								SET @RestaDescargar = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
							END --8
	
							
						/*********************************/
							UPDATE PIDESCARGA
							SET PID_CONGELASUBMAQ=isnull(ISNULL(PID_CONGELASUBMAQ,0)+@QtyADescargar,0)
							WHERE PID_INDICED=@PIDINDICED
	
							INSERT INTO CONGELASUB(FE_CODIGO, FED_INDICED, PID_INDICED, COS_CANT)
							VALUES (@FE_CODIGO, @fed_indiced, @PIDINDICED, @QtyADescargar)
							
						end
	
										
					      FETCH NEXT FROM curPedimentos INTO @PIDINDICED, @PIDSALDOGEN	
					END  --5
					CLOSE curPedimentos
					DEALLOCATE curPedimentos
	
	
				  FETCH NEXT FROM curCongelaMP INTO @fed_indiced, @RestaDescargar, @MA_HIJO
	
			END --2
		END --1
		CLOSE curCongelaMP
		DEALLOCATE curCongelaMP
	
	
	
		UPDATE FACTEXPDET
		SET FED_DESCARGADO='S'
		WHERE FE_CODIGO=@FE_CODIGO
	
		UPDATE FACTEXP 
		SET FE_FECHADESCARGA=GETDATE(), FE_DESCARGADA='S', FE_ESTATUS='L'
		WHERE FE_CODIGO=@FE_CODIGO
  end
  else
  begin
	DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-62
	
	if (select count(*) from IMPORTLOG)=0
	DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS
	  INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
  	  SELECT     'NO SE PUEDEN CONGELAR SALDOS DEL NO. PARTE: ' + feInfo.fed_noparte + ' POR QUE NO EXISTE SALDO SUFICIENTE EN PEDIMENTOS (CANT. A CONGELAR:'+
		CONVERT(VARCHAR(50),CantExp)+
                ', CANT. DISPONIBLE:'+CONVERT(VARCHAR(50),ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)
				FROM VPIDescarga inner join pedimp on VPIDescarga.pi_codigo=pedimp.pi_codigo
				WHERE PID_SALDOGEN > 0 AND MA_CODIGO = feInfo.MA_CODIGO
				AND VPIDescarga.PI_FEC_ENT <= feInfo.fe_fecha) ,0)), -62
	  from (select fed_noparte, sum(fed_cant*eq_gen) as CantExp, ma_codigo, factexp.fe_codigo, fe_fecha
		from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo
		where factexpdet.fe_codigo=@FE_CODIGO
		group by fed_noparte, ma_codigo, fe_fecha, factexp.fe_codigo) feInfo
	  where CantExp> ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)
				FROM VPIDescarga inner join pedimp on VPIDescarga.pi_codigo=pedimp.pi_codigo
				WHERE PID_SALDOGEN > 0 AND MA_CODIGO = feInfo.MA_CODIGO
				AND VPIDescarga.PI_FEC_ENT <= feInfo.fe_fecha) ,0)

  end
GO
