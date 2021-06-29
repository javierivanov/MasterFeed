//
//  Extensions.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//


import SwiftUI



struct ButtonStyle: ViewModifier {
    
    var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: size.width, height: size.height)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}


extension View {
    func buttonStyle(_ size: CGSize) -> some View {
        modifier(ButtonStyle(size: size))
    }
}
