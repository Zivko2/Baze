SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE [dbo].[SP_temp_rect_imp]   as

SET NOCOUNT ON 

DECLARE @PI_CODIGO INT, @PI_NO_RECT INT

	if exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
	                      dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
	WHERE     (dbo.sysobjects.name = N'PEDIMP') AND (dbo.syscolumns.name = N'PI_NO_RECT'))
	exec('DECLARE CUR_PEDIMP CURSOR FOR
	SELECT PI_CODIGO,PI_NO_RECT FROM PEDIMP WHERE PI_NO_RECT<> -1 and PI_NO_RECT<> 0
	OPEN CUR_PEDIMP
	FETCH NEXT FROM CUR_PEDIMP INTO @PI_CODIGO,@PI_NO_RECT
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	  INSERT INTO PEDIMPRECT (PI_CODIGO,PI_NO_RECT) VALUES (@PI_CODIGO,@PI_NO_RECT)
	  UPDATE FACTIMP SET PI_RECTIFICA=@PI_NO_RECT WHERE PI_CODIGO=@PI_CODIGO
	  FETCH NEXT FROM CUR_PEDIMP INTO @PI_CODIGO,@PI_NO_RECT
	END
	UPDATE PEDIMP SET PI_RECTESTATUS = ''R'' WHERE PI_ESTATUS=''R''
	
	
	CLOSE CUR_PEDIMP
	DEALLOCATE CUR_PEDIMP')
	


























GO
