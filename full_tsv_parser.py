import time
import psycopg2
import psycopg2.extras
import io

start_time = time.time()
# dummy = open("dummy.txt", "r", encoding="utf-8")
author_tsv = open("utils/authors.tsv", "r", encoding="utf-8")
author_paper_tsv = open("utils/author_paper.tsv", "r", encoding="utf-8")
paper_tsv = open("utils/papers.tsv", "r", encoding="utf-8")
citations_tsv = open("utils/citations.tsv", "r", encoding="utf-8")

conn = psycopg2.connect("dbname=dbms_a2 user=postgres password=1234")
cur = conn.cursor()
count = 0

cur.copy_from(author_tsv, "author", sep='\t')
cur.copy_from(paper_tsv, "researchpaper", sep='\t',
              columns=("papertitle", "publicationyear", "venue", "paperid", "abstract"))
cur.copy_from(author_paper_tsv, "authored", sep='\t', columns=("authorid", "paperid", "contributionorder"))
cur.copy_from(citations_tsv, "citation", sep='\t')
conn.commit()
cur.close()
conn.close()

author_tsv.close()
paper_tsv.close()
author_paper_tsv.close()
citations_tsv.close()

print(time.time() - start_time)
