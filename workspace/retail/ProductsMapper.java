package retail;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class ProductsMapper extends Mapper<LongWritable, Text, Text, IntWritable> {

    private final static IntWritable one = new IntWritable(1);
    private Text product = new Text();

    public void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        // Splitting the line by comma for CSV processing
        String[] items = value.toString().split(",");
        for (String item : items) {
            String trimmedItem = item.trim();
            if (!trimmedItem.isEmpty()) {
                product.set(trimmedItem);
                context.write(product, one);
            }
        }
    }
}
