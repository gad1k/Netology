import org.apache.spark.sql.{SparkSession, functions}
import org.apache.spark.sql.catalyst.ScalaReflection.schemaFor
import org.apache.spark.sql.functions.{from_json, window}
import org.apache.spark.sql.streaming.StreamingQueryListener
import org.apache.spark.sql.streaming.StreamingQueryListener.{QueryProgressEvent, QueryStartedEvent, QueryTerminatedEvent}

object SparkStreaming {
   def main(args: Array[String]): Unit = {
      val spark = SparkSession
        .builder()
        .master("local[*]")
        .appName("SparkStreaming")
        .getOrCreate()

      spark.sparkContext.setLogLevel("ERROR")
      spark.streams.addListener(new StreamingQueryListener() {
         override def onQueryStarted(queryStarted: QueryStartedEvent): Unit = {
            println("Query started: " + queryStarted.id)
         }

         override def onQueryTerminated(queryTerminated: QueryTerminatedEvent): Unit = {
            println("Query terminated: " + queryTerminated.id)
         }

         override def onQueryProgress(queryProgress: QueryProgressEvent): Unit = {
            println("Query made some progress: " + queryProgress.progress)
         }
      })

      import spark.implicits._

      val pageViews = spark
        .readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", "localhost:9092")
        .option("subscribe", "pageviews")
        .option("startingOffsets", "earliest")
        .load()
        .selectExpr("timestamp", "CAST(value as String)")
        .select($"timestamp", functions.from_json($"value", schemaFor[PageView].dataType).as("pageview"))
        .select("timestamp", "pageview.userid", "pageview.pageid")
        .select($"timestamp".as("pvTimestamp"), $"userid".as("pvUserId"), $"pageid".as("pageId"))
        .withWatermark("pvTimestamp", "10 seconds")

      val users = spark
        .readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", "localhost:9092")
        .option("subscribe", "users")
        .option("startingOffsets", "earliest")
        .load()
        .selectExpr("timestamp", "CAST(value as String)")
        .select($"timestamp", from_json($"value", schemaFor[User].dataType).as("user"))
        .select("timestamp", "user.userid", "user.gender")
        .select($"timestamp".as("uTimestamp"), $"userid".as("uUserId"), $"gender".as("gender"))
        .withWatermark("uTimestamp", "10 seconds")

      val stats = pageViews
        .join (
          users,
          functions.expr("""pvUserId = uUserId and pvTimestamp >= uTimestamp and pvTimestamp <= uTimestamp + interval 3 seconds""")
        )
        .select(users("gender"), pageViews("pvTimestamp"))
        .groupBy($"gender", window($"pvTimestamp", "60 seconds"))
        .count()
        .writeStream
        .option("numRows", 500)
        .format("console")
        .start()

      stats.awaitTermination()
   }
}