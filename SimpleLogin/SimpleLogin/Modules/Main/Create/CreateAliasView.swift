//
//  CreateAliasView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CreateAliasViewModel
    @State private var showingLoadingAlert = false

    private let onCreateAlias: (Alias) -> Void
    private let onCancel: (() -> Void)?
    private let onOpenMyAccount: (() -> Void)?
    private let url: URL?

    init(session: Session,
         url: URL?,
         onCreateAlias: @escaping (Alias) -> Void,
         onCancel: (() -> Void)?,
         onOpenMyAccount: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.url = url
        self.onCreateAlias = onCreateAlias
        self.onCancel = onCancel
        self.onOpenMyAccount = onOpenMyAccount
    }

    var body: some View {
        NavigationView {
            Group {
                if let options = viewModel.options,
                   let mailboxes = viewModel.mailboxes {
                    ContentView(viewModel: viewModel,
                                options: options,
                                mailboxes: mailboxes,
                                url: url)
                } else if !viewModel.isLoading {
                    Button(action: {
                        viewModel.fetchOptionsAndMailboxes()
                    }, label: {
                        Label("Retry", systemImage: "gobackward")
                    })
                }
            }
            .navigationBarTitle("Create an alias", displayMode: .inline)
            .navigationBarItems(leading: cancelButton)
        }
        .accentColor(.slPurple)
        .emptyPlaceholder(isEmpty: viewModel.options?.canCreate == false) {
            UpgradeNeededView(onOk: onCancel) {
                onOpenMyAccount?()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            viewModel.fetchOptionsAndMailboxes()
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.createdAlias)) { createdAlias in
            if let createdAlias = createdAlias {
                // Workaround of a strange bug: https://developer.apple.com/forums/thread/675216
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onCreateAlias(createdAlias)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            onCancel?()
        }, label: {
            Text("Cancel")
        })
    }
}

private struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var viewModel: CreateAliasViewModel
    @State private var isInitialized = false
    @State private var prefix = ""
    @State private var suffixValue = ""
    @State private var mailboxIds = [Int]()
    @State private var notes = ""
    let options: AliasOptions
    let mailboxes: [Mailbox]
    let url: URL?

    var body: some View {
        Form {
            Section(footer: Text("Only lowercase letters, numbers, dot (.), dashes (-) & underscore are supported.")) {
                prefixAndSuffixView
            }

            Section(header: Text("Mailboxes"),
                    footer: mailboxFooter) {
                mailboxesView
            }

            Section(header: Text("Notes"), footer: noteFooter) {
                TextEditor(text: $notes)
                    .frame(height: 80)
            }
        }
        .onAppear {
            guard !isInitialized else { return }
            isInitialized = true
            suffixValue = options.suffixes.map { $0.value }.first ?? ""
            if let defaultMailbox = mailboxes.first(where: { $0.default }) ?? mailboxes.first {
                mailboxIds.append(defaultMailbox.id)
            }
            prefix = url?.notWwwHostname() ?? ""
            notes = url?.host ?? ""
        }
    }

    private var prefixAndSuffixView: some View {
        NavigationLink(destination: {
            EditSuffixView(suffixValue: $suffixValue, suffixes: options.suffixes)
        }, label: {
            HStack(spacing: 2) {
                TextField("custom_prefix", text: $prefix)
                    .labelsHidden()
                    .multilineTextAlignment(.trailing)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(prefix.isValidPrefix ? .primary : .red)
                    .frame(minWidth: 50)

                Text(suffixValue)
                    .foregroundColor(.slPurple)
            }
        })
    }

    private var mailboxesView: some View {
        NavigationLink(destination: {
            EditMailboxesView(mailboxIds: $mailboxIds, mailboxes: mailboxes)
        }, label: {
            VStack {
                ForEach(mailboxIds, id: \.self) { id in
                    if let mailbox = mailboxes.first { $0.id == id } {
                        HStack {
                            Text(mailbox.email)
                            Spacer()
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
        })
    }

    private var mailboxFooter: some View {
        Button("What are mailboxes?") {
            // swiftlint:disable:next force_unwrapping
            openURL(URL(string: "https://simplelogin.io/docs/mailbox/add-mailbox/")!)
        }
        .foregroundColor(.slPurple)
    }

    private var noteFooter: some View {
        VStack {
            let createButtonDisabled = !prefix.isValidPrefix || mailboxIds.isEmpty
            PrimaryButton(title: "Create") {
                guard let suffixObject = options.suffixes.first(where: { $0.value == suffixValue }) else { return }
                let creationOptions = AliasCreationOptions(hostname: nil,
                                                           prefix: prefix,
                                                           suffix: suffixObject,
                                                           mailboxIds: mailboxIds,
                                                           note: notes.isEmpty ? nil : notes,
                                                           name: nil)
                viewModel.createAlias(options: creationOptions)
            }
            .padding(.vertical)
            .opacity(createButtonDisabled ? 0.5 : 1)
            .disabled(createButtonDisabled)

            if prefix.isEmpty && notes.isEmpty {
                GeometryReader { geometry in
                    HStack {
                        Spacer()

                        let lineWidth = geometry.size.width / 5
                        horizontalLine
                            .frame(width: lineWidth)

                        Text("OR")
                            .font(.caption2)
                            .fontWeight(.medium)

                        horizontalLine
                            .frame(width: lineWidth)

                        Spacer()
                    }
                }

                Group {
                    Button("Random by word") {
                        viewModel.random(mode: .word)
                    }
                    .padding(.vertical, 10)

                    Button("Random by UUID") {
                        viewModel.random(mode: .uuid)
                    }
                }
                .foregroundColor(.slPurple)
                .font(.body)
            }
        }
    }

    private var horizontalLine: some View {
        Color.secondary
            .opacity(0.5)
            .frame(height: 1)
    }
}

private struct EditMailboxesView: View {
    @Binding var mailboxIds: [Int]
    let mailboxes: [Mailbox]

    var body: some View {
        Form {
            Section {
                ForEach(mailboxes, id: \.id) { mailbox in
                    HStack {
                        Text(mailbox.email)
                        Spacer()
                        if mailboxIds.contains(mailbox.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if mailboxIds.contains(mailbox.id) && mailboxIds.count > 1 {
                            mailboxIds.removeAll { $0 == mailbox.id }
                        } else if !mailboxIds.contains(mailbox.id) {
                            mailboxIds.append(mailbox.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Mailboxes")
        .navigationBarItems(trailing: reloadButton)
    }

    private var reloadButton: some View {
        Button(action: {
            if let defaultMailbox = mailboxes.first(where: { $0.default }) {
                mailboxIds = [defaultMailbox.id]
            }
        }, label: {
            Image(systemName: "gobackward")
        })
            .padding()
    }
}

struct EditSuffixView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var suffixValue: String
    let suffixes: [Suffix]

    var body: some View {
        Form {
            ForEach(suffixes, id: \.value) { suffix in
                HStack {
                    VStack {
                        Text(suffix.value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(suffix.domainType.localizedDescription)
                            .font(.caption)
                            .foregroundColor(suffix.domainType.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    if suffix.value == suffixValue {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    suffixValue = suffix.value
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}