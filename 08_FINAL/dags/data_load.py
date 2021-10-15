import time
import cx_Oracle as ora

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator


default_args = {
    "owner": "airflow",
    "start_date": datetime(2019, 1, 1),
    "end_date": datetime(2019, 3, 30),
}

add_vars = {
    "connection_string": "netology/netology@192.168.16.2:1521/xe",
    "name": "supermarket_sales",
    "format": "csv",
    "path": "/opt/airflow/datasets/"
}


def clear_nds(date):
    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_misc.clear_nds", [date])
            connection.commit()


def check_prev_date(date):
    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            return cursor.callfunc("pkg_misc.check_prev_date", int, [date - timedelta(days=1)])


def pi_supermarket_sales(**kwargs):
    clear_nds(kwargs["execution_date"])

    if kwargs["execution_date"].strftime("%d-%m-%Y") != "01-01-2019":
        not_completed = 0
        while not_completed == 0:
            not_completed = check_prev_date(kwargs["execution_date"])
            time.sleep(1)

    supermarket_sales = list()
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    file = add_vars["path"] + add_vars["name"] + "_" + exec_date + "." + add_vars["format"]

    with open(file, "r") as data:
        for line in data:
            supermarket_sales.append(line)

    kwargs["ti"].xcom_push(key=add_vars["name"] + "_" + exec_date, value=supermarket_sales)


def si_customers(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1000, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_customers", int, [order[3], order[4]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def si_locations(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1001, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_locations", int, [order[1], order[2]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def si_payment_types(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1002, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_payment_types", int, [order[12]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def si_product_lines(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1003, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_product_lines", int, [order[5]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def si_products(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1004, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_products", int, [order[5], order[6]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def si_orders(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1005, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_orders", int, [order[0], order[1], order[3],
                                                                                       order[4], order[10], order[11],
                                                                                       order[12], order[16]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def si_items(**kwargs):
    exec_date = kwargs["execution_date"].strftime("%Y%m%d")
    data = kwargs["ti"].xcom_pull(key=add_vars["name"] + "_" + exec_date)

    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            stage_id = cursor.var(int)
            cursor.callproc("pkg_logging.log_start", [1006, kwargs["execution_date"], stage_id])
            cursor.callproc("pkg_logging.track_start", [stage_id])

            row_count = 0
            for i, line in enumerate(data):
                if i == 0:
                    continue
                order = line.strip().split(",")
                row_count = row_count + cursor.callfunc("pkg_staging.si_items", int, [order[0], order[5],
                                                                                      order[6], order[7]])

            connection.commit()
            cursor.callproc("pkg_logging.track_cur_state", [stage_id, row_count])
            cursor.callproc("pkg_logging.log_end", [stage_id])


def dim_product_lines(**kwargs):
    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_processing.dim_product_lines", [kwargs["execution_date"]])


def dim_payment_types(**kwargs):
    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_processing.dim_payment_types", [kwargs["execution_date"]])


def dim_add_info(**kwargs):
    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_processing.dim_add_info", [kwargs["execution_date"]])


def ft_item_orders(**kwargs):
    with ora.connect(add_vars["connection_string"]) as connection:
        with connection.cursor() as cursor:
            cursor.callproc("pkg_processing.ft_item_orders", [kwargs["execution_date"]])


with DAG("data_load", description="Pipeline for Loading Supermarket Sales Data", default_args=default_args,
         schedule_interval="@daily", tags=["netology"]) as dag:
    pi_supermarket_sales = PythonOperator(task_id="loading_pi_supermarket_sales", provide_context=True, python_callable=pi_supermarket_sales)

    si_customers = PythonOperator(task_id="staging_si_customers", provide_context=True, python_callable=si_customers)
    si_locations = PythonOperator(task_id="staging_si_locations", provide_context=True, python_callable=si_locations)
    si_payment_types = PythonOperator(task_id="staging_si_payment_types", provide_context=True, python_callable=si_payment_types)
    si_product_lines = PythonOperator(task_id="staging_si_product_lines", provide_context=True, python_callable=si_product_lines)
    si_products = PythonOperator(task_id="staging_si_products", provide_context=True, python_callable=si_products)
    si_orders = PythonOperator(task_id="staging_si_orders", provide_context=True, python_callable=si_orders)
    si_items = PythonOperator(task_id="staging_si_items", provide_context=True, python_callable=si_items)

    dim_add_info = PythonOperator(task_id="processing_dim_add_info", provide_context=True, python_callable=dim_add_info)
    dim_payment_types = PythonOperator(task_id="processing_dim_payment_types", provide_context=True, python_callable=dim_payment_types)
    dim_product_lines = PythonOperator(task_id="processing_dim_product_lines", provide_context=True, python_callable=dim_product_lines)
    ft_item_orders = PythonOperator(task_id="processing_ft_item_orders", provide_context=True, python_callable=ft_item_orders)

    pi_supermarket_sales >> si_locations >> si_orders
    pi_supermarket_sales >> si_customers >> si_orders
    pi_supermarket_sales >> si_payment_types >> si_orders
    pi_supermarket_sales >> si_product_lines >> si_products >> si_items

    si_orders >> si_items

    si_items >> dim_add_info >> ft_item_orders
    si_items >> dim_payment_types >> ft_item_orders
    si_items >> dim_product_lines >> ft_item_orders
