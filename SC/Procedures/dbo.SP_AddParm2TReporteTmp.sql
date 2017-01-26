SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_AddParm2TReporteTmp (@inNombreReporte Varchar(50), @inNombreParametro Varchar(30), @inTipoDatoParam Varchar(25))   as
		INSERT INTO TReporteTmp(TRE_NOMBRE_RTM, TRE_LOOKUPFLD, TRE_LookUpFldDT) VALUES(@inNombreReporte, @inNombreParametro, @inTipoDatoParam)

RETURN



























GO
