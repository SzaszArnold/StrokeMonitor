package com.android.service.strokemonitor.ui.profile

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.findNavController
import com.android.service.strokemonitor.MainActivity
import com.android.service.strokemonitor.R
import com.android.service.strokemonitor.RegistrationActivity
import com.google.firebase.auth.FirebaseAuth
import kotlinx.android.synthetic.main.activity_main_screen.view.*


class ProfileFragment : Fragment() {
    private lateinit var profileViewModel: ProfileViewModel
    @SuppressLint("SetTextI18n")
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        profileViewModel =
            ViewModelProviders.of(this).get(ProfileViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_profile, container, false)
        /*val textView: TextView = root.findViewById(R.id.text_notifications)
        profileViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })*/
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        val userEmail: TextView=root.findViewById(R.id.textViewUserName)
        val btnRisc: Button =root.findViewById(R.id.btnRisc)
        val btnOut: Button = root.findViewById(R.id.btnOut)
        btnRisc.setOnClickListener { requireView().findNavController().navigate(R.id.action_navigation_profile_to_navigation_risc)  }
        btnOut.setOnClickListener {
            FirebaseAuth.getInstance().signOut()
            val intent = Intent(context, MainActivity::class.java).apply {}
            startActivity(intent) }
        userEmail.text= "User: $currentUser"
        return root
    }
}