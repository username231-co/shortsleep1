//
//  karenderTab.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/26.
//
// SleepEntry.swift（別ファイルでもOK。同じファイルでもいい）
import SwiftUI

struct SleepCalendarView: View {
    @State private var currentDate = Date()
    
    // 仮データ（後でデータベース連携可能）
    @State private var sleepData: [String: Double] = [
        "2025/04/01": 6.5,
        "2025/04/02": 7.0,
        "2025/04/03": 5.5,
        "2025/04/04": 8.0,
        "2025/04/05": 7.5
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔵 ヘッダー（前月/次月）
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(date: currentDate))
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            Divider()
            
            // 🔵 カレンダー表
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                ForEach(generateCalendarDays(), id: \.self) { day in
                    VStack {
                        if day > 0 {
                            Text("\(day)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                            if let sleepHours = sleepData[formattedDate(for: day)] {
                                Text(String(format: "%.1f", sleepHours))
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            } else {
                                Text("")
                                    .font(.caption)
                            }
                        } else {
                            Text("")
                        }
                    }
                    .frame(height: 40)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // 🔵 一日ごとリスト
            List {
                ForEach(sortedSleepData(), id: \.key) { date, hours in
                    VStack(alignment: .leading) {
                        Text(date)
                            .font(.subheadline)
                        Text("\(hours, specifier: "%.1f")時間寝ました")
                            .font(.caption)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var weekdays: [String] {
        ["月", "火", "水", "木", "金", "土", "日"]
    }
    
    private func monthYearString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func generateCalendarDays() -> [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        guard let firstOfMonth = calendar.date(from: components) else { return [] }
        
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let numDays = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        
        var days: [Int] = Array(repeating: 0, count: (weekday + 5) % 7) // 月曜日始まり調整
        days += (1...numDays)
        return days
    }
    
    private func formattedDate(for day: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        var components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        components.day = day
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return ""
    }
    
    private func sortedSleepData() -> [(key: String, value: Double)] {
        sleepData.sorted { $0.key > $1.key }
    }
}
#Preview(){
    SleepCalendarView()
}
