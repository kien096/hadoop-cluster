#!/bin/bash
cd /workspace
echo "1. Creating classes directory..."
mkdir -p classes

echo "2. Compiling Java source code..."
export HADOOP_CLASSPATH=$(hadoop classpath)
javac -classpath ${HADOOP_CLASSPATH} -d classes wordcount/*.java

echo "3. Packaging to JAR..."
jar -cvf wordcount.jar -C classes/ .

echo "4. Reading sample data... (modify files in workspace/input_data manually)"
mkdir -p input_data

echo "5. Uploading data to HDFS..."
hdfs dfs -mkdir -p /input
hdfs dfs -put -f input_data/* /input/

echo "6. Removing old output directory on HDFS..."
hdfs dfs -rm -r -f /output

echo "7. Running MapReduce Job..."
hadoop jar wordcount.jar wordcount.WordCountDriver /input /output

echo "8. Viewing results..."
hdfs dfs -cat /output/part-r-00000
