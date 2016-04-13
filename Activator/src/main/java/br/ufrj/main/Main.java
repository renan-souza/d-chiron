package br.ufrj.main;

import java.util.ArrayList;

public class Main {
	public enum Activity {
		SPLITMAP, MAP1, MAP2, FILTER1, FILTER2, REDUCE
	}

	public static String bigdir = "";
	public static boolean shouldPrintStdOut = false, balanced = false, enableRandom=true;
	
	public static void main(String[] args) {
		if (args.length > 0) {
			Activity act = null;
			String relation = "";
			String path = "";
			String ifile = "";
			
			boolean shouldWriteInRelation = false, shouldWriteInFile = false;
			String ofile = "";
			int mbInRelation = 0, mbInFile = 0;
			int elapsedTime = -1;
			ArrayList<ArrayList<String>> tuple = new ArrayList<ArrayList<String>>();

			for (String arg : args) {
				String[] splits = arg.split("=");
				String field = splits[0].toUpperCase();
				String value = splits[1].trim().toUpperCase();

				if (field.equals("TYPE"))
					act = Activity.valueOf(value);
				else if (field.equals("RELATION"))
					relation = value;
				else if (field.equals("PATH"))
					path = splits[1].trim();
				else if (field.equals("BIGDIR"))
					bigdir = splits[1].trim();
				else if (field.equals("IFILE"))
					ifile = splits[1].trim();
				else if (field.equals("BALANCED"))
					balanced = Boolean.parseBoolean(splits[1].trim()
							.toLowerCase());
				else if (field.equals("ENABLERANDOM"))
					enableRandom = Boolean.parseBoolean(splits[1].trim()
							.toLowerCase());
				else if (field.equals("SISAI"))
					ifile = splits[1].trim();
				else if (field.equals("STDOUT"))
					shouldPrintStdOut = Boolean.parseBoolean(splits[1].trim()
							.toLowerCase());
				else if (field.equals("SHOULD_WRITE_RELATION")) {
					shouldWriteInRelation = Boolean.parseBoolean(splits[1]
							.trim().toLowerCase());
					if (shouldWriteInRelation) {
						ArrayList<String> col = new ArrayList<String>();
						col.add("BIGSTRING");
						col.add("");
						tuple.add(col);
					}
				} else if (field.equals("SHOULD_WRITE_FILE"))
					shouldWriteInFile = Boolean.parseBoolean(splits[1].trim()
							.toLowerCase());
				else if (field.equals("KB_IN_RELATION"))
					mbInRelation = Integer.parseInt(splits[1].trim().toLowerCase());
				else if (field.equals("MB_IN_FILE"))
					mbInFile = Integer.parseInt(splits[1].trim().toLowerCase());
				else if (field.equals("OUTPUT_FILE"))
					ofile = splits[1].trim();
				else {
					ArrayList<String> col = new ArrayList<String>();
					col.add(field);
					col.add(value);
					tuple.add(col);
				}
			}
			if (shouldWriteInFile) {
				ArrayList<String> col = new ArrayList<String>();
				col.add("OUTPUT_FILE");
				col.add(ofile);
				tuple.add(col);
			} 
			for (ArrayList<String> col : tuple) {
				if (act != null && col.get(0).equals(act.toString())) {
					elapsedTime = Integer.parseInt(col.get(1));
					tuple.remove(col);
					break;
				}
			}

			executeActivity(act, elapsedTime, tuple, relation, path, ifile,
					mbInRelation, mbInFile, ofile, shouldWriteInRelation,
					shouldWriteInFile);
		} else {
			System.out.println("Wrong arguments");
		}
	}

	public static void executeActivity(Activity act, int elapsedTime,
			ArrayList<ArrayList<String>> tuple, String relation, String path,
			String ifile, int kbInRelation, int mbInFile, String ofile,
			boolean shouldWriteInRelation, boolean shouldWriteInFile) {
		if (act == Activity.SPLITMAP) {
			Process.executeSplitMap(elapsedTime, tuple, path, kbInRelation,
					mbInFile, ofile, shouldWriteInRelation, shouldWriteInFile);
		} else if (act == Activity.MAP1 || act == Activity.MAP2) {
			Process.executeMap(act, elapsedTime, tuple, path, ifile,kbInRelation, mbInFile, ofile, shouldWriteInRelation, shouldWriteInFile);
		} else if (act == Activity.FILTER1 || act == Activity.FILTER2) {
			Process.executeFilter(act, elapsedTime, tuple, kbInRelation,mbInFile, ofile, shouldWriteInRelation, shouldWriteInFile);
		} else if (act == Activity.REDUCE) {
			Process.executeReduce(elapsedTime, tuple, relation, kbInRelation,
					mbInFile, ofile);
		}
	}
}
