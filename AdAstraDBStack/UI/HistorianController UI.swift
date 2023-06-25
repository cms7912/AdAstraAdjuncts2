

import Foundation
import AdAstraBridgingByShim
import AdAstraDBStackCore

extension HistorianController {
    
    
    public func askUserToSendArchiveToDeveloper() {
        try? FileManager.default.removeItem(at: archiveForDevelopmentFile)

        // Present alert to user
        let fullMessage = """
Thanks for help in improving Caleo. An archive of current data will be created and you'll be prompted to send that archive to the developer at clint@caleo.app. Archiving could take a couple minutes, then a prompt to share the archive will appear.
"""

        let alertController = UINSAlertController(title: "Sending archive for development", message: fullMessage, preferredStyle: .alert)
        alertController.addAction( UINSAlertAction(title: "Continue", style: .default, handler: {_ in self.createArchiveForDevelopment() }) )
        alertController.addAction( UINSAlertAction(title: "Cancel", style: .cancel, handler: {_ in }) )

        // let rootViewController = UIApplication.shared.windows.first?.rootViewController
        // rootViewController?.present(alertController, animated: true, completion: { })
        UINSApplication.presentAlert(alertController)

    }

    
}
