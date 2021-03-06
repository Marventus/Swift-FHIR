//
//  ExplanationOfBenefitTests.swift
//  SwiftFHIR
//
//  Generated from FHIR 1.0.2.7202 on 2015-11-24.
//  2015, SMART Health IT.
//

import XCTest
import SwiftFHIR


class ExplanationOfBenefitTests: XCTestCase
{
	func instantiateFrom(filename filename: String) throws -> ExplanationOfBenefit {
		return instantiateFrom(json: try readJSONFile(filename))
	}
	
	func instantiateFrom(json json: FHIRJSON) -> ExplanationOfBenefit {
		let instance = ExplanationOfBenefit(json: json)
		XCTAssertNotNil(instance, "Must have instantiated a test instance")
		return instance
	}
	
	func testExplanationOfBenefit1() {
		let instance = try? runExplanationOfBenefit1()
		XCTAssertNotNil(instance, "Must instantiate ExplanationOfBenefit")
		if let instance = instance {
			try! runExplanationOfBenefit1(instance.asJSON())
		}
	}
	
	func runExplanationOfBenefit1(json: FHIRJSON? = nil) throws -> ExplanationOfBenefit {
		let inst = (nil != json) ? instantiateFrom(json: json!) : try instantiateFrom(filename: "explanationofbenefit-example.json")
		
		XCTAssertEqual(inst.created!.description, "2014-08-16")
		XCTAssertEqual(inst.disposition!, "Claim settled as per contract.")
		XCTAssertEqual(inst.id!, "R3500")
		XCTAssertEqual(inst.identifier![0].system!.absoluteString, "http://www.BenefitsInc.com/fhir/eob")
		XCTAssertEqual(inst.identifier![0].value!, "987654321")
		XCTAssertEqual(inst.organization!.reference!, "Organization/2")
		XCTAssertEqual(inst.outcome!, "complete")
		XCTAssertEqual(inst.request!.reference!, "http://www.BenefitsInc.com/fhir/oralhealthclaim/15476332402")
		XCTAssertEqual(inst.requestOrganization!.reference!, "Organization/1")
		XCTAssertEqual(inst.text!.div!, "<div>A human-readable rendering of the ExplanationOfBenefit</div>")
		XCTAssertEqual(inst.text!.status!, "generated")
		
		return inst
	}
}
