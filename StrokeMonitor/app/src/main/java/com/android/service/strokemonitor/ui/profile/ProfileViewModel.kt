package com.android.service.strokemonitor.ui.profile

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.*
import kotlinx.coroutines.launch

class ProfileViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = "Profile Data"
    }
    val risk: MutableLiveData<Int> = MutableLiveData()
    val contact: MutableLiveData<String> = MutableLiveData()
    val text: LiveData<String> = _text

    init {
        contact()
        risk()
    }

    fun risk() = viewModelScope.launch {
        val firebaseReference: DatabaseReference
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        firebaseReference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@") + "risk")
        firebaseReference.addValueEventListener(object : ValueEventListener {
            override fun onDataChange(dataSnapshot: DataSnapshot) {
                if (dataSnapshot.exists()) {
                    for (data in dataSnapshot.children) {
                        risk.postValue(data.value.toString().toInt())
                        Log.d("ViewModel", "${data.value}")
                    }
                }
            }

            override fun onCancelled(p0: DatabaseError) {
                Log.d("OnCancelled", "Not implemented yet!")

            }
        })
    }

    fun contact() = viewModelScope.launch {
        val firebaseReference: DatabaseReference
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        firebaseReference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@") + "contact")
        firebaseReference.addValueEventListener(object : ValueEventListener {
            override fun onDataChange(dataSnapshot: DataSnapshot) {
                if (dataSnapshot.exists()) {
                    for (data in dataSnapshot.children) {
                        contact.postValue(data.value.toString())
                        Log.d("ViewModel", "${data.value}")
                    }
                }
            }

            override fun onCancelled(p0: DatabaseError) {
                Log.d("OnCancelled", "Not implemented yet!")

            }
        })
    }

    fun insertContact(number: String) = viewModelScope.launch {
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        val reference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@") + "contact")
        val id = reference.push().key.toString()
        reference.child(id).setValue(number)
                .addOnCompleteListener { }
    }
}
