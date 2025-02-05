//
//  RegistrationSelectOptionView.swift
//  edX
//
//  Created by Akiva Leffert on 6/9/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

class RegistrationSelectOptionView: RegistrationFormFieldView {
    @objc var options: [OEXRegistrationOption] = []
    @objc private(set) var selected : RegistrationSelectOptionViewModel?

    @objc var alertController = UIAlertController()
    private let dropdownView = UIView(frame: CGRect(x: 0, y: 0, width: 27, height: 40))
    private let dropdownTab = UIImageView()
    private let tapButton = UIButton()
    
    private var titleStyle : OEXTextStyle {
        return OEXTextStyle(weight: .normal, size: .base, color: OEXStyles.shared().neutralDark())
    }
    
    override var currentValue: String {
        return tapButton.attributedTitle(for: .normal)?.string ?? ""
    }
    
    override init(with formField: OEXRegistrationFormField) {
        super.init(with: formField)
    }
    
    override func loadView() {
        super.loadView()
        textInputField.isEnabled = false
        dropdownView.addSubview(dropdownTab)
        dropdownView.layoutIfNeeded()
        dropdownTab.image = Icon.Dropdown.imageWithFontSize(size: 12)
        dropdownTab.tintColor = OEXStyles.shared().neutralDark()
        dropdownTab.contentMode = .scaleAspectFit
        dropdownTab.sizeToFit()
        dropdownTab.center = dropdownView.center
        tapButton.localizedHorizontalContentAlignment = .Leading
        textInputField.rightViewMode = .always
        textInputField.rightView = dropdownView
        tapButton.oex_addAction( {[weak self] _ in
            self?.showRegistrationSelectOptionView()
            }, for: UIControl.Event.touchUpInside)
        self.addSubview(tapButton)
        
        tapButton.snp.makeConstraints { make in
            make.top.equalTo(textInputField)
            make.leading.equalTo(textInputField)
            make.trailing.equalTo(textInputField)
            make.bottom.equalTo(textInputField)
        }
        let insets = OEXStyles.shared().standardTextViewInsets
        tapButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: insets.left, bottom: 0, right: insets.right)
        refreshAccessibilty()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func refreshAccessibilty() {
        guard let formField = formField else { return }
        
        let errorAccessibility = errorMessage ?? "" != "" ? ",\(Strings.Accessibility.errorText), \(errorMessage ?? "")" : ""
        tapButton.accessibilityLabel = String(format: "%@, %@", formField.label, Strings.accessibilityDropdownTrait)
        tapButton.accessibilityTraits = UIAccessibilityTraits.none
        let accessibilitHintText = isRequired ? String(format: "%@, %@, %@, %@", Strings.accessibilityRequiredInput,formField.instructions, errorAccessibility , Strings.accessibilityShowsDropdownHint) : String(format: "%@, %@, %@, %@", Strings.Accessibility.optionalInput,formField.instructions,errorAccessibility , Strings.accessibilityShowsDropdownHint)
        tapButton.accessibilityHint = accessibilitHintText
        textInputField.isAccessibilityElement = false
        textInputField.accessibilityIdentifier = "RegistrationFieldSelectView:text-input-field"
    }
    
    private func setButtonTitle(title: String) {
        tapButton.setAttributedTitle(titleStyle.attributedString(withText: title), for: .normal)
        tapButton.accessibilityLabel = String(format: "%@, %@, %@", formField?.label ?? "", title, Strings.accessibilityDropdownTrait)
        tapButton.accessibilityIdentifier = "RegistrationFieldSelectView:\(String(describing: formField?.name))-\(title)-dropdown"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showRegistrationSelectOptionView() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NOTIFICATION_REGISTRATION_FORM_SELECT_FIELD_DID_OPEN)))
        
        guard let field = formField, let parent = firstAvailableUIViewController() else { return }
        let items = options.compactMap { RegistrationSelectOptionViewModel(name: $0.name, value: $0.value) }
                
        let controller = RegistrationSelectOptionViewController(options: items, selectedItem: selected) { [weak self] item in
            if let item = item {
                if item.value.isEmpty {
                    self?.setButtonTitle(title: "")
                } else {
                    self?.selected = item
                    self?.setButtonTitle(title: item.name)
                    self?.valueDidChange()
                }
                self?.alertController.dismiss(animated: true, completion: nil)
            }
        }
        
        alertController = UIAlertController(style: .actionSheet, childController: controller, title: field.label)
        alertController.addCancelAction()
        alertController.configurePresentationController(withSourceView: self)
        
        parent.present(alertController, animated: true, completion: nil)
        
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: alertController)
    }
    
    override func validate() -> String? {
        guard let field = formField else {
            return nil
        }
        if isRequired && currentValue == "" {
            return field.errorMessage.required == "" ? Strings.registrationFieldEmptySelectError(fieldName: field.label) : field.errorMessage.required
        }
        return nil
    }

}
