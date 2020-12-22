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
import androidx.lifecycle.ViewModelProviders
import com.android.service.strokemonitor.R
import com.android.service.strokemonitor.SampleData
import com.github.aachartmodel.aainfographics.aachartcreator.AAChartModel
import com.github.aachartmodel.aainfographics.aachartcreator.AAChartType
import com.github.aachartmodel.aainfographics.aachartcreator.AAChartView
import com.github.aachartmodel.aainfographics.aachartcreator.AASeriesElement
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.*
import java.util.*
import kotlin.collections.ArrayList
import kotlin.time.ExperimentalTime

class ChartFragment : Fragment() {

    private lateinit var chartViewModel: ChartViewModel
    private lateinit var spinnerFilter: Spinner
    private lateinit var spinnerChart: Spinner
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
        spinnerChart = root.findViewById(R.id.spinnerChart)
        spinnerFilter=root.findViewById(R.id.spinnerFilter)
        aaChartView = root.findViewById(R.id.aa_chart_view)
        return root
    }

    @ExperimentalTime
    override fun onResume() {
        super.onResume()
        val chartType = resources.getStringArray(R.array.AAChartType)
        val adapter =
                context?.let { ArrayAdapter(it, android.R.layout.simple_spinner_item, chartType) }
        spinnerChart.adapter = adapter

        spinnerChart.onItemSelectedListener = object :
                AdapterView.OnItemSelectedListener {

            override fun onItemSelected(
                    parent: AdapterView<*>,
                    view: View, position: Int, id: Long
            ) {

            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }

        }
        val filterType = resources.getStringArray(R.array.Filters)
        val adapterFilter =
                context?.let { ArrayAdapter(it, android.R.layout.simple_spinner_item, filterType) }
        spinnerFilter.adapter = adapterFilter

        spinnerFilter.onItemSelectedListener = object :
                AdapterView.OnItemSelectedListener {
            override fun onItemSelected(
                    parent: AdapterView<*>,
                    view: View, position: Int, id: Long
            ) {
                val array = arrayListOf<Any>()

                if(filterType[position]=="Last Hour"){
                    val calendar: Calendar = Calendar.getInstance()
                    val hour: Int = calendar.get(Calendar.HOUR_OF_DAY)
                    for (e in sampleDataList) {
                        if(e.time.hours==hour-1)
                            array.add(arrayOf("${e.time.hours}:${e.time.minutes}", e.value))
                    }

                    populateGraphData(array, chartType[position])
                }
                if(filterType[position]=="Last Day"){
                    val calendar: Calendar = Calendar.getInstance()
                    val day: Int = calendar.get(Calendar.DAY_OF_WEEK)
                    for (e in sampleDataList) {
                        if(e.time.day==day-1)
                            array.add(arrayOf("${e.time.hours}:${e.time.minutes}", e.value))
                    }

                    populateGraphData(array, chartType[position])
                }
                if(filterType[position]=="Last Week"){
                    for (e in sampleDataList) {
                            array.add(arrayOf("${e.time.hours}:${e.time.minutes}", e.value))
                    }

                    populateGraphData(array, chartType[position])
                }
            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }

        }
    }

    fun populateGraphData(sampleData: ArrayList<Any>, type: String) {
        val aaChartType: AAChartType = chosenChart(type)
        val aaChartModel: AAChartModel = AAChartModel()
                .chartType(aaChartType)
                .title("Charts")
                .backgroundColor("#4b2b7f")
                .dataLabelsEnabled(true)
                .xAxisVisible(true)
                .gradientColorEnable(true)
                .yAxisMin(50F)
                .series(arrayOf(
                        AASeriesElement()
                                .name("BPM")
                         .data(sampleData.toArray())
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