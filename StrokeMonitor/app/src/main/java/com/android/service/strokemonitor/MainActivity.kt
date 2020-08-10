package com.android.service.strokemonitor


import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.content.Intent
import android.os.Bundle
import android.text.format.DateFormat
import android.util.Log
import android.widget.Button
import android.widget.DatePicker
import android.widget.TextView
import android.widget.TimePicker
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import com.huawei.hmf.tasks.Task
import com.huawei.hms.common.ApiException
import com.huawei.hms.hihealth.data.Scopes
import com.huawei.hms.support.api.entity.auth.Scope
import com.huawei.hms.support.hwid.HuaweiIdAuthAPIManager
import com.huawei.hms.support.hwid.HuaweiIdAuthManager
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParams
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParamsHelper
import com.huawei.hms.support.hwid.result.AuthHuaweiId
import kotlinx.android.synthetic.main.activity_main.*
import java.util.*
import kotlin.collections.ArrayList


class MainActivity : AppCompatActivity(), DatePickerDialog.OnDateSetListener,
TimePickerDialog.OnTimeSetListener {
    private lateinit var firebaseReference: DatabaseReference
    private val REQUEST_SIGN_IN_LOGIN = 1002
    private val TAG = "HihealthKitMainActivity"
    lateinit var buttonStart: Button
    lateinit var textViewStart: TextView
    var day = 0
    var month: Int = 0
    var year: Int = 0
    var hour: Int = 0
    var minute: Int = 0
    var myDay = 0
    var myMonth: Int = 0
    var myYear: Int = 0
    var myHour: Int = 0
    var myMinute: Int = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        textViewStart = findViewById(R.id.startTime)
        buttonStart = findViewById(R.id.btnPickStart)
        buttonStart.setOnClickListener {
            startTime.text = ""
            val calendar: Calendar = Calendar.getInstance()
            day = calendar.get(Calendar.DAY_OF_MONTH)
            month = calendar.get(Calendar.MONTH)
            year = calendar.get(Calendar.YEAR)
            val datePickerDialog =
                    DatePickerDialog(this, this, year, month, day)
            datePickerDialog.show()
        }
        signIn()
        btnChart.setOnClickListener {
             val intent = Intent(this@MainActivity, ChartActivity::class.java).apply {
            }
            startActivity(intent)//daySumBPM(this,startTime.text.toString()) //
           //readData(this,startTime.text.toString())
        }
        btnPushBPM.setOnClickListener { insertDataBPM(this,startTime.text.toString(),heart_rate_value.text.toString().toFloat()) }

    }
    override fun onDateSet(view: DatePicker?, year: Int, month: Int, dayOfMonth: Int) {
        myDay = day
        myYear = year
        myMonth = month
        val calendar: Calendar = Calendar.getInstance()
        hour = calendar.get(Calendar.HOUR)
        minute = calendar.get(Calendar.MINUTE)
        val timePickerDialog = TimePickerDialog(this, this, hour, minute,
                DateFormat.is24HourFormat(this))
        timePickerDialog.show()
    }

    override fun onTimeSet(view: TimePicker?, hourOfDay: Int, minute: Int) {
        myHour = hourOfDay
        myMinute = minute
        val givenString = "$myYear-${myMonth + 1}-$myDay $myHour:$myMinute:00 "
        startTime.text = givenString

    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        handleSignInResult(requestCode, data);
    }

    private fun handleSignInResult(requestCode: Int, data: Intent?) {
        if (requestCode != REQUEST_SIGN_IN_LOGIN) {
            return
        }
        val result = HuaweiIdAuthAPIManager.HuaweiIdAuthAPIService.parseHuaweiIdFromIntent(data)
        Log.d(TAG, "handleSignInResult status = " + result.getStatus() + ", result = " + result.isSuccess());
        if (result.isSuccess) {
            Log.d(TAG, "sign in is success")
            val authResult = HuaweiIdAuthAPIManager.HuaweiIdAuthAPIService.parseHuaweiIdFromIntent(data)
        }

    }

    private fun signIn() {
        val scopeList: MutableList<Scope> = ArrayList()
        scopeList.add(Scope(Scopes.HEALTHKIT_STEP_READ)) // View and save step counts in HUAWEI Health Kit.
        scopeList.add(Scope(Scopes.HEALTHKIT_HEIGHTWEIGHT_READ))
        scopeList.add(Scope(Scopes.HEALTHKIT_OXYGENSTATURATION_READ))
        scopeList.add(Scope(Scopes.HEALTHKIT_OXYGENSTATURATION_WRITE))
        scopeList.add(Scope(Scopes.HEALTHKIT_HEARTRATE_READ))
        scopeList.add(Scope(Scopes.HEALTHKIT_HEARTRATE_WRITE))
        val authParamsHelper = HuaweiIdAuthParamsHelper(
                HuaweiIdAuthParams.DEFAULT_AUTH_REQUEST_PARAM)
        val authParams = authParamsHelper.setIdToken()
                .setAccessToken()
                .setScopeList(scopeList)
                .createParams()
        val authService = HuaweiIdAuthManager.getService(this.applicationContext,
                authParams)
        val authHuaweiIdTask: Task<AuthHuaweiId> = authService.silentSignIn()
        authHuaweiIdTask.addOnSuccessListener {
            Log.i("Huawei", "silentSignIn success")
        }.addOnFailureListener { exception ->
            if (exception is ApiException) {
                val apiException: ApiException = exception as ApiException
                Log.i("Huawei", "sign failed status:" + apiException.getStatusCode())
                Log.i("Huawei", "begin sign in by intent")
                val signInIntent = authService.signInIntent
                this@MainActivity.startActivityForResult(signInIntent, REQUEST_SIGN_IN_LOGIN)
            }
        }
    }
}


