--Задание 1
Declare @a int
Declare @b int
Declare @c int
Declare @d int
Declare @p int

Set @a=7698365
Set @d=1
Set @b=0


while @a<>0
begin
Set @c=@a-@a/10*10
Set @p=@a/10-@a/100*10

if @c>@p
begin
Set @b=@b+@c*@d
Set @d=@d*10
end
Set @a=@a/10
end
Print @b



--Задание 2

declare @x varchar(100) 
set @x = 'небольшой текст для работы' 
declare @x1 varchar(100) 
declare @k int 
declare @c int 
declare @t table(w varchar(100), c int) 
set @x1 = '' 
set @c = 0 
set @k = 1 


while @k <= len (@x) 
begin 
set @x1 = @x1 + SUBSTRING(@x,@k,1) 
if SUBSTRING(@x,@k,1) like '[цкнгшйщзхъфвпрлджчсмтьб]' 
Set @c=@c+1

if SUBSTRING(@x,@k,1) like ' ' 
begin 
insert into @t values(@x1, @c) 
set @x1 = '' 
Set @c=0 
end 
Set @k=@k+1 
end

insert into @t values(@x1, @c)
set @x1 = '' 
Set @c=0 

select * from @t

----------------------------------------------------

--Задание 2 с REPLACE

declare @x varchar(100) 
set @x = 'небольшой текст для работы' 
declare @t table(t1 varchar(100), t2 int) 


insert into @t(t1) select * from string_split(@x,' ')
update @t set t2 = len(t1)-len(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(t1,'б',''),'в',''),'г',''),'д',''),'ж',''),'з',''),'й',''),'к',''),'л',''),'м',''),'н',''),'п',''),'р',''),'с',''),'т',''),'ф',''),'х',''),'ц',''),'ч',''),'ш',''),'щ',''))
select * from @t
