SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























/* esta vista sirve para hacer el lookup de entries en la forma Fast */
CREATE VIEW dbo.VENTRYSUMFAST
with encryption as
SELECT     CONVERT(varchar(100), ENTRYSUM.ET_CODIGO) + 'N' CODIGOTIPO, ET_ENTRY_NO
FROM         dbo.ENTRYSUM
UNION
SELECT     CONVERT(varchar(100), ENTRYCONS.ETC_CODIGO) + 'P', ETC_ENTRY_NO
FROM         dbo.ENTRYCONS



































GO
