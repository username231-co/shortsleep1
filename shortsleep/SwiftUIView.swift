//
//  SwiftUIView.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/09.
//

import SwiftUI

import Charts

struct Data: Identifiable {
    var id: String { category }
    let category: String
    let value: Int
}

struct DataRow: Identifiable {
    let id = UUID()
    let date: String
    let value: Int
}


struct SwiftUIView: View {

    @State var inputName = ""
    @State var inputHizuke = ""
    @FocusState var isFocused: Bool//状態変数としてTextFieldに紐付け
    @State var data: [Data] = [
            .init(category: "2024/4/10", value: 8),
            .init(category: "2024/4/11", value: 10)
        ]
    @State var listyou: [DataRow] = [
           DataRow(date: "2024/4/10", value: 8),
           DataRow(date: "2024/4/11", value: 10)
       ]
    var body: some View {
        VStack{
            TextField("日付を入力してください",text: $inputName) // ⬅︎
            TextField("時間を入力してください",text: $inputHizuke)
            
            Button("送信"){
                isFocused = false
                data.append(.init(category: inputName, value: Int(inputHizuke)!))
                listyou.append(DataRow(date: inputName, value: Int(inputHizuke)!))
                print(data)
                
            }
            
            
            Chart {
                ForEach(data) {
                    BarMark(
                        x: .value("Category", $0.category),
                        y: .value("value", $0.value)
                    )
                }
            }
            .frame(height: 200)
            .padding()
            
            
            
            List{
                ForEach(listyou) { row in
                    Text("\(row.date): \(row.value)")
                }
            }
        }
    }
    // body
} // Vie


#Preview {
    SwiftUIView()
}
