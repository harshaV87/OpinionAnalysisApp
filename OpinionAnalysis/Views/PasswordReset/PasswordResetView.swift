
//
//  PasswordReset.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 10/24/23.
//

import SwiftUI

struct PasswordReset: View {
    // MARK: Properties
    @ObservedObject var viewModel : AuthViewModel
    @State private var email = ""
    var body: some View {
        // MARK: Requirement for Password Setting
        HStack(spacing: 2) {
            Image("InfoIcon")
            Text("Please set your password with the following requirements for security reasons:\n• At least 8 characters\n• At least 1 uppercase character\n• At least 1 lowercase character\n• At least 1 number. \n If these conditions are not met, you will not be able to log in. ").font(.body).multilineTextAlignment(.leading).padding()
        }
        // MARK: Text Field - Email
        CustomTextFieldView(textInput: $email, title: "Email", placeHolderText: "Enter your Email")
        // MARK: Action - Button to reset password
        Button {
            Task {
                try? await viewModel.userAuthenticator.sendPasswordReset(type: .email(email, nil))
            }
        } label: {
            Text("Reset Password")
        }
        .alert(item: $viewModel.outputError) { error in // MARK: Error alert view
            Alert(
                title: Text("Error"),
                message: Text(error.error.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    // Handle the error or dismiss it
                    viewModel.outputError = nil
                }
            )
        }
        Spacer()
    }
}

//struct PasswordReset_Previews: PreviewProvider {
//    static var previews: some View {
//        PasswordReset()
//    }
//}
