//
//  ButtonsNextPreviousView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//

import SwiftUI

struct ButtonsNextPreviousView: View {
    
    @Binding var selection: Int
    
    var body: some View {
        HStack {
            
            if selection > 0 {
                Button(action: {
                    withAnimation(.spring()) {
                        selection -= 1
                    }
                }, label: {
                    Text("Previous").buttonStyle(CGSize(width: 150, height: 44))
                })
                .transition(.opacity)
                .animation(.spring())
            } else {
                Text("Previous").foregroundColor(.secondary).buttonStyle(CGSize(width: 150, height: 44))
            }
            
            if selection < OnboardingPagesViewList.count - 1 {
                Button(action: {
                    withAnimation(.spring()) {
                        selection += 1
                    }
                }, label: {
                    Text("Next").buttonStyle(CGSize(width: 150, height: 44))
                })
                .transition(.opacity)
                .animation(.spring())
            } else {
                Text("Next").foregroundColor(.secondary).buttonStyle(CGSize(width: 150, height: 44))
            }
        }
    }
}


struct ButtonsNextPreviousView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ButtonsNextPreviousView(selection: Binding.constant(0)).previewLayout(.sizeThatFits)
            ButtonsNextPreviousView(selection: Binding.constant(1)).previewLayout(.sizeThatFits)
            ButtonsNextPreviousView(selection: Binding.constant(2)).previewLayout(.sizeThatFits)
        }
    }
}
