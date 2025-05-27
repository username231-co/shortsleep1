//
//  timer.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/21.
//
import SwiftUI

struct ContentView1: View {
    @State var timerHandler: Timer?
    @State var count = 0
    @AppStorage("timer_value") var timerValue = 10    // 秒
    @State var isShowAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("backgroundTimer")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                VStack(spacing: 30.0) {
                    Text("残り\(timeString(from: timerValue - count))")
                        .font(.largeTitle)
                    
                    HStack {
                        Button {
                            startTimer()
                        } label: {
                            Text("スタート")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 140)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            if let timerHandler = timerHandler, timerHandler.isValid {
                                timerHandler.invalidate()
                            }
                        } label: {
                            Text("ストップ")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 140)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .onAppear {
                count = 0
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView()) {
                        Text("時間設定")
                    }
                }
            }
            .alert("終了", isPresented: $isShowAlert) {
                Button("OK") {
                    print("OKがタップされました")
                }
            } message: {
                Text("おはようございます")
            }
        }
    }
    //ここから時間設定、秒数、分数
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return "\(hours)時間\(minutes)分\(seconds)秒"
    }
    
    func countDownTimer() {
        count += 1
        if timerValue - count <= 0 {
            timerHandler?.invalidate()
            isShowAlert = true
        }
    }
    
    func startTimer() {
        if let timerHandler=timerHandler, timerHandler.isValid {
            return
        }
        
        if timerValue-count<=0 {
            count = 0
        }
        
        timerHandler=Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                countDownTimer()
            }
        }
    }
}

#Preview {
    ContentView1()
}

struct SettingView: View {
    @AppStorage("timer_value") var timerValue: Int = 10  //
    let timeOptions = [60, 300, 600, 1800, 3600, 7200, 10800,14400]   // 秒　1分〜4時間、後から追加可能

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("\(timeString(from: timerValue))")
                    .font(.largeTitle)
                Picker(selection: $timerValue) {
                    ForEach(timeOptions, id: \.self) { value in
                        Text(timeString(from: value)).tag(value)
                    }
                } label: {
                    Text("選択")
                }
                .pickerStyle(.wheel)
                
                Spacer()
            }
        }
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours)時間")
        }
        if minutes > 0 { parts.append("\(minutes)分")
        }
        if seconds > 0 || parts.isEmpty { parts.append("\(seconds)秒") }
        
        return parts.joined()
    }
}
