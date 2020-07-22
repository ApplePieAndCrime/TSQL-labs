/*
1. Создать функцию, возвращающую суммарное количество упаковок товара,
реализованное заданным продавцом.
2. Создать функцию, возвращающую список покупателей, чаще всего совершающих
покупки.
3. Создать функцию, возвращающую количество подкатегорий для каждой категории
товара.
*/

use библиотека
go


if object_id('f3') is not null
drop function f3
go


Create function f3() 
returns @t table (Код_категории int, Количество_подкатегорий int) 
as 
begin 

declare @count int
declare @num int
----------------для стэка---------------------
declare @stack table (id int, label int)	--
declare @n int								--
declare @length int							--
----------------------------------------------

insert into @t(код_категории) (select distinct к.код_категории from категория_товара к)
--наполнение @t
while ((select count(*) from @t where Количество_подкатегорий is null)!=0)
begin

--обновление значений---------------------------------------------------------
set @num = (select top 1 код_категории from @t where Количество_подкатегорий is null)	--
set @count = 0																--
delete @stack																--
------------------------------------------------------------------------------
--наполнение стэка
insert into @stack(id) values (@num)

while ((select count(*) from @stack where label is null)!=0)
	begin
	--считаю сколько вершин в стеке
	select @length = count(*) from @stack
	-- беру ближайшую вершину из стэка
	select @n =(select top 1 id from @stack where label is null)
	-- ищу и добавляю ее смежные
	insert into @stack(id)
		(select код_категории from Категория_товара к	
		 where к.код_ссылки=@n and к.код_категории not in 
			(select id from @stack)
		)
	-- помечаю вершину как пройденную
	update @stack set label=1 where id=@n
	-- проверка: является ли вершина конечной? (прибавились ли смежные с ней вершины в стэк) и не равна ли первой
	if(@length=(select count(*) from @stack) and @length!=1)
	begin
	set @count = @count + 1
	end


update @t set Количество_подкатегорий = @count where код_категории=@num

end

end
return end 

go
 
Select * from dbo.f3() 
