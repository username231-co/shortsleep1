//
//  ContentView.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/09.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CommentViewModel()
    var body: some View {
        TabView{
            SleepView()
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("ホーム")
                }
            ContentView1()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("さがす")
                }
            ContentComementsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("メッセージ")
                }
            SleepCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
        }
        //ここで色の指定
    }
}
    
#Preview {
    ContentView()
}
