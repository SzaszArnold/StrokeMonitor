package com.android.service.strokemonitor

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.text.format.DateFormat
import android.util.Log
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import kotlinx.android.synthetic.main.acitivity_registration.*
import kotlinx.android.synthetic.main.activity_mainpage.*
import java.util.*
import java.util.regex.Pattern


class RegistrationActivity : AppCompatActivity(), DatePickerDialog.OnDateSetListener {
    private lateinit var auth: FirebaseAuth
    private lateinit var radioGroupGender: RadioGroup
    private lateinit var firebaseReference: DatabaseReference
    //TODO javitsam ki az xml hivatkozások ahogy tanultam
    private var gender = ""
    var day = 0
    var month: Int = 0
    var year: Int = 0
    var myDay = 0
    var myMonth: Int = 0
    var myYear: Int = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.acitivity_registration)
        auth = FirebaseAuth.getInstance()
        radioGroupGender = findViewById(R.id.registerGender)
        radioGroupGender.setOnCheckedChangeListener(
                RadioGroup.OnCheckedChangeListener { group, checkedId ->
                    val radioButton: RadioButton = findViewById(checkedId)
                    gender = radioButton.text.toString()
                }
        )
        btnRegistration.setOnClickListener {
            createAccount(findViewById<EditText>(R.id.editTextRegisterEmail).text.toString(),findViewById<EditText>(R.id.editTextRegisterPassword).text.toString())
        }
        btnBirthday.setOnClickListener {
            textViewBirthday.text = ""
            val calendar: Calendar = Calendar.getInstance()
            day = calendar.get(Calendar.DAY_OF_MONTH)
            month = calendar.get(Calendar.MONTH)
            year = calendar.get(Calendar.YEAR)
            val datePickerDialog =
                    DatePickerDialog(this, this, year, month, day)
            datePickerDialog.show()
        }
    }
    private fun createAccount(email: String, password: String) {
        Log.d(TAG, "createAccount:$email")
        if (!email.isEmailValid()){
            Toast.makeText(baseContext, "Invalid e-mail address.", Toast.LENGTH_SHORT).show()
            return
        }
        if (!password.isValidPassword()){
            Toast.makeText(baseContext, "Invalid password.", Toast.LENGTH_SHORT).show()
            return
        }
        auth.createUserWithEmailAndPassword(email, password)
                    .addOnCompleteListener(this) { task ->
                        if (task.isSuccessful) {
                            Log.d(TAG, "createUserWithEmail:success")
                            val user = auth.currentUser!!.email.toString()
                            val registrationData = RegistrationData()
                            registrationData.birthday=findViewById<TextView>(R.id.textViewBirthday).text.toString()
                            registrationData.heigth=findViewById<EditText>(R.id.editTextHeight).text.toString().toLong()
                            registrationData.weight=findViewById<EditText>(R.id.editTextWeight).text.toString().toLong()
                            registrationData.gender=gender
                            val reference = FirebaseDatabase.getInstance().getReference("UserData"+user.substringBefore("@"))
                            val id = reference.push().key.toString()
                            reference.child(id).setValue(registrationData)
                                    .addOnCompleteListener {
                                        val intent = Intent(this@RegistrationActivity, MainActivity::class.java).apply {
                                        Toast.makeText(baseContext, "Registration success.", Toast.LENGTH_SHORT).show()}
                                        startActivity(intent)}

                        } else {
                            Log.w(TAG, "createUserWithEmail:failure", task.exception)
                            Toast.makeText(baseContext, "E-mail is already used.",
                                    Toast.LENGTH_SHORT).show()
                        }
                    }
    }

    companion object {
        private const val TAG = "EmailPassword"
    }
    private fun String.isEmailValid(): Boolean {
        return !TextUtils.isEmpty(this) && android.util.Patterns.EMAIL_ADDRESS.matcher(this).matches()
    }

    private fun String.isValidPassword(): Boolean {
        val PASSWORD_PATTERN: Pattern = Pattern.compile("[a-zA-Z0-9$]{8,24}")
        return !TextUtils.isEmpty(this) && PASSWORD_PATTERN.matcher(this).matches()
    }

    override fun onDateSet(view: DatePicker?, year: Int, month: Int, dayOfMonth: Int) {
        myDay = dayOfMonth
        myYear = year
        myMonth = month
        val givenString = "$myYear-${myMonth+1}-$myDay"
        textViewBirthday.text = givenString
    }

}