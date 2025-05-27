//
//  comentclass.swift
//  shortsleep
//
//  Created by 松佳 on 2025/04/12.
//

import FirebaseFirestore
import SwiftUI


struct Comment: Identifiable {
    let id: String
    let userName: String
    let message: String
    let parentID: String? // nilなら親コメント
    let timestamp: Date//時間管理
    var iineCount: Int = 0
}

struct IineTab: Identifiable {
    var id: ObjectIdentifier
    let userName: String
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd" // ← 好きな形式でOK！
    return formatter.string(from: date)
}

import FirebaseFirestore

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private var db = Firestore.firestore()
    @Published var IineComments: [String] = []//いいねタブ表示ようの配列
    @Published var IineTabs : [IineTab] = []
    init() {
        fetchComments()
    }
    
    
    func fetchComments() {
        db.collection("comments")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.comments = docs.compactMap { doc in
                    let data = doc.data()
                    return Comment(
                        id: doc.documentID,
                        userName: data["userName"] as? String ?? "匿名",
                        message: data["message"] as? String ?? "",
                        parentID: data["parentID"] as? String,
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        iineCount: data["iineCount"]as? Int ?? 0
                        
                    )
                }
            }
    }
    
    func postComment(message:String,parentID:String? = nil){
        let newComment:[String:Any]=["userName":getUserName(),
                                     "message":message,
                                     "parentID":parentID as Any,
                                     "timestamp":Timestamp(date:Date())
        ]
        
        db.collection( "comments" ).addDocument(data: newComment)
        
        
        
        
    }
    func incrementLike(for id: String) {
        let ref = db.collection("comments").document(id)
        
        ref.updateData([
            "iineCount": FieldValue.increment(Int64(1))
        ])
        IineComments.append(id) // ✅ これでOK！
        //いいねタブ用
    }
    func decreaseLike(for id: String) {
        let ref = db.collection("comments").document(id)
        ref.updateData([
            "iineCount": FieldValue.increment(Int64(-1))
        ])
    }
    
    func getUserName() ->String{
        if let savedName = UserDefaults.standard.string(forKey: "userName"){
            return savedName
        }else{
            let newName = "匿名\(Int.random(in: 1000...9999))"
            UserDefaults.standard.set(newName, forKey: "userName")
            return newName
        }
    }
    // func IineTouroku(message:String){
    // let newIine:[String:Any]=["userName":getUserName(),
    //                      "message":message,
    
    // ]
    
    // db.collection( "IineTabs" ).addDocument(data: newIine)
    
    
    
    
    //  }
}
    


struct ContentComementsView: View {
    @StateObject var viewModel = CommentViewModel()

    var body: some View {
        TabView {
            CommentsView(viewModel: viewModel) // ✅ ← ここ追加！！
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("コメント")
                }

            ContentIineView(viewModel: viewModel) // ✅ ← ここも同じ！
                .tabItem {
                    Image(systemName: "hand.thumbsup")
                    Text("いいね")
                }
        }
    }
}


struct ContentIineView: View {
    @State private var isLiked = false
   
    @State private var message = ""
    @State private var replyTo: String? = nil
    @ObservedObject var viewModel: CommentViewModel
    var myLikedComments: [Comment] {
        viewModel.comments.filter {
            viewModel.IineComments.contains($0.id) && $0.parentID == nil
        }
    }

    var body: some View {
        ScrollView{
            VStack{
                VStack(alignment: .leading) {
                               Text("あなたがいいねした投稿")
                                   .font(.title2)
                                   .padding()

                               ForEach(myLikedComments) { comment in
                                   VStack(alignment: .leading) {
                                       HStack {
                                           Text(comment.userName).bold()
                                           Spacer()
                                           Text(formatDate(comment.timestamp))
                                               .foregroundColor(.gray)
                                               .font(.caption)
                                       }
                                       Text(comment.message)
                                       HStack {
                                           Image(systemName: "heart.fill").foregroundColor(.red)
                                           Text("\(comment.iineCount)")
                                       }
                                   }
                                   .padding()
                                   Divider()
                               }
                           }
                       }
               
                
              
                }
                
            }
        }


    struct CommentsView: View {
        @State private var isLiked = false
        @State private var message = ""
        @State private var replyTo: String? = nil
        @ObservedObject var viewModel: CommentViewModel
        
        var body: some View {
            NavigationStack {
                VStack {
                    
                    
                    Text("shortsleeper交流部屋")
                        .font(.system(size: 20, weight: .black))
                    
                
                    ScrollView{
                        ForEach(viewModel.comments.filter { $0.parentID == nil }) { parent in
                            NavigationLink(destination: CommentDetailView(parentComment: parent, viewModel: viewModel)) {
                                HStack{
                                    Spacer().frame(width: 22)
                                    
                                    VStack(alignment: .leading) {
                                        Spacer().frame(height: 10)
                                        HStack{
                                            Text(parent.userName).bold()
                                                .foregroundColor(Color.blue)
                                            Spacer().frame(width: 17)
                                            Text(formatDate(parent.timestamp))
                                                .foregroundColor(.gray)
                                        }
                                        
                                            
                                        Text(parent.message)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer(minLength: 7)
                                        HStack{
                                            Image(systemName: "bubble.left")
                                                .foregroundColor(.gray)
                                            
                                            
                                            Text("\(viewModel.comments.filter { $0.parentID == parent.id }.count)")
                                                .foregroundColor(.gray)
                                            Button(action: {
                                                isLiked.toggle()
                                               
                                            }) {
                                                HStack {
                                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                                        .foregroundColor(isLiked ? .red : .gray)
                                                    
                                                    Text("\(parent.iineCount)")
                                                        .foregroundColor(.gray)
                                                    
                                                }
                                                
                                            }
                                        }
                                        Spacer().frame(height: 15)
                                        Divider()
                                            
                                    }
                                }
                                
                            }
                            .frame(maxWidth:.infinity, alignment:.leading)
                        }
                    }
                    // ✅ 入力欄はここだけ！
                    HStack {
                        TextField("コメントを入力", text: $message)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("送信") {
                            viewModel.postComment(message: message, parentID: replyTo)
                            message = ""
                            replyTo = nil
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    
    #Preview {
        ContentComementsView()
    }
    
    
    
    struct CommentDetailView: View {
        var parentComment: Comment
        @State private var isLiked = false
        @ObservedObject var viewModel: CommentViewModel
        
        @State private var message = ""
        @State private var replyTo: String? = nil
        @State private var iineCount = 0
       
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // 親コメント表示
                VStack(alignment: .leading) {
                    HStack{
                        Text(parentComment.userName).bold()
                            .foregroundColor(Color.blue)
                        Spacer().frame(width: 17)
                        Text(formatDate(parentComment.timestamp))
                            .foregroundColor(.gray)
                    }
                    Text(parentComment.message)
                    HStack{
                        Image(systemName: "bubble.left")
                        
                        HStack{
                            Text("\(viewModel.comments.filter { $0.parentID == parentComment.id }.count)")
                        }
                        Button(action: {
                            isLiked.toggle()
                            isLiked ? viewModel.incrementLike(for: parentComment.id): viewModel.decreaseLike(for: parentComment.id)
                           // isLiked.viewModel.IineTouroku
                        }) {
                            HStack {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                Text("\(parentComment.iineCount)")
                                
                                
                            }
                            .foregroundColor(isLiked ? .red : .gray)
                        }
                        
                        
                    }
                    .padding()
                    
                    .cornerRadius(8)
                    
                    Divider()
                    
                    // 返信一覧
                    
                    
                    ScrollView{
                        ForEach(viewModel.comments.filter { $0.parentID == parentComment.id }) { reply in
                            
                            VStack(alignment: .leading) {
                                HStack{
                                    Text(reply.userName).font(.subheadline).bold()
                                    Spacer().frame(width: 17)
                                    Text(formatDate(reply.timestamp))
                                        .foregroundColor(.gray)
                                }
                                Text(reply.message).font(.subheadline);
                               
                                Button(action: {
                                    isLiked.toggle()
                                    isLiked ? viewModel.incrementLike(for: reply.id): viewModel.decreaseLike(for: reply.id)
                                   
                                    
                                }) {
                                    HStack {
                                        Image(systemName: isLiked ? "heart.fill" : "heart")
                                        Text("\(reply.iineCount)")
                                        
                                        
                                    }
                                    .foregroundColor(isLiked ? .red : .gray)
                                }
                                
                                
                            }.frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            
                        }
                        
                        Spacer()
                        
                    }
                    // ✅ 送信欄（常に1つだけ表示）
                    VStack(alignment: .leading) {
                        if replyTo != nil {
                            HStack {
                                Text("返信中…").font(.caption)
                                Button("キャンセル") {
                                    replyTo = nil
                                }.font(.caption).foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            TextField(replyTo != nil ? "返信を入力" : "コメントを入力", text: $message)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("送信") {
                                viewModel.postComment(message: message, parentID: replyTo ?? parentComment.id)
                                message = ""
                                replyTo = nil
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                .padding()
                .navigationTitle("コメント詳細")
            }
        }
        
    }

