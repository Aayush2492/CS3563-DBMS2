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


-- QUERY 4
select citationpaperid_2 , count(citationpaperid_2) as count from citation group by citationpaperid_2 order by count desc limit 20;
