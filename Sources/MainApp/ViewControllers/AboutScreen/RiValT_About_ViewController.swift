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

    @IBOutlet private weak var backupActions: UIStackView?

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
    }

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

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

extension RiValT_About_ViewController: UIDocumentPickerDelegate {
    private func configureBackupActions() {
        let export = backupButton("SLUG-BACKUP-EXPORT".localizedVariant,
                                  symbol: "square.and.arrow.up",
                                  accessibilityLabel: "SLUG-ACC-BACKUP-EXPORT-LABEL".localizedVariant,
                                  accessibilityHint: "SLUG-ACC-BACKUP-EXPORT-HINT".localizedVariant) { [weak self] _ in
            self?.exportTimerBackup()
        }
        let restore = backupButton("SLUG-BACKUP-RESTORE".localizedVariant,
                                   symbol: "square.and.arrow.down",
                                   accessibilityLabel: "SLUG-ACC-BACKUP-RESTORE-LABEL".localizedVariant,
                                   accessibilityHint: "SLUG-ACC-BACKUP-RESTORE-HINT".localizedVariant) { [weak self] _ in
            self?.chooseTimerBackup()
        }
        let hint = UILabel()
        hint.text = "SLUG-BACKUP-FILES-HINT".localizedVariant
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.adjustsFontForContentSizeCategory = true
        hint.textColor = .label
        hint.textAlignment = .center
        hint.numberOfLines = 0
        backupActions?.addArrangedSubview(export)
        backupActions?.addArrangedSubview(restore)
        backupActions?.addArrangedSubview(hint)
    }

    private func backupButton(_ title: String,
                              symbol: String,
                              accessibilityLabel: String,
                              accessibilityHint: String,
                              handler: @escaping UIActionHandler) -> UIButton {
        var configuration = UIButton.Configuration.gray()
        configuration.baseForegroundColor = .accent
        configuration.title = title
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePadding = 8
        let button = UIButton(configuration: configuration, primaryAction: UIAction(handler: handler))
        button.accessibilityLabel = accessibilityLabel
        button.accessibilityHint = accessibilityHint
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }

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

    private func chooseTimerBackup() {
        let type = UTType(exportedAs: RiValT_TimerBackup.typeIdentifier, conformingTo: .json)
        showPicker(UIDocumentPickerViewController(forOpeningContentTypes: [type], asCopy: true))
    }

    private func showPicker(_ picker: UIDocumentPickerViewController) {
        picker.delegate = self
        picker.presentationController?.delegate = self
        present(picker, animated: true)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        removeExportDirectory()
    }

    @objc func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        removeExportDirectory()
    }

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

    private func removeExportDirectory() {
        guard let exportDirectory else { return }
        try? FileManager.default.removeItem(at: exportDirectory)
        self.exportDirectory = nil
    }

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

    private func showBackupMessage(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: .default))
        present(alert, animated: true)
    }
}
