-- QUERY 1

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

create temp table t1 as select  paperid, paperid_1 from researchpaper left join citation on researchpaper.paperID = citation.citationpaperid_2 order by paperid;

create temp table t2 as select t1.*, researchpaper.papertitle, researchpaper.publicationyear , researchpaper.venue from t1 left outer join researchpaper on t1.paperid_1 = researchpaper.paperid order by t1.paperid;

create temp table t3 as select t2.* , auth_list.list from t2 left outer join auth_list on t2.paperid_1 = auth_list.paperid order by t2.paperid;

select * from t3;

-- QUERY 2

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

create temp table t1 as select  paperid, citationpaperid_2 from researchpaper left join citation on researchpaper.paperID = citation.paperid_1 order by paperid;

create temp table t2 as select t1.*, researchpaper.papertitle, researchpaper.publicationyear , researchpaper.venue from t1 left outer join researchpaper on t1.citationpaperid_2 = researchpaper.paperid order by t1.paperid;

create temp table t3 as select t2.* , auth_list.list from t2 left outer join auth_list on t2.citationpaperid_2 = auth_list.paperid order by t2.paperid;

select * from t3;


-- QUERY 4
create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

select citationpaperid_2 as paperid , count(citationpaperid_2) as count , r.papertitle, a.list, r.publicationyear , r.venue from citation, researchpaper as r, auth_list as a where r.paperid = citation.citationpaperid_2 and a.paperid = citation.citationpaperid_2 group by paperid order by count desc limit 20;


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
