-- 1.
select
    cur_sp.ticker,
    cur_sp.date,
    cur_sp.adj_close,
    prev_sp.adj_close as prev_adj_close,
    cur_sp.adj_close-prev_sp.adj_close as price_change
from stock_prices cur_sp
left join stock_prices prev_sp -- left-join to keep nulls
on date(cur_sp.date, '-1 day')=prev_sp.date and
cur_sp.ticker = prev_sp.ticker
order by cur_sp.ticker, cur_sp.date; -- self-join for clean code




-- 2.
select *, ((adj_close-avg_adj_close)*100/avg_adj_close) || ' %' as percentage_fluctuation from
    (select ticker, date, adj_close,
           avg(adj_close) over (
               partition by ticker -- ticker sorted asc by default as well as date
               ) as avg_adj_close
    from stock_prices)
-- order by ticker, date
;




-- 3.
select *,
       rank() over(
           partition by ticker
           order by daily_fluctuation desc
           ) as fluct_rank
from
(select ticker, date, high, low, high-low as daily_fluctuation
from stock_prices) as t;




-- 4. Please query one by one
/*-- Pre-insertion check
select * from stock_prices
where ticker='AAPL' and date='2022-09-29' and high=1234.5; -- returns nothing*/

-- Insertion
insert into stock_prices (ticker, date, high)
values ('AAPL', '2022-09-29', 1234.5); -- insert as instructed

/*-- Post-insertion check
select * from stock_prices
where ticker='AAPL' and date='2022-09-29' and high=1234.5; -- returned row indicates successful insertion*/

-- Deletion
delete from stock_prices
where ticker='AAPL' and date='2022-09-29' and high=1234.5; -- delete

/*-- Post-deletion check
select * from stock_prices
where ticker='AAPL' and date='2022-09-29' and high=1234.5; -- nothing returned indicates successful deletion*/




-- 5. Please query one by one
-- create stock_prices2 with constraints
create table if not exists stock_prices2 (
    date text not null, -- not null enforced since date is part of primary key
    open real,
    high real,
    low real,
    close real,
    adj_close real,
    volume integer,
    ticker text not null,  -- not null enforced since date is part of primary key
    constraint StockPricesPK primary key (ticker, date)
);

-- insert all the data from stock_prices to stock_prices2
insert into stock_prices2
select * from stock_prices;




-- 6. Repeat the operation in Question 4
-- Insertion
insert into stock_prices2 (ticker, date, high)
values ('AAPL', '2022-09-29', 1234.5);

/*Got this error:
[19] [SQLITE_CONSTRAINT_PRIMARYKEY] A PRIMARY KEY constraint failed
(UNIQUE constraint failed: stock_prices2.ticker, stock_prices2.date)*/

/*
-- Double check NO successful insertion
select * from stock_prices2
where ticker='AAPL' and date='2022-09-29' and high=1234.5; -- nothing returned*/




-- 7. Please query step by step
/*
 Caution!
 After personal_library.db is created,
 PLEASE SWITCH SESSION for this database
 to prevent modifying the other databases
 (.db files) in the same folder
*/
-- create authors table
create table if not exists authors (
    authorid integer primary key autoincrement, -- optional autoincrement
    author_name text,
    author_DOB text
);

/*According to SQLite offical documentation,
autoincrement is optional (and can cause
extra overheads), while a column of type
INTEGER PRIMARY KEY is enough because it
becomes an alias for ROWID which increments
automatically.
Ref: https://www.sqlite.org/autoinc.html*/

-- create books table
create table if not exists books (
    bookid integer primary key autoincrement,
    title text,
    authorid integer references authors(authorid) deferrable initially deferred
);

-- enable foreign key support
pragma foreign_keys = on;

-- populate authors table
insert into authors (author_name, author_DOB)
values ('Ernest Hemingway','1899-07-01'), ('Willa Cather','1873-12-07');

-- populate books table
insert into books(title, authorid)
values ('For Whom the Bell Tolls',1), ('My Antonia',2);




-- 8. try adding a book written by a new author without adding the author
-- should cause an error
insert into books (title, authorid)
values ('The Golden Notebook',3);

/*Got this error:
[19] [SQLITE_CONSTRAINT_FOREIGNKEY] A foreign key constraint failed
(FOREIGN KEY constraint failed)*/




-- 9. bundle insertions of the book then the author in one transaction
-- taking advantage of deferred initial constraint check
begin transaction;
insert into books (title, authorid)
values ('The Golden Notebook',3);
insert into authors (author_name, author_DOB)
values ('Doris Lessing','1919-10-22');

commit; -- just in case autocommit is off

-- No errors generated

/*
-- Double check the transaction took effect
select * from authors
where author_name='Doris Lessing';

select * from books
where title='The Golden Notebook';*/