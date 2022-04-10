
import os
import psycopg2
import json
import random
# CREATE TABLE food2 (name STRING NOT NULL,options int);

def insert(conn, name, option, table):
    with conn.cursor() as cur:
        print("INSERT INTO " +table +" (name, option) VALUES (%s, %s)", (name, option))
        cur.execute("USE defaultdb")
        cur.execute("INSERT INTO "+ table+ " (name, options) VALUES (%s, %s)", (name, option))
        conn.commit()
        
def main():
    print("Start")
    data = json.load(open("info.txt"))
    conn_string = input('Enter the connection string: ')
    conn = psycopg2.connect(os.path.expandvars(conn_string))

    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food1")
    
    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food2")

    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food3")
    
    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food4")

    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food5")

    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food6")

    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food7")
    
    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food8")
    
    i = 0;
    x = data['lunch']
    random.shuffle(x)
    for name, option in x:
        insert(conn, name, option,"food9")
    

    conn.close()
if __name__ == "__main__":
    main()

