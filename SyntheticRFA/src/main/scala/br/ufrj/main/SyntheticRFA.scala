package br.ufrj.main

  
import java.io.FileOutputStream

import br.ufrj.main.utils.Utils
import org.apache.commons.io.IOUtils
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.apache.spark.rdd.RDD.rddToPairRDDFunctions

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

import java.io.File



object SyntheticRFA {
  
  var isDebug = false

  def main(args: Array[String]) {
  	val tiTotal = System.currentTimeMillis()
  	println("Starting...")
    val sparkMaster = args(0)
    println("sparkMaster="+sparkMaster)
    val totalNumberOfCores = args(1).toInt
    println("totalNumberOfCores="+totalNumberOfCores)
    val inputPath = new File(args(2)).getAbsolutePath()
    println("inputPath="+inputPath)
    val tagName = args(3)
    println("tagName="+tagName)
    val outputDir = new File(args(4)).getAbsolutePath()
    println("outputDir="+outputDir)
    val balanced = args(5).toBoolean
    println("balanced="+balanced)
    isDebug = args(6).toBoolean
    println("isDebug="+isDebug)
    val path = new File(args(7)).getAbsolutePath()
    println("path="+path)
    val activatorJarPath = new File(args(8)).getAbsolutePath()
    println("activatorJarPath="+activatorJarPath)
    val swbPath = new File(args(9)).getAbsolutePath()
    println("swbPath="+swbPath)
    val enableRandom = args(10).toBoolean
    println("enableRandom="+enableRandom)
  	
    val tasksPath = outputDir+"/"+"tasks"
    
    var times=""
    val conf = new SparkConf().setAppName("SyntheticRFA App").setMaster(sparkMaster)
    val sc = new SparkContext(conf)

    val ti = System.currentTimeMillis()

    //Reading Input Data
    val inputData = sc.textFile(inputPath).filter(x => !x.contains("ID"))
    inputData.cache()
//   //We do a cache in the line above. 
    
    //Executing Act 1 (SplitMap)

  	val uncompress = inputData.flatMap{x =>
  	   val taskId = org.apache.spark.TaskContext.get().taskAttemptId()
  	   val dir = new File(tasksPath+"/task"+taskId.toString())
  	   dir.mkdirs()
  	   val outs = x.split(";")
  	   val commandLineForSplitMap = Seq("TYPE=SPLITMAP", s"ID=${outs(0)}", s"SPLITMAP=${outs(1)}", s"SPLITFACTOR=${outs(2)}", s"MAP1=${outs(3)}", s"MAP2=${outs(4)}", s"FILTER1=${outs(5)}", s"FILTERFACTOR1=${outs(6)}", s"FILTER2=${outs(7)}", s"FILTERFACTOR2=${outs(8)}", s"REDUCE=${outs(9)}", s"REDUCEFACTOR=${outs(10)}", s"PATH=${path}", s"STDOUT=true", s"BALANCED=${balanced}", s"ENABLERANDOM=${enableRandom}")
  	   val output = sys.process.Process((Seq("java","-jar", activatorJarPath) ++ commandLineForSplitMap), dir).!!
       debugMsg("SplitMap", taskId, org.apache.spark.TaskContext.getPartitionId(), output)
       output.lines.drop(1).map{ x=>
  	       val t = x.split(';')
  	       (t(0),t)
  	   }
    }
    .repartition(totalNumberOfCores)
    //We do a repartition in the line above (the only place where we repartition is here)
    

    
    //Executing Act 2 (Map1) 

    val preprocessing = uncompress.map { x =>
      val taskId = org.apache.spark.TaskContext.get().taskAttemptId()
      val dir = new File(tasksPath+"/task"+taskId.toString())
  	  dir.mkdirs()
      val commandLineForMap1 = Seq(s"TYPE=MAP1", s"ID=${x._2(0)}", s"MAP1=${x._2(1)}", s"MAP2=${x._2(2)}", s"FILTER1=${x._2(3)}", s"F1=${x._2(4)}", s"FILTER2=${x._2(5)}", s"F2=${x._2(6)}", s"REDUCE=${x._2(7)}", s"REDUCEVALUE=${x._2(8)}", s"IFILE=${x._2(9)}", s"PATH=${path}", s"STDOUT=true", s"ENABLERANDOM=${enableRandom}")
      val output = sys.process.Process((Seq("java","-jar", activatorJarPath) ++ commandLineForMap1), dir).!!
      debugMsg("Map1", taskId, org.apache.spark.TaskContext.getPartitionId(), output)
      val t = output.split("\n")(1).split(';')
      (t(0),t)
    }

    
    //Executing Act 3 (Map2)

    var analyzerisers = preprocessing.map { x =>
      val taskId = org.apache.spark.TaskContext.get().taskAttemptId()
      val dir = new File(tasksPath+"/task"+taskId.toString())
  	  dir.mkdirs()
      val commandLineForMap2 = Seq(s"TYPE=MAP2", s"ID=${x._2(0)}", s"MAP2=${x._2(1)}", s"FILTER1=${x._2(2)}", s"F1=${x._2(3)}", s"FILTER2=${x._2(4)}", s"F2=${x._2(5)}", s"REDUCE=${x._2(6)}", s"REDUCEVALUE=${x._2(7)}", s"SISAI=${x._2(8)}", s"PATH=${path}", s"STDOUT=true", s"ENABLERANDOM=${enableRandom}")
      val output = sys.process.Process((Seq("java","-jar", activatorJarPath) ++ commandLineForMap2), dir).!!
      debugMsg("Map2", taskId, org.apache.spark.TaskContext.getPartitionId(), output)
      val t = output.split("\n")(1).split(';')
      (t(0),t)
    }
    analyzerisers.cache()

    //Executing Act 4 (Filter1)

    val calcweartear = analyzerisers.filter{x =>
      val taskId = org.apache.spark.TaskContext.get().taskAttemptId()
      val dir = new File(tasksPath+"/task"+taskId.toString())
  	  dir.mkdirs()
      val commandLineForFilter1 = Seq(s"TYPE=FILTER1", s"ID=${x._2(0)}", s"FILTER1=${x._2(1)}", s"F1=${x._2(2)}", s"REDUCE=${x._2(5)}", s"REDUCEVALUE=${x._2(6)}", s"STDOUT=true", s"ENABLERANDOM=${enableRandom}")
      val output = sys.process.Process((Seq("java","-jar", activatorJarPath) ++ commandLineForFilter1), dir).!!     
      debugMsg("Filter1", taskId, org.apache.spark.TaskContext.getPartitionId(), output)
      (output != "\n\n")
    }
    
    //Executing Act 5 (Filter2)

    val analyzeposition = analyzerisers.filter{x =>
      val taskId = org.apache.spark.TaskContext.get().taskAttemptId()
      val dir = new File(tasksPath+"/task"+taskId.toString())
      dir.mkdirs()
      val commandLineForFilter2 = Seq(s"TYPE=FILTER2", s"ID=${x._2(0)}", s"FILTER2=${x._2(3)}", s"F2=${x._2(4)}", s"STDOUT=true", s"ENABLERANDOM=${enableRandom}")
      val output = sys.process.Process((Seq("java","-jar", activatorJarPath) ++ commandLineForFilter2), dir).!!
      debugMsg("Filter2", taskId, org.apache.spark.TaskContext.getPartitionId(), output)
      (output != "\n\n")
    }

    //Executing Act 6 (Join)

    var joinResults = calcweartear.join(analyzeposition)
    
    //Executing Act 7 (Reduce)
    val red = joinResults.map{x => 
      if (isDebug) {
        debugMsg("Join",org.apache.spark.TaskContext.get().taskAttemptId(), org.apache.spark.TaskContext.getPartitionId(), x._2._1(6) +"->"+ x._2._1.mkString(","));
      }
      (x._2._1(6),x._2._1)}
    .reduceByKey {
      (x, y) =>
        debugMsg("Reduce", org.apache.spark.TaskContext.get().taskAttemptId(), org.apache.spark.TaskContext.getPartitionId(), (x,y).toString)
        x
    }
    //After reducing tuples, now executing Reduce activity
    val redPipe = red.map(x => x._2.mkString(",")).pipe("python "+swbPath)
    redPipe.count()
    //We do an action above
    //END OLD
   
    val tf = System.currentTimeMillis()
    val tfTotal = System.currentTimeMillis()
    
    var lastMsg =Utils.getPrettyNow() + ": " + tagName + "\n";
    lastMsg += Utils.getPrettyNow() + ": Only main Spark process took " + (tf - ti) / 1000.0 + " seconds\n"
     lastMsg += Utils.getPrettyNow() + ": Whole Spark process took " + (tfTotal - tiTotal) / 1000.0 + " seconds\n"
     lastMsg+= "\n"+times+"\n";
    println(lastMsg)
    
    val fout = new File(outputDir + "/results")
    fout.mkdirs()
    val fos = new FileOutputStream(fout.getAbsolutePath+"/Result-" + tagName + "-" + Utils.getPrettyNow() + ".log")
   
    IOUtils.write(lastMsg.toCharArray(), fos)
   }
  
  def debugMsg(actname:String, taskId:Long, partitionId:Int, msg:String) {
    if (isDebug) {
      println("\n["+actname+"][TaskId="+taskId+"][PartitionId="+partitionId+"][ERelation.txt=]["+msg+"]")
    }
  }
}