package br.ufrj.main;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;
import java.util.Scanner;

import br.ufrj.main.Main.Activity;

/**
 *
 * @author vitor
 */
public class Utils {
    
    public static String readFile(String filepath) throws FileNotFoundException {
        File fr = new File(filepath);
        Scanner sc = new Scanner(fr);
        
        while(sc.hasNextLine()){
            String line = sc.nextLine();
            System.out.println(line);
        }
        
        return "read";
    }

    public static ArrayList<File> getFilteredFiles(String path, String suffix) {
        File folder = new File(path);
        File[] listOfFiles = folder.listFiles();
        ArrayList<File> filtered = new ArrayList<File>();

        for (File element : listOfFiles) {
          if (element.isFile() && element.getName().endsWith(suffix)) {
            filtered.add(element);
          }
        }
        
        return filtered;
    }
    
    public static File selectFile(String filePath, String inputFilePath, String previousSuffix, String newSuffix) {
        String[] slices = inputFilePath.split("/");
        String fileName = slices[slices.length - 1].replaceAll(previousSuffix, newSuffix);
        
        File file = new File(filePath + "/" + fileName);
        //Utils.copyFile(file.getAbsolutePath(), ".");
        
        return file;
    }

    public static File randomSelection(String path, String sdat) {
        ArrayList<File> files = getFilteredFiles(path, sdat);
        if (Main.enableRandom)
        	Collections.shuffle(files);
        
        File selected = files.get(0);
        //Utils.copyFile(selected.getAbsolutePath(), ".");
        
        return selected;
    }
    
    public static void copyFile(String origin, String destination) {
        try {
            String cmd = "";
            if (Utils.isWindows()) {
                cmd = "xcopy " + origin + " " + destination;
                cmd = cmd.replace("/", "\\");
                cmd += " /q /c /y";
            } else {
                Utils.createDirectory(destination);
                cmd = "cp " + origin + " " + destination;
            }
            runCommand(cmd, null);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
    
    public static boolean isWindows() {
        String os = System.getProperty("os.name").toLowerCase();
        return (os.indexOf("win") >= 0);
    }

    public static boolean isMacOS() {
        String os = System.getProperty("os.name").toLowerCase();
        return (os.indexOf("mac") >= 0);
    }
    
    public static int runCommand(String cmd, String dir) throws IOException, InterruptedException {
        Runtime run = Runtime.getRuntime();
        int result = 0;
        String command[] = null;
        if (Utils.isWindows()) {
            String cmdWin[] = {"cmd.exe", "/c", cmd};
            command = cmdWin;
        } else {
            String cmdLinux = cmd;
            if (cmd.contains(">")) {
                cmdLinux = cmd.replace(">", ">>");
            }
            String cmdLin[] = {"/bin/bash", "-c", cmdLinux};
            command = cmdLin;
        }
        
        java.lang.Process pr = null;
        if (dir == null) {
            pr = run.exec(command);
        } else {
            pr = run.exec(command, null, new File(dir));
        }
        pr.waitFor();
        pr.destroy();
        
        return result;
    }
    
    public static boolean createDirectory(String directory) {
        boolean result = true;
        File f = new File(directory);
        try {
            f.mkdir();
        } catch (Exception e) {
            result = false;
            e.printStackTrace();
        }
        f = null;
        return result;
    }

    public static void selectRandomData(Activity activity, File filepath, ArrayList<ArrayList<String>> tuple) {
        try {
            int lineIndex = selectRandomValidLine(activity);

            Scanner sc = new Scanner(filepath);
            int counter = 0;
            while(sc.hasNextLine()){
                counter++;
                String line = sc.nextLine();

                if(counter == lineIndex){
                    extractDataToMapActivity(activity, tuple, line);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void extractDataToMapActivity(Activity activity, ArrayList<ArrayList<String>> tuple, String line) {
        String[] slices = line.trim().split(" ");
        
        String[] columns = null;
        
        if(activity == Activity.MAP1){
            columns = new String[]{
                "NUMBER","NAME","CX","CY","CZ","SX","SY","SZ","RX","RY","RZ","FAX"};
        }else if(activity == Activity.MAP2){
            columns = new String[]{
                "ELEMENT","NODE","TENSION","FX","FY","FZ","MX","MY","MZ","CURVATURE"};
        }
        
        ArrayList<String> values = new ArrayList<String>();
        for(String slice : slices){
            if(!slice.isEmpty()){
                if(slice.endsWith(".")){
                    slice = slice.replace(".", "");
                }
                
                if(slice.contains("E-")){
                    slice = "0.0000";
                }
                        
                values.add(slice);
            }
        }
        
        
        for(int i=0; i<columns.length; i++){
            ArrayList<String> col = new ArrayList<String>();
            col.add(columns[i]);
            col.add(values.get(i));
            tuple.add(col);
        }
    }

    private static int selectRandomValidLine(Activity activity) {
        int groupSortValue = -1;
        int groupSortLimit = -1;
        int groupSortInterval = -1;
        int lineSortRange = -1;
        int line = -1;        
        
        if(activity == Activity.MAP1){
        	line = 33;
            groupSortValue = 159;
            groupSortLimit = 7089;
            groupSortInterval = 63;
            lineSortRange = 44;
        }else if(activity == Activity.MAP2){
        	line = 11;
            groupSortValue = 10371;
            groupSortLimit = 27249;
            groupSortInterval = 58;
            lineSortRange = 15;
        }
        
        ArrayList<String> index = new ArrayList<String>();
        int group = groupSortValue;
        while(group < groupSortLimit){
            index.add(String.valueOf(group));
            group += groupSortInterval;
        }
        int groupIndex = group;
        if (Main.enableRandom) {
        	Collections.shuffle(index);
        	groupIndex = Integer.parseInt(index.get(0));        	
        	Random randomGenerator = new Random();        
        	line = randomGenerator.nextInt(lineSortRange);
        }      
        if(activity == Activity.MAP2){
            line *= 3;
        }        
        int lineIndex = groupIndex + line;
        
        return lineIndex;
    }
    
}
