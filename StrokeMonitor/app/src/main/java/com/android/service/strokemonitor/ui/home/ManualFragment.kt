package com.android.service.strokemonitor.ui.home

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.content.Intent
import android.os.Bundle
import android.text.format.DateFormat
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.DatePicker
import android.widget.TextView
import android.widget.TimePicker
import androidx.fragment.app.Fragment
import com.android.service.strokemonitor.R
import com.android.service.strokemonitor.readData
import com.google.firebase.auth.FirebaseAuth
import com.huawei.hmf.tasks.Task
import com.huawei.hms.common.ApiException
import com.huawei.hms.hihealth.data.Scopes
import com.huawei.hms.support.api.entity.auth.Scope
import com.huawei.hms.support.hwid.HuaweiIdAuthAPIManager
import com.huawei.hms.support.hwid.HuaweiIdAuthManager
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParams
import com.huawei.hms.support.hwid.request.HuaweiIdAuthParamsHelper
import com.huawei.hms.support.hwid.result.AuthHuaweiId
import kotlinx.android.synthetic.main.fragment_manual.*
import java.util.*
import kotlin.collections.ArrayList

class ManualFragment : Fragment(), DatePickerDialog.OnDateSetListener,
TimePickerDialog.OnTimeSetListener {
    private lateinit var auth: FirebaseAuth
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
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val root = inflater.inflate(R.layout.fragment_manual, container, false)
        textViewStart = root.findViewById(R.id.startTime)
        buttonStart = root.findViewById(R.id.btnPickStart)
        auth = FirebaseAuth.getInstance()
        buttonStart.setOnClickListener {
            startTime.text = ""
            val calendar: Calendar = Calendar.getInstance()
            day = calendar.get(Calendar.DAY_OF_MONTH)
            month = calendar.get(Calendar.MONTH)
            year = calendar.get(Calendar.YEAR)
            context?.let { it1 -> DatePickerDialog(it1, this, year, month, day) }?.show()
        }
        signIn()
        val btnChart: Button=root.findViewById(R.id.btnChart)
        btnChart.setOnClickListener {
            context?.let { it1 ->
                readData(it1)
            }

            /*  val intent = Intent(this@MainPage, ChartActivity::class.java).apply {
              }
              startActivity(intent)*/
            //readData(this,startTime.text.toString())
            // daySumBPM(this,startTime.text.toString()) //
            // todaySum(this)

        }
     /*   btnPushBPM.setOnClickListener {
            context?.let { it1 ->
                insertDataBPM(
                    it1,
                    startTime.text.toString(),
                    heart_rate_value.text.toString().toFloat()
                )
            }
        }*/
        //  btnPushBPM.setOnClickListener { todaySum(this) }
        /*    btnOut.setOnClickListener {
                FirebaseAuth.getInstance().signOut()

                val intent = Intent(this@MainPage, MainActivity::class.java).apply {}
                startActivity(intent)
            }*/
        return root
    }
    override fun onDateSet(view: DatePicker?, year: Int, month: Int, dayOfMonth: Int) {
        myDay = day
        myYear = year
        myMonth = month
        val calendar: Calendar = Calendar.getInstance()
        hour = calendar.get(Calendar.HOUR)
        minute = calendar.get(Calendar.MINUTE)
        val timePickerDialog = TimePickerDialog(context, this, hour, minute,
            DateFormat.is24HourFormat(context))
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

        scopeList.add(Scope(Scopes.HEALTHKIT_HEARTRATE_READ))
        scopeList.add(Scope(Scopes.HEALTHKIT_HEARTRATE_WRITE))
        val authParamsHelper = HuaweiIdAuthParamsHelper(
            HuaweiIdAuthParams.DEFAULT_AUTH_REQUEST_PARAM)
        val authParams = authParamsHelper.setIdToken()
            .setAccessToken()
            .setScopeList(scopeList)
            .createParams()
        val authService = HuaweiIdAuthManager.getService(context, authParams)
        val authHuaweiIdTask: Task<AuthHuaweiId> = authService.silentSignIn()
        authHuaweiIdTask.addOnSuccessListener {
            Log.i("Huawei", "silentSignIn success")
        }.addOnFailureListener { exception ->
            if (exception is ApiException) {
                val apiException: ApiException = exception as ApiException
                Log.i("Huawei", "sign failed status:" + apiException.statusCode)
                Log.i("Huawei", "begin sign in by intent")
                val signInIntent = authService.signInIntent
                this.startActivityForResult(signInIntent, REQUEST_SIGN_IN_LOGIN)
            }
        }
    }
}