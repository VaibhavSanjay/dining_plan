import logging 
import os
import psycopg2

def main():
    print("Start")
    conn_string = input('Enter the connection string: ')
    conn = psycopg2.connect(os.path.expandvars(conn_string))
    with conn.cursor() as cur:
        cur.execute("USE name")
        cur.execute("DELETE FROM food2")
        conn.commit()
    conn.close()

if __name__ == "__main__":
    main()

