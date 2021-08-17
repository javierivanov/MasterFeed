//
//  OnboardingTabsView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//

import SwiftUI

struct OnboardingTabsView: View {
    
    @Binding var selection: Int
    
    var body: some View {

        TabView(selection: $selection) {
            ForEach(OnboardingPagesViewList.indices, id: \.self) { index in
                OnboardingPagesViewList[index].view.padding()
            }
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
    }
}

struct OnboardingTabsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTabsView(selection: Binding.constant(0))
    }
}
