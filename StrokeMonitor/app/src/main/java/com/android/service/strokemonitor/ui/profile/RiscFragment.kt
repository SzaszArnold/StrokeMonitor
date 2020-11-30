package com.android.service.strokemonitor.ui.profile

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.CheckBox
import android.widget.RadioButton
import android.widget.RadioGroup
import androidx.fragment.app.Fragment
import com.android.service.strokemonitor.R
import com.android.service.strokemonitor.risk
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.FirebaseDatabase

//TODO recycleView
class RiscFragment : Fragment() {
    private lateinit var radioGroupClinicalAge: RadioGroup
    private lateinit var radioGroupClinicalSex: RadioGroup
    private lateinit var checkBox1: CheckBox
    private lateinit var checkBox2: CheckBox
    private lateinit var checkBox3: CheckBox
    private lateinit var checkBox4: CheckBox
    private lateinit var checkBox5: CheckBox
    private lateinit var btnSubmit: Button
    private var value: Int = 0
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val root = inflater.inflate(R.layout.fragment_risc, container, false)
        checkBox1 = root.findViewById(R.id.checkbox1)
        checkBox2 = root.findViewById(R.id.checkbox2)
        checkBox3 = root.findViewById(R.id.checkbox3)
        checkBox4 = root.findViewById(R.id.checkbox4)
        checkBox5 = root.findViewById(R.id.checkbox5)
        btnSubmit = root.findViewById(R.id.btnSubmit)
        val listOfCheckBox = listOf(checkBox1, checkBox2, checkBox3, checkBox4, checkBox5)
        radioGroupClinicalAge = root.findViewById(R.id.clinicalAge)
        radioGroupClinicalAge.setOnCheckedChangeListener { _, checkedId ->
            val radioButton: RadioButton = root.findViewById(checkedId)
            value += radioButton.hint.toString().toInt()
        }
        radioGroupClinicalSex = root.findViewById(R.id.clinicalSex)
        radioGroupClinicalSex.setOnCheckedChangeListener { _, checkedId ->
            val radioButton: RadioButton = root.findViewById(checkedId)
            value += radioButton.hint.toString().toInt()
        }
        btnSubmit.setOnClickListener {
            checkBoxs(listOfCheckBox)
            uploadToFirebase(value)
            Log.d("RadioTest", "Value: $value, ${risk(value)}")
        }

        return root
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