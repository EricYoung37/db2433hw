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
('a',1, 22, 33),
('a',2, 50, 60);

create table if not exists NoViolation (
  id integer primary key,
  A text,
  B integer,
  C integer,
  D integer
);

insert into NoViolation (A, B, C, D)
values
('a',1, 22, 33),
('b',2, 50, 60);

-- return the attributes of A that cannot determine B

-- returns attribute a since FD A->B does NOT hold for it
select A from Violation
group by A
having count(distinct B)>1;

-- returns NOTHING, meaning that FD A->B holds
select A from NoViolation
group by A
having count(distinct B)>1;

/*-- Alternative:
-- return the number of attributes of A that cannot determine B

-- returns 1 for a which is the violation case
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
