SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_GET_BOM_ASSEMBLYDATA(@ASSEMBLYID INTEGER, @PERINI datetime , @PERFIN datetime, @HISTORY VARCHAR(1))   as

BEGIN
     IF @HISTORY = 'H'
     BEGIN
	SELECT bs.*, m.MA_NOPARTE AS NOPARTPT, m2.MA_NOPARTE AS NOPART FROM BOM_STRUCT bs, MAESTRO m, MAESTRO m2 
	WHERE (BST_PERINI <= 1) AND     (BST_PERFIN >= 1) AND  (BSU_SUBENSAMBLE = 1) AND

 	-- moi  24agosto 2000  esta linea la comente para poder compilar el program.. no idea que le habra pasado a la columna original
           /* AND (bs.BMS_HIJO = m.MA_CODIGO) AND  */
	(bs.BSU_SUBENSAMBLE = m2.MA_CODIGO)
     END
     ELSE
     BEGIN
	SELECT bs.*, m.MA_NOPARTE AS NOPARTPT, m2.MA_NOPARTE AS NOPART
             FROM BOM_STRUCT bs, MAESTRO m, MAESTRO m2 
	WHERE  (BSU_SUBENSAMBLE = @ASSEMBLYID) and (bs.BST_HIJO = m.MA_CODIGO) AND (bs.BSU_SUBENSAMBLE = m2.MA_CODIGO)
     END
END



























GO
