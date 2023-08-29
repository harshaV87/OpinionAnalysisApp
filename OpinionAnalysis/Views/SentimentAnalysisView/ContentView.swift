//
//  ContentView.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/29/23.
//

import SwiftUI

struct SentimentView: View {
    // MARK: Properties
    @ObservedObject var viewModel = CommentsViewModel()
    @ObservedObject var authViewModel: AuthViewModel
    @State private var textInput: String = " "
    @State private var pageNumber = 4
    @State private var showOptionStack = true
    @State private var animateList = false

    var body: some View {
        // MARK: Navigation view
        NavigationView {
            VStack {
                // MARK: FLOATING LABEL FOR YOUTUBE URL
                FloatingLabelInput(placeHolderText: "Please enter the youtube link below", text: $textInput)
                // MARK: Laoding view
            LoaderView(tintColor: .red, scaleSize: 1.0).padding(.bottom, 10).hidden(!viewModel.loading).foregroundColor(.blue)
                // MARK: Toggling the Show options stack
                if showOptionStack {
                    VStack {
                        // MARK: Picker view for page numbers
                    VStack {
                        Text("No of results selection")
                        Picker("No of results to analyze", selection: $pageNumber) {
                            ForEach(1...100, id: \.self) {
                                Text("\($0)")
                            }
                        }.pickerStyle(.wheel).labelsHidden()
                    }
                // MARK: Show Options button toggle
                        Button {
                            self.showOptionStack.toggle()
                            viewModel.videoUrl = extractIDFromURL.extract.getIDFromURL(from: textInput)
                            viewModel.maxValues = "\(pageNumber)"
                // MARK: Action to get the comments from youtube API
                            Task {
                                viewModel.commentDict = [:]
                                await viewModel.getCommentsFromOrigin()
                                    //viewModel.getCombineEvents()
                            }
                        } label: {
                            Text("Show Insights").padding().background(textInput == " " ? Color.gray : Color.black).foregroundColor(Color.white).cornerRadius(10)
                        }.disabled(textInput == " " ? true : false)
                    }.padding().border(Color.gray)
                } else {
                    // MARK: Color palette to show the corresponding color for the comments
                    ColorPaletteView()
                    // MARK: Comment List view
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(viewModel.commentDict.keys), id: \.self) { k in
                                HStack {
                                    Text(k).padding(20)
                                }
                                .frame(maxWidth: .infinity).frame(height: animateList ? nil : 0)
                                .clipShape(RoundedRectangle(cornerRadius: animateList ? 10 : 0)).overlay(
                                    RoundedRectangle(cornerRadius: 20).stroke(viewModel.getColorGradients(givenScore: Double(String(viewModel.commentDict[k] ?? "")) ?? 0.0), lineWidth: 5) // MARK: Setting the color palette around the stack
                                ).padding(10).onAppear {
                                    withAnimation {
                                        self.animateList = true
                                    }
                                }
                            }
                        }
                    }
                }
            // MARK: SHOW OPTION STACK BUTTON FOR TOGGLING THE VIEW AND OPTIONS
                Button {
                    withAnimation {
                        self.showOptionStack.toggle()
                    }
                } label: {
                    Text("Show Options").padding().background(Color.black).foregroundColor(Color.white).cornerRadius(10)
                }.hidden(showOptionStack ? true : false).frame(height: 30, alignment: .center)
            }.padding().navigationBarTitle("Comment Analysis").navigationBarTitleDisplayMode(.inline) // MARK: Comment analysis Navigation title
                .font(.custom("Helvetica-Bold", size: 17)).navigationBarItems(trailing:
            NavigationLink(destination: ProfileView(viewModel: authViewModel)) {
                    // MARK: Person view bar button
            Image(systemName: "person.circle").font(.title).foregroundColor(.blue) }
        )
    }
}
}




