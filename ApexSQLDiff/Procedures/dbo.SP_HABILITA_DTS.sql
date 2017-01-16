SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_HABILITA_DTS]   as


		UPDATE    DTS
	SET              DTS_ENUSO = 'N'
	WHERE     (DTS_ENUSO = 'S')



























GO
