-- QUERY 1
DROP TABLE IF EXISTS auth;
create temp table auth as select authored.paperid , authored.authorid , authored.contributionorder , author.authorname from authored left join author on authored.authorid = author.authorid;

DROP TABLE IF EXISTS auth_list;
create temp table auth_list as select paperid, string_agg(auth.authorname , ',' order by contributionorder) as list from auth group by paperid;

DROP TABLE IF EXISTS t1;
create temp table t1 as select  paperid, paperid_1 from researchpaper left join citation on researchpaper.paperID = citation.citationpaperid_2 order by paperid;

DROP TABLE IF EXISTS t2;
create temp table t2 as select t1.*, researchpaper.papertitle, researchpaper.publicationyear , researchpaper.venue from t1 left outer join researchpaper on t1.paperid_1 = researchpaper.paperid order by t1.paperid;

DROP TABLE IF EXISTS t3;
create temp table t3 as select t2.* , auth_list.list from t2 left outer join auth_list on t2.paperid_1 = auth_list.paperid order by t2.paperid;

select * from t3;

-- QUERY 2

DROP TABLE IF EXISTS auth;
CREATE temp TABLE auth AS SELECT authored.* , author.authorname FROM authored LEFT JOIN author on authored.authorid = author.authorid;

--auth_list: paperid, list of its authors
DROP TABLE IF EXISTS auth_list;
CREATE temp TABLE auth_list AS SELECT paperid, string_agg(auth.authorname , ',' ORDER BY contributionorder) AS authors_list FROM auth GROUP BY paperid;

--cit_list: paperid, list of its citations
DROP TABLE IF EXISTS cit_list;
CREATE temp TABLE cit_list AS SELECT citation.paperid_1 as paper_id, string_agg(CAST(citationpaperid_2 AS VARCHAR(20)) , ',') AS citations_list FROM citation GROUP BY citation.paperid_1;

-- joining researchpaper, auth_list and cit_list
SELECT researchpaper.*, auth_list.authors_list, cit_list.citations_list FROM researchpaper LEFT JOIN auth_list ON researchpaper.paperid = auth_list.paperid LEFT JOIN cit_list ON researchpaper.paperid = cit_list.paper_id ORDER BY researchpaper.paperid;

-- QUERY 3

DROP TABLE IF EXISTS auth;
CREATE temp TABLE auth AS SELECT authored.* , author.authorname FROM authored LEFT JOIN author on authored.authorid = author.authorid;

--auth_list: paperid, list of its authors
DROP TABLE IF EXISTS auth_list;
CREATE temp TABLE auth_list AS SELECT paperid, string_agg(auth.authorname , ',' ORDER BY contributionorder) AS authors_list FROM auth GROUP BY paperid;

--lvl2: paper_id, 2nd level paper that cites it
DROP TABLE IF EXISTS lvl2;
CREATE TEMP TABLE lvl2 AS 
SELECT c1.citationpaperid_2 AS paper_id, c2.paperid_1 AS level_2
FROM citation AS c1, citation AS c2
WHERE c2.citationpaperid_2 = c1.paperid_1
ORDER BY paper_id;

SELECT lvl2.*, r.papertitle, a.authors_list, r.publicationyear, r.venue FROM lvl2, researchpaper AS r, auth_list AS a WHERE r.paperid = lvl2.level_2 AND a.paperid = lvl2.level_2 ORDER BY lvl2.paper_id;

-- QUERY 4
DROP TABLE IF EXISTS auth;
CREATE temp TABLE auth AS SELECT authored.* , author.authorname FROM authored LEFT JOIN author on authored.authorid = author.authorid;

--auth_list: paperid, list of its authors
DROP TABLE IF EXISTS auth_list;
CREATE temp TABLE auth_list AS SELECT paperid, string_agg(auth.authorname , ',' ORDER BY contributionorder) AS authors_list FROM auth GROUP BY paperid;

DROP TABLE IF EXISTS t1;
CREATE temp TABLE t1 AS SELECT c.citationpaperid_2 as paperid , COUNT(c.citationpaperid_2) AS count FROM citation AS c GROUP BY c.citationpaperid_2 ORDER BY count DESC LIMIT 20;

SELECT t1.* , r.papertitle, a.authors_list, r.publicationyear , r.venue FROM t1, researchpaper AS r, auth_list AS a WHERE r.paperid = t1.paperid AND a.paperid = t1.paperid ORDER BY count DESC;

--QUERY 5
DROP TABLE IF EXISTS t1;
CREATE temp TABLE t1 AS SELECT a1.paperid ,  a1.authorid AS author1, a2.authorid AS author2 FROM authored AS a1 , authored AS a2 where a1.paperid = a2.paperid;

DROP TABLE IF EXISTS t2;
CREATE temp TABLE t2 AS SELECT (author1||','||author2) AS pair FROM t1 WHERE author1 < author2 ORDER BY paperid;

DROP TABLE IF EXISTS t3;
CREATE temp TABLE t3 AS SELECT pair , COUNT(pair) FROM t2 GROUP BY pair;

DROP TABLE IF EXISTS t4;
CREATE temp TABLE t4 AS SELECT split_part(t3.pair , ',' , 1)::INTEGER AS auth1 , split_part(t3.pair , ',' , 2)::INTEGER AS auth2 FROM t3 WHERE count>1; 

SELECT t4.* , ((SELECT authorname FROM author WHERE authorid = t4.auth1)|| ', '||(SELECT authorname FROM author WHERE authorid = t4.auth2)) AS pair_authors FROM t4;


-- QUERY 6
DROP TABLE IF EXISTS trichain;
CREATE temp TABLE trichain AS
SELECT c1.paperid_1 as lvl1, c1.citationpaperid_2 as lvl2, c2.citationpaperid_2 as lvl3
FROM citation AS c1
LEFT JOIN citation AS c2 ON c1.citationpaperid_2 = c2.paperid_1
WHERE c2.citationpaperid_2 IS NOT NULL AND c1.paperid_1 <> c2.citationpaperid_2;

DROP TABLE IF EXISTS t2;
CREATE temp TABLE t2 AS
SELECT ins1.*
FROM trichain AS ins1
LEFT JOIN citation ON ins1.lvl3 = citation.paperid_1
WHERE citation.citationpaperid_2 = ins1.lvl1
UNION
SELECT ins1.*
FROM trichain AS ins1
LEFT JOIN citation ON ins1.lvl1 = citation.paperid_1
WHERE citation.citationpaperid_2 = ins1.lvl3;

DROP TABLE IF EXISTS t4;
CREATE temp TABLE t4 AS
SELECT LEAST(lvl1, lvl2, lvl3) AS lvl1,
CASE LEAST(lvl1, lvl2, lvl3) WHEN lvl1 THEN LEAST(lvl2, lvl3)
                         WHEN lvl2 THEN LEAST(lvl1, lvl3)
                         WHEN lvl3 THEN LEAST(lvl1, lvl2)
                         END AS lvl2,
GREATEST(lvl1, lvl2, lvl3) AS lvl3
FROM t2;

DROP TABLE IF EXISTS t5;
CREATE temp TABLE t5 AS
SELECT DISTINCT *
FROM t4;

DROP TABLE IF EXISTS t6;
CREATE temp TABLE t6 AS
SELECT a1.authorid as id1, a2.authorid as id2, a3.authorid as id3
FROM t5
LEFT JOIN authored AS a1 ON t5.lvl1 = a1.paperid
LEFT JOIN authored AS a2 ON t5.lvl2 = a2.paperid
LEFT JOIN authored AS a3 ON t5.lvl3 = a3.paperid
WHERE a1.authorid <> a2.authorid AND a2.authorid <> a3.authorid AND a1.authorid <> a3.authorid;

DROP TABLE IF EXISTS t7;
CREATE temp TABLE t7 AS
SELECT LEAST(id1, id2, id3) AS id1,
CASE LEAST(id1, id2, id3) WHEN id1 THEN LEAST(id2, id3)
                         WHEN id2 THEN LEAST(id1, id3)
                         WHEN id3 THEN LEAST(id1, id2)
                         END AS id2,
GREATEST(id1, id2, id3) AS id3
FROM t6;

DROP TABLE IF EXISTS t9;
CREATE temp TABLE t9 AS
SELECT t7.*, COUNT(*) as count
FROM t7
GROUP BY t7.id1, t7.id2, t7.id3;

SELECT a1.authorname, a2.authorname, a3.authorname, t9.count
FROM t9
LEFT JOIN author as a1 ON t9.id1 = a1.authorid
LEFT JOIN author as a2 ON t9.id2 = a2.authorid
LEFT JOIN author as a3 ON t9.id3 = a3.authorid
ORDER BY t9.count DESC;