////
////  ProvidersView.swift
////  MasterFeed
////
////  Created by Javier Fuentes on 30-03-21.
////
//
//import SwiftUI
//
//
//struct ProviderIconView: View {
//    
//    var size: CGFloat = 100
//    var provider: String
//    var body: some View {
//        Image(provider)
//            .resizable()
//            .scaledToFit()
//            .frame(width: size, height: size)
//            .clipShape(Circle())
//            .shadow(color: .white, radius: 1, x: 0.0, y: 3.0)
//            .shadow(color: .gray, radius: 7, x: 0.0, y: 3.0)
//            .overlay(Circle().stroke(Color.white, lineWidth: 7))
//    }
//}
//
//struct ProvidersView: View {
//    
//    var providers: [String]
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(providers, id:\.self) { provider in
//                    VStack {
//                        ProviderIconView(provider: provider)
//                            .padding(.bottom, 5)
//                        Text(provider)
//                            .font(.footnote)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.gray)
//                    }.padding()
//                }
//            }
//        }
//    }
//}
//
//struct ProvidersView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ProviderIconView(provider: "fox")
//                .previewLayout(.sizeThatFits)
//            ProvidersView(providers: ["cnn", "fox","nyt", "cnn", "fox","nyt"])
//                .previewLayout(.sizeThatFits)
//            ProvidersView(providers: ["cnn", "fox","nyt", "cnn", "fox","nyt"])
//                .previewLayout(.sizeThatFits)
//                .preferredColorScheme(.dark)
//        }
//    }
//}
