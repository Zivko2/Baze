SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















CREATE VIEW dbo.vtiempos
with encryption as

SELECT referencia,fechahora,(select  us_nombre collate database_default +' '+us_paterno collate database_default from personal where sysusrlst_id=user_id) sysusername,
(SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog44 log1
WHERE     (log1.referencia = sysusrlog44.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44.user_id)) AS maximo,
(SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog44 log1
WHERE     (log1.referencia = sysusrlog44.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44.user_id)) AS minima,
DATEDIFF(mi, (SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog44 log1
WHERE     (log1.referencia = sysusrlog44.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44.user_id)), 
                      (SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog44 log1
WHERE     (log1.referencia = sysusrlog44.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44.user_id))) AS DIF, 44 as frmTag
from sysusrlog44
union
SELECT referencia,fechahora,(select  us_nombre collate database_default +' '+us_paterno collate database_default from personal where sysusrlst_id=user_id) sysusername,
(SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog44Hist log1
WHERE     (log1.referencia = sysusrlog44Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44Hist.user_id)) AS maximo,
(SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog44Hist log1
WHERE     (log1.referencia = sysusrlog44Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44Hist.user_id)) AS minima,
DATEDIFF(mi, (SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog44Hist log1
WHERE     (log1.referencia = sysusrlog44Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44Hist.user_id)), 
                      (SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog44Hist log1
WHERE     (log1.referencia = sysusrlog44Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog44Hist.user_id))) AS DIF, 44 as frmTag
from sysusrlog44Hist
union
SELECT referencia,fechahora,(select  us_nombre collate database_default +' '+us_paterno collate database_default from personal where sysusrlst_id=user_id) sysusername,
(SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog62 log1
WHERE     (log1.referencia = sysusrlog62.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62.user_id)) AS maximo,
(SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog62 log1
WHERE     (log1.referencia = sysusrlog62.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62.user_id)) AS minima,
DATEDIFF(mi, (SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog62 log1
WHERE     (log1.referencia = sysusrlog62.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62.user_id)), 
                      (SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog62 log1
WHERE     (log1.referencia = sysusrlog62.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62.user_id))) AS DIF, 62 as frmTag
from sysusrlog62
union
SELECT referencia,fechahora,(select  us_nombre collate database_default +' '+us_paterno collate database_default from personal where sysusrlst_id=user_id) sysusername,
(SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog62Hist log1
WHERE     (log1.referencia = sysusrlog62Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62Hist.user_id)) AS maximo,
(SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog62Hist log1
WHERE     (log1.referencia = sysusrlog62Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62Hist.user_id)) AS minima,
DATEDIFF(mi, (SELECT     MIN(log1.fechahora) 
FROM         dbo.sysusrlog62Hist log1
WHERE     (log1.referencia = sysusrlog62Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62Hist.user_id)), 
                      (SELECT     MAX(log1.fechahora) 
FROM         dbo.sysusrlog62Hist log1
WHERE     (log1.referencia = sysusrlog62Hist.referencia) AND (log1.mov_id <> 3) AND (log1.user_id = sysusrlog62Hist.user_id))) AS DIF, 62 as frmTag
from sysusrlog62Hist

























GO
