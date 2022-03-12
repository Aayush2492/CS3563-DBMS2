-- QUERY 1

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

create temp table t1 as select  paperid, paperid_1 from researchpaper left join citation on researchpaper.paperID = citation.citationpaperid_2 order by paperid;

create temp table t2 as select t1.*, researchpaper.papertitle, researchpaper.publicationyear , researchpaper.venue from t1 left outer join researchpaper on t1.paperid_1 = researchpaper.paperid order by t1.paperid;

create temp table t3 as select t2.* , auth_list.list from t2 left outer join auth_list on t2.paperid_1 = auth_list.paperid order by t2.paperid;

select * from t3;

drop table auth;

drop table auth_list;

drop table t1;

drop table t2;

drop table t3;

-- QUERY 2

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

create temp table t1 as select  paperid, citationpaperid_2 from researchpaper left join citation on researchpaper.paperID = citation.paperid_1 order by paperid;

create temp table t2 as select t1.*, researchpaper.papertitle, researchpaper.publicationyear , researchpaper.venue from t1 left outer join researchpaper on t1.citationpaperid_2 = researchpaper.paperid order by t1.paperid;

create temp table t3 as select t2.* , auth_list.list from t2 left outer join auth_list on t2.citationpaperid_2 = auth_list.paperid order by t2.paperid;

select * from t3;

drop table auth;

drop table auth_list;

drop table t1;

drop table t2;

drop table t3;

-- QUERY 3

create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

CREATE TEMP TABLE lvl2 AS 
SELECT c1.citationpaperid_2 AS paper_id, c2.paperid_1 AS level_2
FROM citation AS c1, citation AS c2
WHERE c2.citationpaperid_2 = c1.paperid_1
ORDER BY paper_id;

select lvl2.*, r.papertitle, a.list, r.publicationyear, r.venue from lvl2, researchpaper as r, auth_list as a where r.paperid = lvl2.level_2 and a.paperid = lvl2.level_2 order by paper_id, level_2;

drop table auth;

drop table auth_list;

drop table lvl2;

-- QUERY 4
create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

-- select citationpaperid_2 as paperid , count(citationpaperid_2) as count , r.papertitle, a.list, r.publicationyear , r.venue from citation, researchpaper as r, auth_list as a where r.paperid = citation.citationpaperid_2 and a.paperid = citation.citationpaperid_2 group by paperid order by count desc limit 20;

create temp table t1 as select c.citationpaperid_2 as paperid , count(c.citationpaperid_2) as count from citation as c group by c.citationpaperid_2 order by count desc limit 20;

select t1.* , r.papertitle, a.list, r.publicationyear , r.venue from t1, researchpaper as r, auth_list as a where r.paperid = t1.paperid and a.paperid = t1.paperid order by count desc;

drop table auth;

drop table auth_list;

drop table t1;

-- QUERY 5
create temp table t1 as select a1.paperid ,  a1.authorid as author1, a2.authorid as author2 from authored as a1 , authored as a2 where a1.paperid = a2.paperid;

create temp table t2 as select * , (author1||','||author2) as pair from t1 where author1 < author2 order by paperid;

create temp table t3 as select pair , count(pair) from t2 group by pair;

create temp table t4 as select split_part(t3.pair , ',' , 1)::INTEGER as auth1 , split_part(t3.pair , ',' , 2)::INTEGER as auth2 from t3 where count>1; 

select t4.* , ((select authorname from author where authorid = t4.auth1)|| ', '||(select authorname from author where authorid = t4.auth2)) as pair_authors from t4;

drop table t1;

drop table t2;

drop table t3;

drop table t4;


-- QUERY 6

create temp table t1 as select c.*, a.authorid as auth_p1 from citation as c, authored as a where c.paperid_1 = a.paperid order by c.paperid_1;

create temp table t2 as select t1.*, a.authorid as auth_p2 from t1, authored as a where t1.citationpaperid_2 = a.paperid order by t1.paperid_1, auth_p1;

create temp table cite_pair as select auth_p1, auth_p2 from t2 where auth_p1 != auth_p2;
