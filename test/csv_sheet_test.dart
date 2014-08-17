library csv_sheet.test.csv_sheet;

import 'package:unittest/unittest.dart';
import 'package:unittest/compact_vm_config.dart';

import 'package:csv_sheet/csv_sheet.dart';

const SHEET = 'col1,col2,col3\n1,2,3\n4,5,6\n7,8,9';
/*      1    2    3
 *   .----+----+----.
 *   |col1|col2|col3|
 *   +----+----+----+
 * 1 |  1 |  2 |  3 |
 *   +----+----+----+
 * 2 |  4 |  5 |  6 |
 *   +----+----+----+
 * 3 |  7 |  8 |  9 |
 *   '----+----+----'
 */

main() {
  useCompactVMConfiguration();

  group('CsvSheet Constructor', () {
    test('Should accept only CSV string for arguments', () {
      works () { new CsvSheet(SHEET); };
      expect(works, returnsNormally);
    });
    test('Should accept boolean headerRow flag', () {
      works() { new CsvSheet(SHEET, headerRow: true); };
      expect(works, returnsNormally);
    });
    test('Should accept fieldSeperator argument', () {
      var testSheet = '1\t2\t\3\n3\t\2\t1';
      works() { new CsvSheet(testSheet, fieldSep: '\t'); };
      expect(works, returnsNormally);
    });
    test('Should accept lineSeperator argument', () {
      var testSheet = '1,2,3\r\n3,2,1';
      works() { new CsvSheet(testSheet, lineSep: '\r\n'); };
      expect(works, returnsNormally);
    });
    test('Should automatically remove extra whitespace.', () {
      var testSheet = '1, 2  ,3,\t4\n5   ,     6,\t\t7\t,8';
      var sheet = new CsvSheet(testSheet);
      expect(sheet[2][2], equals('6'));
      expect(sheet[3][2], equals('7'));
    });
    test('Throws FormatException if a header column is repeated', () {
      var testSheet = 'col1,col2,col1\n1,2,3\n4,5,6\n7,8,9';
      doesntwork() { new CsvSheet(testSheet, headerRow: true); }
      expect(doesntwork, throwsFormatException);
    });
    test('Should support quoted fields containing commas', () {
      var testSheet = 'col1,col2,col3\n1,2,3\n"4,5",5,6\n7,8,9';
      var sheet = new CsvSheet(testSheet, headerRow: true);
      var sheet2 = new CsvSheet(testSheet);
      expect(sheet['col1'][2], equals('4,5'));
      expect(sheet2[1][3], equals('4,5'));
    });
    test('Should support quoted fields containing new lines', () {
      var testSheet = 'col1,col2,col3\n1,2,3\n"4\n5",5,6\n7,8,9';
      var sheet = new CsvSheet(testSheet, headerRow: true);
      var sheet2 = new CsvSheet(testSheet);
      expect(sheet['col1'][2], equals('4\n5'));
      expect(sheet2[1][3], equals('4\n5'));
    });
    test('Should throw FormatExcept on unterminated quoted field', () {
      var testSheet = 'col1,col2,col3\n1,2,3\n"4\n5,5,6\n7,8,9';
      var testSheet2 = 'col1,col2,col3\n1,2,3\n"4,5,5,6\n7,8,9';
      doesntwork() { new CsvSheet(testSheet, headerRow: true); }
      doesntwork2() { new CsvSheet(testSheet2, headerRow: true); }
      expect(doesntwork, throwsFormatException);
      expect(doesntwork2, throwsFormatException);
    });
    test('Should truncate empty rows', () {
      var testSheet = 'col1,col2,col3\n1,2,3\n4,5,6\n7,8,9\n\n\n';
      var sheet = new CsvSheet(testSheet, headerRow: true);
      expect(sheet.numRows, equals(3));
    });
  });
  
  group('CsvSheet attributes', () {
    test('hasHeaderRow Is true when headerRow is passed to constructor', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      expect(sheet.hasHeaderRow, isTrue);
    });
    
    test('numRows returns number of rows, excluding header row.', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      expect(sheet.numRows, equals(3));
    });
  });
  
  group('CsvSheet access operator', () {
    test('Returns 0-based index via columns and rows.', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      expect(sheet[1][2], equals('4'));
    });
    test('Works with column headers', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      expect(sheet['col2'][2], equals('5'));
    });
    test('Throws range error on invalid header', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      doesntWork() => sheet['col5'][2];
      expect(doesntWork, throwsRangeError);
    });
    test('Throws range error if String index passed but no headers set', () {
      var sheet = new CsvSheet(SHEET);
      doesntWork() => sheet['col1'][2];
      expect(doesntWork, throwsRangeError);
    });
  });
  
  group('CsvSheet forEachRow', () {
    test('Should call the callback for each row passed', () {
      var testSheet = '1,2,3\n1,2,3';
      var sheet = new CsvSheet(testSheet);
      var callback = expectAsync((CsvRow row) {
        expect(row[1], equals('1'));
      }, count: 2);
      
      sheet.forEachRow(callback);
    });
    test('Should not pass the header row to the callback', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      var callback = expectAsync((CsvRow row) {
        expect(row, new isInstanceOf<CsvRow>('CsvRow'));
      }, count: 3);
      
      sheet.forEachRow(callback);
    });
    group('CsvRow', () {
      test('Should be 1-based index', () {
        var testSheet = '1,2,3\n1,2,3';
        var sheet = new CsvSheet(testSheet);
        var callback = expectAsync((CsvRow row) {
          expect(row[1], equals('1'));
        }, count: 2);
        sheet.forEachRow(callback);
      });
      test('Should be header indexable', () {
        var testSheet = 'one,two,three\n1,2,3\n1,2,3';
        var sheet = new CsvSheet(testSheet, headerRow: true);
        var callback = expectAsync((CsvRow row) {
          expect(row['two'], equals('2'));
        }, count: 2);
        sheet.forEachRow(callback);
      }); 
    }); // end Group CsvRow
  }); // End group CsvSheet forEachRow
}