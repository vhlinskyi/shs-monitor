# SHS monitor

Tool to reproduce SPARK-XXXXX.


# Prerequisites

* Build SHS from sources:
```
$ git clone https://github.com/apache/spark.git
$ git checkout origin/branch-3.0
$ export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=1g"
$ ./build/mvn -DskipTests clean package
```

* Download Hadoop AWS and AWS Java SDK
```
$ cd assembly/target/scala-2.12/
$ wget https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-aws/2.7.4
$ wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar
```

* Prepare S3 bucket and user for programmatic acccess, grant required roles to the user and get access key and secret key 
* Configure it to read event logs from S3 by creating the next `conf/spark-defaults.conf`:
```
spark.history.fs.logDirectory  s3a\://shs-reproduce-bucket/eventlog
spark.hadoop.fs.s3a.impl       org.apache.hadoop.fs.s3a.S3AFileSystem
spark.hadoop.fs.s3a.access.key <YOUR-ACCESS-KEY>
spark.hadoop.fs.s3a.secret.key <YOUR-SECRET-KEY>
```

* Starts SHS:
```
./sbin/start-history-server.sh
```

# Reproduce

Start event log producer:
```
./producer.sh shs-reproduce-bucket/eventlog
```

Start SHS monitor:
```
./monitor.sh http://192.168.31.189:18080
```

# Event log template

Event log template file under the `history/` directory has been produced by following the next steps:

* Enable event logging by executing the next commands from the Spark 3 installation directory
```
$ echo "spark.eventLog.enabled true" > conf/spark-defaults.conf
$ echo "spark.eventLog.dir `pwd`/history" >> conf/spark-defaults.conf
```

* Start `spark-shell` and run meaningless computation to create event log
```
$ ./bin/spark-shell --master local

:paste
(1 to 5).foreach(i => {
  // meaningless computation to create event log
  spark.sparkContext.parallelize(1 to 10).collect()
})
print("Done")
// Press Ctrl + D to interprete
// Press Ctrl + C to exit
```

* Verify that event log file has been created
```
$ ls history/
local-1608227687233
```