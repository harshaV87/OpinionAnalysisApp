//
//  SignUpView.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/26/23.
//

import SwiftUI

struct SignUpView: View {
    // ViewModel
    @ObservedObject var viewModel: AuthViewModel
    // navigationDismiss
    @Environment(\.dismiss) var dismiss
    // responder chain - not using now
    @Environment(\.eventClosure) var eventClosure
    // MARK: Passwordchecker init
    @ObservedObject var model = PasswordCheckerModel()
    
    var body: some View {
        ScrollView {
        VStack {
        VStack {
       // MARK: Dynamic email and password criteria checker
            VStack(alignment: .leading , spacing: 10) {
                Text("Email Criteria :").font(.custom(
                    "AmericanTypewriter",
                    fixedSize: 26))
                HStack {
                    Image(systemName: model.validEmail ? "checkmark.circle" : "xmark.circle").clipped() .frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay(
                        Circle()
                    .stroke(model.validEmail ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("Email must be valid")
                }
                Text("Password Criteria :").font(.custom(
                    "AmericanTypewriter",
                    fixedSize: 26))
                HStack {
                    Image(systemName: model.isLengthValid ? "checkmark.circle" : "xmark.circle").clipped().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay (
                        Circle().stroke(model.isLengthValid ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("At least 8 characters")
                }
                HStack  {
                    Image(systemName: model.hasUppercase ? "checkmark.circle" : "xmark.circle").clipped().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay (
                        Circle().stroke(model.hasUppercase ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("At least one uppercase character")
                }
                HStack {
                    Image(systemName: model.hasLowercase ? "checkmark.circle" : "xmark.circle").clipped().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay (
                        Circle().stroke(model.hasLowercase ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("At least one lowercase character")
                }
                HStack {
                    Image(systemName: model.hasNumber ? "checkmark.circle" : "xmark.circle").clipped().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay (
                        Circle().stroke(model.hasNumber ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("At least one number")
                }
                HStack {
                    Image(systemName: model.passwordsMatch ? "checkmark.circle" : "xmark.circle").clipped().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay (
                        Circle().stroke(model.passwordsMatch ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("Passwords match")
                }
                HStack {
                    Image(systemName: model.validPassword ? "checkmark.circle" : "xmark.circle").clipped().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay (
                        Circle().stroke(model.validPassword ? Color.green : Color.red, lineWidth: 3)
                    )
                    Text("Passwords are valid and fits the criteria")
                }
            }
            // MARK: Email, Password and Forgot Password text fields
        CustomTextFieldView(textInput: $model.Email, title: "Email", placeHolderText: "Enter your Email")
        CustomTextFieldView(textInput: $model.password, title: "Password", placeHolderText: "Enter a Password", isSecureTextField: true)
        CustomTextFieldView(textInput: $model.confirmPassword, title: "Confirm Password", placeHolderText: "Confirm your password", isSecureTextField: true) }
            // MARK: SIGNUP button
            CustomButton(textInput: "Sign Up", iconName: "", buttonAction:  {
                Task {
                    try? await viewModel.createUser(withEmail: model.Email, withPassword: model.password)
                }
            }, backGroundColor: (!model.validPassword) ? Color.gray : Color.blue).disabled((!model.validPassword))
        // MARK: Button dismiss navigation
            CustomButton(textInput: "Already have an account?", iconName: "", buttonAction: {
                eventClosure(MyEvent())
                dismiss()
            }, backGroundColor: Color.blue)
        }
        .alert(item: $viewModel.outputError) { error in // MARK: Error alert
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
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}

// responder chain struct
struct MyEvent {
    
}


class PasswordCheckerModel: ObservableObject {
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var singlePassword: String = ""
    @Published var Email: String = ""
    
    
    var isLengthValid: Bool {
        return password.count >= 8 && confirmPassword.count >= 8
    }
    
    var hasUppercase: Bool {
        return password.rangeOfCharacter(from: .uppercaseLetters) != nil && confirmPassword.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    var hasLowercase: Bool {
        return password.rangeOfCharacter(from: .lowercaseLetters) != nil && confirmPassword.rangeOfCharacter(from: .lowercaseLetters) != nil
    }
    
    var hasNumber: Bool {
        return password.rangeOfCharacter(from: .decimalDigits) != nil && confirmPassword.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var passwordsMatch: Bool {
        return password == confirmPassword && password != "" && confirmPassword != ""
    }
    
    var validPassword: Bool {
        return isLengthValid && hasUppercase && hasLowercase && hasNumber && passwordsMatch && validEmail
    }
    
    var validEmail: Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: Email)
    }
    
    var singlePasswordValid: Bool {
        return singlePassword.count >= 8 && singlePassword.rangeOfCharacter(from: .uppercaseLetters) != nil && singlePassword.rangeOfCharacter(from: .lowercaseLetters) != nil && singlePassword.rangeOfCharacter(from: .decimalDigits) != nil && validEmail
    }
}

