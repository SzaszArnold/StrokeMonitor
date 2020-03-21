package com.android.service.strokemonitor

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Toast
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {
    private lateinit var firebaseReference: DatabaseReference
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        button.setOnClickListener { testfun() }
    }
    fun testfun(){
        val reference = FirebaseDatabase.getInstance().getReference("User")
        val id = reference.push().key.toString()
        reference.child(id).setValue("ez")
            .addOnCompleteListener { Toast.makeText(applicationContext, "Register success!", Toast.LENGTH_LONG).show() }
    }
}
