package com.android.service.strokemonitor.ui.profile

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.findNavController
import com.android.service.strokemonitor.MainActivity
import com.android.service.strokemonitor.R
import com.android.service.strokemonitor.risk
import com.bumptech.glide.Glide
import com.google.android.gms.common.GooglePlayServicesNotAvailableException
import com.google.firebase.auth.FirebaseAuth


class ProfileFragment : Fragment() {
    private lateinit var profileViewModel: ProfileViewModel
    private lateinit var img: ImageView
    private lateinit var textViewRisk: TextView
    private lateinit var textViewContact: TextView
    private lateinit var ediTextContact: EditText
    private lateinit var btnInsert: Button

    @SuppressLint("SetTextI18n")
    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        profileViewModel =
                ViewModelProviders.of(this).get(ProfileViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_profile, container, false)
        img = root.findViewById(R.id.image_view)
        textViewRisk = root.findViewById(R.id.textViewRisc)
        textViewContact = root.findViewById(R.id.textViewContact)
        ediTextContact = root.findViewById(R.id.editTextContact)
        btnInsert = root.findViewById(R.id.btnSave)
        profileViewModel.risk.observe(viewLifecycleOwner, Observer { profile ->
            textViewRisk.text = risk(profile)
        })
        profileViewModel.contact.observe(viewLifecycleOwner, Observer { contact ->

            textViewContact.text = contact.toString()
            btnInsert.visibility=View.GONE
            ediTextContact.visibility=View.GONE

        })
        btnInsert.setOnClickListener {
            profileViewModel.insertContact(ediTextContact.text.toString())
        }
        img.setOnClickListener {
            val uriSms = Uri.parse("smsto:${textViewContact.text}")
            val intentSMS = Intent(Intent.ACTION_SENDTO, uriSms)
            intentSMS.putExtra("sms_body", "Help me!")
            startActivity(intentSMS)
            val intent =
                    Intent(Intent.ACTION_CALL, Uri.parse("tel:" + "${textViewContact.text}"))
            requireContext().startActivity(intent)

        }
        Glide.with(img)
                .load("https://blog.whitemountain.ro/wp-content/uploads/2014/02/sos.png")
                .override(500, 500)
                .placeholder(R.drawable.ic_home_black_24dp)
                .into(img)
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        val userEmail: TextView = root.findViewById(R.id.textViewUserName)
        val btnRisc: Button = root.findViewById(R.id.btnRisc)
        val btnOut: Button = root.findViewById(R.id.btnOut)
        btnRisc.setOnClickListener { requireView().findNavController().navigate(R.id.action_navigation_profile_to_navigation_risc) }
        btnOut.setOnClickListener {
            FirebaseAuth.getInstance().signOut()
            val intent = Intent(context, MainActivity::class.java).apply {}
            startActivity(intent)
        }
        userEmail.text = "User: $currentUser"
        return root
    }
}