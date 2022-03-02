# Assignment 2 DBMS-II

## To install the requirements: (Assuming you use venv for virtual environment)

### To create the virtual environment

```
python3 -m venv db_venv
```

### To activate the virtual environment

```
source db_venv/bin/activate
```

### To install via pip

```
pip install -r requirements.txt
```

## To load the database

Step 1: Generate the required tsv files

```
python generate_tsv.py
```

Step 2: To create the schema, go to the postgres shell

```
\i ./create_table.sql
```

Step 3: To load the data, run

```
python pg_loader.py
```
