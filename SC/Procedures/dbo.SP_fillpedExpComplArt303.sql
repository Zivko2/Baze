SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_fillpedExpComplArt303] (@PI_CODIGO int, @periodo char(1)='N')   as

SET NOCOUNT ON 
declare @cf_pagocontribdet char(1), @piorigen int


	select @cf_pagocontribdet=cf_pagocontribdet from configuracion

	if @periodo<>'S'
	begin
		declare cur_J1origen cursor for
			SELECT     PI_CODIGO
			FROM         dbo.PEDIMP
			WHERE     (PI_COMPLEMENTA = @PI_CODIGO)
		open cur_J1origen
		
			FETCH NEXT FROM cur_J1origen INTO @piorigen
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		
				if @cf_pagocontribdet='S'
				exec fillpedExpDetBArt303Fed @piorigen, 'S'
				else
				exec fillpedExpDetBArt303Comp @piorigen, 'S'
		
			FETCH NEXT FROM cur_J1origen INTO @piorigen
		
		END
		
		CLOSE cur_J1origen
		DEALLOCATE cur_J1origen
	end	


	IF NOT EXISTS (SELECT * FROM PEDIMPDETB WHERE PI_CODIGO=@PI_CODIGO)
	begin
		exec sp_fillpedimpdetB @PI_CODIGO, 1	/*inserta detalle B del pedimento */
	end


	-- actualiza la informacion de la tabla PEDIMPDETB en base a los generado por cada J1
	UPDATE PEDIMPDETB
	SET     PIB_ADVMNIMPMEX=isnull((SELECT SUM(PEDIMPDETBorig.PIB_ADVMNIMPMEX) 
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	PIB_EXCENCION=	isnull((SELECT SUM(PEDIMPDETBorig.PIB_EXCENCION)
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	 
	PIB_IMPORTECONTRSINRECARGOS= isnull((SELECT SUM(PEDIMPDETBorig.PIB_IMPORTECONTRSINRECARGOS) 
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	PIB_IMPORTERECARGOS= isnull((SELECT SUM(PEDIMPDETBorig.PIB_IMPORTERECARGOS) 
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	
	PIB_IMPORTECONTR= isnull((SELECT SUM(PEDIMPDETBorig.PIB_IMPORTECONTR) 
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	
	PIB_IMPORTECONTRUSD= isnull((SELECT SUM(PEDIMPDETBorig.PIB_IMPORTECONTRUSD) 
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	
	PIB_VALORMCIANOORIG= isnull((SELECT SUM(PEDIMPDETBorig.PIB_VALORMCIANOORIG)
				FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMPDET PEDIMPDETcompl ON dbo.PEDIMPDET.PID_INDICEDLIGA = PEDIMPDETcompl.PID_INDICED INNER JOIN
	                		      dbo.PEDIMPDETB PEDIMPDETBorig ON dbo.PEDIMPDET.PIB_INDICEB = PEDIMPDETBorig.PIB_INDICEB
				WHERE PEDIMPDETcompl.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0)
	WHERE PI_CODIGO=@PI_CODIGO




GO
