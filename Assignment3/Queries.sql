-- QUERY 1
create temp table cite_in as select * from researchpaper left join citation on researchpaper.paperID = citation.citationpaperid_2;

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;


do $$               
declare r record;
begin 
for r in (select * from cite_in) loop
if r.paperid_1 is NULL
then raise notice '% - %',r.paperid , r.paperid_1;
else raise notice '% - % - % - % - % - %' , r.paperid , r.paperid_1 , (select papertitle from researchpaper as q where q.paperid = r.paperid_1),(select list from auth_list where auth_list.paperid = r.paperid_1) ,(select publicationyear from researchpaper as q where q.paperid = r.paperid_1), (select venue from researchpaper as q where q.paperid = r.paperid_1);
end if;
end loop;
end $$
;
drop table cite_in;
drop table auth;
drop table auth_list;



-- QUERY 2

create temp table cite as select * from researchpaper left join citation on researchpaper.paperID = citation.paperid_1;

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;


do $$               
declare r record;
begin 
for r in (select * from cite) loop
if r.citationpaperid_2 is NULL
then raise notice '% - %',r.paperid , r.citationpaperid_2;
else raise notice '% - % - % - % - % - %' , r.paperid , r.citationpaperid_2 , (select papertitle from researchpaper as q where q.paperid = r.citationpaperid_2),(select list from auth_list where auth_list.paperid = r.citationpaperid_2) ,(select publicationyear from researchpaper as q where q.paperid = r.citationpaperid_2), (select venue from researchpaper as q where q.paperid = r.citationpaperid_2);
end if;
end loop;
end $$
;
drop table cite;
drop table auth;
drop table auth_list;


--QUERY 3
create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

CREATE TEMP TABLE lvl2 AS 
SELECT c1.citationpaperid_2 AS paper_id, c2.paperid_1 AS level_2
FROM citation AS c1, citation AS c2
WHERE c2.citationpaperid_2 = c1.paperid_1
ORDER BY paper_id;

select lvl2.*, r.papertitle, r.publicationyear, r.venue, a.list from lvl2, researchpaper as r, auth_list as a where r.paperid = lvl2.level_2 and a.paperid = lvl2.level_2 order by paper_id, level_2;

drop table lvl2;
drop table auth;
drop table auth_list;

-- QUERY 4
select citationpaperid_2 , count(citationpaperid_2) as count from citation group by citationpaperid_2 order by count desc limit 20;
-- QUERY 4 UPDATED
select * from researchpaper as rp join (
select citationpaperid_2 , count(citationpaperid_2) 
as count 
from citation group by citationpaperid_2 
order by count desc limit 20) T2
on rp.paperid = T2.citationpaperid_2;

-- QUERY 5
create temp table t1 as select a1.paperid ,  a1.authorid as author1, a2.authorid as author2 from authored as a1 , authored as a2 where a1.paperid = a2.paperid;

create temp table t2 as select * , (author1||','||author2) as pair from t1 where author1 < author2 order by paperid;

create temp table t3 as select pair , count(pair) from t2 group by pair;

do $$                                                               
declare r record;
begin
for r in (select * from t3 where count > 1) loop
raise notice '% - %' , (select authorname from author where authorid = (split_part(r.pair , ',' , 1))::INTEGER), (select authorname from author where authorid = (split_part(r.pair , ',' , 2))::INTEGER);
end loop;
end $$;



-- QUERY 2 But in table format and can output ID and title for each (must be updated according to requirement
select T1.paperid, T1.papertitle, T2.citationpaperid_2, T3.papertitle
from (
	(select paperid, papertitle from researchpaper)T1
	full outer join
	(select paperid_1, citationpaperid_2 from citation)T2
	on T1.paperid = T2.paperid_1
	full outer join
	(select paperid, papertitle from researchpaper)T3
	on T2.citationpaperid_2 = T3.paperid
)
order by T1.paperid
