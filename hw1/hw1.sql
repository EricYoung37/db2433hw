/* Answers:

   Q1: Frankfurt, Stuttgart

   Q2: 37.97

   Q3: 72

   Q4: 15

   Q5: Dominique Lefebvre

   Q6: A Luz De Tieta

   Q7: 6

   Q8: 19.7

   Q9: 8

   Q10: Metallica (ArtistId: 50), U2 (ArtistId: 150)

   Q11: Deep Waters

   Q12: 71

   Q13: Battlestar Galactica (Classic), Season 1 (AlbumId: 253)

   Q14: Berlin, London, Mountain View, Paris, Prague, São Paulo

*/

-- Q1 Ans:
-- Frankfurt, Stuttgart
select BillingCity from invoices
where BillingCountry='Germany'
group by BillingCity
having count(BillingCity) = -- cities with max count 2 (2nd most)
    (select max(cnt_tab2.Count) from -- max count 2 in count table 2
        (select BillingCity, count(BillingCity) as Count
        from invoices
        where BillingCountry='Germany'
        group by BillingCity) as cnt_tab2 -- count table by BCity
    where Count < -- max count 2 < max count 1
                (select max(cnt_tab1.Count) from -- max count 1 in count table 1
                    (select BillingCity, count(BillingCity) as Count
                    from invoices
                    where BillingCountry='Germany'
                    group by BillingCity) as cnt_tab1)); -- count table by BCity




-- Q2 Ans:
-- 37.97
select round(avg(TrackSum),2) from
    (select sum(TrackCount) as TrackSum
    from invoices
    join
        (select InvoiceId, count(TrackId) as TrackCount from invoice_items
        group by InvoiceId) as track_counts -- num of tracks per invoice
        on track_counts.InvoiceId=invoices.InvoiceId -- num of tracks per customer
    group by CustomerId);




-- Q3 Ans:
-- 72
select count(AlbumId) from -- count unique AlbumId with Classical Tracks
    (select AlbumId from tracks -- unique AlbumId with Classical Tracks
    where GenreId =
        (select GenreId from genres
        where Name='Classical') -- GenreId for Classical
    group by AlbumId); -- 1 Album may have N classical tracks




-- Q4 Ans:
-- 15
select count(InvoiceId) as PurchasedBN -- unique InvoiceId with BN tracks
from invoice_items,
    (select TrackId from tracks -- Bossa Nova tracks
    where GenreId =
        (select GenreId from genres
        where Name='Bossa Nova')) as bn_tracks -- GenreId for Bossa Nova
where bn_tracks.TrackId=invoice_items.TrackId;




-- Q5 Ans:
-- Dominique Lefebvre
select FirstName, LastName
from customers,
    (select CustomerId, max(count) from -- customer with max count
        (select CustomerId, count(CustomerId) as count -- CustomerId with Jazz invoices, count
        from invoices,
            (select InvoiceId -- InvoiceId with Jazz tracks
            from invoice_items,
                (select TrackId from tracks -- Jazz tracks
                    where GenreId =
                        (select GenreId from genres
                        where Name='Jazz')) as j_tracks-- GenreId for Jazz
            where j_tracks.TrackId = invoice_items.TrackId) as j_invoices
        where invoices.InvoiceId=j_invoices.InvoiceId
        group by CustomerId)) as cust_max
where customers.CustomerId=cust_max.CustomerId;




-- Q6 Ans:
-- A Luz De Tieta
select Name -- names of Brazilian tracks in alphabetical order
from tracks,
    (select TrackId -- Brazilian tracks
    from playlist_track,
        (select PlaylistId from playlists
        where Name like '%Brazilian%') as b_pl -- PlaylistId for Brazilian playlist
    where b_pl.PlaylistId=playlist_track.PlaylistId) as b_tracks
where tracks.TrackId=b_tracks.TrackId
order by Name limit 1,1; -- skip 1st row, get 1 row (2nd row)




-- Q7 Ans:
-- 6
select count(AlbumId) from -- number of albums with profit > 25
    (select AlbumId, sum(UnitPrice) as Profit from -- Profit by album
        (select tracks.AlbumId, tracks.UnitPrice -- albums with sold tracks
        from tracks, invoice_items
        where tracks.TrackId = invoice_items.TrackId)
    group by AlbumId)
where Profit > 25;




-- Q8 Ans:
-- 19.7
select round(avg(Count), 1) from
(select SupportRepId, count(SupportRepId) as Count from customers
group by SupportRepId); -- num of customers per rep




-- Q9 Ans:
-- 8
select count(GenreId) from -- number of genres with sales > 25
    (select GenreId, sum(UnitPrice) as Sales from -- sales by genre
        (select tracks.GenreId, tracks.UnitPrice -- genres with sold tracks
        from tracks, invoice_items
        where tracks.TrackId = invoice_items.TrackId)
    group by GenreId)
where Sales > 50;




-- Q10 Ans:
-- Metallica (ArtistId: 50), U2 (ArtistId: 150)
select Name
from artists,
    (select ArtistId as AId from albums-- artists with 4th largest count
    group by AId
    having count(AlbumId) =
        (select max(Count) from -- 4th largest count
            (select count(AlbumId) as Count from albums
            group by ArtistId)
        where Count <
            (select max(Count) from -- 3rd largest count
                (select count(AlbumId) as Count from albums
                group by ArtistId)
            where Count <
                (select max(Count) from -- 2nd largest count
                    (select count(AlbumId) as Count from albums
                    group by ArtistId)
                where Count <
                    (select max(Count) from -- largest count
                        (select count(AlbumId) as Count from albums
                        group by ArtistId))))))
where ArtistId=AId;

-- double check by reading
/*
select ArtistId, count(AlbumId) as Count  from albums
group by ArtistId
order by Count desc;*/




-- Q11 Ans:
-- Deep Waters
select Name from tracks -- track names with AId for 'BM'
where AlbumId=
    (select AlbumId from albums
    where Title='Blue Moods') -- AlbumId for 'Blue Moods'
order by Name limit 2,1; -- 3rd track

-- to get all track names (not just 3rd) with AId for 'BM'
/*select Name from tracks -- track names with AId for 'BM'
where AlbumId=
    (select AlbumId from albums
    where Title='Blue Moods')
order by Name;*/




-- Q12 Ans:
-- 71
select count(distinct ArtistId) from artists -- artists without albums
where ArtistId not in
(select ArtistId from albums
group by ArtistId); -- unique artists with albums

-- double check using except
/*select count(ArtistId) from
(select ArtistId from artists -- artists without albums
except -- except ensures distinct AId AFTER except
select ArtistId from albums
group by ArtistId); -- unique artists with albums*/




-- Q13 Ans:
-- Battlestar Galactica (Classic), Season 1 (AlbumId: 253)
select Title from albums
where AlbumId =
    (select AlbumId from tracks -- AlbumId with 2nd longest duration
    group by AlbumId
    having sum(Milliseconds) =
        (select max(Duration) from -- 2nd longest
        (select sum(Milliseconds) as Duration from tracks
        group by AlbumId)
        where Duration <
            (select max(Duration) from -- longest
            (select sum(Milliseconds) as Duration from tracks
            group by AlbumId)))); -- millisec per album




-- Q14 Ans:
-- Berlin, London, Mountain View, Paris, Prague, São Paulo
select BillingCity from invoices -- Cities with largest num of invoices
group by BillingCity
having count(InvoiceId) =
(select max(Count) from -- largest num of invoices per BC
    (select count(InvoiceId) as Count from invoices
    group by BillingCity)); -- num of invoices per BC

-- double check by reading
/*
select BillingCity, count(InvoiceId) as Count from invoices
group by BillingCity
order by Count desc;*/
