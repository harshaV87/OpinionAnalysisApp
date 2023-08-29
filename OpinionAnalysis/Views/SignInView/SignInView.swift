//
//  ContentView.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/26/23.
//

import SwiftUI

struct ContentView<ViewModel: AuthDelegate>: View {
    // we are initialising this from the protocol
    @EnvironmentObject var viewModel: ViewModel
   
    @State var showErrorAlert: Bool = false
    @State var showAlertForCredentialSave = false
    @State var showWaitAlertForCredentialsSave = false
    @ObservedObject var model = PasswordCheckerModel()
    @State var rememberMeToggle : Bool = true
    @State var showTermsOfUse: Bool = false
    // to check for the preferences
    @AppStorage("autoLogin") private var autoLoginProperty : Bool?
    var body: some View {
        // view components
        // wrapping in Vstack
        // If the useesession is active, we show sentimental view , otherwise just
        if viewModel.userSessionActive == false {
            NavigationView {
                ScrollView {
            VStack {
                // MARK: Image - Logo
                Image("MainLogo").resizable().scaledToFit().frame(width: 150, height: 150, alignment: .center).cornerRadius(70)
                // lets make it a custom one and in vstack
                //MARK: TextFields
                VStack(alignment: .leading, spacing: 10){
                    // label, textfield, placeholder
                    // label, textfield, placeholder
                    CustomTextFieldView(textInput: $model.Email, title: "Username", placeHolderText: "Enter your username")
                    CustomTextFieldView(textInput: $model.singlePassword, title: "Password", placeHolderText: "Enter your password", isSecureTextField: true)
                    // MARK: PASSWORD AND EMAIL VALIDATION
                    if model.Email.count >= 1 {
                        HStack {
                            Image(systemName: model.validEmail ? "checkmark.circle" : "xmark.circle")
                                .resizable().frame(width: 16, height: 16).aspectRatio(contentMode: .fit).overlay(
                                    Circle()
                                .stroke(model.validEmail && model.singlePasswordValid ? Color.green : Color.red, lineWidth: 3)
                                )
                            Text("Email must be valid and Password must have atleast 8 characters, have atleast 1 upper character, 1 lower character and 1 number.")
                        }.padding()
                    }
                  Spacer(minLength: 10)
                }.onAppear() {
                 // MARK: ALERTS FOR CONFIGURING THE FACEID CREDENTIALS SAVING
                    rememberMeToggle = autoLoginProperty ?? true
                    if viewModel.showFaceIdCredntialSave == true {
                        showAlertForCredentialSave = true
                    }
                }
                // MARK: Remember me Button
                VStack(alignment: .leading, spacing: 10){
                    Button {
                        // action
                        rememberMeToggle.toggle()
                        // we also need to have a logic to save the defaults - already an appstore property
                        autoLoginProperty = rememberMeToggle
                    } label: {
                        HStack {
                            Text("Remember me")
                            Image(systemName: rememberMeToggle == true ? "checkmark.circle" : "xmark.circle")
                        }
                    }
                }
                // MARK: Button action and setting up face/touch id and
                Spacer()
                VStack(alignment: .center, spacing: 10) {
                    // faceID UI
                    Button {
                        Task {
                            try? await viewModel.signIn(withEmail: model.Email, withPassword: model.singlePassword, usingBiometrics: true, saveCredentials: false) }
                } label: {
                    // MARK: Configuring the kind of ID
                    switch viewModel.biometryType {
                    case 1 :
                        // touch id
                        Image("touchIDIcon").resizable().frame(width: 60, height: 60, alignment: .center)
                    case 2 :
                        //face id
                        Image("faceIDIcon").resizable().frame(width: 60, height: 60, alignment: .center)
                    default :
                        Image("noTouchIDFaceID").resizable().frame(width: 60, height: 60, alignment: .center)
                    }
                }.frame(width: 60, height: 60)
                    // MARK: SignIn Button
                    CustomButton(textInput: "Sign In", iconName: "", buttonAction: {
                        if showAlertForCredentialSave {
                            // if it is true
                            showWaitAlertForCredentialsSave = showAlertForCredentialSave
                        } else {
                            Task {
                                try? await viewModel.signIn(withEmail: model.Email, withPassword: model.singlePassword, usingBiometrics: false, saveCredentials: false)
                            }
                        }
                    }, backGroundColor: (!model.singlePasswordValid) ? Color.gray : Color.blue).disabled((!model.singlePasswordValid))
                } // MARK: ALERT FOR FACEID/TOUCH ID SAVE
                .alert(isPresented: $showWaitAlertForCredentialsSave) {
                    Alert(title: Text("TouchID/FaceID activation"), message: Text("Would you like to save your credentials for your TouchID/FaceID?"), primaryButton: .destructive(Text("Continue with saving"), action: {
                        // you need to save credentials and then sign in to the account using those credentials
                        // save the credentials and then login
                        Task {
                            try? await viewModel.signIn(withEmail: model.Email, withPassword: model.singlePassword, usingBiometrics: false, saveCredentials: true)
                        }
                    }), secondaryButton: .destructive(Text("Continue without saving "), action: {
                        Task {
                            try? await viewModel.signIn(withEmail: model.Email, withPassword: model.singlePassword, usingBiometrics: false, saveCredentials: false)
                        }
                    })
                    )
                }
                // MARK: button - forgot password
                VStack(alignment: .leading, spacing: 10) {
                    // sending the viewmodel
                    NavigationLink {
                        PasswordReset(viewModel: viewModel as! AuthViewModel)
                    } label : {
                        Text("Forgot Password?")
                    }
                }.frame(alignment: .trailing)
                Spacer(minLength: 40)
                // MARK: button - signup
                    NavigationLink {
                        SignUpView(viewModel: viewModel as! AuthViewModel)
                    } label: {
                        HStack(alignment: .center, spacing: 4.0){
                        Text("Dont have an account?")
                            Text("Sign up")}.foregroundColor(Color.blue)
                    } // MARK: ERROR ALERT
                    .alert(item: $viewModel.outputError) { error in
                                    Alert(
                                        title: Text("Error"),
                                        message: Text(error.error.localizedDescription),
                                        dismissButton: .default(Text("OK")) {
                                            // Handle the error or dismiss it
                                            viewModel.outputError = nil
                                            if viewModel.showFaceIdCredntialSave == true {
                                                showAlertForCredentialSave = true
                                            }
                                        }
                                    )
                                }
                Spacer(minLength: 25)
                // MARK: Clear out the Email and Password
            }.onDisappear() {
                model.Email = ""
                model.singlePassword = ""
            }
            }.safeAreaInset(edge: .bottom, content: {
                // this gets to the aspects to the bottom
                // MARK: Bottom stick to the edge T and c and Privacy Policy
                VStack {
                    HStack(spacing: 1) {
                        Text("By continuing to Sign up, you agree to our").font(.system(size: 10))
                        NavigationLink {
                            TermsAndConditions()
                        } label: {
                            Text("Terms of Use").font(.system(size: 10))
                        }
                    }
                    HStack(spacing: 1) {
                        Text(" and acknowledge that you have read our").font(.system(size: 10))
                        NavigationLink {
                            PrivacyPolicy()
                        } label: {
                            Text("Privacy poilicy").font(.system(size: 10))
                        }
                    }
                    Text("Digmobile Technologies @ 2023").font(.system(size: 10))
                }
            })
            }
            // MARK: Responder chain events - Not implemented
            // Any event that needs to be passed over to the child views
            .eventHandler { event in
            // reponder chain events triggered here
            print("the event here is handled")
            return nil
        }
        } else if viewModel.userSessionActive == true {
            // MARK: Sentiment analysis View after looking at an active user session
            // MARK: Place to replace if it is a different
            SentimentView(authViewModel: viewModel as! AuthViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView<AuthViewModel>().environmentObject(AuthViewModel(biometricManager: BiometricManager()))
    }
}


//

