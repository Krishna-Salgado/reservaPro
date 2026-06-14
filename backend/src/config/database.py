import psycopg2
from psycopg2.extras import RealDictCursor
from psycopg2.pool import SimpleConnectionPool
import os
from dotenv import load_dotenv


load_dotenv()

def get_env_or_die(key: str) -> str:
    value = os.getenv(key)
    if value is None:
        raise ValueError(f"Variable {key} no encontrada en .env")
    return value


DB_CONFIG = {
    "host": get_env_or_die("DB_HOST"),
    "port": get_env_or_die("DB_PORT"),
    "database": get_env_or_die("DB_NAME"),
    "user": get_env_or_die("DB_USER"),
    "password": get_env_or_die("DB_PASSWORD"),
}


pool = SimpleConnectionPool(minconn=1, maxconn=10, **DB_CONFIG)

def get_connection():
    return pool.getconn()

def release_connection(conn):
    pool.putconn(conn)

def execute_query(sql: str, params: tuple = None, fetch: bool = True):
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            if fetch:
                result = cur.fetchall()
            else:
                result = None
            conn.commit()
            return result
    except psycopg2.errors.UniqueViolation as e:
        conn.rollback()
        raise DoubleBookingException("Ese horario ya fue tomado, elige otro") from e
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        release_connection(conn)

class DoubleBookingException(Exception):
    pass