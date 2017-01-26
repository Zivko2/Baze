SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_NAFTACICLO]   as

--SET NOCOUNT ON 
declare @BST_PT int, @BST_ENTRAVIGOR VARCHAR(11)


	SELECT @BST_ENTRAVIGOR=convert(varchar(11),getdate(),101)


	EXEC SP_DROPTABLE 'BOMCICLO'

	
		
	SELECT    0 AS BST_PT, '01/01/9999' AS ENTRAVIGOR
	INTO dbo.BOMCICLO

	TRUNCATE TABLE BOMCICLO

		/* explosion de subensambles */
		declare CUR_NAFTACICLO cursor for
			SELECT    DISTINCT( MA_CODIGO)
			FROM ##MACODIGO

		 OPEN CUR_NAFTACICLO
		
		
			FETCH NEXT FROM CUR_NAFTACICLO INTO @BST_PT
			
		
		  WHILE (@@fetch_status = 0) 
		  BEGIN  

				EXEC SP_BOMCICLO @BST_PT, @BST_ENTRAVIGOR
	

		
		
			FETCH NEXT FROM CUR_NAFTACICLO INTO @BST_PT
		END
		
		CLOSE CUR_NAFTACICLO
		DEALLOCATE CUR_NAFTACICLO




		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA)
		SELECT 'NO. PARTE : ' +MA_NOPARTE+' CON ESTRUCTURA(BOM) CICLADA', -88,  ma_codigo
		FROM MAESTRO WHERE MA_CODIGO in (select distinct(bst_pt) from BOMCICLO where bst_pt<>0)

GO
