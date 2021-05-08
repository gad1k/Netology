import sys

from pyspark.sql import SparkSession
from pyspark.sql.window import Window

import pyspark.sql.functions as f
from pyspark.sql.functions import round as round
from pyspark.sql.functions import max as max
from pyspark.sql.functions import lag as lag

spark = SparkSession.builder \
    .appName('SparkLab') \
    .getOrCreate()

df = spark.read.option('header', True).format('csv').load(sys.argv[1] + 'owid-covid-data.csv')
df = df.withColumn('new_cases', df.new_cases.cast('int'))


res1 = df.filter(df.date == '2021-03-31') \
         .filter(~df.iso_code.rlike('OWID')) \
         .withColumn('ill_percent', round(df.total_cases / df.population * 100, 2))\
         .select(df.iso_code, df.location, 'ill_percent') \
         .sort('ill_percent', ascending=False)

  
res2_t1 = df.select(df.date, df.location, df.new_cases) \
            .filter(~df.iso_code.rlike('OWID')) \
            .filter((df.date > '2021-03-24') & (df.date <= '2021-03-31')) \
            .alias('res2_t1')


res2_t2 = df.filter(~df.iso_code.rlike('OWID')) \
            .filter((df.date > '2021-03-24') & (df.date <= '2021-03-31')) \
            .groupby(df.location).agg(max('new_cases').alias('new_cases')) \
            .alias('res2_t2')

  
res2 = res2_t1.join(res2_t2, [(res2_t1.location == res2_t2.location) & (res2_t1.new_cases == res2_t2.new_cases)], how = 'inner') \
              .select(res2_t1['date'], res2_t1['location'], res2_t1['new_cases']) \
              .sort(res2_t1['new_cases'], ascending=False)


res3 = df.filter(df.iso_code == 'RUS') \
         .filter((df.date > '2021-03-23') & (df.date <= '2021-03-31')) \
         .select(df.date, df.new_cases) \
         .withColumn('prev_new_cases', lag(df.new_cases).over(Window.partitionBy().orderBy('date'))) \
         .filter(df.date > '2021-03-24')
				 
				 
res3 = res3.withColumn('delta', res3.new_cases - res3.prev_new_cases)
res3 = res3.select(res3.date, res3.prev_new_cases, res3.new_cases, res3.delta)


print(res1.show(15))
print(res2.show(10))
print(res3.show())