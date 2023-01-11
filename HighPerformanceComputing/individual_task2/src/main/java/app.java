import java.util.Scanner;
import java.io.IOException;

public class app {
    private static final String COMMA = ",";
    private static final String delimiter = "-";
    private static final String tableName = "CityWithTime";
    private static final String columnFamily = "Dates";

    public static String[] getTimeRange(String path, String input) {
        String[] info = input.split(COMMA);
        if (info.length != 3) {
            System.out.println("Wrong input, please restart the app!");
            System.exit(1);
        }
        String[] start = info[1].split(delimiter);
        int startDate = Integer.parseInt(start[2]);
        String[] finish = info[2].split(delimiter);
        int finishDate = Integer.parseInt(finish[2]);
        int num = finishDate - startDate + 1;

        String[] timeRange = new String[num];
        String prefix = path + "/2022-1-";
        String file = "";
        for (int i = 0; i < num; i++, startDate++) {
            file = file + prefix + String.valueOf(startDate) + ".log";
            timeRange[i] = file;
            file = "";
        }
        return timeRange;
    }

    public static void main(String[] args) throws IOException{
        Scanner sc = new Scanner(System.in);
        System.out.println("This app returns the visited cities for a mobile between 2022-1-1 and 2022-1-31");
        System.out.println("Usage: mobile,start_date,end_date");
        System.out.println("Example: 15705140455,2022-1-1,2022-1-4");
        System.out.println("Please enter mobile,start_date,end_date:");

        String input = sc.next();
        String[] info = input.split(COMMA);
        if (info.length != 3) {
            System.out.println("Wrong input, please restart the app!");
            System.exit(1);
        }
        String mobile = info[0];
        //[2022-1-10,2022-1-11,2022-1-12.....]
        String[] timeRange = getTimeRange(args[0], input);
        searchWithTime.searchCities(args[1], timeRange, mobile);

    }
}
