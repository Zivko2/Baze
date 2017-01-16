SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















































CREATE PROCEDURE [dbo].[SP_temp_bomarancel]   as

SET NOCOUNT ON 

if exists (select * from bom_arancel where ba_tipocosto='A')
update bom_arancel
set ba_tipocosto='1'
where ba_tipocosto='A'

if exists (select * from bom_arancel where ba_tipocosto='B')
update bom_arancel
set ba_tipocosto='6'
where ba_tipocosto='B'

if exists (select * from bom_arancel where ba_tipocosto='C')
update bom_arancel
set ba_tipocosto='2'
where ba_tipocosto='C'

if exists (select * from bom_arancel where ba_tipocosto='D')
update bom_arancel
set ba_tipocosto='7'
where ba_tipocosto='D'

if exists (select * from bom_arancel where ba_tipocosto='E')
update bom_arancel
set ba_tipocosto='8'
where ba_tipocosto='E'

if exists (select * from bom_arancel where ba_tipocosto='F')
update bom_arancel
set ba_tipocosto='3'
where ba_tipocosto='F'

if exists (select * from bom_arancel where ba_tipocosto='N')
update bom_arancel
set ba_tipocosto='5'
where ba_tipocosto='N'

if exists (select * from bom_arancel where ba_tipocosto='V')
update bom_arancel
set ba_tipocosto='5'
where ba_tipocosto='V'



























GO
