package com.android.service.strokemonitor.ui.chart

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.android.service.strokemonitor.R
import com.android.service.strokemonitor.SampleData
import com.github.aachartmodel.aainfographics.aachartcreator.AAChartModel
import com.github.aachartmodel.aainfographics.aachartcreator.AAChartType
import com.github.aachartmodel.aainfographics.aachartcreator.AAChartView
import com.github.aachartmodel.aainfographics.aachartcreator.AASeriesElement
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.*
import kotlin.time.ExperimentalTime

class ChartFragment : Fragment() {

    private lateinit var chartViewModel: ChartViewModel
    private lateinit var spinner: Spinner
    private lateinit var aaChartView: AAChartView
    private lateinit var firebaseReference: DatabaseReference
    lateinit var sampleDataList: MutableList<SampleData>
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val auth: FirebaseAuth = FirebaseAuth.getInstance()
        val currentUser = auth.currentUser!!.email.toString()
        sampleDataList = mutableListOf()
        this.firebaseReference = FirebaseDatabase.getInstance().getReference(currentUser.substringBefore("@"))
        firebaseReference.addValueEventListener(object : ValueEventListener {
            override fun onDataChange(dataSnapshot: DataSnapshot) {
                if (dataSnapshot.exists()) {
                    for (data in dataSnapshot.children) {
                        val sampleData = data.getValue(SampleData::class.java)
                        sampleDataList.add(sampleData!!)
                    }
                }
            }

            override fun onCancelled(p0: DatabaseError) {
                Log.d("OnCancelled", "Not implemented yet!")

            }
        })
    }
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        chartViewModel =
            ViewModelProviders.of(this).get(ChartViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_chart, container, false)
        spinner = root.findViewById(R.id.spinnerChart)
        aaChartView=root.findViewById(R.id.aa_chart_view)
        return root
    }

    @ExperimentalTime
    override fun onResume() {
        super.onResume()
        val chartType = resources.getStringArray(R.array.AAChartType)
        val adapter =
            context?.let { ArrayAdapter(it, android.R.layout.simple_spinner_item, chartType) }
        spinner.adapter = adapter

        spinner.onItemSelectedListener = object :
            AdapterView.OnItemSelectedListener {
            override fun onItemSelected(
                parent: AdapterView<*>,
                view: View, position: Int, id: Long
            ) {

                    populateGraphData(sampleDataList, chartType[position])


            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }

        }
    }
    fun populateGraphData(sampleData: MutableList<SampleData>, type: String) {
        for(e in sampleData){
            Log.d("Nezzuk meg","${e.value}")
        }
        val aaChartType: AAChartType = chosenChart(type)
        val aaChartModel: AAChartModel = AAChartModel()
            .chartType(aaChartType)
            .title("Charts")
            .backgroundColor("#4b2b7f")
            .dataLabelsEnabled(true)
            .yAxisMin(50F)
            .series(arrayOf(
                AASeriesElement()
                    .name("BPM")
                    .data(arrayOf(
                        // arrayOf(55,100),
                        100.00,
                        133.00,
                        126.00,
                        129.00,
                        121.00,
                        121.00,
                        122.00,
                        119.00,
                        131.00,
                        123.00,
                        92.00,
                        117.00,
                        129.00,
                        156.00,
                        154.00,
                        72.00,
                        90.00,
                        88.00,
                        89.00,
                        90.00,
                        91.00,
                        90.00
                    ))
            )
            )
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
    private fun chosenChart(type: String): AAChartType {
        var aaChartType = AAChartType.Line
        if (type == "Bar") {
            aaChartType = AAChartType.Bar
        } else if (type == "Column") {
            aaChartType = AAChartType.Column
        }
        return aaChartType
    }
}