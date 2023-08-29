//
//  AccountDeletion.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 10/21/23.
//

import SwiftUI

struct AccountDeletion: View {
    // MARK: Properties
    @ObservedObject var viewModel: AuthViewModel
    @State private var showAlert = false
    @ObservedObject var model = PasswordCheckerModel()
    var body: some View {
        VStack {
            // MARK: Info button that gives some info on the action
            HStack(spacing: 2) {
                Image("InfoIcon")
                Text("Please note that you cannot undo this action").font(.body).multilineTextAlignment(.leading).padding()
            }
            // MARK: Email and password - Text Fields
            CustomTextFieldView(textInput: $model.Email, title: "Email", placeHolderText: "Enter your Email")
            CustomTextFieldView(textInput: $model.singlePassword, title: "Password", placeHolderText: "Enter your Password", isSecureTextField: true)
            // MARK: Action - Deleting the account
            CustomButton(textInput: "Delete Account", iconName: "", buttonAction: {
              // MARK: Alert to ask if the user is sure to delete
                showAlert = true
            }, backGroundColor: (!model.singlePasswordValid) ? Color.gray : Color.blue).disabled((!model.singlePasswordValid))
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Confirm Deletion"), message: Text("Are you sure you want to delete your account?"), primaryButton: .destructive(Text("Delete"), action: {
              // MARK: Action to delete the account
                Task {
                    try? await viewModel.deleteAccount(withEmail: model.Email, withPassword: model.singlePassword)
                }
            }), secondaryButton: .destructive(Text("Cancel")))
        }
    }
}

//struct AccountDeletion_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountDeletion()
//    }
//}


