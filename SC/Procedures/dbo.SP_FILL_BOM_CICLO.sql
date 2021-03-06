SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[SP_FILL_BOM_CICLO] (@BST_PT Int, @BST_ENTRAVIGOR datetime/*, @MENSAJE1 char(1)='N' output*/) as
--SET NOCOUNT ON 
declare @BST_HIJO int



--set @MENSAJE1='N'


		/* explosion de subensambles */
		declare CUR_BOMSTRUCT cursor for
			SELECT     dbo.BOM_STRUCT.BST_HIJO
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO 
					LEFT OUTER JOIN dbo.MAESTROREFER ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO CONFIGURATIPO2 ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPO2.TI_CODIGO
			WHERE   (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
				AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
				AND (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'S') 
				AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'C') AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'P')
				AND dbo.BOM_STRUCT.BST_INCORPOR >0
				--AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE NOT IN (SELECT BOM_STRUCTA.BST_HIJO FROM BOM_STRUCT BOM_STRUCTA GROUP BY BOM_STRUCTA.BST_HIJO))
				AND dbo.BOM_STRUCT.BST_HIJO NOT IN (SELECT BST_HIJO FROM BOMCICLO WHERE ENTRAVIGOR=@BST_ENTRAVIGOR)
			GROUP BY dbo.BOM_STRUCT.BST_HIJO
		
		 OPEN CUR_BOMSTRUCT
		
		
			FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO
			
		
		  WHILE (@@fetch_status = 0) 
		  BEGIN  
				

				exec  SP_FILL_BOM_CICLO1 @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, 1--, @mensaje=@MENSAJE1 output
	

	
				/*if @MENSAJE1='S'
				begin				
					break
				end*/
		
		
			FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO
		END
		
		CLOSE CUR_BOMSTRUCT
		DEALLOCATE CUR_BOMSTRUCT
GO
