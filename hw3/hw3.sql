-- Demo1 for Q12 and Q13
create table if not exists Violation (
  id integer primary key,
  A text,
  B integer,
  C integer,
  D integer
);

insert into Violation (A, B, C, D)
values
('a',1, 50, 51),
('b',2, 60, 61),
('c',3, 70, 71),
('c',9, 80, 81),
('d',4, 90, 91),
('d',8, 100, 101),
('d',16, 110, 111),
('e',5, 120, 121);

create table if not exists NoViolation (
  id integer primary key,
  A text,
  B integer,
  C integer,
  D integer
);

insert into NoViolation (A, B, C, D)
values
('a',1, 20, 10),
('b',2, 30, 11),
('c',3, 40, 12),
('d',4, 50, 13),
('e',5, 60, 14);

-- return the attributes A that cannot determine B

-- returns attributes c, d since FD A->B does NOT hold for them
select A from Violation
group by A
having count(distinct B)>1;

-- returns NOTHING, meaning that FD A->B holds
select A from NoViolation
group by A
having count(distinct B)>1;

/*
-- Alternative:
-- return the number of attributes A that cannot determine B

-- returns 2 for c, d which are violation cases
select count(distinct A) from
    (select r1.A
    from Violation as r1
    join Violation as r2
    on r1.A = r2.A and r1.B <> r2.B);

-- returns 0, indicating NO violation cases
select count(distinct A) from
    (select r1.A
    from NoViolation as r1
    join NoViolation as r2
    on r1.A = r2.A and r1.B <> r2.B);*/
