package com.android.service.strokemonitor.ui.home

import android.os.Bundle
import android.text.method.ScrollingMovementMethod
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.findNavController
import com.android.service.strokemonitor.R
import java.util.*


class HomeFragment : Fragment() {

    private lateinit var homeViewModel: HomeViewModel
    private lateinit var textView: TextView
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        homeViewModel =
            ViewModelProviders.of(this).get(HomeViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_home, container, false)
        textView=root.findViewById(R.id.textViewHint)
        val calendar: Calendar = Calendar.getInstance()
        val day: Int = calendar.get(Calendar.DAY_OF_WEEK)
        Log.d("Dayteszt","$day")
        textView.text=homeViewModel.prevention[day-1]
        textView.movementMethod = ScrollingMovementMethod()
        val textView: TextView = root.findViewById(R.id.text_home)
        val button: Button = root.findViewById(R.id.manualInstertBTN)
        homeViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })
        button.setOnClickListener {requireView().findNavController().navigate(R.id.action_navigation_home_to_navigation_manual) }
        return root
    }
}