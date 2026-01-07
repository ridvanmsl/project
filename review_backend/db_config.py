"""
PostgreSQL database configuration and connection management
"""
import os
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
from contextlib import contextmanager

# Load environment variables
load_dotenv()

# Database configuration
DATABASE_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'database': os.getenv('DB_NAME', 'review_analysis_db'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', '1')
}

# Connection pool (initialized on first use)
_connection_pool = None


def init_connection_pool(minconn=1, maxconn=10):
    """Initialize PostgreSQL connection pool"""
    global _connection_pool
    if _connection_pool is None:
        try:
            _connection_pool = SimpleConnectionPool(
                minconn=minconn,
                maxconn=maxconn,
                **DATABASE_CONFIG
            )
            print(f"INFO: PostgreSQL connection pool initialized (max: {maxconn})")
        except Exception as e:
            print(f"ERROR: Failed to initialize connection pool: {e}")
            raise
    return _connection_pool


@contextmanager
def get_db_connection():
    """
    Get database connection from pool (context manager)
    Usage:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM table")
    """
    pool = init_connection_pool()
    conn = None
    try:
        conn = pool.getconn()
        yield conn
        conn.commit()
    except Exception as e:
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            pool.putconn(conn)


def get_direct_connection():
    """
    Get a direct database connection (without pool)
    Use for one-time operations like database initialization
    Remember to close the connection manually!
    """
    try:
        conn = psycopg2.connect(**DATABASE_CONFIG)
        return conn
    except Exception as e:
        print(f"ERROR: Failed to connect to database: {e}")
        raise


def test_connection():
    """Test database connection"""
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT version();")
                version = cursor.fetchone()
                print(f"INFO: Connected to PostgreSQL: {version[0][:50]}...")
                return True
    except Exception as e:
        print(f"ERROR: Connection test failed: {e}")
        return False


def create_database_if_not_exists():
    """Create database if it doesn't exist (connect to default 'postgres' db)"""
    db_name = DATABASE_CONFIG['database']
    temp_config = DATABASE_CONFIG.copy()
    temp_config['database'] = 'postgres'
    
    try:
        conn = psycopg2.connect(**temp_config)
        conn.autocommit = True
        cursor = conn.cursor()
        

        cursor.execute(f"SELECT 1 FROM pg_database WHERE datname = '{db_name}'")
        exists = cursor.fetchone()
        
        if not exists:
            cursor.execute(f"CREATE DATABASE {db_name}")
            print(f"INFO: Database '{db_name}' created")
        else:
            print(f"INFO: Database '{db_name}' already exists")
        
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"ERROR: Failed to create database: {e}")
        return False


if __name__ == "__main__":

    print("Testing PostgreSQL connection...")
    print(f"Config: {DATABASE_CONFIG['user']}@{DATABASE_CONFIG['host']}:{DATABASE_CONFIG['port']}/{DATABASE_CONFIG['database']}")
    
    if create_database_if_not_exists():
        if test_connection():
            print("\n All tests passed!")
        else:
            print("\n Connection test failed!")
