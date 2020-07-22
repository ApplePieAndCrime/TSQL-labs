/*
Тригер №1
Разработать триггер, запрещающий формировать покупки с количеством 
товара большим, чем есть на складе.


Тригер №2
Разработат триггер, который автоматически корректирует количество 
товара на складе при покупке или возврате товара. 
Товар считается возвращенным, если уменьшается его количество 
в записи о покупке или такая запись удаляется. 
В конце месяца количество товаров пополняется на 150% от количества 
купленных упаковок в месяц.
*/



use библиотека


if object_id('number_one') is not null
drop trigger number_one
go



create trigger number_one
on содержимое_покупки
instead of
insert, update
as
declare @code int
declare @count int
declare @buy_id int
declare @text varchar(50)
declare @cur cursor 
set @cur = cursor for select код_товара, Номер_покупки, Количество from inserted

open @cur
fetch next from @cur into @code, @buy_id, @count

while @@FETCH_STATUS=0
begin


if @count > (Select Количество_на_складе from товар where Код_товара=@code)
begin
print 'Запрещаю! Товара ' + @code + ' и так мало...'
end
else
begin
insert into Содержимое_покупки values(@code, @buy_id, @count)
print 'Товар ' + @code + ' успешно добавлен'
end
fetch next from @cur into @code, @buy_id, @count
end

close @cur
deallocate @cur


go


if object_id('number_two') is not null
drop trigger number_two
go



create trigger number_two
on содержимое_покупки
instead of
update, insert
as

declare @code int
declare @count int
declare @old_count int
declare @difference int
declare @buy_id int
declare @cur cursor
set @cur = cursor for select код_товара, Номер_покупки, Количество from inserted

open @cur
fetch next from @cur into @code, @buy_id, @count

while @@FETCH_STATUS=0
begin



/* авто пополнение в конце месяца  */
declare @date date
select @date = getdate()

if @date=(select eomonth(@date)) and (select count(Код_товара) from Содержимое_покупки с inner join покупка п on п.номер_покупки=с.Номер_покупки where Дата_покупки=@date)=0
begin	
	declare @autocount int
	select @autocount = sum(количество)*1.5 from Содержимое_покупки where Код_товара=@code
	declare @stock_count int
	select @stock_count = Количество_на_складе from товар where Код_товара=@code
	if @stock_count is null
		set @stock_count = 0
	update товар set Количество_на_складе=@stock_count+@autocount where Код_товара=@code
	print 'АВТООБНОВЛЕНИЕ! Количество товаров на складе увеличилось на ' + cast(@autocount as varchar(50))
end



/* */



select @old_count = (select количество from Содержимое_покупки where Код_товара=@code and Номер_покупки=@buy_id)
if @old_count is null
	set @old_count=0
set @difference = @old_count - @count


if @count > cast((select количество_на_складе from товар where Код_товара=@code) as int)
begin
	print 'Запрещаю! Товара ' + cast(@code as varchar(50)) + ' и так мало...'
	goto cont
	continue
	
end


if @difference=0
begin
	print 'Заказ ' + cast(@buy_id as varchar(50)) + ' не менялся'
	goto cont
	continue
end




if(select count(*) from Содержимое_покупки where Код_товара=@code and Номер_покупки=@buy_id)!=0
begin
	update Содержимое_покупки set Количество=@count where Код_товара=@code and Номер_покупки=@buy_id
	print 'Заказ ' + cast(@buy_id as varchar(50)) + ' изменён'
end
else
begin
	insert into Содержимое_покупки values (@code,@buy_id,@count)
	print 'Заказ ' + cast(@buy_id as varchar(50)) + ' добавлен'
end
update товар set Количество_на_складе=Количество_на_складе+@difference where Код_товара=@code



if  @difference > 0
begin
print 'Количество товара ' + cast(@code as varchar(50)) + ' на складе увеличилось на ' + cast(@difference as varchar(50))
end


else if @difference < 0
begin
print 'Количество товара ' + cast(@code as varchar(50)) + ' на складе уменьшилось на ' + cast(@difference*(-1) as varchar(50))
end

cont:
fetch next from @cur into @code, @buy_id, @count
end

close @cur
deallocate @cur




go





if object_id('number_three') is not null
drop trigger number_three
go



create trigger number_three
on содержимое_покупки
instead of
delete
as

declare @code int
declare @count int
declare @old_count int
declare @difference int
declare @buy_id int
declare @cur cursor

set @cur = cursor for select код_товара, Номер_покупки, Количество from deleted

open @cur
fetch next from @cur into @code, @buy_id, @count

while @@FETCH_STATUS=0
begin


set @difference = cast(@count as int)

delete Содержимое_покупки where Количество=@count and Код_товара=@code and Номер_покупки=@buy_id
update товар set Количество_на_складе=Количество_на_складе+@count where Код_товара=@code

print 'Заказ ' + cast(@buy_id as varchar(50)) + ' успешно удален: количество товара ' + cast(@code as varchar(50)) + ' на складе увеличилось на ' + cast(@difference as varchar(50))


fetch next from @cur into @code, @buy_id, @count
end

close @cur

deallocate @cur

go







if object_id('number_four') is not null
drop trigger number_four
go



create trigger number_four
on покупка
instead of
delete
as

declare @buy_id int
declare @cur cursor

set @cur = cursor for select Номер_покупки from deleted

open @cur
fetch next from @cur into @buy_id

while @@FETCH_STATUS=0
begin
	delete from Содержимое_покупки where Номер_покупки=@buy_id
	fetch next from @cur into @buy_id
end

close @cur

deallocate @cur

go

