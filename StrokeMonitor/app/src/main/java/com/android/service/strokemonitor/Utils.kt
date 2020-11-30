package com.android.service.strokemonitor

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.FirebaseDatabase
import com.huawei.hmf.tasks.OnFailureListener
import com.huawei.hmf.tasks.Task
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HiHealthOptions
import com.huawei.hms.hihealth.HiHealthStatusCodes
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.*
import com.huawei.hms.hihealth.options.OnSamplePointListener
import com.huawei.hms.hihealth.options.ReadOptions
import com.huawei.hms.hihealth.result.ReadReply
import com.huawei.hms.support.hwid.HuaweiIdAuthManager
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit


fun logger(string: String) {
    Log.i("DataController", string);
}

@SuppressLint("SimpleDateFormat")
private fun showSampleSet(sampleSet: SampleSet) {
    val auth: FirebaseAuth = FirebaseAuth.getInstance()
    val currentUser = auth.currentUser!!.email.toString()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
    for (samplePoint in sampleSet.samplePoints) {
        val reference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@"))
        val id = reference.push().key.toString()
        val sampleData = SampleData()
        logger("Sample point type: " + samplePoint.dataType.name)
        logger("Start: " + dateFormat.format(Date(samplePoint.getStartTime(TimeUnit.MILLISECONDS))))
        logger("End: " + dateFormat.format(Date(samplePoint.getEndTime(TimeUnit.MILLISECONDS))))
        sampleData.time = Date(samplePoint.getEndTime(TimeUnit.MILLISECONDS))
        for (field in samplePoint.dataType.fields) {
            logger("Field: " + field.name.toString() + " Value: " + samplePoint.getFieldValue(field))
            sampleData.value = samplePoint.getFieldValue(field).toString()
        }

    /* reference.child(id).setValue(sampleData)
                .addOnCompleteListener { }*/
    }
}

fun todaySum(context: Context) {
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_BODY_WEIGHT, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.POLYMERIZE_CONTINUOUS_HEART_RATE_STATISTICS,HiHealthOptions.ACCESS_READ)
            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    val dataController: DataController = HuaweiHiHealth.getDataController(context, signInHuaweiId)
    val todaySummationTask: Task<SampleSet> = dataController.readTodaySummation(DataType.DT_INSTANTANEOUS_HEART_RATE)
    todaySummationTask.addOnSuccessListener { sampleSet ->
        logger("Success read today summation from HMS core")
        logger("size:${sampleSet.samplePoints.size}")
        showSampleSet(sampleSet)
        for (e in sampleSet.samplePoints) {
            logger("Test ${e.dataType.name}")
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
    logger("StartDate: $startDate, EndDate: $endDate, Value: $value")
    val samplePoint = sampleSet.createSamplePoint()
            .setTimeInterval(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
    samplePoint.getFieldValue(Field.FIELD_BPM).setFloatValue(value)
    sampleSet.addSample(samplePoint)
    val insertTask: Task<Void> = dataController.insert(sampleSet)
    insertTask.addOnSuccessListener {
        logger("Success insert an SampleSet into HMS core")
        showSampleSet(sampleSet)
    }.addOnFailureListener { e ->
        val errorCode = e.message
        val errorMsg = HiHealthStatusCodes.getStatusCodeMessage(errorCode!!.toInt())
        logger("$errorCode: $errorMsg") }
}

@Throws(ParseException::class)
fun readData(context: Context, date: String) {
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    val dataController: DataController = HuaweiHiHealth.getDataController(context, signInHuaweiId)
    val dataCollector: DataCollector = DataCollector.Builder().setPackageName(context)
            .setDataType(DataType.DT_INSTANTANEOUS_HEART_RATE)
            .setDataStreamName("HEART_RATE")
            .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
            .build()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
    val startDate = dateFormat.parse("2020-11-22 16:50:00")
    val endDate = dateFormat.parse("2020-11-23 16:50:00")
    logger("StartDate: $startDate, EndDate: $endDate")
    val readOptions = ReadOptions.Builder().read(DataType.DT_INSTANTANEOUS_HEART_RATE)
            .setTimeRange(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
            .build()
    val readReplyTask: Task<ReadReply> = dataController.read(readOptions)
    readReplyTask.addOnSuccessListener { readReply ->
        logger("Success read an SampleSets from HMS core")
        for (sampleSet in readReply.sampleSets) {
            logger("List is empty? Answer: ${sampleSet.isEmpty}")
            showSampleSet(sampleSet!!)
        }
    }.addOnFailureListener {e ->
        val errorCode = e.message
        val errorMsg = HiHealthStatusCodes.getStatusCodeMessage(errorCode!!.toInt())
        logger("$errorCode: $errorMsg")}
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
        startDate = dateFormat.parse("2019-01-01 10:10:00")
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
    var str = ""
    if (value == 0) str = "0% per year."
    if (value == 1) str = "1.3% per year."
    if (value == 2) str = "2.2% per year."
    if (value == 3) str = "3.2% per year."
    if (value == 4) str = "4% per year."
    if (value == 5) str = "6.7% per year."
    if (value == 6) str = "9.8% per year."
    if (value == 7) str = "9.6% per year."
    if (value == 8) str = "6.7% per year."
    if (value == 9) str = "15.2% per year."
    return str
}
fun trz(context: Context){
    val options = HiHealthOptions.builder().build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(options)
    val controller = HuaweiHiHealth.getAutoRecorderController(context, signInHuaweiId)

// Create the data callback object onSamplePointListener to print the step count data.

// Create the data callback object onSamplePointListener to print the step count data.
    val onSamplePointListener = OnSamplePointListener { samplePoint ->
        for (field in samplePoint.dataType.fields) {
            Log.i("AutoRecorderTest","Field: " + field.name.toString() + " Value: " + samplePoint.getFieldValue(field))
        }
    }
/*Take DT_CONTINUOUS_STEPS_TOTAL as an example. Start real-time reading of the total number of steps. The total number of steps starts from 0 and the subsequently measured total step count will be recorded. When the user shakes the phone, the total number of steps is returned to the user in real time at a fixed interval until the user stops reading the data. The callback of total step count will then stop.*/
/*Take DT_CONTINUOUS_STEPS_TOTAL as an example. Start real-time reading of the total number of steps. The total number of steps starts from 0 and the subsequently measured total step count will be recorded. When the user shakes the phone, the total number of steps is returned to the user in real time at a fixed interval until the user stops reading the data. The callback of total step count will then stop.*/
    val dataType = DataType.DT_INSTANTANEOUS_HEART_RATE
    controller.startRecord(dataType, onSamplePointListener).addOnCompleteListener { taskResult -> // Handling of callback exceptions needs to be added for the case that the calling fails due to the app not being authorized or type not being supported.
        if (taskResult.isSuccessful) {

            Log.i("AutoRecorderTest", "onComplete startRecordByType Successful")
        } else {
            Log.i("AutoRecorderTest", "onComplete startRecordByType Failed")
        }
    }.addOnSuccessListener { Log.i("AutoRecorderTest", "onSuccess startRecordByType Successful") }.addOnFailureListener(object : OnFailureListener {
        override fun onFailure(e: Exception) {
            Log.i("AutoRecorderTest", "onFailure startRecordByType Failed: " + e.message)
        }
    })
}
fun trz2(context: Context){
    val options = HiHealthOptions.builder().build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(options)
    val controller = HuaweiHiHealth.getAutoRecorderController(context, signInHuaweiId)

// Create the callback object onSamplePointListener.

// Create the callback object onSamplePointListener.
    val onSamplePointListener = OnSamplePointListener { }
    controller.stopRecord(DataType.DT_CONTINUOUS_STEPS_TOTAL, onSamplePointListener)
            .addOnCompleteListener { taskResult -> // Handling of callback exceptions needs to be added for the case that the calling fails due to the app not being authorized or type not being supported.
                if (taskResult.isSuccessful) {
                    Log.i("AutoRecorderTest", "onComplete stopRecordByType Successful")
                } else {
                    Log.i("AutoRecorderTest", "onComplete stopRecordByType Failed")
                }
            }
            .addOnSuccessListener { Log.i("AutoRecorderTest", "onSuccess stopRecordByType Successful") }
            .addOnFailureListener { e -> Log.i("AutoRecorderTest", "onFailure stopRecordByType Failed: " + e.message) }
}
fun trz3(context: Context){

}


