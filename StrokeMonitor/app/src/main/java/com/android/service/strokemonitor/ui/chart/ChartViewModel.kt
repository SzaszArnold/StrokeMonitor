package com.android.service.strokemonitor.ui.chart

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.android.service.strokemonitor.SampleData
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.*
import kotlinx.coroutines.launch

class ChartViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = "This is dashboard Fragment"
    }
    val text: LiveData<String> = _text

}