////
////  CardsView.swift
////  MasterFeed
////
////  Created by Javier Fuentes on 15-05-21.
////
//
//import SwiftUI
//
//struct CardView: View {
//
//    var tweets: [Tweet]
//    @State var offsetBlur: Double = 0
//    @State var selection: String = "sample"
//
//    @State var cardSelection = [false, false]
//    @State var cardOpacity = [0.0, 0.0]
//    @Environment(\.safeAreaInsets) private var safeAreaInsets
//    @Environment(\.colorScheme) var scheme
//    var body: some View {
//
//            ScrollView {
//                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
//                    GeometryReader { geo -> AnyView in
//
//                        let offsetMin = geo.frame(in: .global).minY
//
//                        let offset = offsetMin > 0 ? offsetMin : 0
//
//
//                        return AnyView(
//
//                            TabView(selection: $selection) {
//                                Image("sample").resizable().aspectRatio(contentMode: .fill)
//
//                                    .frame(width: UIScreen.main.bounds.width).clipped()
//                                    .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
//                                    .overlay(Text("T fkjherkfjhek kfhjerkf kjfrehkf kjferh kfer ferkgh jfheritle")
//                                                .foregroundColor(.white)
//                                                .font(.title).fontWeight(.heavy).padding(.bottom, 40), alignment: .bottom)
//                                    .overlay(NavigationLink(
//                                                destination: Text("Destination 0"),
//                                                isActive: $cardSelection[0],
//                                                label: {}))
//                                    .onTapGesture {
//                                        cardSelection[0] = true
//                                    }
//                                    .overlay(Color.black.opacity(cardOpacity[0]))
//                                    .onLongPressGesture(minimumDuration: 1, pressing: { pressing in
//                                        withAnimation {
//                                            cardOpacity[0] = pressing ? 0.4 : 0.0
//                                        }
//                                    }, perform: {})
//                                    .tag("sample")
//
//                                Image("sample2").resizable().aspectRatio(contentMode: .fill)
//                                    .frame(width: UIScreen.main.bounds.width).clipped()
//                                    .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
//                                    .overlay(Text("T fkjherkfjhek kfhjerkf kjfrehkf kjferh kfer ferkgh jfheritle")
//                                                .foregroundColor(.white)
//                                                .font(.title).fontWeight(.heavy).padding(.bottom, 40), alignment: .bottom)
//                                    .overlay(NavigationLink(
//                                                destination: Text("Destination 1"),
//                                                isActive: $cardSelection[1],
//                                                label: {Color.clear}))
//                                    .onTapGesture {
//                                        cardSelection[1] = true
//                                    }
//                                    .overlay(Color.black.opacity(cardOpacity[1]))
//                                    .onLongPressGesture(minimumDuration: 1, pressing: { pressing in
//                                        withAnimation {
//                                            cardOpacity[1] = pressing ? 0.4 : 0.0
//                                        }
//                                    }, perform: {})
//                                    .tag("sample2")
//
//                            }.tabViewStyle(PageTabViewStyle())
//                            .frame(height: 400 + offset)
//                            .offset(y: -offset)
//
//                        )
//                    }.frame(height: 400)
//
//
//                    Section {
//                        Text("Section 1 ").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//
//                        Text("Section 1").padding()
//                    }
//                    Section {
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                    }
//                    Section {
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                        Text("Section 1").padding()
//                    }
//                }
//            }.overlay((scheme == .light ? Color.white : Color.black)
//                        .frame(width: UIScreen.screens.first!.bounds.width, height: safeAreaInsets.top, alignment: .center).opacity(0.5), alignment: .top)
//
//            .ignoresSafeArea(.container, edges: .top)
//            .navigationBarHidden(true)
//
//    }
//}
//
//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            CardView(tweets: [])
//                .navigationBarHidden(true)
//        }
//    }
//}
//
//
