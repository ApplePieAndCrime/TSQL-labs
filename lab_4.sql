/*
1. ������� �������, ������������ ��������� ���������� �������� ������,
������������� �������� ���������.
2. ������� �������, ������������ ������ �����������, ���� ����� �����������
�������.
3. ������� �������, ������������ ���������� ������������ ��� ������ ���������
������.
*/

use ����������
go


if object_id('f3') is not null
drop function f3
go


Create function f3() 
returns @t table (���_��������� int, ����������_������������ int) 
as 
begin 

declare @count int
declare @num int
----------------��� �����---------------------
declare @stack table (id int, label int)	--
declare @n int								--
declare @length int							--
----------------------------------------------

insert into @t(���_���������) (select distinct �.���_��������� from ���������_������ �)
--���������� @t
while ((select count(*) from @t where ����������_������������ is null)!=0)
begin

--���������� ��������---------------------------------------------------------
set @num = (select top 1 ���_��������� from @t where ����������_������������ is null)	--
set @count = 0																--
delete @stack																--
------------------------------------------------------------------------------
--���������� �����
insert into @stack(id) values (@num)

while ((select count(*) from @stack where label is null)!=0)
	begin
	--������ ������� ������ � �����
	select @length = count(*) from @stack
	-- ���� ��������� ������� �� �����
	select @n =(select top 1 id from @stack where label is null)
	-- ��� � �������� �� �������
	insert into @stack(id)
		(select ���_��������� from ���������_������ �	
		 where �.���_������=@n and �.���_��������� not in 
			(select id from @stack)
		)
	-- ������� ������� ��� ����������
	update @stack set label=1 where id=@n
	-- ��������: �������� �� ������� ��������? (����������� �� ������� � ��� ������� � ����) � �� ����� �� ������
	if(@length=(select count(*) from @stack) and @length!=1)
	begin
	set @count = @count + 1
	end


update @t set ����������_������������ = @count where ���_���������=@num

end

end
return end 

go
 
Select * from dbo.f3() 
