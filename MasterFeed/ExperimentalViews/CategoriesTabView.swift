////
////  CategoriesTabView.swift
////  MasterFeed
////
////  Created by Javier Fuentes on 30-03-21.
////
//
//import SwiftUI
//
//struct CategoriesTabView: View {
//    var categories: [String]
//    var selectedCategory: String
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            ScrollViewReader { proxy in
//                HStack {
//                    ForEach(categories, id:\.self) { category in
//                        Group {
//                            Spacer(minLength: category == selectedCategory ? 15 : 5)
//                            (Text(category == selectedCategory ? "#" : "") +
//                            Text(category))
//                                .fontWeight(category == selectedCategory ? .bold : nil)
//                                .font(.title3)
//                                .foregroundColor(category == selectedCategory ? .blue : nil)
//                            Spacer(minLength: category == selectedCategory ? 15 : 5)
//                        }.id(category)
//                    }
//                }.onAppear(perform: {
//                    proxy.scrollTo(selectedCategory)
//                })
//            }
//        }.background(Color.gray)
//    }
//}
//
//struct CategoriesTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesTabView(categories: ["Latest", "US", "Politics", "Health", "Entertainment", "Education"], selectedCategory: "Health")
//            .previewLayout(.sizeThatFits)
//    }
//}
