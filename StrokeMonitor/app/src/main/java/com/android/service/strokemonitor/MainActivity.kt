package com.android.service.strokemonitor


import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.database.DatabaseReference
import com.huawei.hihealth.error.HiHealthError
import com.huawei.hihealthkit.data.store.HiHealthDataStore
import com.huawei.hmf.tasks.OnFailureListener
import com.huawei.hmf.tasks.OnSuccessListener
import com.huawei.hmf.tasks.Task
import com.huawei.hms.common.ApiException
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HiHealthOptions
import com.huawei.hms.hihealth.HiHealthStatusCodes
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.*
import com.huawei.hms.hihealth.options.ReadOptions
import com.huawei.hms.hihealth.result.ReadReply
import com.huawei.hms.support.api.entity.auth.Scope
import com.huawei.hms.support.hwid.HuaweiIdAuthAPIManager
import com.huawei.hms.support.hwid.HuaweiIdAuthManager
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParams
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParamsHelper
import com.huawei.hms.support.hwid.result.AuthHuaweiId
import kotlinx.android.synthetic.main.activity_main.*
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.ArrayList


class MainActivity : AppCompatActivity() {
    private lateinit var firebaseReference: DatabaseReference
    private val REQUEST_SIGN_IN_LOGIN = 1002
    private val TAG = "HihealthKitMainActivity"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
     signIn()

        button.setOnClickListener {

          getdata()


        }

        /*
        val read = intArrayOf(
            HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_USER_PROFILE_INFORMATION,
            HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_POINT_CALORIES_SUM,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_POINT_DISTANCE_SUM,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_POINT_INTENSITY,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_POINT_STEP_SUM,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_REAL_TIME_SPORT,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_SET_HEART,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_REALTIME_HEARTRATE,
                HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_READ_DATA_SET_CORE_SLEEP
        )
        val write = intArrayOf(HiHealthOpenPermissionType.HEALTH_OPEN_PERMISSION_TYPE_WRITE_DATA_SET_WEIGHT)
        HiHealthAuth.requestAuthorization(
            applicationContext, write, read
        ) { resultCode, resultDesc ->
            // Go to HiHealthError for more info
            Log.d("twst", "requestAuthorization onResult:$resultCode")
        }
        button.setOnClickListener {*/
/*
            HiHealthDataStore.getGender(this@MainActivity, object : ResultCallback {
                override fun onResult(errorCode: Int, gender: Any?) {
                    Log.d("FragmentActivity.TAG", "call doGetGender() resultCode is $errorCode")
                    Log.d("FragmentActivity.TAG", "call doGetGender() gender is $gender")
                    if (gender != null) {

                        val message: Message = Message.obtain()
                        Log.d("Tesztek","Gender $gender, MSG:n $message")

                    }
                }
            })
            //---------------------------------------------------------
            HiHealthDataStore.getWeight(applicationContext) { resultCode, weight ->
                Log.d("Test", "Weight:$weight, code:$resultCode")
                if (resultCode == HiHealthError.SUCCESS) {
                    val value = weight as Int
                }
            }

            HiHealthDataStore.getBirthday(applicationContext) { resultCode, birthday ->
                Log.d("tesztek", "Birthday:$birthday, code:$resultCode")
                if (resultCode == HiHealthError.SUCCESS) {
                    // For example, "1978-05-20" would return 19780520
                    val value = birthday as Int
                }
            }
            HiHealthDataStore.getHeight(applicationContext) { resultCode, height ->
                Log.d("tesztek", "Height:$height, code:$resultCode")
                if (resultCode == HiHealthError.SUCCESS) {
                    val value = height as Int
                }
            }
            HiHealthDataStore.getGender(applicationContext) { errorCode, gender ->
                Log.d("tesztek", "Gender:$gender, code:$errorCode")
                if (errorCode == HiHealthError.SUCCESS) {
                    val value = gender as Int
                }
            }


            HiHealthDataStore.startReadingHeartRate(applicationContext, object : HiRealTimeListener {
                override fun onResult(state: Int) {
                    Log.i("proba", "startReadingHeartRate onResult state:$state")
                }

                override fun onChange(resultCode: Int, value: String) {
                    Log.i("poba", "startReadingHeartRate onChange resultCode: $resultCode value: $value")
                    try {
                        val jsonObject = JSONObject(value)
                        val heartRateInfo = Integer.parseInt(jsonObject.getString("hr_info"))
                        val time = Long.parseLong(jsonObject.getString("time_info"))
                        Log.i("proba", " hr: $heartRateInfo time: $time")
                    } catch (e: JSONException) {
                        Log.e("proba", e.message)
                    } catch (e: NumberFormatException) {
                        Log.e("proba", e.message)
                    }

                }
            })
            HiHealthDataStore.stopReadingHeartRate(applicationContext, object : HiRealTimeListener {
                override fun onResult(state: Int) {
                    Log.i("proba", "stopReadingHeartRate onResult state:$state")
                }

                override fun onChange(resultCode: Int, value: String) {
                    Log.i("proba", "would not be called.")
                }
            })
            fun testfun() {
            val reference = FirebaseDatabase.getInstance().getReference("User")
            val id = reference.push().key.toString()
            reference.child(id).setValue("ez")
                .addOnCompleteListener {
                    Toast.makeText(applicationContext, "Register success!", Toast.LENGTH_LONG).show()
                }
        }
*/

    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        handleSignInResult(requestCode, data);
    }

    fun handleSignInResult(requestCode: Int, data: Intent?) {
        if (requestCode != REQUEST_SIGN_IN_LOGIN) {
            return
        }
        val result = HuaweiIdAuthAPIManager.HuaweiIdAuthAPIService.parseHuaweiIdFromIntent(data)
        Log.d(TAG, "handleSignInResult status = " + result.getStatus() + ", result = " + result.isSuccess());
        if (result.isSuccess) {
            Log.d(TAG, "sign in is success")

            // Obtain the authorization result.
            val authResult = HuaweiIdAuthAPIManager.HuaweiIdAuthAPIService.parseHuaweiIdFromIntent(data)
        }

    }
    fun data3(){
        val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
                .build()
        val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
        val dataController: DataController = HuaweiHiHealth.getDataController(this, signInHuaweiId)
        val todaySummationTask: Task<SampleSet> = dataController.readTodaySummationFromDevice(DataType.DT_CONTINUOUS_STEPS_DELTA)

        // 2. Calling the data controller to query the summary data of the current day is an asynchronous operation.
        // Therefore, a listener needs to be registered to monitor whether the data query is successful or not.

        // 2. Calling the data controller to query the summary data of the current day is an asynchronous operation.
        // Therefore, a listener needs to be registered to monitor whether the data query is successful or not.
        todaySummationTask.addOnSuccessListener { sampleSet ->
            logger("Success read today device summation from HMS core")
            logger("${sampleSet.isEmpty}")
            sampleSet?.let { showSampleSet(it) }

        }

    }
    fun signIn() {
        val scopeList: MutableList<Scope> = ArrayList()

        // Add scopes to apply for. The following only shows an example. Developers need to add scopes according to their specific needs.

        // Add scopes to apply for. The following only shows an example. Developers need to add scopes according to their specific needs.
        scopeList.add(Scope(Scopes.HEALTHKIT_STEP_READ)) // View and save step counts in HUAWEI Health Kit.

        scopeList.add(Scope(Scopes.HEALTHKIT_HEIGHTWEIGHT_READ)) // View and save height and weight in HUAWEI Health Kit.
        scopeList.add(Scope(Scopes.HEALTHKIT_OXYGENSTATURATION_READ))
        scopeList.add(Scope(Scopes.HEALTHKIT_HEARTRATE_READ)) // View and save the heart rate data in HUAWEI Health Kit.
        val authParamsHelper = HuaweiIdAuthParamsHelper(
                HuaweiIdAuthParams.DEFAULT_AUTH_REQUEST_PARAM)
        val authParams = authParamsHelper.setIdToken()
                .setAccessToken()
                .setScopeList(scopeList)
                .createParams()
        // Initialize the HuaweiIdAuthService object.

        // Initialize the HuaweiIdAuthService object.
        val authService = HuaweiIdAuthManager.getService(this.applicationContext,
                authParams)

        // Silent sign-in. If authorization has been granted by the current account, the authorization screen will not display. This is an asynchronous method.

        // Silent sign-in. If authorization has been granted by the current account, the authorization screen will not display. This is an asynchronous method.
        val authHuaweiIdTask: Task<AuthHuaweiId> = authService.silentSignIn()
        // Add the callback for the call result.

        // Add the callback for the call result.
        authHuaweiIdTask.addOnSuccessListener(object : OnSuccessListener<AuthHuaweiId?> {
            override fun onSuccess(huaweiId: AuthHuaweiId?) {
                // The silent sign-in is successful.
                Log.i("Huawei", "silentSignIn success")
            }
        }).addOnFailureListener(object : OnFailureListener {
            override fun onFailure(exception: Exception) {
                // The silent sign-in fails. This indicates that the authorization has not been granted by the current account.
                if (exception is ApiException) {
                    val apiException: ApiException = exception as ApiException
                    Log.i("Huawei", "sign failed status:" + apiException.getStatusCode())
                    Log.i("Huawei", "begin sign in by intent")

                    // Call the sign-in API using the getSignInIntent() method.
                    val signInIntent = authService.signInIntent

                    // Display the authorization screen by using the startActivityForResult() method of the activity.
                    // Developers can change HihealthKitMainActivity to the actual activity.
                    this@MainActivity.startActivityForResult(signInIntent, REQUEST_SIGN_IN_LOGIN)
                }
            }
        })
    }
    //***********************************************************************************************************************
    fun getdata() {
        HiHealthDataStore.getWeight(this) { resultCode, weight ->
            Log.d("Test", "Weight:$weight, code:$resultCode")
            if (resultCode == HiHealthError.SUCCESS) {
                val value = weight as Int
            }
        }


        val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE, HiHealthOptions.ACCESS_WRITE)

                .build()
        val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
        val dataController: DataController = HuaweiHiHealth.getDataController(this, signInHuaweiId)
        val todaySummationTask: Task<SampleSet> = dataController.readTodaySummation(DataType.DT_INSTANTANEOUS_HEART_RATE)
        todaySummationTask.addOnSuccessListener { sampleSet ->
            logger("Success read today summation from HMS core")
            logger("size:${sampleSet.samplePoints.size}")
            showSampleSet(sampleSet)
            for(e in sampleSet.samplePoints){
                logger("proba ${e.dataType.name}")
            }

        }
        todaySummationTask.addOnFailureListener { e ->
            val errorCode = e.message
            val errorMsg: String = HiHealthStatusCodes.getStatusCodeMessage(errorCode!!.toInt())
            logger("$errorCode: $errorMsg")
        }

    }
    //***********************************************************************************************************************

    fun logger(string: String) {
        Log.i("DataController", string);
    }

    fun getdata2(){
        val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_INSTANTANEOUS_HEART_RATE,HiHealthOptions.ACCESS_READ)
                .build()
        val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
        logger("id:$signInHuaweiId")
        val dataController: DataController = HuaweiHiHealth.getDataController(this, signInHuaweiId)
        val dataCollector: DataCollector = DataCollector.Builder().setPackageName(this)
                .setDataType(DataType.DT_INSTANTANEOUS_HEIGHT)
                .setDataStreamName("HeartRate")
                .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
                .build()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
        var startDate: Date? = null
        var endDate: Date? = null
        try {
            startDate = dateFormat.parse("2020-06-23 09:00:00")
            endDate = dateFormat.parse("2020-07-27 09:05:00")
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
fun insert(){
    val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
            .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
            .build()
    val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
    val dataController: DataController = HuaweiHiHealth.getDataController(this, signInHuaweiId)

    val dataCollector: DataCollector = DataCollector.Builder().setPackageName(this)
            .setDataType(DataType.DT_CONTINUOUS_STEPS_DELTA)
            .setDataStreamName("STEPS_DELTA")
            .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
            .build()
    val sampleSet = SampleSet.create(dataCollector)
    val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
    var startDate: Date? = null
    var endDate: Date? = null
    try {
        startDate = dateFormat.parse("2020-03-17 09:00:00")
        endDate = dateFormat.parse("2020-03-17 09:05:00")
    } catch (e: ParseException) {
        logger("Time parsing error")
    }
    val stepsDelta = 1000
    val samplePoint = sampleSet.createSamplePoint()
            .setTimeInterval(startDate!!.time, endDate!!.time, TimeUnit.MILLISECONDS)
    samplePoint.getFieldValue(Field.FIELD_STEPS_DELTA).setIntValue(stepsDelta)
    sampleSet.addSample(samplePoint);
    val insertTask: Task<Void> = dataController.insert(sampleSet)
    insertTask.addOnSuccessListener {
        logger("Success insert a SampleSet into HMS core")
        showSampleSet(sampleSet)
    }.addOnFailureListener { e ->
        val errorCode = e.message
        val errorMsg = HiHealthStatusCodes.getStatusCodeMessage(errorCode!!.toInt())
        logger("$errorCode: $errorMsg")














}


}
    private fun showSampleSet(sampleSet: SampleSet) {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        for (samplePoint in sampleSet.samplePoints) {
            logger("Sample point type: " + samplePoint.dataType.name)
            logger("Start: " + dateFormat.format(Date(samplePoint.getStartTime(TimeUnit.MILLISECONDS))))
            logger("End: " + dateFormat.format(Date(samplePoint.getEndTime(TimeUnit.MILLISECONDS))))
            for (field in samplePoint.dataType.fields) {
                logger("Field: " + field.name.toString() + " Value: " + samplePoint.getFieldValue(field))
            }
        }
    }

    @Throws(ParseException::class)
    fun readData() {
        val hiHealthOptions: HiHealthOptions = HiHealthOptions.builder()
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_CONTINUOUS_STEPS_DELTA, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_READ)
                .addDataType(DataType.DT_INSTANTANEOUS_HEIGHT, HiHealthOptions.ACCESS_WRITE)
                .addDataType(DataType.DT_CONTINUOUS_DISTANCE_DELTA, HiHealthOptions.ACCESS_READ)
                .build()
        val signInHuaweiId = HuaweiIdAuthManager.getExtendedAuthResult(hiHealthOptions)
        val dataController: DataController = HuaweiHiHealth.getDataController(this, signInHuaweiId)
        // 1. Build the condition for data query: a DataCollector object.
        val dataCollector: DataCollector = DataCollector.Builder().setPackageName(this)
                .setDataType(DataType.DT_CONTINUOUS_STEPS_DELTA)
                .setDataType(DataType.DT_INSTANTANEOUS_HEART_RATE)
                .setDataStreamName("STEPS_DELTA")
                .setDataGenerateType(DataCollector.DATA_TYPE_RAW)
                .build()

        // 2. Build the time range for the query: start time and end time.
        val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
        val startDate = dateFormat.parse("2020-07-27 08:00:00")
        val endDate = dateFormat.parse("2020-07-27 09:05:00")

        // 3. Build the condition-based query objec
        val readOptions = ReadOptions.Builder().read(dataCollector)
                .setTimeRange(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
                .build()

        // 4. Use the specified condition query object to call the data controller to query the sampling dataset.
        val readReplyTask: Task<ReadReply> = dataController.read(readOptions)

        // 5. Calling the data controller to query the sampling dataset is an asynchronous operation.
        // Therefore, a listener needs to be registered to monitor whether the data query is successful or not.
        readReplyTask.addOnSuccessListener { readReply ->
            logger("Success read an SampleSets from HMS core")

            for (sampleSet in readReply.sampleSets) {
                if(sampleSet.isEmpty){logger("nincs adat")}
                else{
                showSampleSet(sampleSet!!)}
            }
        }.addOnFailureListener { }
    }
}

