SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































































CREATE TRIGGER [DELETE_KARDESPEDCONT] ON dbo.KARDESPEDCONT 
FOR DELETE
AS


	if exists(select * from factexpcont where fec_indicec in (select fec_indicec from deleted))
	UPDATE FACTEXPCONT
	SET FEC_DESCARGADO='N'
	WHERE FEC_INDICEC IN (SELECT FEC_INDICEC FROM DELETED)

	if exists(select * from pedimpcont where pic_indicec in (select pic_indicec from deleted) and pic_indicec<>0)
	UPDATE PEDIMPCONT
	SET PIC_USO_DESCARGA='N'
	WHERE PIC_INDICEC IN (SELECT PIC_INDICEC FROM DELETED)
































































GO
