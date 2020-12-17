import org.apache.spark.sql.SparkSession

object EventLogProducer {

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder()
      .appName("event-log-producer")
      .getOrCreate()
    (1 to 5).foreach(i => {
      // meaningless computation to create event log
      spark.sparkContext.parallelize(1 to 10).collect()
    })
    spark.stop()
  }
}
