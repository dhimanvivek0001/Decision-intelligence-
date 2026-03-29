import psycopg2

import pandas as pd

def get_connection():
    return psycopg2.connect(
        host="olist-platform.214725067573.us-east-1.redshift-serverless.amazonaws.com",
        port=5439,
        database="dev",
        user="admin",
        password="kPoint#1234"
    )

def run_query(query):
    conn = get_connection()
    df = pd.read_sql(query, conn)
    conn.close()
    return df


