//
//  StatsViewController.swift
//  stressReminder
//
//  Created on 2025/04/20.
//
import UIKit
import DGCharts

class StatsViewController: UIViewController {
    
    private let stressManager = StressManager.shared
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ストレス統計"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["週間", "月間", "レベル別"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let chartView: BarChartView = {
        let chart = BarChartView()
        chart.noDataText = "データがありません"
        chart.rightAxis.enabled = false
        chart.legend.enabled = true
        chart.legend.horizontalAlignment = .center
        chart.legend.verticalAlignment = .bottom
        chart.xAxis.labelPosition = .bottom
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    private let pieChartView: PieChartView = {
        let chart = PieChartView()
        chart.noDataText = "データがありません"
        chart.isHidden = true
        chart.legend.enabled = true
        chart.legend.horizontalAlignment = .center
        chart.legend.verticalAlignment = .bottom
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.entryLabelColor = .label
        chart.entryLabelFont = .systemFont(ofSize: 12)
        return chart
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "統計"
        
        setupViews()
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        registerForNotifications()
        
        // 初期表示
        updateWeeklyChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChart()
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(entriesDidChange),
            name: NSNotification.Name("EntriesDidChange"),
            object: nil
        )
    }
    
    @objc private func entriesDidChange() {
        updateChart()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(chartView)
        view.addSubview(pieChartView)
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            chartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            chartView.heightAnchor.constraint(equalToConstant: 300),
            
            pieChartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            pieChartView.heightAnchor.constraint(equalToConstant: 300),
            
            statusLabel.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateChart()
    }
    
    private func updateChart() {
        // 選択されたセグメントによってグラフを切り替え
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            chartView.isHidden = false
            pieChartView.isHidden = true
            updateWeeklyChart()
        case 1:
            chartView.isHidden = false
            pieChartView.isHidden = true
            updateMonthlyChart()
        case 2:
            chartView.isHidden = true
            pieChartView.isHidden = false
            updateLevelPieChart()
        default:
            break
        }
    }
    
    private func updateWeeklyChart() {
        // 週間データの取得（過去7日間）
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        var stressEntries: [BarChartDataEntry] = []
        var solutionEntries: [BarChartDataEntry] = []
        var xLabels: [String] = []
        
        // 過去7日間のデータを用意
        for dayOffset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dayEntries = stressManager.entriesForDate(date)
                let stressCount = dayEntries.filter { $0.type == .stress }.count
                let solutionCount = dayEntries.filter { $0.type == .solution }.count
                
                stressEntries.append(BarChartDataEntry(x: Double(6 - dayOffset), y: Double(stressCount)))
                solutionEntries.append(BarChartDataEntry(x: Double(6 - dayOffset), y: Double(solutionCount)))
                
                xLabels.append(dateFormatter.string(from: date))
            }
        }
        
        // データセットの作成
        let stressDataSet = BarChartDataSet(entries: stressEntries, label: "ストレス")
        stressDataSet.colors = [.systemRed]
        
        let solutionDataSet = BarChartDataSet(entries: solutionEntries, label: "解決策")
        solutionDataSet.colors = [.systemGreen]
        
        // グループ化したバーチャートデータの作成
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        
        let data = BarChartData(dataSets: [stressDataSet, solutionDataSet])
        data.barWidth = barWidth
        
        // X軸の設定
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
        chartView.xAxis.granularity = 1
        
        // グループ化の設定
        data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        chartView.data = data
        
        // ステータスラベルの更新
        let totalStress = stressEntries.reduce(0) { $0 + $1.y }
        let totalSolution = solutionEntries.reduce(0) { $0 + $1.y }
        statusLabel.text = "過去7日間: ストレス \(Int(totalStress))件, 解決策 \(Int(totalSolution))件"
    }
    
    private func updateMonthlyChart() {
        // 月間データの取得（過去30日間）
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        var stressEntries: [BarChartDataEntry] = []
        var solutionEntries: [BarChartDataEntry] = []
        var xLabels: [String] = []
        
        // 過去30日間のデータを、6グループに分ける
        for group in 0..<6 {
            var stressCount = 0
            var solutionCount = 0
            var groupLabel = ""
            
            for day in 0..<5 {
                let dayOffset = group * 5 + day
                if dayOffset < 30, let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                    let dayEntries = stressManager.entriesForDate(date)
                    stressCount += dayEntries.filter { $0.type == .stress }.count
                    solutionCount += dayEntries.filter { $0.type == .solution }.count
                    
                    if day == 0 {
                        groupLabel = dateFormatter.string(from: date)
                    }
                }
            }
            
            stressEntries.append(BarChartDataEntry(x: Double(5 - group), y: Double(stressCount)))
            solutionEntries.append(BarChartDataEntry(x: Double(5 - group), y: Double(solutionCount)))
            xLabels.append(groupLabel)
        }
        
        // データセットの作成
        let stressDataSet = BarChartDataSet(entries: stressEntries, label: "ストレス")
        stressDataSet.colors = [.systemRed]
        
        let solutionDataSet = BarChartDataSet(entries: solutionEntries, label: "解決策")
        solutionDataSet.colors = [.systemGreen]
        
        // グループ化したバーチャートデータの作成
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        
        let data = BarChartData(dataSets: [stressDataSet, solutionDataSet])
        data.barWidth = barWidth
        
        // X軸の設定
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
        chartView.xAxis.granularity = 1
        
        // グループ化の設定
        data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        chartView.data = data
        
        // ステータスラベルの更新
        let totalStress = stressEntries.reduce(0) { $0 + $1.y }
        let totalSolution = solutionEntries.reduce(0) { $0 + $1.y }
        statusLabel.text = "過去30日間: ストレス \(Int(totalStress))件, 解決策 \(Int(totalSolution))件"
    }
    
    private func updateLevelPieChart() {
        // ストレスレベル別の統計データ
        let stats = stressManager.stressLevelStatistics()
        
        var entries: [PieChartDataEntry] = []
        
        // 各レベルのデータをパイチャートエントリーに変換
        for level in StressLevel.allCases {
            let count = stats[level] ?? 0
            if count > 0 {
                entries.append(PieChartDataEntry(value: Double(count), label: level.description))
            }
        }
        
        // データセットの作成
        let dataSet = PieChartDataSet(entries: entries, label: "ストレスレベル")
        
        // 色の設定
        dataSet.colors = StressLevel.allCases.map { $0.color }
        
        // フォーマットの設定
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        // データセットの設定
        dataSet.valueFont = .systemFont(ofSize: 12)
        dataSet.valueTextColor = .white
        
        // チャートデータの設定
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        
        // ステータスラベルの更新
        let total = entries.reduce(0) { $0 + $1.value }
        statusLabel.text = "総ストレス記録数: \(Int(total))件"
    }
}
