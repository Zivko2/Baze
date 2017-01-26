SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillsysusrlogHist] (@fechaHoraNva varchar(25), @TAG int)   as

declare @TAGT varchar(50)

select @TAGT=convert(varchar(50),@TAG)

exec('if exists (select * from sysusrlog'+@TAGT+'  where fechahora <= '''+@fechaHoraNva+''' )
begin


			insert into sysusrlog'+@TAGT+'Hist(user_id, mov_id, referencia, frmtag, fechahora, sysusrlog_id)
			select user_id, mov_id, referencia, frmtag, fechahora, sysusrlog_id
			from sysusrlog'+@TAGT+'
			where sysusrlog_id in (SELECT sysusrlog_id
					FROM         sysusrlog'+@TAGT+' 
					where fechahora <= '''+@fechaHoraNva+''') 
			and sysusrlog_id not in
			(select sysusrlog_id from sysusrlog'+@TAGT+'Hist)

			delete from sysusrlog'+@TAGT+' where sysusrlog_id in
			(SELECT    sysusrlog_id
					FROM         sysusrlog'+@TAGT+'
					where fechahora <= '''+@fechaHoraNva+''')
			 and sysusrlog_id in (select sysusrlog_id from sysusrlog'+@TAGT+'Hist)

end')



















GO
