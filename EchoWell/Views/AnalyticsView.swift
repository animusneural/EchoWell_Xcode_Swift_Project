//  AnalyticsView.swift
//  EchoWell
//
//  Created by Matei Grigore on 6/23/25.
//

import SwiftUI
import Charts    // available in iOS 16+/macOS 13+

/// Simple usage analytics: clips per day and tag distribution.
struct AnalyticsView: View {
    @State private var clips: [EchoClip] = []

    // MARK: — Aggregated data
    private var clipsByDay: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: clips) { clip in
            calendar.startOfDay(for: clip.timestamp)
        }
        return grouped
            .map { (date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    private var tagFrequencies: [(tag: String, count: Int)] {
        let grouped = Dictionary(grouping: clips) { $0.contextTag }
        return grouped
            .map { (tag: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    DataExportView()
                    Spacer()
                               }
                // — Clips per Day —
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clips per Day")
                        .font(.headline)
                    Chart(clipsByDay, id: \.date) { entry in
                        BarMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Clips", entry.count)
                        )
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 1)) { tick in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                    .frame(height: 180)
                }

                // — Tag Distribution —
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tag Distribution")
                        .font(.headline)
                    Chart(tagFrequencies, id: \.tag) { entry in
                        SectorMark(
                            angle: .value("Count", entry.count),
                            innerRadius: .ratio(0.5),
                            outerRadius: .ratio(1.0)
                        )
                        .foregroundStyle(by: .value("Tag", entry.tag))
                    }
                    .frame(height: 180)
                    .chartLegend(position: .bottom)
                }
            }
            .padding([.horizontal, .bottom]) // no top padding so charts sit tight under nav bar
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            clips = Database.shared.fetchAll()
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnalyticsView()
                .navigationTitle("Analytics")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
