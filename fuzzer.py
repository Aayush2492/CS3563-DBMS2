import html
from rapidfuzz import process, fuzz
import threading
import pprint

names = {}
with open('source.txt', 'r', encoding='utf8') as f:
    contents = f.read()
    content = contents.split('\n\n')

author_dict = {}
author_id  = 1
unusual_hash_to_dollar = [3710, 3730, 146445, 525455]
for paper_info in content[:-1]:
    paper_info = paper_info.split('\n')
    authors = []
    for line in paper_info:
        if line.startswith('#@'): # authors
            authors+= [s.strip() for s in line[2:].split(',')]
            authors = [html.unescape(s.lower()) for s in authors if s != '']
            for idx, a in enumerate(authors):
                if a.find('\\') != -1:
                    authors[idx] = a.replace('\\', '')
            if len(authors) == 0:
                authors = ['NULL']
    assert(len(authors) > 0)
    if authors[0] != 'NULL': # There are cases in source.txt where the authors are empty
        for index, a in enumerate(authors):
            if a not in author_dict.keys():
                if author_id in unusual_hash_to_dollar:
                    a = html.unescape(a.replace('$', '#'))
                    unusual_hash_to_dollar = unusual_hash_to_dollar[1:]
                author_id += 1
                author_dict[a] = author_id
                names[a] = author_id

s_names = sorted(list(names.keys()))

s = {}
for key in names:
    if len(key) == 0:
        print('Here') # It never reached here. No key is empty in sanitised_names.
        continue
    if key[0] in s:
        s[key[0]] += 1
    else:
        s[key[0]] = 1

# pprint.pprint(s)

sum1 = 0
for key in sorted(s.keys()):
    if key <= 'a':
        sum1 += s[key]

sum2 = 0
for key in sorted(s.keys()):
    if key >= 'z':
        sum2 += s[key]

lengths = []
for i in range(1,27):
    if i == 1:
        lengths.append(sum1)
    elif i == 26:
        lengths.append(sum2)
    else:
        lengths.append(s[chr(i+96)])
lengths.insert(0, 0)
cu_lengths = [sum(lengths[0:x+1]) for x in range(0, len(lengths)+1)]

# print(lengths)
# print(cu_lengths)
assert(sum(lengths) == len(names)) # character division is proper
assert(cu_lengths[-1] == len(names))

# This will group the names according to their similarity in fuzzy matching(90 percent threshold chosen).
# group_names dictionary has key as the name and value as a list of names that are similar to it as values
threshold = 90
count = 0
lock = threading.Lock() 
name_dicts = [None]*26
for i in range(0, 26):
    name_dicts[i] = {'grouped_names': {}}
''' Takes indices of keys of sanitised_names, groups them according to their similarity and writes them in
grouped_names dictionary.
'''
def group_names(thread_id, start_idx, end_idx):
    global count
    for idx in range(start_idx, end_idx+1):
        key = s_names[idx]
        if len(name_dicts[thread_id]['grouped_names']) == 0:
            name_dicts[thread_id]['grouped_names'][key] = []
            continue
        match = process.extractOne(key, name_dicts[thread_id]['grouped_names'].keys(), scorer=fuzz.token_sort_ratio)
        if match[1] > threshold:
            name_dicts[thread_id]['grouped_names'][match[0]].append(key)
        else:
            name_dicts[thread_id]['grouped_names'][key] = []
        lock.acquire()
        count+=1
        if count % 3000 == 0:
            print("Grouping progress: {:.2f}% done.".format(count/len(names)*100.0))
        lock.release()

count = 0
threads = []
for i in range(0,26):
    threads.append(threading.Thread(target=group_names, args=(i, cu_lengths[i], cu_lengths[i+1]-1)))

for thread in threads:
    thread.start()

for thread in threads:
    thread.join()

count2 = 0
with open(f'data/name_similarity.txt', 'w') as f:
    for i in range(0,26):
        for key in  name_dicts[i]['grouped_names'].keys():
            f.write(f"{count2}% {key}\n") # using % because its not present in author_names_grouped.txt
            for name in name_dicts[i]['grouped_names'][key]:
                f.write(f"{count2}% {name}\n")
            count2+=1