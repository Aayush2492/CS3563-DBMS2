-- QUERY 1
DROP TABLE IF EXISTS auth;
CREATE temp TABLE auth AS SELECT authored.* , author.authorname FROM authored LEFT JOIN author on authored.authorid = author.authorid;

--auth_list: paperid, list of its authors
DROP TABLE IF EXISTS auth_list;
CREATE temp TABLE auth_list AS SELECT paperid, string_agg(auth.authorname , ',' ORDER BY contributionorder) AS authors_list FROM auth GROUP BY paperid;

SELECT researchpaper.paperid, citation.paperid_1, auth_list.authors_list FROM researchpaper LEFT JOIN citation ON researchpaper.paperid = citation.citationpaperid_2 LEFT JOIN auth_list ON citation.paperid_1 = auth_list.paperid  ORDER BY researchpaper.paperid;

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

create temp table t1 as select c.*, a.authorid as auth_p1 from citation as c, authored as a where c.paperid_1 = a.paperid order by c.paperid_1;

create temp table t2 as select t1.*, a.authorid as auth_p2 from t1, authored as a where t1.citationpaperid_2 = a.paperid order by t1.paperid_1, auth_p1;

create temp table cite_pair as select auth_p1, auth_p2 from t2 where auth_p1 != auth_p2;

create temp table cite_pair_rev  as select cp.auth_p1 as auth_p2, cp.auth_p2 as auth_p1 from cite_pair as cp;

create temp table cite_pair_undir as select * from cite_pair union select auth_p1,auth_p2 from cite_pair_rev;

create temp table triangle as select c1.auth_p1 as auth1, c1.auth_p2 as auth2, c2.auth_p2 as auth3 from cite_pair_undir as c1 inner join cite_pair_undir as c2 on c1.auth_p2 = c2.auth_p1;

select * from triangle as t where (select exists(select * from cite_pair_undir as c where c.auth_p1 = t.auth1 and c.auth_p2 = t.auth3));

-- Query 6 : 2nd version
DROP TABLE IF EXISTS t1;
CREATE temp TABLE t1 AS SELECT a1.paperid,  a1.authorid AS author1, a2.authorid AS author2, a3.authorid AS author3 FROM authored AS a1 , authored AS a2,  authored AS a3 WHERE a1.paperid = a2.paperid AND a2.paperid = a3.paperid AND a1.authorid < a2.authorid AND a2.authorid < a3.authorid; 

DROP TABLE IF EXISTS t2;
CREATE temp TABLE t2 AS SELECT (author1||','||author2||','||author3) AS triplet FROM t1 ORDER BY paperid;

SELECT triplet, COUNT(triplet) as total FROM t2 GROUP BY triplet ORDER BY total DESC;
