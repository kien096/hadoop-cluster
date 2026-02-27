#!/bin/bash
cd /workspace
echo "1. Creating classes directory..."
mkdir -p classes_retail

echo "2. Compiling Java source code for Retail task..."
export HADOOP_CLASSPATH=$(hadoop classpath)
javac -classpath ${HADOOP_CLASSPATH} -d classes_retail retail/*.java

echo "3. Packaging to JAR..."
jar -cvf retail.jar -C classes_retail/ .

echo "4. Uploading CSV data to HDFS..."
hdfs dfs -mkdir -p /input_retail
hdfs dfs -put -f input_retail/*.csv /input_retail/

echo "5. Removing old output directory on HDFS..."
hdfs dfs -rm -r -f /output_retail

echo "6. Running MapReduce Job..."
hadoop jar retail.jar retail.ProductsDriver /input_retail /output_retail

echo "7. Viewing results..."
hdfs dfs -cat /output_retail/part-r-00000
