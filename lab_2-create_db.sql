/*
Создать базу данных «Библиотека». 
Для данных определить два файла: 
минимальный размер – 700 Мб, 
максимальный – 1,5 Мб, 
величина приращения – 200 Мб; 
для журнала транзакций определить один файл: 
минимальный размер – 50 Мб, 
максимальный – 500 Мб, 
величина приращения – 10%. 
*/
use master
go


if db_id('Библиотека') is not null 
drop database Библиотека
go

create database Библиотека
on primary

(
name=lib1,
filename='C:\lab2\lib1.mdf',
size=700 mb,
maxsize=1500 mb,
filegrowth=200 mb
),

(
name=lib2,
filename='C:\lab2\lib2.mdf',
size=700 mb,
maxsize=1500 mb,
filegrowth=200 mb
)

log on

(
name=lib_log,
filename='C:\lab2\lib_log.ldf',
size=50 mb,
maxsize=500 mb,
filegrowth=10 %
)
go
use Библиотека


create table Покупатель
(
Код_покупателя int primary key,
Фамилия char(20) null,
Имя char(20) ,
Отчество char(20) ,
Паспортные_данные char(50) , 
Домашний_адрес char(20) ,
Телефон char(11) 
)

create table Продавец
(
Код_продавца int primary key,
Фамилия char(20) null,
Имя char(20) null,
Отчество char(20) null,
Паспортные_данные char(50) null, 
Домашний_адрес char(20),
Телефон char(11) 
)

create table Покупка
(
Номер_покупки int not null primary key,
Дата_покупки datetime,
Код_покупателя int,
Код_продавца int,
foreign key (Код_покупателя) references Покупатель (Код_покупателя),
foreign key (Код_продавца) references Продавец (Код_продавца)
)

create table Категория_товара
(
Код_категории int primary key, -- прямая рекурсия
Код_ссылки int,
Название char(20),
Описание char(100)
)




alter table Категория_товара
add
foreign key (Код_ссылки) references категория_товара(код_категории)
go






create table Товар
(
Код_товара int primary key,
Название char(50),
Описание char(250),
Стоимость money,
Код_категории int null,
Количество_на_складе int,
foreign key (Код_категории) references категория_товара(Код_категории)
)

create table Содержимое_покупки
(
Код_товара int,
Номер_покупки int,
Количество int,
primary key(Код_товара, Номер_покупки),
foreign key (Код_товара) references Товар (Код_товара),
foreign key (Номер_покупки) references Покупка (Номер_покупки)
)


go
use master

