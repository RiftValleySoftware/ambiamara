/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import UniformTypeIdentifiers
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the "About" screen -
/* ###################################################################################################################################### */
/**
 This is the main view controller for the "About This App" screen (accessed from the global settings popover).
 */
class RiValT_About_ViewController: RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     The app icon is displayed here.
     */
    @IBOutlet weak var appIconImageView: UIImageView?
    
    /* ################################################################## */
    /**
     This is the main about text.
     */
    @IBOutlet weak var aboutText: UITextView?

    /// The stack that holds the divider, backup help text, and actions.
    @IBOutlet private weak var backupActions: UIStackView?

    /// The two backup buttons, arranged to fit their localized titles.
    private weak var backupButtons: UIStackView?

    /// The temporary directory backing the active export picker.
    private var exportDirectory: URL?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_About_ViewController {
    /* ############################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAboutText()
        if let image = Bundle.main.appIcon {
            appIconImageView?.image = image
        } else {
            appIconImageView?.isHidden = true
        }
        navigationItem.title = String(format: "SLUG-NAME-VERSION-FORMAT".localizedVariant, Bundle.main.appDisplayName, Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(openSettings))
        settingsButton.tintColor = .accent
        settingsButton.accessibilityLabel = "SLUG-ACC-ABOUT-SETTINGS-LABEL".localizedVariant
        settingsButton.accessibilityHint = "SLUG-ACC-ABOUT-SETTINGS-HINT".localizedVariant
        navigationItem.rightBarButtonItem = settingsButton
        configureBackupActions()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (controller: RiValT_About_ViewController, _) in
            controller.view.setNeedsLayout()
        }
    }

    /// Reflows the backup buttons when their available width or text size changes.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackupButtonLayout()
    }

    /// Rechecks the row after UIKit finishes applying the initial text size to the buttons.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateBackupButtonLayout()
    }

    /// Formats the About text and appends an accessible link to the RiVal.T website.
    private func configureAboutText() {
        guard let aboutText else { return }
        let font = aboutText.font ?? .preferredFont(forTextStyle: .body)
        let text = NSMutableAttributedString(string: aboutText.text + "\n\n", attributes: [.font: font, .foregroundColor: UIColor.label])
        let website = NSAttributedString(string: "SLUG-ABOUT-WEBSITE-LINK".localizedVariant,
                                         attributes: [.font: font, .link: "https://riftvalleysoftware.com/work/ios-apps/rival-t/"])
        text.append(website)
        aboutText.attributedText = text
        aboutText.accessibilityValue = text.string
    }

    /// Opens the system Settings page for RiVal.T.
    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

extension RiValT_About_ViewController: UIDocumentPickerDelegate {
    /// Lays out the backup help text and actions below a thin divider.
    private func configureBackupActions() {
        guard let backupActions else { return }

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let hint = UILabel()
        hint.text = "SLUG-BACKUP-FILES-HINT".localizedVariant
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.adjustsFontForContentSizeCategory = true
        hint.textColor = .label
        hint.textAlignment = .center
        hint.numberOfLines = 0

        let restore = backupButton("SLUG-BACKUP-RESTORE".localizedVariant,
                                   symbol: "square.and.arrow.down",
                                   accessibilityHint: "SLUG-ACC-BACKUP-RESTORE-HINT".localizedVariant) { [weak self] _ in
            self?.chooseTimerBackup()
        }
        let export = backupButton("SLUG-BACKUP-EXPORT".localizedVariant,
                                  symbol: "square.and.arrow.up",
                                  accessibilityHint: "SLUG-ACC-BACKUP-EXPORT-HINT".localizedVariant) { [weak self] _ in
            self?.exportTimerBackup()
        }
        let buttons = UIStackView(arrangedSubviews: [restore, export])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 8

        backupActions.addArrangedSubview(divider)
        backupActions.addArrangedSubview(hint)
        backupActions.addArrangedSubview(buttons)
        backupButtons = buttons
    }

    /// Gives the actions full width when two columns cannot fit the localized titles.
    private func updateBackupButtonLayout() {
        guard let backupButtons, backupButtons.bounds.width > 0 else { return }

        let columnWidth = (backupButtons.bounds.width - backupButtons.spacing) / 2
        let buttonTraits = backupButtons.traitCollection
        let titleFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: buttonTraits)
        let titleScale: CGFloat = buttonTraits.preferredContentSizeCategory <= .large ? 0.7 : 1
        let fitsInRow = backupButtons.arrangedSubviews.allSatisfy { view in
            guard let button = view as? UIButton, let label = button.titleLabel,
                  let title = button.configuration?.title else { return false }
            // The label can still have its default font during the first layout pass.
            let titleWidth = (title as NSString).size(withAttributes: [.font: titleFont]).width
            let otherWidth = max(0, button.intrinsicContentSize.width - label.intrinsicContentSize.width)
            return ceil(otherWidth + titleWidth * titleScale) <= columnWidth
        }
        let axis: NSLayoutConstraint.Axis = fitsInRow ? .horizontal : .vertical
        if backupButtons.axis != axis {
            backupButtons.axis = axis
        }
    }

    /// Creates a single-line backup button with a matching accessible name and a localized hint.
    private func backupButton(_ title: String,
                              symbol: String,
                              accessibilityHint: String,
                              handler: @escaping UIActionHandler) -> UIButton {
        var configuration = UIButton.Configuration.gray()
        configuration.baseForegroundColor = .accent
        configuration.title = title
        configuration.titleLineBreakMode = .byTruncatingTail
        configuration.titleAlignment = .center
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePadding = 4
        configuration.contentInsets.leading = 4
        configuration.contentInsets.trailing = 4
        let button = UIButton(configuration: configuration, primaryAction: UIAction(handler: handler))
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.35
        button.accessibilityLabel = title
        button.accessibilityHint = accessibilityHint
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }

    /// Writes a dated backup to a temporary folder and offers it to the document picker.
    private func exportTimerBackup() {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        exportDirectory = directory
        do {
            let backup = try RiValT_Settings().timerBackup(for: timerModel)
            let day = backup.exportedAt.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day().dateSeparator(.dash))
            let filename = String(format: "SLUG-BACKUP-FILENAME".localizedVariant, day)
            let file = directory.appendingPathComponent(filename).appendingPathExtension(RiValT_TimerBackup.fileExtension)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
            try backup.encoded().write(to: file, options: .atomic)
            showPicker(UIDocumentPickerViewController(forExporting: [file], asCopy: true))
        } catch {
            removeExportDirectory()
            showBackupMessage("SLUG-BACKUP-EXPORT-FAILED".localizedVariant)
        }
    }

    /// Presents a document picker restricted to timer backup files.
    private func chooseTimerBackup() {
        let type = UTType(exportedAs: RiValT_TimerBackup.typeIdentifier, conformingTo: .json)
        showPicker(UIDocumentPickerViewController(forOpeningContentTypes: [type], asCopy: true))
    }

    /// Configures delegate callbacks before presenting a backup document picker.
    private func showPicker(_ picker: UIDocumentPickerViewController) {
        picker.delegate = self
        picker.presentationController?.delegate = self
        present(picker, animated: true)
    }

    /// Removes the temporary export if the user cancels the picker.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        removeExportDirectory()
    }

    /// Removes the temporary export after an interactive dismissal.
    @objc func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        removeExportDirectory()
    }

    /// Cleans up a completed export or validates the chosen restore file after closing the picker.
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if exportDirectory != nil {
            removeExportDirectory()
            return
        }
        guard let file = urls.first else { return }
        let result = Result { try RiValT_TimerBackup.decode(Data(contentsOf: file)) }
        let showResult: () -> Void = { [weak self] in self?.showRestoreResult(result) }
        if controller.isBeingDismissed, let transition = controller.transitionCoordinator {
            transition.animate(alongsideTransition: nil) { _ in showResult() }
        } else if controller.presentingViewController != nil {
            controller.dismiss(animated: true, completion: showResult)
        } else {
            showResult()
        }
    }

    /// Removes the temporary export directory and clears the reference to it.
    private func removeExportDirectory() {
        guard let exportDirectory else { return }
        try? FileManager.default.removeItem(at: exportDirectory)
        self.exportDirectory = nil
    }

    /// Requests confirmation for a valid restore or shows the appropriate validation error.
    private func showRestoreResult(_ result: Result<RiValT_TimerBackup, Error>) {
        switch result {
        case .success(let backup):
            confirmRestore(backup)
        case .failure(RiValT_TimerBackup.BackupError.unsupportedVersion):
            showBackupMessage("SLUG-BACKUP-UNSUPPORTED".localizedVariant)
        case .failure:
            showBackupMessage("SLUG-BACKUP-INVALID".localizedVariant)
        }
    }

    /// Shows how many presets and groups will replace the current setup and asks for confirmation.
    private func confirmRestore(_ backup: RiValT_TimerBackup) {
        let message = String(format: "SLUG-BACKUP-RESTORE-CONFIRMATION".localizedVariant, locale: .current,
                             backup.timerCount, backup.groupCount)
        let alert = UIAlertController(title: "SLUG-BACKUP-RESTORE-TITLE".localizedVariant, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel))
        alert.addAction(UIAlertAction(title: "SLUG-BACKUP-RESTORE-ACTION".localizedVariant, style: .destructive) { [weak self] _ in
            self?.restoreTimerBackup(backup)
        })
        present(alert, animated: true)
    }

    /// Applies the confirmed backup, refreshes Watch state, and reports the result.
    private func restoreTimerBackup(_ backup: RiValT_TimerBackup) {
        do {
            try RiValT_Settings().restoreTimerBackup(backup, into: timerModel)
            // The group editor reloads its snapshot when About is closed.
            watchDelegate?.publishSnapshot()
            showBackupMessage("SLUG-BACKUP-RESTORED".localizedVariant)
        } catch {
            showBackupMessage("SLUG-BACKUP-RESTORE-FAILED".localizedVariant)
        }
    }

    /// Presents a localized backup status or error with a single dismissal action.
    private func showBackupMessage(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: .default))
        present(alert, animated: true)
    }
}
