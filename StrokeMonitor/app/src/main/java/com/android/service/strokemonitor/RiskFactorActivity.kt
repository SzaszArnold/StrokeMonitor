package com.android.service.strokemonitor

import android.os.Bundle
import android.util.Log
import android.widget.CheckBox
import android.widget.RadioButton
import android.widget.RadioGroup
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.FirebaseDatabase
import kotlinx.android.synthetic.main.activity_risk_factor.*


class RiskFactorActivity : AppCompatActivity() {
    private lateinit var radioGroupClinicalAge: RadioGroup
    private lateinit var radioGroupClinicalSex: RadioGroup
    private lateinit var checkBox1: CheckBox
    private lateinit var checkBox2: CheckBox
    private lateinit var checkBox3: CheckBox
    private lateinit var checkBox4: CheckBox
    private lateinit var checkBox5: CheckBox
    private var value: Int = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_risk_factor)
        checkBox1 = findViewById(R.id.checkbox1)
        checkBox2 = findViewById(R.id.checkbox2)
        checkBox3 = findViewById(R.id.checkbox3)
        checkBox4 = findViewById(R.id.checkbox4)
        checkBox5 = findViewById(R.id.checkbox5)
        val listOfCheckBox = listOf(checkBox1, checkBox2, checkBox3, checkBox4, checkBox5)
        radioGroupClinicalAge = findViewById(R.id.clinicalAge)
        radioGroupClinicalAge.setOnCheckedChangeListener { _, checkedId ->
            val radioButton: RadioButton = findViewById(checkedId)
            value += radioButton.hint.toString().toInt()
        }
        radioGroupClinicalSex = findViewById(R.id.clinicalSex)
        radioGroupClinicalSex.setOnCheckedChangeListener { _, checkedId ->
            val radioButton: RadioButton = findViewById(checkedId)
            value += radioButton.hint.toString().toInt()
        }
        btnSubmit.setOnClickListener {
            checkBoxs(listOfCheckBox)
            uploadToFirebase(value)
            Log.d("RadioTest", "Value: $value, ${risk(value)}")
        }


    }

    private fun uploadToFirebase(value: Int) {
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        val reference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@") + "risk")
        val id = reference.push().key.toString()
        reference.child(id).setValue(value)
                .addOnCompleteListener { }
    }

    private fun checkBoxs(checkBoxList: List<CheckBox>) {
        for (c in checkBoxList) {
            Log.d("Tessstt","${c.isChecked}")
            if (c.isChecked) {
                value += c.hint.toString().toInt()
            }
        }
    }
}

