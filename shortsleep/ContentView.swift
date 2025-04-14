//
//  ContentView.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            SwiftUIView()
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("ホーム")
                }
            Text("2")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("さがす")
                }
            CommentsView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("メッセージ")
                }
        }
        //ここで色の指定
    }
}
    
#Preview {
    ContentView()
}
