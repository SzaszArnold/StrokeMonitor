package com.android.service.strokemonitor


import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import kotlinx.android.synthetic.main.activity_main.*


class MainActivity : AppCompatActivity() {
    private lateinit var auth: FirebaseAuth
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        auth = FirebaseAuth.getInstance()
        //TODO javitsam ki az xml hivatkozások ahogy tanultam
        btnRegister.setOnClickListener {
            val intent = Intent(this@MainActivity, RegistrationActivity::class.java).apply {}
            startActivity(intent)
        }
        btnLogin.setOnClickListener {
            signIn(findViewById<EditText>(R.id.editTextLoginEmail).text.toString(),findViewById<EditText>(R.id.editTextLoginPassword).text.toString())
        }

    }

    public override fun onStart() {
        super.onStart()
        val currentUser = auth.currentUser
        Log.d("CurrentUSer", "$currentUser")
        if (currentUser != null) {
            val intent = Intent(this@MainActivity, MainPage::class.java).apply {}
            startActivity(intent)
        }
    }
    private fun signIn(email: String, password: String) {
        Log.d(TAG, "signIn:$email")
        auth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(this) { task ->
                    if (task.isSuccessful) {
                        Log.d(TAG, "signInWithEmail:success")
                        val user = auth.currentUser
                        val intent = Intent(this@MainActivity, MainPage::class.java).apply {}
                        startActivity(intent)
                    } else {
                        Log.w(TAG, "signInWithEmail:failure", task.exception)
                        Toast.makeText(baseContext, "Authentication failed.",
                                Toast.LENGTH_SHORT).show()
                    }
                }
    }
    companion object {
        private const val TAG = "EmailPassword"
    }

}


