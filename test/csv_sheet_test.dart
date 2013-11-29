library csv_sheet.test.csv_sheet;

import 'package:unittest/unittest.dart';
import 'package:unittest/compact_vm_config.dart';

import 'package:csv_sheet/csv_sheet.dart';

const SHEET = 'col1,col2,col3\n1,1,1\n2,2,2\n1,2,3';

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
  });
  
  group('CsvSheet hasHeaderRow', () {
    test('Is true when headerRow is passed to constructor', () {
      var sheet = new CsvSheet(SHEET, headerRow: true);
      expect(sheet.hasHeaderRow, isTrue);
    });
  });
}