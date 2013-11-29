library csv_sheet;

part 'src/csv_row.dart';

/**
 * An indexable collection of CSV Values as a spreadsheet.
 * 
 * As spreadsheets (and unlike lists), a [CsvSheet] is indexed via 
 * column and then row, rather than row and column.
 * 
 * Columns can be referenced via their index number (1-based) or
 * via their column header [String].
 * 
 *     // access the value of cell 3,4 (in a spreadsheet as C4)
 *     var value = csvSheet[3][4];
 *     
 *     // If the cell has the header value of 'first name'
 *     var value = csvSheet['first name'][4];
 */
class CsvSheet {
  List _contents;
  List _rows;
  _CsvRow _fakeRow;
  
  /// Return true if this sheet was created with a header row.
  bool hasHeaderRow;
  
  /**
   * Creates a CSV Sheet with the given contents. 
   * 
   * If headerRow is provided indicates that the first row of contents is a
   * header and not part of the data. Default is [false].
   * 
   * fieldSep is an optional field seperator if values are not comma separated.
   * 
   *     // tab separated sheet can be parsed with:
   *     var sheet = new CsvSheet(contents, fieldSep: '\t');
   * 
   * If you're using a file format which does not end lines with a simple '\n'
   * you can optionally specify what terminator rows are deliminated with.
   * 
   *     // Usually windows style should automatically be detected anyways.
   *     var sheet = new CsvSheet(contents, lineSep: '\r\n');
   */
  CsvSheet(String contents, 
      { bool headerRow: false,
      String fieldSep: ',',
      String lineSep: '\n' }) {
    _fakeRow = new _CsvRow(this);
    
    var rows = contents.split(lineSep);
    hasHeaderRow = headerRow;
    
    if(hasHeaderRow) {
      _rows = rows[0].split(fieldSep);
      _contents = new List.generate(rows.length - 1, (index) =>
          rows[index+1].split(fieldSep).map((cell) => cell.trim()).toList());
    } else {
      _contents = new List.generate(rows.length, (index) => 
        rows[index].split(fieldSep).map((cell) => cell.trim()).toList());
    }
  }
  
  _CsvRow operator [](index) {
    if(index is String) {
      var tmp = index;
      index = _rows.indexOf(index);
      if(index == -1) throw new RangeError('$tmp is not a valid column header');
      _fakeRow.row = index;
    } else {
      _fakeRow.row = index-1;
    }
    
    return _fakeRow;
  }
  
  _getValue(row, index) => _contents[index][row];
}