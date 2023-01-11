import org.apache.hadoop.hbase.client.*;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.SparkSession;
import scala.Tuple2;
import java.util.Arrays;
import java.util.regex.Pattern;



public class searchWithTime {
    private static final Pattern ROW = Pattern.compile("\\n");
    private static final Pattern COMMA = Pattern.compile(",");
    private static final Pattern SPACE = Pattern.compile(" ");
    private static Connection connection = null;
    private static Admin admin = null;
    private static final String tableName = "CityWithTime";
    private static final String columnFamily = "Dates";

    public static String extractKey(String line) {
        if (line.equals("")) {
            return "";
        }
        String[] record = COMMA.split(line);
        String LAC = record[1];
        String CELL = record[2];

        return LAC + "-" + CELL;
    }


    public static String extractValue(String line) {
        if (line.equals("")) {
            return "";
        }
        String[] record = COMMA.split(line);
        return record[3];
    }


    public static String extractCsvKey(String line) {
        if (line.equals("")) {
            return "";
        }
        String[] record = COMMA.split(line);
        String LAC = record[2];
        String CELL = record[3];

        return LAC + "-" + CELL;
    }

    public static String extractCity(String line) {
        if (line.equals("")) {
            return "";
        }
        String[] record = COMMA.split(line);

        return record[12];
    }

    public static void searchCities(String file, String[] timeRange, String mobile) {
        SparkSession spark = SparkSession.builder().appName("TravelLog").config("spark.master", "local").getOrCreate();
        JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());

        // Read Logs
        JavaRDD<String> context = spark.read().textFile(timeRange).javaRDD();
        JavaRDD<String> lines = context.flatMap(s -> Arrays.asList(ROW.split(s)).iterator());
        JavaPairRDD<String, String> logPair1 = lines.mapToPair(x -> new Tuple2(extractKey(x), extractValue(x)));
        JavaPairRDD<String, String> logPair2 = logPair1.filter(x -> x._2.equals(mobile));
        JavaPairRDD<String, String> logRdd = logPair2.distinct();

        // Read csv file
        JavaRDD<String> csvFile = spark.read().textFile(file).javaRDD();
        JavaRDD<String> csvLine = csvFile.flatMap(s -> Arrays.asList(ROW.split(s)).iterator());
        JavaPairRDD<String, String> csvRdd = csvLine.mapToPair(x -> new Tuple2(extractCsvKey(x), extractCity(x)));

        // Join two dataset
        JavaPairRDD<String, Tuple2<String, String>> joined =
                (JavaPairRDD<String, Tuple2<String, String>>) logRdd.join(csvRdd);
        JavaRDD<Tuple2<String, String>> mobileCity = joined.map(x -> x._2());
        JavaPairRDD<String, String> mobileLocation = (JavaPairRDD<String, String>) JavaPairRDD.fromJavaRDD(mobileCity);
        JavaPairRDD groupByKeyResult = mobileLocation.distinct().groupByKey();

        groupByKeyResult.foreach(x -> System.out.println(x));
        spark.stop();

    }


}
















