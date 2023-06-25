//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
// import SwiftUI
import CoreData
// import SFSafeSymbols
//#if !DebugWithoutCloudKit
import CloudKit
//#endif
import AdAstraExtensions
//import AdAstraBridgingByShim

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

#if true //os(iOS)


@available(macCatalyst 15, iOS 15, macOS 12, *)
struct CollaboratorPlaceHolder: Ladder_ShareParticipant {

	var userIdentity_: Ladder_UserIdentity

	var role: CKShare.ParticipantRole

	var permission: CKShare.ParticipantPermission

	var acceptanceStatus: CKShare.ParticipantAcceptanceStatus

	var uniqueID: String?

	static func build(_ i: Int) -> CollaboratorPlaceHolder {
		var givenName = "First\(i)"
		var familyName = "Last\(i)"
		var role: CKShare.ParticipantRole = .owner
		var permission: CKShare.ParticipantPermission = .readWrite
		var acceptanceStatus: CKShare.ParticipantAcceptanceStatus = .accepted
		switch i {
			case 1:
				givenName = "Johnny"
				familyName = "Appleseed"
			case 2:
				givenName = "Heather"
				familyName = "Crispin"
			case 3:
				givenName = "Jermaine"
				familyName = "Sable"
			case 4:
				givenName = "Mary"
				familyName = "Saunders"
			case 5:
				givenName = "Percy"
				familyName = "Hampton"
			default:
				true
		}

		return CollaboratorPlaceHolder(
			userIdentity_: UserIdentityPlaceholder(
				nameComponents: PersonNameComponents(namePrefix: nil,
													 givenName: givenName,
													 middleName: nil,
													 familyName: familyName,
													 nameSuffix: nil,
													 nickname: nil,
													 phoneticRepresentation: nil),
				contactIdentifiers: [String]() ),
			role: role,
			permission: permission,
			acceptanceStatus: acceptanceStatus,
			uniqueID: "fakeCollaborator\(i)")
	}

}
struct UserIdentityPlaceholder: Ladder_UserIdentity{
	var nameComponents: PersonNameComponents?

	var contactIdentifiers: [String]
}


protocol Ladder_Share {
	var participants_: [Ladder_ShareParticipant] { get }
}
extension CKShare: Ladder_Share {
	var participants_: [Ladder_ShareParticipant] {
		return participants
	}
}


public protocol Ladder_UserIdentity {
	var nameComponents: PersonNameComponents? { get }
	var contactIdentifiers: [String] { get }
	// var userRecordID: CKRecord.ID? { get }
}
extension CKUserIdentity: Ladder_UserIdentity {
	var a: NSObject? {
		return nil
	}
}

public protocol Ladder_ShareParticipant {
	var userIdentity_: Ladder_UserIdentity { get }
	var role: CKShare.ParticipantRole { get }
	var permission: CKShare.ParticipantPermission { get set }
	var acceptanceStatus: CKShare.ParticipantAcceptanceStatus { get }
	var uniqueID: String? { get }
	var initials: String { get }
	var permissionAsString: String { get }
	var roleAsString: String { get }
	var acceptanceStatusAsString: String { get }
}

extension CKShare.Participant: Ladder_ShareParticipant {
	public var userIdentity_: Ladder_UserIdentity {
		return userIdentity
	}
	public var uniqueID: String? {
		userIdentity.userRecordID?.recordName
	}

}

extension Ladder_ShareParticipant {
	public var uniqueIDOrUUID: String {
		uniqueID ?? UUID().uuidString
	}

	public var displayName: String? {
      
      if #available(macOS 12.0, iOS 15, *) {
         return userIdentity_.nameComponents?.formatted() 
      } else {
         let firstName = userIdentity_.nameComponents?.givenName
         let lastName = userIdentity_.nameComponents?.familyName
         if firstName.isNilOrEmpty && lastName.isNilOrEmpty {return nil}
         return "\(firstName) \(lastName)"
      }
	}

	public var initials: String {

		var givenNameInitial: String = ""
		var familyNameInitial: String = ""

		if let initial = userIdentity_.nameComponents?.givenName?.first {
			givenNameInitial = String(initial)
		}
		if let initial = userIdentity_.nameComponents?.familyName?.first {
			familyNameInitial = String(initial)
		}

		return givenNameInitial + familyNameInitial
	}

   // public var calculatedColor: UINSColor {

		// let scalarValues: [Double] = displayName.unicodeScalars.map{ scalar in
		//     let v = Double(scalar.value)
		//     return v
		// }
		//       let sumValues = vDSP.sum(scalarValues)

  //     let sumScalarValues = displayName?.unicodeScalars.reduce(0){ prior, scalar in
      //    prior + scalar.value
      // }

      // var generator = RandomNumberGeneratorWithSeed(seed: Int(sumScalarValues) )

      // let randomHue: CGFloat = Double.random(in: 0..<1000, using: &generator) / 1000

      // let updatedColor = UINSColor(hue: randomHue,
      //                      saturation: 0.4,
      //                      brightness: 1.0,
      //                      alpha: 1.0
      // )

		// let saturation = 0.40
		// let brightness = 1.0
		// let alpha = 1.0
		//
		// let updatedColor = UIColor(hue: calcColor.hsba.hue, saturation: saturation, brightness: brightness, alpha: alpha)

      // return updatedColor
   // }

    #if Disabled
	var calculatedColor2: UINSColor {
        AdAstraColor.allCases.randomElement()?.system.platformColor ?? UINSColor.gray
	}
    #endif
    
	public var roleAsString: String {
		switch role {
			case .owner:
				return "Owner"
			case .privateUser:
				return "Private User"
			case .publicUser:
				return "Public User"
			case .unknown:
				return "Unknown"
			@unknown default:
				return "error"
				// fatalError("It looks like a new value was added to CKShare.Participant.Role")
		}
	}

	public var acceptanceStatusAsString: String {
		switch acceptanceStatus {
			case .accepted:
				return "Accepted"
			case .removed:
				return "Removed"
			case .pending:
				return "Invited"
			case .unknown:
				return "Unknown"
			@unknown default:
				return "error"
				// fatalError("It looks like a new value was added to CKShare.Participant.AcceptanceStatus")
		}
	}

	public var permissionAsString: String {
		switch permission {
			case .unknown:
				return "Unknown"
			case .none:
				return "No access"
			case .readOnly:
				return "View"
			case .readWrite:
				return "Edit"
			@unknown default:
				return "error"
				// fatalError("It looks like a new value was added to CKShare.Participant.Permission")
		}
	}

	var dashboardString: String {
		var dashboard: String = ""
		if role == .owner {
			return roleAsString // simply "Owner" as dashboard
		} else {
			dashboard += roleAsString
		}
		dashboard += " - "

		dashboard += acceptanceStatusAsString
		dashboard += " to "

		dashboard += permissionAsString

		return dashboard
	}

}


struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
	init(seed: Int) {
		// Set the random seed
		srand48(seed)
	}

	func next() -> UInt64 {
		// drand48() returns a Double, transform to UInt64
		return withUnsafeBytes(of: drand48()) { bytes in
			bytes.load(as: UInt64.self)
		}
	}
}

#endif
