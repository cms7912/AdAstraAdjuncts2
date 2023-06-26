//
//  File.swift
//  
//
//  Created by cms on 1/20/22.
//

import Foundation
import os.log
import AdAstraExtensions
import AALogger
import AAFileManager
//import AdAstraBridgingByShim  
import System
import AppleArchive

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


// Backup & Archiving process
//   quick backup, then in background queue move that into a compressed archive
//
//   #1 - createQuickBackup(named backupFolderName: String) will quickly create a copy of root "/CurrentData/" folder to new subfolder in "/Backups/" -- this is a fast process
//         -- backup folders are named in order of CaleoMigration enums. (e.g. "MigrationFrom20200818")
//  #2 - archiveAnyBackupFolders() is called every app launch and will check "/Backups/" folder for any subfolders needing archived
//         -- archive files are named after backup folder (e.g. "MigrationFrom20200818.aar")
//
// caleoNewVersionMigrations() will call for a backup whenever new version detected
//

/*


 Version backups -- records latest app version. If appVersion parameter is different, then create backup
 Periodic backups -- backup if time since last backup is greater than periodic interval
These only will run backup when HistorianController is initialized--assumes that data on disk is not being written to and can cleanly backup. The archiving is done later

 Version backups and Periodic backups are intermingled, no need to separate.


 folders and archive files are simply named the timestamp of when taken.
Structure:
 - BackupFolder
      - [Quick backup folders]
      - [Archive files].aar

 */

public extension Calendar.Component {
	var asTimeInterval: TimeInterval {
		Calendar.current.dateInterval(of: self, for: .distantFuture)!.duration
	}
	typealias DurationTuple = (TimeInterval, Calendar.Component)

}

open class HistorianController: NSObject, ObservableObjectWithLLogging {

	public var llogPrefix: String = { "🦣" }()
	public var llogIsEnabled: Bool = true

	static var appLevelShare: HistorianController?

	let PeriodBetweenArchiveCompressions = 30 // seconds

	public init(
		CurrentDataFolder: URL,
		BackupsFolder: URL,
		version: String?,
		autoBackupOnVersionChange: Bool,
		pruneVersionBackupsToKeep versionBackupsCount: Int,
		autoBackupPeriodicallyOf periodicBackupInterval: Calendar.Component.DurationTuple?,
		prunePeriodicBackupsToKeep periodicBackupsCount: Int
	) {
		self.version = version
		self.CurrentDataFolder = CurrentDataFolder
		self.BackupsFolder = BackupsFolder
		self.versionBackupsCount = versionBackupsCount
		self.periodicBackupInterval = periodicBackupInterval?.0 * periodicBackupInterval?.1.asTimeInterval
		self.periodicBackupsCount = periodicBackupsCount
		super.init()
		Self.appLevelShare = self

		if autoBackupOnVersionChange{
			createBackupOnVersionChange()
		} else if periodicBackupInterval.isNotNil {
			createBackupOnPeriodicInterval()
		}

		archiveAnyBackupFolders()
	}


	let version: String?
	let CurrentDataFolder: URL
	let BackupsFolder: URL
	lazy var destinationsChecksum: String = {
		if let checksum =
            Data.init(base64Encoded:
            (CurrentDataFolder.absoluteString + BackupsFolder.absoluteString)
            )?.checksum{
			return checksum.description
		}
//		CrashDuringDebug🛑()
        assertionFailure()
		return ""
	}()

	let versionBackupsCount: Int
	let periodicBackupInterval: TimeInterval?
	let periodicBackupsCount: Int

	var timestampFormatter: DateFormatter = TimestampFormatter
public static var TimestampFormatter: DateFormatter =
	{
		let format = DateFormatter()
		format.locale = Locale(identifier: "en_US_POSIX") // set locale to avoid device changing its locale and then backup names being in different formats
		format.dateFormat = "yyyyMMdd HHmmss"
return format
	}()

	lazy var LatestVersionBackupPreferenceKey: String = "HistorianControllerLatestVersionBackup_\(destinationsChecksum)"
	lazy var LatestPeriodicBackupPreferenceKey: String = "HistorianControllerLatestPeriodicBackup_\(destinationsChecksum)"

	lazy var VersionBackupsListPreferenceKey: String = "HistorianControllerVersionBackupsPreferenceKey_\(destinationsChecksum)"
	lazy var PeriodicBackupsListPreferenceKey: String = "HistorianControllerPeriodicBackupsPreferenceKey_\(destinationsChecksum)"


	public var versionBackupsList: [String] {
		get { (UserDefaults.standard.object(forKey: VersionBackupsListPreferenceKey) as? [String]) ?? [String]() }
		set { UserDefaults.standard.set(newValue, forKey: VersionBackupsListPreferenceKey)
		}
	}
	public var periodicBackupsList: [String] {
		get { (UserDefaults.standard.object(forKey: PeriodicBackupsListPreferenceKey) as? [String]) ?? [String]() }
		set { UserDefaults.standard.set(newValue, forKey: PeriodicBackupsListPreferenceKey)
		}
	}

	public func createBackupOnVersionChange(){
		// Only backup when version changes. If no version in UserDefaults then don't backup

		let latestVersionCheck = (UserDefaults.standard.object(forKey: LatestVersionBackupPreferenceKey) as? String)


		if latestVersionCheck.isNil {
			UserDefaults.standard.set(version, forKey: LatestVersionBackupPreferenceKey)
			return
		}

		if latestVersionCheck != version {
			let newestName = createBackupNow()
			UserDefaults.standard.set(version, forKey: LatestVersionBackupPreferenceKey)
			versionBackupsList.append(newestName)
		}
	}


	func createBackupOnPeriodicInterval() {
		// Only backup when period interval has passed. If no latest period backup in UserDefaults then assume first run and don't backup, simply set the current date
		guard let periodicBackupInterval = periodicBackupInterval else { return }
		var latestDateOfBackup: Date?

		if let latestPeriodCheck = (UserDefaults.standard.object(forKey: LatestPeriodicBackupPreferenceKey) as? String){

			latestDateOfBackup = timestampFormatter.date(from: latestPeriodCheck)
		}
		if let latestDate = latestDateOfBackup {
			if latestDate + periodicBackupInterval < Date() {
				// more than periodicBackupInterval time has passed, will do a backup
				let newestName = createBackupNow()
				UserDefaults.standard.set(version, forKey: LatestPeriodicBackupPreferenceKey)
				periodicBackupsList.append(newestName)
			}

		} else {
			// no latest date, so skip backup and set one
			UserDefaults.standard.set( timestampFormatter.string(from: Date() )
																 , forKey: LatestPeriodicBackupPreferenceKey)
		}

	}


	@Published public var backupInProgress: Bool = false
	@Published public var archiveInProgress: Bool = false

	@discardableResult
	public func createBackupNow() -> String {
		let timestamp = timestampFormatter.string(from: Date() )
		createQuickBackup(named: "\(timestamp)")
		return timestamp
	}


	func createQuickBackup(named backupFolderName: String) {
		llog()
		let backupFolder = BackupsFolder.appendingPathComponent(backupFolderName)
		// this folder is temporary while archiving happens
		// archiving can be interrupted and this folder will remain

		do {
			guard !itemExists(atPath: backupFolder) else { return }
			llog("Folder does not exist, will start backup")
			backupInProgress = true

			// Disconnect persistent stores
			ProjectsDBStack.shared?.disconnectPersistentStores()

			// first, copy to temporary folder
			// (could take a while?)
			llog("will copy to temporary folder")
			let tempFolder = AdAstraFM_NEW.createTempFolder()
			try AdAstraFM_NEW.copy(formerItem: CurrentDataFolder, newItem: tempFolder)

			// Reconnect persistent stores
			 try ProjectsDBStack.shared?.reconnectPersistentStores()

			// second, move to backup temp folder
			// (fast, simple rename)
			llog("will move to backup folder")
			try AdAstraFM_NEW.move(formerItem: tempFolder, newItem: backupFolder)

		} catch {
			llog("🛑 failed during backup attempt")
		}
		llog("successfully created backup")
		backupInProgress = false
		// successfully created copy for backup purposes, allow main thread to continue and move archiving work to background thread

		archiveAnyBackupFolders()
	}
	public func listBackupsAndArchives() -> [URL] {
		// Get folder contents
		var contents: [URL] = [URL]()
		do {
			contents = try FileManager.default.contentsOfDirectory(at: BackupsFolder, includingPropertiesForKeys: nil, options: [])
		} catch {
			print(error.localizedDescription)
		}
		return contents
	}


	public func archiveAnyBackupFolders(skipDelay: Bool = false ) {
		// called on every app launch
		// recursively called until not folderToArchive found
		self.llog()
		DispatchQueue.global(qos: .background).asyncAfter(
			deadline: .now() +
			DispatchTimeInterval.seconds(PeriodBetweenArchiveCompressions * ( skipDelay ? 0 : 1) )
		) {[ weak self ] in

			guard let self = self else { return }
			self.cleanup() // also use this delay and archiving loop to do clean up

			var folderToArchive: URL?

			// Get folder contents
			let folders = self.listBackupsAndArchives()
			for eachFolder in folders {
				var isDirResult: ObjCBool = false
				if self.itemExists(atPath: eachFolder, isDirectory: &isDirResult),
					 isDirResult.boolValue {

					folderToArchive = eachFolder
					break // exit loop
				}
			}
			if let folderToArchive = folderToArchive {
				self.llog("will start archive for: \(folderToArchive.lastPathComponent)")

				DispatchQueue.main.async { self.archiveInProgress = true }

				self.archiveBackupFolder(named: folderToArchive)

				DispatchQueue.main.async { self.archiveInProgress = false }

				self.archiveAnyBackupFolders() // recursively call to trigger next .async
			} else {
				// no more folders to archive, allow to exit
			}

		}
	}


	func archiveBackupFolder(named backupFolder: URL) {
		llog()

		var isDirResult: ObjCBool = false
		guard itemExists(atPath: backupFolder, isDirectory: &isDirResult),
					isDirResult.boolValue else {
						llog("did not find backupFolder exists")
						return }

		let backupArchiveFile = BackupsFolder.appendingPathComponent(backupFolder.lastPathComponent + ".aar")

		func removeBackupFolder() throws {
			// if backup folder still exists, delete it
			if itemExists(atPath: backupFolder) {
				llog("found redundant backup folder")
				do {
					llog("will try to delete redundant backup folder")
					try FileManager.default.removeItem(at: backupFolder)
				} catch {
					llog("error while deleting redundant backup folder")
					llog("error in removing \(backupFolder): \(error.localizedDescription) ")
					throw error
				}
			}
		}
		func cleanupBackups() {
			// TODO:
			// loop through contents of backup folders & backup archives, removing any that are outdated
		}

#if !targetEnvironment(simulator)

		do {

			// first check whether archive file already exists
			// (could happen if archive completed, then app crash before removing backupFolder)
			// this check prevents re-creating existing archive
			if !itemExists(atPath: backupArchiveFile) {
				// First create the archive to temporary folder
				// (slow compression)
				let tempFile = AdAstraFM_NEW.createTempFolder().appendingPathComponent(backupArchiveFile.lastPathComponent)
				try saveCompressedArchive(fromDirectory: backupFolder, toFile: tempFile)

				// After archive created, then move it to final location
				// (fast renaming)
				try AdAstraFM_NEW.move(formerItem: tempFile, newItem: backupArchiveFile)

				try? removeBackupFolder()
			} else {
				// odd state -- backup folder exists, but so does the archive file. Will delete archive file. Then on next call the archive file can be recreated.
				// (avoid calling for archive immediately so as to avoid a possible recursion loop)
				try FileManager.default.removeItem(at: backupArchiveFile)

			}
		} catch {
			llog("🛑 failed during backup attempt")
		}

#endif

	}

#if !targetEnvironment(simulator)

	func saveCompressedArchive(fromDirectory sourceDir: URL, toFile archiveFile: URL) throws {
		llog()
		// Create the File Stream to Write the Compressed File

		guard let archiveFilePath: FilePath = FilePath(archiveFile),
					let writeFileStream = ArchiveByteStream.fileStream(
						path: archiveFilePath,
						mode: .writeOnly,
						options: [ .create ],
						permissions: FilePermissions(rawValue: 0o644)) else {
							throw ArchiveError.ioError
						}
		defer {
			try? writeFileStream.close()
		}

		// Create the Compression Stream
		guard let compressStream = ArchiveByteStream.compressionStream(
			using: .lzfse,
			writingTo: writeFileStream) else {
				throw ArchiveError.ioError
			}
		defer {
			try? compressStream.close()
		}

		// Create the Encoding Stream
		guard let encodeStream = ArchiveStream.encodeStream(writingTo: compressStream) else {
			throw ArchiveError.ioError
		}
		defer {
			try? encodeStream.close()
		}


		// Define the Header Keys
		guard let keySet = ArchiveHeader.FieldKeySet("TYP,PAT,LNK,DEV,DAT,UID,GID,MOD,FLG,MTM,BTM,CTM") else {
			throw ArchiveError.ioError
		}


		// Compress the Directory Contents
		let sourceFilePath = FilePath(sourceDir.relativePath)
		do {
			try encodeStream.writeDirectoryContents(
				archiveFrom: sourceFilePath,
				keySet: keySet)
		} catch {
			llog("Write directory contents failed.")
			throw ArchiveError.ioError
		}

		//https://developer.apple.com/documentation/accelerate/compressing_file_system_directories
	}

#endif



	func cleanup() {

		let existingList: [URL] = listBackupsAndArchives()
		let versionBackupsList = self.versionBackupsList
		let periodicBackupsList = self.periodicBackupsList

		do {
			// Remove any items on the lists that are beyond the prune count
			if versionBackupsList.count > versionBackupsCount,
				 let pathToRemove = existingList.first(where: { $0.deletingPathExtension().lastPathComponent == versionBackupsList.first} ) {
				llog("will remove \(versionBackupsList.first)")
				try FileManager.default.removeItem(at: pathToRemove)
				self.versionBackupsList.removeFirst()

			} else if periodicBackupsList.count > periodicBackupsCount,
								let pathToRemove = existingList.first(where: {$0.deletingPathExtension().lastPathComponent == periodicBackupsList.first} ) {
				llog("will remove \(periodicBackupsList.first)")
				try FileManager.default.removeItem(at: pathToRemove)
				self.periodicBackupsList.removeFirst()

			} else {
				// no version or period files were removed

				if existingList.count > (versionBackupsList.count + periodicBackupsList.count) {
					// more backups exist than in known lists. try to remove

					if let pathToRemove = existingList.first(where: {
						!(versionBackupsList + periodicBackupsList).contains(
							$0.deletingPathExtension().lastPathComponent )
					}){
						try FileManager.default.removeItem(at: pathToRemove)
						cleanup()
					}
				}
			}
		} catch {
			llog(error)
			llog("failed in attempt to remove extra backup file")
		}
	}


	public func deleteBackupOrArchive(_ name: String) throws {
		let item: URL? = listBackupsAndArchives().first{ i in
			var item = i
			item.deletePathExtension()
			return (name == item.lastPathComponent)
		}
		guard let item else {
			llog("no item found")
			return }

		if itemExists(atPath: item) {
			llog("found item")
			do {
				llog("will try to delete item")
				try FileManager.default.removeItem(at: item)
			} catch {
				llog("error while deleting item")
				llog("error in removing \(item): \(error.localizedDescription) ")
				throw error
			}
		}
		cleanup()

	}




	public func createArchiveForDevelopment() {

		self.createQuickBackup(named: archiveForDevelopmentName)

		if true {
			// Compile file of Directory Structures
			var textContentsOverall: String = ""
			let backupFolder = BackupsFolder.appendingPathComponent(archiveForDevelopmentName)
			let filename = backupFolder.appendingPathComponent("DirectoryStructures.txt")

			textContentsOverall.append("appTargetDocumentsDirectory: \n")
			textContentsOverall.append( AdAstraFM_NEW.traverseContentsOfFolder(path: CurrentDataFolder) )

			textContentsOverall.append("\n\n appGroupDocumentsDirectory: \n")
			textContentsOverall.append( AdAstraFM_NEW.traverseContentsOfFolder(path: CurrentDataFolder) )

			do {
				try textContentsOverall.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
			} catch {
				// failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
			}
		}

		// insert any additional files / logs / data into the backupFolder


		self.archiveAnyBackupFolders()

		promptToShareArchiveForDevelopment()
	}

	// let promptToShareArchiveForDevelopmentDelivered: Bool = false
	func promptToShareArchiveForDevelopment() {

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
			if itemExists(atPath: archiveForDevelopmentFile) {
#if os(iOS)
				UIActivityViewController( activityItems: [archiveForDevelopmentFile.relativePath], applicationActivities: nil )
#endif

			} else {
				promptToShareArchiveForDevelopment()
			}
		}
	}





	lazy var archiveForDevelopmentName: String = {
		let date = Date()
		let format = DateFormatter()
		format.dateFormat = "yyyyMMdd HHmmss"
		let timestamp = format.string(from: date)

		return "ArchiveForDevelopment \(version ?? "") \(timestamp)"
	}()

	public lazy var archiveForDevelopmentFile = BackupsFolder.appendingPathComponent(archiveForDevelopmentName + ".aar")



	func itemExists(atPath path: URL, isDirectory isDirObjcBool: UnsafeMutablePointer<ObjCBool>? = nil) -> Bool { AdAstraFM_NEW.itemExists(atPath: path, isDirectory: isDirObjcBool) }



}
