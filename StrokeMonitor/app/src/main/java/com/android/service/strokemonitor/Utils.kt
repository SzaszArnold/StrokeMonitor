package com.android.service.strokemonitor

import android.content.Context
import android.text.TextUtils
import android.util.Log
import android.widget.Toast
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import com.huawei.hmf.tasks.Task
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HiHealthOptions
import com.huawei.hms.hihealth.HiHealthStatusCodes
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.*
import com.huawei.hms.hihealth.options.ReadOptions
import com.huawei.hms.hihealth.result.ReadReply
import com.huawei.hms.support.hwid.HuaweiIdAuthManager
import kotlinx.android.synthetic.main.activity_mainpage.*
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.time.milliseconds

fun logger(string: String) {
    Log.i("DataController", string);
}
private fun showSampleSet(sampleSet: SampleSet) {
    var auth: FirebaseAuth = FirebaseAuth.getInstance()
    val currentUser = auth.currentUser!!.email.toString()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
    for (samplePoint in sampleSet.samplePoints) {
        val reference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@"))
        val id = reference.push().key.toString()
        var sampleData=SampleData()
        logger("Sample point type: " + samplePoint.dataType.name)
        logger("Start: " + dateFormat.format(Date(samplePoint.getStartTime(TimeUnit.MILLISECONDS))))
        logger("End: " + dateFormat.format(Date(samplePoint.getEndTime(TimeUnit.MILLISECONDS))))
        sampleData.time=Date(samplePoint.getEndTime(TimeUnit.MILLISECONDS))
        for (field in samplePoint.dataType.fields) {
            logger("Field: " + field.name.toString() + " Value: " + samplePoint.getFieldValue(field))
            sampleData.value=samplePoint.getFieldValue(field).toString()
        }

        reference.child(id).setValue(sampleData)
                .addOnCompleteListener { }
    }
}
fun todaySum(context: Context) {
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_WRITE)

            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    val dataController: DataController = HuaweiHiHealth.getDataController(context, signInHuaweiId)
    val todaySummationTask: Task<SampleSet> = dataController.readTodaySummation(DataType.DT_INSTANTANEOUS_HEART_RATE)
    todaySummationTask.addOnSuccessListener { sampleSet ->
        logger("Success read today summation from HMS core")
        logger("size:${sampleSet.samplePoints.size}")
        showSampleSet(sampleSet)
        for (e in sampleSet.samplePoints) {
            logger("proba ${e.dataType.name}")
        }

    }
    todaySummationTask.addOnFailureListener { e ->
        val errorCode = e.message
        val errorMsg: String = HiHealthStatusCodes.getStatusCodeMessage(errorCode!!.toInt())
        logger("$errorCode: $errorMsg")
    }

}

@Throws(ParseException::class)
fun insertDataBPM(context: Context, date: String, value: Float) {
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_WRITE)
            .addDataType(HealthDataTypes.DT_INSTANTANEOUS_SPO2, HiHealthOptions.ACCESS_READ)
            .addDataType(HealthDataTypes.DT_INSTANTANEOUS_SPO2, HiHealthOptions.ACCESS_WRITE)

            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    val dataController: DataController = HuaweiHiHealth.getDataController(context, signInHuaweiId)
    val dataCollector: DataCollector = DataCollector.Builder().setPackageName(context)
            .setDataType(DataType.DT_INSTANTANEOUS_HEART_RATE)
            .setDataStreamName("HEART_RATE")
            .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
            .build()
    val sampleSet = SampleSet.create(dataCollector)
    val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
    val startDate = dateFormat.parse(date)
    val endDate = dateFormat.parse(date)
    val samplePoint = sampleSet.createSamplePoint()
            .setTimeInterval(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
    samplePoint.getFieldValue(Field.FIELD_BPM).setFloatValue(value)
    sampleSet.addSample(samplePoint)
    val insertTask: Task<Void> = dataController.insert(sampleSet)
    insertTask.addOnSuccessListener {
        logger("Success insert an SampleSet into HMS core")
        showSampleSet(sampleSet)
    }.addOnFailureListener {logger("Fail") }
}

@Throws(ParseException::class)
fun readData(context: Context, date: String){
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    val dataController: DataController = HuaweiHiHealth.getDataController(context, signInHuaweiId)
    val dataCollector: DataCollector = DataCollector.Builder().setPackageName(context)
            .setDataType(DataType.DT_CONTINUOUS_STEPS_DELTA)
            .setDataStreamName("STEPS_DELTA")
            .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
            .build()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
    val startDate = dateFormat.parse("2019-01-01 10:10:00")
    val endDate = dateFormat.parse(date)
    val readOptions = ReadOptions.Builder().read(dataCollector)
            .setTimeRange(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
            .build()
    val readReplyTask: Task<ReadReply> = dataController.read(readOptions)
    readReplyTask.addOnSuccessListener { readReply ->
        logger("Success read an SampleSets from HMS core")
        for (sampleSet in readReply.sampleSets) {
            logger("${sampleSet.isEmpty}")
             showSampleSet(sampleSet!!)
        }
    }.addOnFailureListener {  }

}


fun daySumBPM(context: Context, date: String) {
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    logger("id:$signInHuaweiId")
    val dataController: DataController = HuaweiHiHealth.getDataController(context, signInHuaweiId)
    val dataCollector: DataCollector = DataCollector.Builder().setPackageName(context)
            //.setDataType(DataType.DT_INSTANTANEOUS_HEART_RATE)
            .setDataType(DataType.DT_INSTANTANEOUS_HEART_RATE)
            .setDataStreamName("HEART_RATE")
            .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
            .build()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
    var startDate: Date? = null
    var endDate: Date? = null
    try {
        //startDate = dateFormat.parse(date)
        startDate= dateFormat.parse("2019-01-01 10:10:00")
        endDate = dateFormat.parse(date)
    } catch (exception: ParseException) {
        logger("Time parsing error")
    }
    val readOptions: ReadOptions = ReadOptions.Builder().read(dataCollector)
            .setTimeRange(startDate!!.time, endDate!!.time, TimeUnit.MILLISECONDS)
            .build()
    val readReplyTask: Task<ReadReply> = dataController.read(readOptions)
    readReplyTask.addOnSuccessListener { readReply ->
        logger("Success read a SampleSets from HMS core")
        for (sampleSet in readReply.sampleSets) {
            showSampleSet(sampleSet)
            logger("$sampleSet")
        }

    }.addOnFailureListener { e ->
        val errorCode = e.message
        val errorMsg = HiHealthStatusCodes.getStatusCodeMessage(errorCode!!.toInt())
        logger("$errorCode: $errorMsg")
    }

}
fun risk(value: Int): String {
    var str=""
    if (value==0) str= "0% per year."
    if (value==1) str= "1.3% per year."
    if (value==2) str= "2.2% per year."
    if (value==3) str= "3.2% per year."
    if (value==4) str= "4% per year."
    if (value==5) str= "6.7% per year."
    if (value==6) str= "9.8% per year."
    if (value==7) str= "9.6% per year."
    if (value==8) str= "6.7% per year."
    if (value==9) str= "15.2% per year."
    return str
}

