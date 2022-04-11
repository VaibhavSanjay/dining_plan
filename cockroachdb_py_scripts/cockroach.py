import logging 
import os
import psycopg2
import json

def main():
    print("Start")
    data = json.load(open("info.txt"))
    conn_string = input('Enter the connection string: ')
    conn = psycopg2.connect(os.path.expandvars(conn_string))
    
    i = 0;

    for name, option in data['lunch']:
        insert(conn, name, option)
    conn.close()



def insert(conn, name, option):
    with conn.cursor() as cur:
        print("INSERT INTO food2 (name, option) VALUES (%s, %s)", (name, option))
        cur.execute("USE name")
        cur.execute("INSERT INTO food2 (name, options) VALUES (%s, %s)", (name, option))
        conn.commit()
#run the main bruh
if __name__ == "__main__":
    main()

