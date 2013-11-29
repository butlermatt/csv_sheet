library csv_sheet.test.csv_sheet;

import 'package:unittest/unittest.dart';
import 'package:unittest/compact_vm_config.dart';

import 'package:csv_sheet/csv_sheet.dart';

const SHEET = 'col1,col2,col3\n1,2,3\n4,5,6\n7,8,9';
/*      1    2    3
 *   .----+----+----.
 *   |col1|col2|col3| <-- Header
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
    test('Should accept boolean titleRow flag', () {
      works() { new CsvSheet(SHEET, headerRow: true); };
      expect(works, returnsNormally);
    });
    test('Should accept fieldSeperator argument', () {
      var testSheet = '1\t2\t\3\n3\t\2\t1';
      works() { new CsvSheet(testSheet, fieldSep: '\t'); };
      expect(works, returnsNormally);
    });
    test('Should accept lineSeperator argument', () {
      var testSheet = '1,2,3\r\n,3,2,1';
      works() { new CsvSheet(testSheet, lineSep: '\r\n'); };
      expect(works, returnsNormally);
    });
    // TODO: Add a test for trims whitespace.
  });
  
  group('CsvSheet hasHeaderRow', () {
    test('Is true when headerRow is passed to constructor', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      expect(sheet.hasHeaderRow, isTrue);
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
  });
}