//
//  TagTextfieldView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/27.
//

import SwiftUI

struct TagTestView: View {
    @State private var tags: [Tag] = []

    var body: some View {
        NavigationStack {
            VStack {
                Text("Tags")
                    .font(.caption)
                    .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                    .horizontalSpacing(.leading)
                
                TagField(tags: $tags)
                    .horizontalSpacing(.leading)
            }
            .navigationTitle("Tag Test View")
        }
    }
}

struct TagField: View {
    @Binding var tags: [Tag]
    
    var body: some View {
        HStack {
            TagLayout(alignment: .leading) {
                ForEach($tags) { $tag in
                    TagView(tag: $tag, allTags: $tags)
                        .onChange(of: tag.name) { oldValue, newValue in
                            if newValue.last == "," {
                                /// Removing Comma
                                tag.name.removeLast()
                                /// Inserting New Tag Item
                                if !tag.name.isEmpty {
                                    /// Safe Check
                                    tags.append(createNewTag(value: "", isInitial: false))
                                }
                            }
                        }
                }
            }
            .padding()
        }
        .background(.bar, in: .rect(cornerRadius: 12))
        .onAppear(perform: {
            /// Initialing tag view
            if tags.isEmpty {
                let tag = createNewTag(value: "")
                tags.append(tag)
            }
        })
        .padding(.horizontal, 16)
    }
    
    func createNewTag(value: String, isInitial: Bool = true) -> Tag {
        let colorComponents = Color.themeStyle.theme.accent.components
        let tag = Tag(name: value,
                      colourR: colorComponents.r,
                      colourG: colorComponents.g,
                      colourB: colorComponents.b,
                      colourA: colorComponents.a,
                      isInitial: isInitial)
        return tag
    }
}

struct TagView: View {
    @Binding var tag: Tag
    @Binding var allTags: [Tag]
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        BackSpaceListenerTextField(hint: "Tag", text: $tag.name, onBackPressed: {
            /// Removing tag
            if allTags.count > 1 {
                if tag.name.isEmpty {
                    allTags.removeAll(where: { $0.id == tag.id })
                }
            }
        })
        .focused($isFocused)
        .padding(.horizontal, isFocused || tag.name.isEmpty ? 0 : 10)
        .padding(.vertical, 10)
        .background((colorScheme == .dark ? Color.black : Color.white).opacity(isFocused || tag.name.isEmpty ? 0 : 1), in: .rect(cornerRadius: 5))
        .disabled(tag.isInitial)
        .onChange(of: allTags, initial: true, { oldValue, newValue in
            if newValue.last?.id == tag.id && !(newValue.last?.isInitial ?? false) && !isFocused {
                isFocused = true
            }
        })
        .overlay {
            if tag.isInitial {
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        tag.isInitial = false
                        isFocused = false
                    }
            }
        }
    }
}

fileprivate struct BackSpaceListenerTextField: UIViewRepresentable {
    var hint: String = "Tag"
    @Binding var text: String
    var onBackPressed: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> CustomTextField {
        let textField = CustomTextField()
        textField.delegate = context.coordinator
        textField.onBackPressed = onBackPressed
        /// Optionals
        textField.placeholder = hint
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.backgroundColor = .clear
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChange(textField:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: CustomTextField, context: Context) {
        uiView.text = text
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CustomTextField, context: Context) -> CGSize? {
        return uiView.intrinsicContentSize
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        /// Text Change
        @objc
        func textChange(textField: UITextField) {
            text = textField.text ?? ""
            
            /// Closing on Pressing Return Button
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        }
    }
}

fileprivate class CustomTextField: UITextField {
    open var onBackPressed: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        ///  This will be called when ever keyboard back button is pressed
        onBackPressed?()
        super.deleteBackward()
    }
}


#Preview {
    let previewContainer = PreviewContainer([Tag.self])
    return TagTestView().modelContainer(previewContainer.container)
}
