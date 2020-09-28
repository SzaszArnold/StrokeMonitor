package com.android.service.strokemonitor

import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import androidx.appcompat.app.AppCompatActivity
import com.github.mikephil.charting.charts.BarChart
import com.github.mikephil.charting.charts.PieChart
import com.github.mikephil.charting.components.Legend
import com.github.mikephil.charting.components.LegendEntry
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.data.*
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter
import com.github.mikephil.charting.formatter.LargeValueFormatter
import com.github.mikephil.charting.utils.MPPointF
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.*
import kotlin.time.ExperimentalTime


class ChartActivity : AppCompatActivity() {
    private lateinit var firebaseReference: DatabaseReference
    lateinit var sampleDataList: MutableList<SampleData>

    @ExperimentalTime
    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chart)
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

    @ExperimentalTime
    override fun onResume() {
        super.onResume()
        val chartType = resources.getStringArray(R.array.Charts)
        val spinner = findViewById<Spinner>(R.id.spinner)
        if (spinner != null) {
            val adapter = ArrayAdapter(this,
                    android.R.layout.simple_spinner_item, chartType)
            spinner.adapter = adapter

            spinner.onItemSelectedListener = object :
                    AdapterView.OnItemSelectedListener {
                override fun onItemSelected(parent: AdapterView<*>,
                                            view: View, position: Int, id: Long) {
                    populateGraphData(sampleDataList, 10F, chartType[position].toString())
                }

                override fun onNothingSelected(parent: AdapterView<*>) {
                }

            }
        }
    }

    @ExperimentalTime
    fun populateGraphData(sampleData: MutableList<SampleData>, visibilityNumber: Float, type: String) {
        if (type == "Pie") {
            val anotherChart = findViewById<BarChart>(R.id.barChartView)
            anotherChart.visibility = View.INVISIBLE
            val pieChart = findViewById<PieChart>(R.id.pieChartView)
            pieChart.visibility = View.VISIBLE
            val noOfEmp = ArrayList<PieEntry>()
            for (e in sampleData) {
                noOfEmp.add(PieEntry(e.value.toFloat(), "${e.time.hours}:${e.time.minutes}"))
            }
            val dataSet = PieDataSet(noOfEmp, "BPM")

            dataSet.setDrawIcons(false)
            dataSet.sliceSpace = 3f
            dataSet.iconsOffset = MPPointF(0F, 40F)
            dataSet.selectionShift = 5f

            val data = PieData(dataSet)
            data.setValueTextSize(11f)
            data.setValueTextColor(Color.WHITE)
            pieChart.data = data
            pieChart.highlightValues(null)
            pieChart.invalidate()
            pieChart.animateXY(5000, 5000)
        }

        if (type == "Bar") {
            val anotherChart = findViewById<PieChart>(R.id.pieChartView)
            anotherChart.visibility = View.GONE
            val barChartView = findViewById<BarChart>(R.id.barChartView)
            barChartView.visibility = View.VISIBLE
            val barWidth = 0.15f
            val barSpace = 0.07f
            val groupSpace = 0.56f

            val xAxisValues = ArrayList<String>()
            val yValueGroup1 = ArrayList<BarEntry>()
            val yValueGroup2 = ArrayList<BarEntry>()
            val barDataSet1: BarDataSet
            val barDataSet2: BarDataSet
            for (e in sampleData) {
                val time = "${e.time.hours}:${e.time.minutes}"
                xAxisValues.add(time)
                yValueGroup1.add(BarEntry(e.value.toFloat(), e.value.toFloat()))
            }
            barDataSet1 = BarDataSet(yValueGroup1, "")
            barDataSet1.setColors(Color.BLUE)
            barDataSet1.label = "Date"
            barDataSet1.setDrawIcons(false)
            barDataSet1.setDrawValues(false)

            barDataSet2 = BarDataSet(yValueGroup2, "")
            barDataSet2.setColors(Color.YELLOW)

            barDataSet2.setDrawIcons(false)
            barDataSet2.setDrawValues(false)

            val barData = BarData(barDataSet1, barDataSet2)

            barChartView.description.isEnabled = false
            barChartView.description.textSize = 0f
            barData.setValueFormatter(LargeValueFormatter())
            barChartView.data = barData
            barChartView.barData.barWidth = barWidth
            barChartView.xAxis.axisMinimum = 0f
            barChartView.groupBars(0f, groupSpace, barSpace)
            barChartView.data.isHighlightEnabled = false
            barChartView.invalidate()
            barChartView.scrollX

            val legend = barChartView.legend
            legend.verticalAlignment = Legend.LegendVerticalAlignment.BOTTOM
            legend.horizontalAlignment = Legend.LegendHorizontalAlignment.RIGHT
            legend.orientation = Legend.LegendOrientation.HORIZONTAL
            legend.setDrawInside(false)

            val legenedEntries = arrayListOf<LegendEntry>()

            legenedEntries.add(LegendEntry("BPM", Legend.LegendForm.SQUARE, 8f, 8f, null, Color.BLUE))

            legend.setCustom(legenedEntries)

            legend.yOffset = 2f
            legend.xOffset = 2f
            legend.yEntrySpace = 0f
            legend.textSize = 5f

            val xAxis = barChartView.xAxis
            xAxis.granularity = 1f
            xAxis.isGranularityEnabled = true
            xAxis.setCenterAxisLabels(true)
            xAxis.setDrawGridLines(false)
            xAxis.textSize = 10f

            xAxis.position = XAxis.XAxisPosition.BOTTOM
            xAxis.valueFormatter = IndexAxisValueFormatter(xAxisValues)

            xAxis.labelCount = visibilityNumber.toInt()
            xAxis.mAxisMaximum = visibilityNumber
            xAxis.setCenterAxisLabels(true)
            xAxis.setAvoidFirstLastClipping(true)
            xAxis.spaceMin = 4f
            xAxis.spaceMax = 4f
            barChartView.setVisibleXRangeMaximum(visibilityNumber)
            barChartView.setVisibleXRangeMinimum(visibilityNumber)
            barChartView.isDragEnabled = true

            barChartView.axisRight.isEnabled = false
            barChartView.setScaleEnabled(true)

            val leftAxis = barChartView.axisLeft
            leftAxis.valueFormatter = LargeValueFormatter()
            leftAxis.setDrawGridLines(false)
            leftAxis.spaceTop = 1f
            leftAxis.axisMinimum = 0f


            barChartView.data = barData
            barChartView.setVisibleXRange(1f, visibilityNumber)
        }
       
    }
}

