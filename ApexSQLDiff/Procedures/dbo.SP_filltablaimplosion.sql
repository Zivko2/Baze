SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_filltablaimplosion] (@BST_HIJO Int)   as


declare @bsu_pt int, @CFT_TIPO char(1) , @BST_PERINI datetime, @entravigor varchar(10)


Select @entravigor=convert(varchar(10),getdate(),101)

if not exists (select * from dbo.sysobjects where name='tempImplosion')
create table [dbo].[tempImplosion]
( bsu_subensamble int,
bst_hijo int)


if exists (select * from tempImplosion WHERE bst_hijo = @BST_HIJO)
DELETE FROM tempImplosion WHERE bst_hijo = @BST_HIJO


			insert into tempImplosion(bst_hijo, Bsu_subensamble)

			SELECT     bst_hijo, bsu_subensamble
			from bom_struct
			where bst_hijo= @BST_HIJO and bst_perini<=@entravigor 
			and bst_perfin >=@entravigor 
			group by  bsu_subensamble, bst_hijo
			ORDER BY bsu_subensamble


declare CUR_TABLAIMPLOSION cursor for

	SELECT    bsu_subensamble
	from bom_struct
	where bst_hijo= @BST_HIJO and bst_perini<=@entravigor and
	bst_perfin >=@entravigor 
--	and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='S' or cft_tipo='P')
	and bsu_subensamble in (select bst_hijo from bom_struct)
	group by  bsu_subensamble
	ORDER BY bsu_subensamble


 OPEN CUR_TABLAIMPLOSION


	FETCH NEXT FROM CUR_TABLAIMPLOSION INTO @bsu_pt

  WHILE (@@fetch_status = 0) 

  BEGIN  

			exec  SP_filltablaimplosion1 @BST_HIJO, @bsu_pt, @entravigor


	FETCH NEXT FROM CUR_TABLAIMPLOSION INTO @bsu_pt

END

	CLOSE CUR_TABLAIMPLOSION
	DEALLOCATE CUR_TABLAIMPLOSION




GO
