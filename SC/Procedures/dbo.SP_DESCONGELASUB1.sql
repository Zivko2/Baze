SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DESCONGELASUB1] (@FI_CODIGO INT, @USER INT=1)   as

DECLARE @fifecha varchar(11), @fed_indiced int, @RestaDescargar decimal(38,6), @MA_HIJO int, @PIDINDICED int, @PIDSALDOGEN decimal(38,6),
@QtyADescargar decimal(38,6), @SaldoPedimento decimal(38,6), @cl_codigo int, @COS_CODIGO INT


  SELECT @fifecha=convert(varchar(11),FI_FECHA,101), @cl_codigo=pr_codigo FROM FACTIMP WHERE FI_CODIGO=@FI_CODIGO


  EXEC SP_CreaVPIDescargaSub 'M', @fifecha



  if (select count(*)
  from (select round(sum(fed_cant*factconv*bst_incorpor),6) as CantExp, bst_hijo
		from factimpdet inner join bom_desctemp on factimpdet.fid_indiced=bom_desctemp.fed_indiced 
		where factimpdet.fi_codigo=@FI_CODIGO
		group by fid_noparte, bst_hijo) fiInfo
  where CantExp> ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)
			FROM VPIDescargaSub inner join pedimp on VPIDescargaSub.pi_codigo=pedimp.pi_codigo
			WHERE PID_SALDOGEN > 0 AND MA_CODIGO = fiInfo.bst_hijo) ,0))=0

  begin

	  DECLARE curDescongelaMP CURSOR FOR
			select fed_indiced, round(fed_cant*factconv*bst_incorpor,6), bst_hijo
			from bom_desctemp
			where fe_codigo=@FI_CODIGO
			ORDER BY bst_hijo
	
	  OPEN curDescongelaMP
	  FETCH NEXT FROM curDescongelaMP INTO @fed_indiced, @RestaDescargar, @MA_HIJO
	  WHILE (@@fetch_status <> -1) 
	  BEGIN  --1
	    IF(@@fetch_status <> -2)
	    BEGIN --2


			DECLARE curDescongelaPed CURSOR FOR 
				SELECT     CONGELASUB.PID_INDICED, CONGELASUB.COS_CANT, CONGELASUB.COS_CODIGO
				FROM         CONGELASUB INNER JOIN
				      FACTEXP ON CONGELASUB.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
				      PIDescarga ON CONGELASUB.PID_INDICED = PIDescarga.PID_INDICED
				WHERE     (FACTEXP.CL_DESTINI = @cl_codigo) AND (PIDescarga.PI_FEC_ENT <= @fifecha) and PIDescarga.MA_CODIGO=@MA_HIJO
				AND CONGELASUB.COS_CANT>0
	
		      OPEN curDescongelaPed
		      FETCH NEXT FROM curDescongelaPed INTO @PIDINDICED, @PIDSALDOGEN, @COS_CODIGO
		
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
						SET PID_CONGELASUBMAQ=isnull(ISNULL(PID_CONGELASUBMAQ,0)-@QtyADescargar,0)
						WHERE PID_INDICED=@PIDINDICED

						INSERT INTO DESCONGELASUB(FI_CODIGO, FID_INDICED, PID_INDICED, DOS_CANT)
						VALUES (@FI_CODIGO, @fed_indiced, @PIDINDICED, @QtyADescargar)
						
						UPDATE CONGELASUB
						SET COS_CANT=COS_CANT-@QtyADescargar
						WHERE COS_CODIGO=@COS_CODIGO


					end

									
				      FETCH NEXT FROM curDescongelaPed INTO @PIDINDICED, @PIDSALDOGEN, @COS_CODIGO	
				END  --5
				CLOSE curDescongelaPed
				DEALLOCATE curDescongelaPed


			  FETCH NEXT FROM curDescongelaMP INTO @fed_indiced, @RestaDescargar, @MA_HIJO

		END --2
	END --1
	CLOSE curDescongelaMP
	DEALLOCATE curDescongelaMP

	UPDATE FACTIMP
	SET PI_CODIGO=0, FI_ESTATUS='L'
	WHERE FI_CODIGO=@FI_CODIGO

   end
   else
   begin
	DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-44
	
	if (select count(*) from IMPORTLOG)=0
	DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS



	  INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	  SELECT     'NO SE PUEDEN DESCONGELAR SALDOS DEL NO. PARTE: ' + fiInfo.ma_noparte + ' POR QUE NO EXISTE SALDO CONGELADO SUFICIENTE EN PEDIMENTOS (CANT. A DESCONGELAR:'+
		CONVERT(VARCHAR(50),CantExp)+
		', CANT. DISPONIBLE CONGELADA:'+CONVERT(VARCHAR(50),ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)
				FROM VPIDescargaSub inner join pedimp on VPIDescargaSub.pi_codigo=pedimp.pi_codigo
				WHERE PID_SALDOGEN > 0 AND MA_CODIGO = fiInfo.bst_hijo) ,0))+')', -44
	  from (SELECT     dbo.MAESTRO.ma_noparte, ROUND(SUM(dbo.BOM_DESCTEMP.FED_CANT * dbo.BOM_DESCTEMP.FACTCONV * dbo.BOM_DESCTEMP.BST_INCORPOR), 4) AS CantExp, 
	                      dbo.BOM_DESCTEMP.BST_HIJO
		FROM         dbo.FACTIMPDET INNER JOIN
		                      dbo.BOM_DESCTEMP ON dbo.FACTIMPDET.FID_INDICED = dbo.BOM_DESCTEMP.FED_INDICED INNER JOIN
		                      dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMPDET.FI_CODIGO = @FI_CODIGO)
		GROUP BY dbo.MAESTRO.ma_noparte, dbo.FACTIMPDET.FID_NOPARTE, dbo.BOM_DESCTEMP.BST_HIJO) fiInfo
	  where CantExp> ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)
				FROM VPIDescargaSub inner join pedimp on VPIDescargaSub.pi_codigo=pedimp.pi_codigo
				WHERE PID_SALDOGEN > 0 AND MA_CODIGO = fiInfo.bst_hijo) ,0)

/*

 	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'REPORTE DE PEDIMENTOS CONGELADOS', -44

 	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     '-----------------------------------------------------------------------', -44

 	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'PEDIMENTO CONGELADO: '+ AGENCIAPATENTE.AGT_PATENTE + '-' + PEDIMP.PI_FOLIO +' FECHA PAGO: '+CONVERT(VARCHAR(50),PEDIMP.PI_FEC_PAG,101)+' CLAVE: '+ CLAVEPED.CP_CLAVE+
		' NO. PARTE: '+MAESTRO.MA_NOPARTE+' CANTIDAD: '+CONVERT(VARCHAR(50),PIDESCARGA.PID_CONGELASUBMAQ), -44        
	FROM         PIDESCARGA INNER JOIN
	                      PEDIMP ON PIDESCARGA.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN
	                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
	                      AGENCIAPATENTE ON PEDIMP.AGT_CODIGO = AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
		        MAESTRO ON PIDESCARGA.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (PIDESCARGA.PID_CONGELASUBMAQ > 0) AND (PIDESCARGA.PI_FEC_ENT <= @fifecha)

*/

  end
GO
