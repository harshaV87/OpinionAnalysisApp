//
//  ProfileView.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/27/23.
//

import SwiftUI

struct ProfileView: View {
    // MARK: Properties
    @ObservedObject var viewModel: AuthViewModel
    @State var userInfo : UserInfo?
    @AppStorage("autoLogin") private var autoLoginProperty : Bool?
    @AppStorage("autoLoginCounter") private var autoLoginPropertyCounter : Int?
    var body: some View {
       // MARK: NavigationView
        Spacer()
        NavigationView {
         // MARK: List view
        List {
                Section("Profile") {
                    // MARK: Email UI and Render
                    HStack {
                        Image("MailImage").frame(width: 50, height: 50).clipShape(Rectangle())
                        VStack {
                            Text(viewModel.userInfo?.userEmail ?? "").font(.footnote).accentColor(.gray)
                        }
                    }
                }.modifier(CustomFontModifier())
                // MARK: General Section
                Section("General") {
                    CustomSectionComponent(imageName: "gear", textName: "Version", versionNumber: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "", tintColor: Color(.systemCyan))
                }
                // MARK: Account Section
                Section ("Account"){
                    VStack {
                        // MARK: Action ButtonSigning the user out
                        Button {
                            Task {
                                try? await viewModel.signOut()
                            }
                        } label: {
                            CustomSectionComponent(imageName: "gear", textName: "Sign Out", versionNumber: "", tintColor: Color(.systemCyan))
                        }
                        // MARK: Action Account Deletion - Navigation Link
                        NavigationLink() {
                            AccountDeletion(viewModel: viewModel).navigationBarBackButtonHidden(true)
                        } label: {
                            CustomSectionComponent(imageName: "gear", textName: "Delete Account", versionNumber: "", tintColor: Color(.systemCyan)).modifier(CustomFontModifier())
                        }
                    }.buttonStyle(BorderlessButtonStyle())
                        .onAppear() {
                            // MARK: Signout automatically when User unchecked sign out and terminates the app
                            if autoLoginPropertyCounter == 1 {
                                Task { try? await viewModel.signOut() }
                            }
                            autoLoginPropertyCounter = 0
                        }
                }
        }
        .alert(item: $viewModel.outputError) { error in // MARK: Error show implementation
            Alert(
                title: Text("Error"),
                message: Text(error.error.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    // Handle the error or dismiss it
                    viewModel.outputError = nil
                }
            )
        }
    }
}
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        //ProfileView(viewModel: <#AuthViewModel#>)
//    }
//}


 

