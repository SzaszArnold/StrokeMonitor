package com.android.service.strokemonitor

import android.os.Bundle
import android.util.Log
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import kotlinx.android.synthetic.main.acitivity_registration.*


class RegistrationActivity : AppCompatActivity() {
    private lateinit var auth: FirebaseAuth
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.acitivity_registration)
        auth = FirebaseAuth.getInstance()
        btnRegistration.setOnClickListener {
            createAccount(findViewById<EditText>(R.id.editTextRegisterEmail).text.toString(),findViewById<EditText>(R.id.editTextRegisterPassword).text.toString())
        }
    }
    private fun createAccount(email: String, password: String) {
        Log.d(TAG, "createAccount:$email")
       /* if (!validateForm()) {
            return
        }*/
        auth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(this) { task ->
                    if (task.isSuccessful) {
                        Log.d(TAG, "createUserWithEmail:success")
                        val user = auth.currentUser
                    } else {
                        // If sign in fails, display a message to the user.
                        Log.w(TAG, "createUserWithEmail:failure", task.exception)
                        Toast.makeText(baseContext, "Authentication failed.",
                                Toast.LENGTH_SHORT).show()
                    }
                }
    }

    private fun validateForm(): Boolean {
        TODO("Not yet implemented")
    }

    companion object {
        private const val TAG = "EmailPassword"
    }
}