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
        aaChartView = root.findViewById(R.id.aa_chart_view)
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
                val array = arrayOf("")
                for (e in sampleDataList) {
                    array.plus(arrayOf("${e.time.hours}:${e.time.minutes}", e.value))
                }
                populateGraphData(sampleDataList, chartType[position])


            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }

        }
    }

    fun populateGraphData(sampleData: MutableList<SampleData>, type: String) {
        /*  val list= mutableListOf<Pair<String,String>>()
          for(e in sampleData){
              list.add( Pair("${e.time.hours}:${e.time.minutes}","${e.value}"))
          }
          for(e in list) {
              Log.d("Tesztek", "${e.first}-----${e.second}")

          }*/
        val aaChartType: AAChartType = chosenChart(type)
        val aaChartModel: AAChartModel = AAChartModel()
                .chartType(aaChartType)
                .title("Charts")
                .backgroundColor("#4b2b7f")
                .dataLabelsEnabled(true)
                .xAxisVisible(false)
                .gradientColorEnable(true)
                .yAxisMin(50F)
                .series(arrayOf(
                        AASeriesElement()
                                .name("BPM")
                                .data(arrayOf(
                                        arrayOf("15:53", 100),
                                        arrayOf("15:54", 133),
                                        arrayOf("15:55", 126),
                                        arrayOf("15:56", 129),
                                        arrayOf("15:57", 121),
                                        arrayOf("15:58", 121),
                                        arrayOf("15:59", 122),
                                        arrayOf("16:00", 119),
                                        arrayOf("16:01", 131),
                                        arrayOf("16:02", 123),
                                        arrayOf("16:03", 92),
                                        arrayOf("16:04", 117),
                                        arrayOf("16:05", 129),
                                        arrayOf("16:06", 156),
                                        arrayOf("16:07", 154),
                                        arrayOf("16:08", 72),
                                        arrayOf("16:09", 90),
                                        arrayOf("16:10", 88),
                                        arrayOf("16:11", 89),
                                        arrayOf("16:12", 90),
                                        arrayOf("16:13", 91),
                                        arrayOf("16:14", 90)
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