package br.ufrj.main;

import flanagan.analysis.Stat;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;

import br.ufrj.main.Main.Activity;

/**
 *
 * @author vitor
 */
public class Process {

	public static final int KB = 1024;
	public static final int MB = KB*KB;
    public static final String outputFileName = "ERelation.txt";
    private static Random random = new Random(100);
    
    private static void sleep(long elapsedTime) {
        try {
            Thread.sleep(elapsedTime);
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
    
    public static String getFields(ArrayList<ArrayList<String>> tuple){
        String relation = "";
        for(ArrayList<String> col : tuple){
        	if (col.get(0).equals("OUTPUT_FILE") || col.get(0).equals("BIGSTRING")) continue;
            if(!relation.isEmpty()){
                relation += ";";
            }
            
            relation += col.get(0);
        }
        
        return relation;
    }
    
    public static String getValues(ArrayList<ArrayList<String>> tuple){
        String relation = "";
        String row = "";
        
        for(ArrayList<String> col : tuple){
        	if (col.get(0).equals("OUTPUT_FILE") || col.get(0).equals("BIGSTRING")) continue;
            if(!row.isEmpty()){
                row += ";";
            }

            row += col.get(1);
        }
        relation += "\n" + row;
        
        return relation;
    }
    
    public static String getSplitFields(ArrayList<ArrayList<String>> tuple){
        String relation = "";
        for(ArrayList<String> col : tuple){
            if(!relation.isEmpty() && !col.get(0).equals("SPLITFACTOR")){
                relation += ";";
            }
            
            if(!col.get(0).equals("FILTERFACTOR1") && !col.get(0).equals("FILTERFACTOR2")
                    && !col.get(0).equals("REDUCEFACTOR") && !col.get(0).equals("SPLITFACTOR")){
                relation += col.get(0);
            }else if(col.get(0).equals("FILTERFACTOR1") || col.get(0).equals("FILTERFACTOR2")){
                relation += col.get(0).replaceAll("ILTERFACTOR", "");
            }else if(col.get(0).equals("REDUCEFACTOR")){
                relation += col.get(0).replaceAll("FACTOR", "VALUE");
            }
        }
        
        relation += ";IFILE";
        
        return relation;
    }
    
    public static void generateRelation(ArrayList<ArrayList<String>> tuple, int kbInRelation, int mbInFile, String ofile, boolean shouldWriteInRelation, boolean shouldWriteInFile){
        try{
            FileWriter fstream = new FileWriter(outputFileName);
            BufferedWriter out = new BufferedWriter(fstream);

            String relation = getFields(tuple);
            if (shouldWriteInRelation)
            	relation += ";BIGSTRING";
            if (shouldWriteInFile)
            	relation += ";OUTPUT_FILE";
            
            relation += getValues(tuple);
            String stringInRelation = "";
            
            if (shouldWriteInRelation)
            	relation += ";"+stringInRelation;
            if (shouldWriteInFile)
            	relation += ";"+ofile;
            
            if (Main.shouldPrintStdOut)
            	System.out.println(relation);
            
            out.write(relation);
            out.flush();
            out.close();
        }catch (Exception e){//Catch exception if any
            System.err.println("Error: " + e.getMessage());
        }
    }
    
    public static void executeSplitMap(int elapsedTime, ArrayList<ArrayList<String>> tuple, String path, int kbInRelation, int mbInFile, String ofile, boolean shouldWriteInRelation, boolean shouldWriteInFile) {
        
        try{
        	long t1 = System.currentTimeMillis();
            FileWriter fstream = new FileWriter(outputFileName);
            BufferedWriter out = new BufferedWriter(fstream);
            
            String relation = getSplitFields(tuple);
            
            float filter1Factor = -1;
            float filter2Factor = -1;
            int splitMapFactor = -1;
            int reduceFactor = -1;
            
            for(ArrayList<String> col : tuple){
                if(col.get(0).equals("FILTERFACTOR1")){
                    filter1Factor = Float.parseFloat(col.get(1)) / (float) 100.00 ;
                }else if(col.get(0).equals("FILTERFACTOR2")){
                    filter2Factor = Float.parseFloat(col.get(1)) / (float) 100.00 ;
                }else if(col.get(0).equals("SPLITFACTOR")){
                    splitMapFactor = Integer.parseInt(col.get(1));
                }else if(col.get(0).equals("REDUCEFACTOR")){
                    reduceFactor = Integer.parseInt(col.get(1));
                }
            }
            
            int filter1 = (int) Math.ceil(splitMapFactor * filter1Factor);
            int filter2 = (int) Math.ceil(splitMapFactor * filter2Factor);
                     
            String stringInRelation = "";
            
            int id = 0;
            for(int splitRow=0; splitRow<splitMapFactor; splitRow++){
                String row = "";
                int reduceValue = splitRow % reduceFactor;
        
                for(ArrayList<String> col : tuple){
                    if(!row.isEmpty() && !col.get(0).equals("SPLITFACTOR")){
                        row += ";";
                    }

                    if(col.get(0).equals("FILTERFACTOR1")){
                        if(splitRow < filter1){
                            row += "1.0";
                        }else{
                            row += "0.0";
                        }
                    }else if(col.get(0).equals("FILTERFACTOR2")){
                        if(splitRow < filter2){
                            row += "1.0";
                        }else{
                            row += "0.0";
                        }
                    }else if(col.get(0).equals("ID")){
                        id++;
                        row += Integer.toString(id);
                    }else if(col.get(0).equals("REDUCEFACTOR")){
                        row += Integer.toString(reduceValue);
                    }else if(col.get(0).equals("OUTPUT_FILE")){
                        row += Main.bigdir+ofile;
                    }else if(col.get(0).equals("BIGSTRING") && !stringInRelation.isEmpty()){
                    	row += stringInRelation;
                    }else if(!col.get(0).equals("SPLITFACTOR")){
                        row += activityExecutionTime(Integer.valueOf(col.get(1)),2);
                    }
                }
                
                File selected = Utils.randomSelection(path, "S.DAT");
                row += ";" + selected.getName();
               
                
                relation += "\n" + row;
            }
            
            
            out.write(relation);
            out.flush();
            out.close();
            
            if (Main.shouldPrintStdOut)
            	System.out.println(relation);
            
            
            long t2 = System.currentTimeMillis();
            
            long sleepTime = Math.max( (1000*elapsedTime) - (t2-t1), 0);
            sleep( sleepTime);
            
        }catch (Exception e){//Catch exception if any
            System.err.println("Error: " + e.getMessage());
        }
    }
    
    protected static int activityExecutionTime(int avg, int qtd) {
    	if (Main.balanced)
    		return avg * 1000;
    	else
        return (int) (1000 * Stat.gammaRand(0, 1, avg, qtd, random.nextLong())[1]);
    }

    public static void executeMap(Activity activity, int elapsedTime, ArrayList<ArrayList<String>> tuple, String path, String ifile, int kbInRelation, int mbInFile, String ofile, boolean shouldWriteInRelation, boolean shouldWriteInFile) {
        sleep(elapsedTime);
        
        String previousSuffix = null;
        String suffix = null;
        if(activity == Activity.MAP1){
            previousSuffix = "S.DAT";
            suffix = "SI.SAI";
        }else if(activity == Activity.MAP2){
            previousSuffix = "SI.SAI";
            suffix = "SS.SAI";
        }
        
        if(previousSuffix != null && suffix != null){
            File selected = Utils.selectFile(path, ifile, previousSuffix, suffix);

            ArrayList<String> col = new ArrayList<String>();
            suffix = suffix.replace(".", "");
            col.add(suffix);
            col.add(selected.getAbsolutePath());
            tuple.add(col);

            Utils.selectRandomData(activity, selected, tuple);
        }

        generateRelation(tuple, kbInRelation, mbInFile, ofile, shouldWriteInRelation, shouldWriteInFile);
    }

    public static void executeFilter(Activity act, int elapsedTime, ArrayList<ArrayList<String>> tuple, int kbInRelation, int mbInFile, String ofile, boolean shouldWriteInRelation, boolean shouldWriteInFile) {
        sleep(elapsedTime);
        
        tuple = filterTuple(tuple);
        
        generateRelation(tuple, kbInRelation, mbInFile, ofile, shouldWriteInRelation, shouldWriteInFile);
    }

    public static ArrayList<ArrayList<String>> filterTuple(ArrayList<ArrayList<String>> tuple) {
        for(ArrayList<String> col : tuple){
            String field = col.get(0);
            String value = col.get(1);
            
            if(field.length()==2 && (field.equals("F1") || field.equals("F2")) && Double.parseDouble(value)==0.0){
                return new ArrayList<ArrayList<String>>();
            }
        }
            
        return tuple;
    }

    public static void executeReduce(int elapsedTime, ArrayList<ArrayList<String>> tuple, String docName, int kbInRelation, int mbInFile, String ofile) {
        try{
            FileReader reader = new FileReader(docName.toLowerCase() + ".hfrag");
            Scanner in = new Scanner(reader);

            String relation = "";
            int minID = -1;
            int reduce = -1;
            int reduceValue = -1;
            
            relation += "ID;REDUCE;REDUCEVALUE\n";
            in.nextLine();
            while(in.hasNextLine()){
                String[] split = in.nextLine().split(";");
                String idStr = split[0];
                String rStr = split[1];
                String rvStr = split[2];
                
                if(minID == -1 || Integer.parseInt(idStr) < minID){
                    minID = Integer.parseInt(idStr);
                }
                
                if(reduceValue==-1){
                    reduceValue = Integer.parseInt(rvStr);
                }
                
                int value = Integer.parseInt(rStr);
                if(reduce == -1){
                    reduce = value;
                }else if(reduce != -1 && reduce < value){
                    reduce = value;
                }
            }
            
            sleep(reduce);
                  
            relation += String.valueOf(minID) + ";" 
                    + String.valueOf(reduce) + ";" 
                    + String.valueOf(reduceValue) + "\n";
            
            File fout = new File(outputFileName);
            FileOutputStream fo = new FileOutputStream(fout);
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(fo));
            writer.write(relation);
            writer.flush();
            writer.close();
        }catch (Exception e){//Catch exception if any
            System.err.println("Error: " + e.getMessage());
        }
    }
   
    
}
