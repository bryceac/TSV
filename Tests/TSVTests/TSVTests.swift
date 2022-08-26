import XCTest
@testable import TSV

final class TSVTests: XCTestCase {
    func testTSVParsing() {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000
        """
        
        XCTAssertNoThrow(try TSV(text, withHeaders: true))
    }
    
    func testTSVPARsingFailsDueToTooFewHeaders() {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000
        """
        
        XCTAssertThrowsError(try TSV(text, withHeaders: true), "initializer should throw error because there are too few headers") { error in
            XCTAssertEqual(error as? TSVParseError, TSVParseError.tooFewColumnHeadings(lineNumber: 2))
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
            "Credit"
        ]
        
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
}
