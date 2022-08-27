import XCTest
@testable import TSV

final class TSVTests: XCTestCase {
    func testTSVParsing() {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        XCTAssertNoThrow(try TSV(text, withHeaders: true))
    }
    
    func testTSVPARsingFailsDueToTooFewHeaders() {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        XCTAssertThrowsError(try TSV(text, withHeaders: true), "initializer should throw error because there are too few headers") { error in
            XCTAssertEqual(error as? TSVParseError, TSVParseError.tooFewColumnHeadings(lineNumber: 1))
        }
    }
    
    func testTSVParsingFailsDueToUnequalColumns() {
        let text = """
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000
        """
        
        XCTAssertThrowsError(try TSV(text), "initializer should throw error because columns are not equal.") { error in
            XCTAssertEqual(error as? TSVParseError, TSVParseError.columnsNotEqual(lineNumber: 2))
        }
    }
    
    func testCreatingTSV() {
        let columns = [
            "Date",
            "Check No.",
            "Reconciled",
            "Caegory",
            "Vendor",
            "Memo",
            "Credit",
            "Withdrawal"
        ]
        
        let records = [
            [
                "08/25/2022",
                "1260",
                "Y",
                "Opening Balance",
                "Sam Hill Credit Union",
                "Open Account",
                "500",
                ""
            ],
            [
                "08/25/2022",
                "",
                "N",
                "Gifts",
                "Fake Street Electronics",
                "Head set",
                "",
                "200"
            ],
            [
                "08/25/2022",
                "",
                "N",
                "",
                "Velociraptor Entertainment",
                "Pay Day",
                "50000",
                ""
            ]
        ]
        
        XCTAssertNoThrow(try TSV(columns: columns, records: records))
    }
    
    func testCreatingTSVFailsDueToTooFewHeaders() {
        let columns = [
            "Date",
            "Check No.",
            "Reconciled",
            "Caegory",
            "Vendor",
            "Memo",
            "Credit",
        ]
        
        let records = [
            [
                "08/25/2022",
                "1260",
                "Y",
                "Opening Balance",
                "Sam Hill Credit Union",
                "Open Account",
                "500",
                ""
            ],
            [
                "08/25/2022",
                "",
                "N",
                "Gifts",
                "Fake Street Electronics",
                "Head set",
                "",
                "200"
            ],
            [
                "08/25/2022",
                "",
                "N",
                "",
                "Velociraptor Entertainment",
                "Pay Day",
                "50000",
                ""
            ]
        ]
        
        XCTAssertThrowsError(try TSV(columns: columns, records: records), "initializer should throw error because columns are not an adequate numner") { error in
            XCTAssertEqual(error as? TSVError, TSVError.tooFewColumnHeadings)
        }
    }
    
    func testCreatingTSVFailsDueToColumnsNotBeingEqual() {
        let records = [
            [
                "08/25/2022",
                "1260",
                "Y",
                "Opening Balance",
                "Sam Hill Credit Union",
                "Open Account",
                "500"
            ],
            [
                "08/25/2022",
                "",
                "N",
                "Gifts",
                "Fake Street Electronics",
                "Head set",
                "",
                "200"
            ],
            [
                "08/25/2022",
                "",
                "N",
                "",
                "Velociraptor Entertainment",
                "Pay Day",
                "50000"
            ]
        ]
        
        XCTAssertThrowsError(try TSV(records: records), "initializer should fail because the records do not have an equal number of columns") { error in
            XCTAssertEqual(error as? TSVError, TSVError.columnsNotEqual)
        }
    }
    
    func testRetrieveRowByIndex() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        let tsv = try TSV(text, withHeaders: true)
        
        let expectedRow = [
            "08/25/2022",
            "1260",
            "Y",
            "Opening Balance",
            "Sam Hill Credit Union",
            "Open Account",
            "500",
            ""
        ]
        
        XCTAssertEqual(tsv[0], expectedRow)
    }
    
    func testRetrieveColumnByIndex() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        let tsv = try TSV(text, withHeaders: true)
        
        let expectedColumn = [String](repeating: "08/25/2022", count: 3)
        
        XCTAssertEqual(tsv[column: 0], expectedColumn)
    }
    
    func testRetrieveValueByCoordinates() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        let tsv = try TSV(text, withHeaders: true)
        
        XCTAssertEqual(tsv[0,0], "08/25/2022")
    }
    
    func testRetrieveColumnByName() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        let tsv = try TSV(text, withHeaders: true)
        
        let expectedColumn = [String](repeating: "08/25/2022", count: 3)
        
        XCTAssertEqual(tsv["Date"], expectedColumn)
    }
    
    func testWriteValueToRecord() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        var tsv = try TSV(text, withHeaders: true)
        
        let newDate = "08/26/2022"
        
        tsv[0,0] = newDate
        
        XCTAssertEqual(tsv[0,0], newDate)
    }
    
    func testTSVStringEqualsOriginal() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        let tsv = try TSV(text, withHeaders: true)
        
        XCTAssertEqual("\(tsv)", text)
    }
    
    func testSavingTSVToFile() throws {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500\t
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000\t
        """
        
        let tsv = try TSV(text, withHeaders: true)
        let desktopDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        
        XCTAssertNoThrow(try tsv.save(to: desktopDirectory.appendingPathComponent("transactions").appendingPathExtension("tsv")))
    }
}
