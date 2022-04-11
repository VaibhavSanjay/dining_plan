
import os
import psycopg2
import json
import random
# CREATE TABLE food2 (name STRING NOT NULL,options int);

def main():
    print("Start")
    data = json.load(open("info.txt"))
    conn_string = input('Enter the connection string: ')
    conn = psycopg2.connect(os.path.expandvars(conn_string))
    with conn.cursor() as cur:
        cur.execute("CREATE TABLE food1 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food2 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food3 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food4 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food5 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food6 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food7 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food8 (name STRING NOT NULL,options int);")
        cur.execute("CREATE TABLE food9 (name STRING NOT NULL,options int);")
        conn.commit()


if __name__ == "__main__":
    main()

def insert(conn, name, option, table):
    with conn.cursor() as cur:
        print("INSERT INTO ",table," (name, option) VALUES (%s, %s)", (name, option))
        cur.execute("USE name")
        cur.execute("INSERT INTO ",table," (name, options) VALUES (%s, %s)", (name, option))
        conn.commit()