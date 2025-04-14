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
    let timestamp: Date
}

import FirebaseFirestore

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private var db = Firestore.firestore()

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
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        
                    )
                }
            }
    }

    func postComment(message:String,parentID:String? = nil){
        let randomName="匿名\(Int.random(in: 1000...9999))"
        let newComment:[String:Any]=["userName":randomName,
                                     "message":message,
                                     "parentID":parentID as Any,
                                     "timestamp":Timestamp(date:Date())
        ]
        
        db.collection( "comments" ).addDocument(data: newComment)
        
        
    }
}

struct CommentsView: View {
    @StateObject var viewModel = CommentViewModel()
    @State private var message = ""
    @State private var replyTo: String? = nil

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.comments.filter { $0.parentID == nil }) { comment in
                    VStack(alignment: .leading) {
                        Text(comment.userName).bold()
                        Text(comment.message)
                        Button("返信") {
                            replyTo = comment.id
                        }

                        // 返信表示
                        ForEach(viewModel.comments.filter { $0.parentID == comment.id }) { reply in
                            HStack {
                                Spacer().frame(width: 20)
                                VStack(alignment: .leading) {
                                    Text(reply.userName).font(.subheadline).bold()
                                    Text(reply.message).font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }

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

#Preview {
    CommentsView()
}

