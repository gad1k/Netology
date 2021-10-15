import cx_Oracle as ora

from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator


default_args = {
    "owner": "airflow",
    "start_date": datetime(2019, 1, 1),
    "end_date": datetime(2019, 3, 30)
}

connection_string = "netology/netology@192.168.16.2:1521/xe"


def tag_format(**kwargs):
    with ora.connect(connection_string) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_checking.tag_format", [kwargs["execution_date"]])


def negative_quantity(**kwargs):
    with ora.connect(connection_string) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_checking.negative_quantity", [kwargs["execution_date"]])


def cogs_less_total(**kwargs):
    with ora.connect(connection_string) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_checking.cogs_less_total", [kwargs["execution_date"]])


def product_line_names_exist(**kwargs):
    with ora.connect(connection_string) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_checking.product_line_names_exist", [kwargs["execution_date"]])


with DAG("data_quality", description="Pipeline for Checking Supermarket Sales Data", default_args=default_args,
         schedule_interval="@daily", tags=["netology"]) as dag:
    tag_format = PythonOperator(task_id="checking_tag_format", provide_context=True, python_callable=tag_format)
    negative_quantity = PythonOperator(task_id="checking_negative_quantity", provide_context=True, python_callable=negative_quantity)
    cogs_less_total = PythonOperator(task_id="checking_cogs_less_total", provide_context=True, python_callable=cogs_less_total)
    product_line_names_exist = PythonOperator(task_id="checking_product_line_names_exist", provide_context=True, python_callable=product_line_names_exist)
