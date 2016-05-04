package br.ufrj.main.utils
import java.text.SimpleDateFormat
import java.util.Date

object Utils {
  def formatDate(date:Date):String = {
    val sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH.mm.ss.S");
    return sdf.format(date)
  }
  
  def getPrettyNow():String = {
    return formatDate(new Date())
  }
}