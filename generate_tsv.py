"""
Execution time: 13 seconds

Generates 4 tsv files in a utils folder
authors.tsv - author_id, author_name, similarity_id
author_paper.tsv - author_id, paper_id, contribution_order
paper.tsv - title, year, venue, id, abstract
citations.tsv - paper_id, cited_paper_id

Year was empty for some papers so added 9999
Title, Venue, Abstract, Author were empty for some papers so added "NULL" as string

---Decide whether to use re library to replace \t or normal string.replace()

"""
import os
# import re
import html
from pylatexenc.latex2text import LatexNodes2Text

if not os.path.exists("utils"):
    os.mkdir("utils")
with open('source.txt', 'r', encoding='utf8') as f:
    contents = f.read()
    content = contents.split('\n\n')

f1 = open('utils/papers.tsv', 'w', encoding='utf8')
f2 = open('utils/citations.tsv', 'w', encoding='utf8')
f3 = open('utils/authors.tsv', 'w', encoding='utf8')
f4 = open('utils/author_paper.tsv', 'w', encoding='utf8')
author_dict = {}
author_id  = 1
unusual = [3710, 3730, 146445, 525455]
for paper_info in content[:-1]:
    paper_info = paper_info.split('\n')
    flag = 0
    title = ''
    year = ''
    venue = ''
    id = ''
    abstract = ''
    citations = []
    authors = []
    for line in paper_info:
        if line.startswith('#*'): # title
            title = line[2:].lower()
            # title = re.sub(r'\t', '', title)
            title = title.replace('\\', '')
            if title == '':
                title = 'NULL'
        elif line.startswith('#t'): # year
            year = line[2:]
            if not year.isdigit(): # There are cases in source.txt where the year -1
                year = '9999'
            assert(len(year) == 4)
            assert(year.isdigit())
        elif line.startswith('#c'): # venue
            venue = line[2:].lower()
            if venue.startswith('usenix'):
                venue = venue.replace('\\', '')
            if venue == '':
                venue = 'NULL'
        elif line.startswith('#index'): # id
            id = line[6:]
            assert(id.isdigit())
        elif line.startswith('#!'): # abstract
            abstract = line[2:].lower()
            # abstract = re.sub(r'\t', '', abstract)
            abstract = abstract.replace('\\', '')
            flag = 1
        elif line.startswith('#%'): # citations
            assert(line[2:].isdigit())
            citations.append(line[2:])
        elif line.startswith('#@'): # authors
            authors+= [s.strip() for s in line[2:].split(',')]
            authors = [html.unescape(s.lower()) for s in authors if s != '']
            # authors = [s.lower() for s in authors if s != '']
            if len(authors) == 0:
                authors = ['NULL']
        if flag == 0:
            abstract = 'NULL'
    assert(title != '')
    assert(year != '')
    assert(venue != '')
    assert(id != '')
    assert(len(authors) > 0)
    f1.write(title + '\t' + year + '\t' + venue + '\t' + id + '\t' + abstract + '\n')
    for c in citations:
        f2.write(id + '\t' + c + '\n')
    if authors[0] != 'NULL': # There are cases in source.txt where the authors are empty
        for index, a in enumerate(authors):
            if a not in author_dict.keys():
                if author_id in unusual:
                    print(a)
                    a = html.unescape(a.replace('$', '#'))
                    unusual = unusual[1:]
                f3.write(str(author_id) + '\t' + a + '\t' + '0' + '\n')
                f4.write(str(author_id) + '\t' + id + '\t' + str(index+1) +'\n')
                author_id += 1
                author_dict[a] = author_id
            else:
                f4.write(str(author_dict[a]) + '\t' + id + '\t' + str(index+1) +'\n')
            # f3.write(str(author_id) + '\t' + a + '\t' + '0' + '\n')
            # f4.write(str(author_id) + '\t' + id + '\t' + str(index+1) +'\n')
            # author_id += 1

f1.close()
f2.close()
f3.close()
f4.close()