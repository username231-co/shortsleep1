//
//  SwiftUIView.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/09.
//

import Foundation

struct SleepEntry: Identifiable {
    let id: String
    let date: String
    let hours: Double
}


import FirebaseFirestore

class SleepViewModel: ObservableObject {
    @Published var entries: [SleepEntry] = []
    private var db = Firestore.firestore()

    init() {
        fetchEntries()
    }

    func addEntry(date: String, hours: Double) {
        let newEntry: [String: Any] = [
            "date": date,
            "hours": hours
        ]

        db.collection("sleep_logs").addDocument(data: newEntry)
    }

    func fetchEntries() {
        db.collection("sleep_logs")
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.entries = docs.compactMap { doc in
                    let data = doc.data()
                    return SleepEntry(
                        id: doc.documentID,
                        date: data["date"] as? String ?? "",
                        hours: data["hours"] as? Double ?? 0
                    )
                }
            }
    }
}

import SwiftUI
import Charts

struct SleepView: View {
    @StateObject var viewModel = SleepViewModel()
    @State private var date = ""
    @State private var hours = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 入力フォーム
                VStack(alignment: .leading, spacing: 10) {
                    Text("日付（例: 2025/04/21）").font(.caption).foregroundColor(.gray)
                    TextField("日付を入力", text: $date)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focused)

                    Text("睡眠時間（h）").font(.caption).foregroundColor(.gray)
                    TextField("例: 7.5", text: $hours)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button("送信") {
                    if let h = Double(hours) {
                        viewModel.addEntry(date: date, hours: h)
                        date = ""
                        hours = ""
                        focused = false
                    }
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)

                // グラフ（最新7件）
                Chart {
                    ForEach(viewModel.entries.suffix(7)) { entry in
                        BarMark(
                            x: .value("日付", entry.date),
                            y: .value("時間", entry.hours)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: 200)
                .padding(.top)

                // リスト表示（確認用）
                List {
                    ForEach(viewModel.entries.suffix(7)) { entry in
                        Text("\(entry.date): \(entry.hours, specifier: "%.1f") 時間")
                    }
                }
                .listStyle(.inset)
            }
            .padding()
            .navigationTitle("睡眠ログ")
            .background(Color(.systemGroupedBackground))
        }
    }
}
#Preview {
    SleepView()
}