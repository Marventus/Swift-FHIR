//
//  ReferenceTests.swift
//  SwiftFHIR
//
//  Created by Pascal Pfiffner on 11/30/15.
//  2016, SMART Health IT.
//

import XCTest
import SwiftFHIR


/**
Test reference resolving.
*/
class ReferenceTests: XCTestCase {
	
	func testContainedReference() {
		if let path = NSBundle(forClass: self.dynamicType).pathForResource("ReferenceContained1", ofType: "json", inDirectory: "TestResources") {
			let order1 = try! MedicationOrder.instantiateFromPath(path)
			XCTAssertEqual("order-ref-contained", order1.id)
			XCTAssertNotNil(order1.medicationReference)
			XCTAssertEqual("Red Pill", order1.medicationReference?.resolved(Medication)?.code?.text ?? "missing")
			XCTAssertEqual("Red Pill", order1.medicationReference?.resolved(Medication)?.code?.text ?? "missing")		// second time, reading from `_resolved`
			XCTAssertEqual("Morpheus Co.", order1.medicationReference?.resolved(Medication)?.manufacturer?.resolved(Organization)?.name)
		}
		else {
			XCTAssertTrue(false, "Test resource not bundled")
		}
		
		if let path = NSBundle(forClass: self.dynamicType).pathForResource("ReferenceContained2", ofType: "json", inDirectory: "TestResources") {
			let order1 = try! MedicationOrder.instantiateFromPath(path)
			XCTAssertEqual("order-ref-contained-wrong", order1.id)
			XCTAssertNotNil(order1.medicationReference)
			XCTAssertNil(order1.medicationReference?.resolved(Medication), "Must not resolve contained resource with wrong type")
			XCTAssertNil(order1.medicationReference?.resolved(Medication), "Must still not resolve contained resource with wrong type")		// second time, reading from `_resolved`
			XCTAssertEqual("Morpheus Co.", order1.medicationReference?.resolved(Organization)?.name)
		}
		else {
			XCTAssertTrue(false, "Test resource not bundled")
		}
	}
	
	func testBundledReference() {
		if let path = NSBundle(forClass: self.dynamicType).pathForResource("ReferenceBundled", ofType: "json", inDirectory: "TestResources") {
			let bundle = try! Bundle.instantiateFromPath(path)
			XCTAssertEqual("Bundle", bundle.dynamicType.resourceName)
			
			// get resources
			let pat23 = bundle.entry?[0].resource as? Patient
			XCTAssertEqual("Patient", pat23?.dynamicType.resourceName)
			XCTAssertEqual("Darth", pat23?.name?[0].given?[0])
			let patURN = bundle.entry?[1].resource as? Patient
			XCTAssertEqual("Patient", patURN?.dynamicType.resourceName)
			XCTAssertEqual("Ben", patURN?.name?[0].given?[0])
			let obs123 = bundle.entry?[2].resource as? Observation
			XCTAssertEqual("Observation", obs123?.dynamicType.resourceName)
			XCTAssertEqual("123", obs123?.id)
			let obs56 = bundle.entry?[3].resource as? Observation
			XCTAssertEqual("Observation", obs56?.dynamicType.resourceName)
			XCTAssertEqual("56", obs56?.id)
			let obs34 = bundle.entry?[4].resource as? Observation
			XCTAssertEqual("Observation", obs34?.dynamicType.resourceName)
			XCTAssertEqual("34", obs34?.id)
			
			// test resolving
			bundle._server = FHIROpenServer(baseURL: NSURL(string: "https://fhir.smarthealthit.org")!)
			let res1 = obs123!.subject!.resolved(Patient.self)      // relative reference, bundled
			XCTAssertTrue(res1 === pat23)
			let res2 = obs123!.subject!.resolved(Medication.self)
			XCTAssertNil(res2, "Must not resolve on type mismatch")
			
			let res3 = obs56!.subject!.resolved(Patient.self)       // bundled, URN-referenced
			XCTAssertTrue(res3 === patURN)
			
			let readyExpectation = expectationWithDescription("absolute")
			obs34!.subject!.resolve(Patient.self) { pat in          // absolute reference, on same server but different endpoint
				XCTAssertNil(pat, "Must not resolve Patient on same server but different endpoint")
				readyExpectation.fulfill()
			}
			waitForExpectationsWithTimeout(1) { error in
				XCTAssertNil(error, "Should return immediately")
			}
		}
		else {
			XCTAssertTrue(false, "Test resource not bundled")
		}
	}
	
	func testRelativeReference() {
		if let path = NSBundle(forClass: self.dynamicType).pathForResource("ReferenceRelative", ofType: "json", inDirectory: "TestResources") {
			let order1 = try! MedicationOrder.instantiateFromPath(path)
			XCTAssertEqual("order-ref-relative", order1.id)
			XCTAssertEqual("Medication/med-1234", order1.medicationReference?.reference)
			XCTAssertNil(order1.medicationReference?.resolved(Medication), "Cannot already be resolved")
			
			let readyExpectation = expectationWithDescription("reference")
			order1.medicationReference?.resolve(Medication.self) { medication in
				XCTAssertNil(medication, "Resolving must be impossible without server instance")
				readyExpectation.fulfill()
			}
			waitForExpectationsWithTimeout(1) { error in
				XCTAssertNil(error, "Should return immediately")
			}
		}
		else {
			XCTAssertTrue(false, "Test resource not bundled")
		}
	}
	
	func testAbsoluteReference() {
		if let path = NSBundle(forClass: self.dynamicType).pathForResource("ReferenceAbsolute", ofType: "json", inDirectory: "TestResources") {
			let order1 = try! MedicationOrder.instantiateFromPath(path)
			XCTAssertEqual("order-ref-absolute", order1.id)
			XCTAssertEqual("https://fhir-open-api-dstu2.smarthealthit.org/Medication/1", order1.medicationReference?.reference)
			XCTAssertNil(order1.medicationReference?.resolved(Medication), "Cannot already be resolved")
			
			let readyExpectation = expectationWithDescription("reference")
			order1.medicationReference?.resolve(Medication.self) { medication in
				XCTAssertNil(medication, "Unfortunately, don't currently have Medication/1 on the SMART server")
				readyExpectation.fulfill()
			}
			waitForExpectationsWithTimeout(5) { error in
				XCTAssertNil(error, "Error resolving reference")
			}
		}
		else {
			XCTAssertTrue(false, "Test resource not bundled")
		}
	}
}

