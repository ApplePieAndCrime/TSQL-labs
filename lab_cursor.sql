/*
С помощью курсора сформируйте чеки на покупки. 

На каждую покупку должен выводиться чек, содержащий товары и их стоимости, сгруппированные по категориям. 
Для каждого товара итоговая стоимость определяется исходя из количества товара в покупке.

В случае, если покупатель каждый месяц приобретал товары из определенной категории, то на все товары этой категории даётся скидка 10%. 

Если в чеке каждый из товаров соответствует отличной от других категории, формируется бонус - скидка на случайный товар из любой категории, представленной в чеке в размере 5% от суммы чека. 

Если в чеке встретились товары с одинаковыми наименованиями, но из различных категорий, то включить их в отдельную категорию "сопутствующие товары".
*/


use Библиотека



if object_id('tab_between') is not null
drop function tab_between
go


create function tab_between (@s1 varchar(50),@s2 varchar(50))
returns varchar(50)
as
begin
declare @s varchar(50)
set @s = @s1 + @s2

set @s = STUFF(@s, len(@s1)+1, 0, replicate(' ',50-len(@s)))
return @s

end
go

if object_id('tab_local_between') is not null
drop function tab_local_between
go


create function tab_local_between (@s1 varchar(70),@s2 varchar(70))
returns varchar(30)
as
begin
declare @s varchar(30)
set @s = @s1 + @s2

set @s = STUFF(@s, len(@s1)+1, 0, replicate(' ',30-len(@s)))
return @s

end
go

if object_id('tab_right') is not null
drop function tab_right
go


create function tab_right (@s varchar(50))
returns varchar(50)
as
begin
-- пробел поставила т.к. стаффу заменять нечего в конце строки
set @s = STUFF(@s+' ', len(@s)+1, 0, replicate(' ',50-len(@s)))
return @s
end
go



if object_id('tab_left') is not null
drop function tab_left
go


create function tab_left (@s varchar(50))
returns varchar(50)
as
begin
-- пробел поставила т.к. стаффу заменять нечего в конце строки
-- STUFF(строка, номер_начала, количество_заменяемых, заменяющий_символ)
set @s = STUFF(@s, 1, 0, replicate(' ',50-len(@s)))
return @s
end
go

if object_id('tab_around') is not null
drop function tab_around
go


create function tab_around (@s varchar(50))
returns varchar(50)
as
begin
declare @tab varchar(25)
set @tab = replicate(' ',25-len(@s)/2)

set @s = @tab + @s + @tab
return @s

end
go


if object_id('default_category') is not null
drop function default_category
go


create function default_category (@id int)
returns int
as
begin
declare @result int

while (select count(*) from Категория_товара where Код_категории=@id and Код_ссылки is not null)!=0
begin
select @result = Код_ссылки from Категория_товара where Код_категории=@id
select @id = @result
end

return @id

end
go




if object_id('is_regular') is not null
drop function is_regular
go

create function is_regular(@cust_id int, @category_id int, @date date)
returns bit
as
begin
declare @month int
declare @year int
declare @is_regular bit
set @is_regular = 1

declare @prev_month int

if(month(@date)>6)
begin
set @prev_month = month(@date)-6
set @year = year(@date)
end
else
set @prev_month = month(@date)+6
set @year = year(@date)-1




while @prev_month!=month(@date) and @year!=year(@date)
begin
select top 1 @month = month(дата_покупки) from покупка п
inner join содержимое_покупки с on п.номер_покупки = с.номер_покупки
inner join товар т on с.код_товара=т.код_товара 
where код_покупателя = @cust_id and dbo.default_category(код_категории) = @category_id
and month(дата_покупки)=@prev_month and year(Дата_покупки)=@year
order by дата_покупки

if @month is null
begin
	set @is_regular = 0
	break
end

set @prev_month = @prev_month + 1
if(@prev_month=13)
begin
set @prev_month = 1
set @year = @year+1
end

end

return @is_regular

end

go
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

declare @all_cat table (код int)
insert into @all_cat select Код_категории from Категория_товара where Код_ссылки is null

declare @cur cursor
declare @text varchar(50)
declare @date date 
declare @buy_id int
set @cur = cursor local scroll for
select Номер_покупки from покупка

open @cur
fetch next from @cur into @buy_id


while @@FETCH_STATUS=0
begin


-- КАТЕГОРИЯ
----------------------------------------------------------
declare @list_category table (код_категории int)
declare @product_list table (код_категории int, код_товара int, название varchar(50), количество int, цена decimal(10,2))
declare @group cursor 
declare @category int
declare @category_name varchar(50)
declare @regular bit
set @regular = 0
declare @is_all_categories bit

declare @cust_id int
select @cust_id = код_покупателя from покупка where Номер_покупки=@buy_id

declare @ran_id int
set @ran_id = -1

delete from @product_list
delete from @list_category





insert into @product_list(код_категории, код_товара, название, количество, цена) select dbo.default_category(т.Код_категории), с.код_товара, название, количество, Стоимость*количество as цена  from Содержимое_покупки с
inner join товар т on т.Код_товара=с.Код_товара
where Номер_покупки=@buy_id





if ((select count(*) from @product_list p1 where exists (select * from @product_list p2 where p1.код_категории!=p2.код_категории and p1.название=p2.название))) !=0
begin

update @product_list set код_категории=99 where код_товара in
(select код_товара from @product_list p1 where exists (select * from @product_list p2 where p1.код_категории!=p2.код_категории and p1.название=p2.название))
end

insert into @list_category select distinct код_категории from @product_list

-- ПРОВЕРКА НА ВСЕ КАТЕГОРИИ
if (select count (код_категории) from @product_list) = (select count(*) from @list_category) and (select count(*) from @list_category) > 1
begin
set @is_all_categories = 1
select top 1 @ran_id = код_товара from @product_list order by newid()
end

print ''
print ''
print ''
print  replicate('_',50)
select @date = cast(Дата_покупки as date) from покупка where Номер_покупки=@buy_id
select @text = convert(varchar(10), @date, 104)
print dbo.tab_left(@text)
set @text = dbo.tab_around ('ЧЕК № ' + convert(varchar(50), @buy_id))
print @text

set @group = cursor local scroll for
select код_категории from @list_category

open @group
fetch next from @group into @category

while @@FETCH_STATUS=0
begin

-- ТОВАР
--*********************
set @regular = 0

if (dbo.is_regular(@cust_id,@category, @date)=1)
begin
set @regular = 1
update @product_list set цена=цена-цена*0.1 where код_категории=@category
end

select @category_name = к.название from категория_товара к
inner join @product_list п on п.код_категории=к.код_категории
where п.Код_категории=@category
print replicate('-',50)


select @text = dbo.tab_right ('Категория: ' + (select название from категория_товара where Код_категории=@category))
print @text
print replicate('*',50)









declare @product cursor 
declare @product_id int
declare @product_name varchar(50)
declare @count int
declare @price money
set @product = cursor local scroll for
select код_товара,название, количество, цена from @product_list where код_категории=@category

open @product
fetch next from @product into @product_id,@product_name,@count,@price


while @@FETCH_STATUS=0
begin

select @product_name = т.название from товар т
inner join @product_list п on п.Код_товара=т.код_товара
where п.Код_товара=@product_id

if @product_id = @ran_id and @is_all_categories=1
begin
print dbo.tab_around('ОСТОРОЖНО! СЛУЧАЙНАЯ СКИДКА В 5% :)')
update @product_list set цена=цена-цена*0.05 where код_товара=@product_id
end

set @text = dbo.tab_local_between(cast(@product_id as varchar(50)) +' ' + rtrim(@product_name), convert(varchar(50),@count) + ' шт.   ')
print dbo.tab_between (@text , cast(@price as varchar(50)) + ' р.') 



fetch next from @product into @product_id,@product_name,@count,@price 
end
close @product
deallocate @product



if (@regular=1)
begin
print dbo.tab_left('СКИДКА - 10%')
end


fetch next from @group into @category
end

close @group
deallocate @group

--****************************
---------------------------------------------------------
fetch next from @cur into @buy_id

declare @sum decimal(10,2)
select @sum = sum(цена) from @product_list
print ''
print ''
print ''
print replicate('.-',25)
print dbo.tab_around('ВАША ПОКУПКА ВАЖНА ДЛЯ НАС')
print replicate('.-',25)
print ''
print dbo.tab_left ('ИТОГО: ' + cast(@sum as varchar(50)) + ' р.')
print replicate('_',50)
end

close @cur

deallocate @cur
