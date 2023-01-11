import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.mllib.clustering.KMeans;
import org.apache.spark.mllib.clustering.KMeansModel;
import org.apache.spark.mllib.linalg.Vector;
import org.apache.spark.mllib.linalg.Vectors;
import scala.Tuple2;

import java.io.IOException;
import java.util.Arrays;
import java.util.regex.Pattern;

public class TravelCodeKMeans {
    private static final Pattern ROW = Pattern.compile("\\n");
    private static final Pattern COMMA = Pattern.compile(",");
    private static final Pattern SPACE = Pattern.compile(" ");

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

    public static String extractLocation(String line) {
        if (line.equals("")) {
            return "";
        }
        String[] record = COMMA.split(line);
        String LNG = record[4];
        String LAT = record[5];
        return LNG+"_"+LAT;
    }

    public static void main(String[] args) throws IOException{

        SparkConf conf = new SparkConf().setAppName("TravelCodeKMeans").setMaster("local");;
        JavaSparkContext jsc = new JavaSparkContext(conf);

        // Read Logs
        JavaRDD<String> context = jsc.textFile(args[0]);
        JavaRDD<String> lines = context.flatMap(s -> Arrays.asList(ROW.split(s)).iterator());
        JavaPairRDD<String, String> logPair = lines.mapToPair(x -> new Tuple2(extractKey(x), extractValue(x)));
        JavaPairRDD<String, String> logRdd = logPair.distinct();

        // Read csv file
        JavaRDD<String> csvFile = jsc.textFile(args[1]);
        JavaRDD<String> csvLine = csvFile.flatMap(s -> Arrays.asList(ROW.split(s)).iterator());
        JavaPairRDD<String, String> csvRdd = csvLine.mapToPair(x -> new Tuple2(extractCsvKey(x), extractLocation(x)));

        // Join two dataset
        JavaPairRDD<String, Tuple2<String, String>> joined =
                (JavaPairRDD<String, Tuple2<String, String>>) logRdd.join(csvRdd);
        JavaRDD<Tuple2<String, String>> mobileCity = joined.map(x -> x._2());
        JavaPairRDD<String, String> mobileLocation = (JavaPairRDD<String, String>) JavaPairRDD.fromJavaRDD(mobileCity);
        JavaRDD<String> location = mobileLocation.map(x -> x._2.replace("_",","));


        JavaRDD<Vector> parsedData = location.map(s -> {
            String[] sarray = s.split(",");
            double[] values = new double[sarray.length];
            for (int i = 0; i < sarray.length; i++) {
                values[i] = Double.parseDouble(sarray[i].trim());
            }
            return Vectors.dense(values);
        });

        parsedData.cache();

        // Cluster the data into five classes using KMeans
        int numClusters = 5;
        int numIterations = 20;
        KMeansModel clusters = KMeans.train(parsedData.rdd(), numClusters, numIterations);

        System.out.println("Cluster centers:");
        for (Vector center: clusters.clusterCenters()) {
            System.out.println(" " + center);
        }
        double cost = clusters.computeCost(parsedData.rdd());
        System.out.println("Cost: " + cost);

        // Evaluate clustering by computing Within Set Sum of Squared Errors
        double WSSSE = clusters.computeCost(parsedData.rdd());
        System.out.println("Within Set Sum of Squared Errors = " + WSSSE);

        // Save and load model
        clusters.save(jsc.sc(), "target/KMeansModel");
        KMeansModel sameModel = KMeansModel.load(jsc.sc(),
                "target/KMeansModel");

        jsc.stop();
    }


}
