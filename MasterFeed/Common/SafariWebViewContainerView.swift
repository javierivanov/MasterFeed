//
//  SafariWebViewContainerView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 26-07-21.
//

import SwiftUI

struct SafariWebViewContainerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var presented: Bool = true
    var url: URL
    var readerMode: Bool
    var body: some View {
        Text("")
//        SafariWebView(url: url, presented: $presented, readerMode: true)
//            .onChange(of: presented, perform: { value in
//                print(value)
//                if !value {
//                    presentationMode.dismiss()
//                }
//            })
    }
}

//struct SafariWebViewContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SafariWebViewContainerView()
//    }
//}
