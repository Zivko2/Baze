SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VPEDEXPPERIODO
with encryption as
SELECT     'mes'=case when MONTH(FE_FECHA)=1 then 'ENERO' when MONTH(FE_FECHA)=2 then 'FEBRERO'
when MONTH(FE_FECHA)=3 then 'MARZO' when MONTH(FE_FECHA)=4 then 'ABRIL' when MONTH(FE_FECHA)=5 then 'MAYO'
when MONTH(FE_FECHA)=6 then 'JUNIO' when MONTH(FE_FECHA)=7 then 'JULIO' when MONTH(FE_FECHA)=8 then 'AGOSTO'
when MONTH(FE_FECHA)=9 then 'SEPTIEMBRE' when MONTH(FE_FECHA)=10 then 'OCTUBRE' when MONTH(FE_FECHA)=11 then 'NOVIEMBRE'
when MONTH(FE_FECHA)=12 then 'DICIEMBRE' end, YEAR(FE_FECHA) AS 'year', MONTH(FE_FECHA) as mesnum, PI_CODIGO, PI_RECTIFICA
FROM         dbo.FACTEXP

























































GO
