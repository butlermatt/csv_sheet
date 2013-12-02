library csv_sheet;

part 'src/csv_column.dart';

/**
 * An indexable collection of CSV Values as a spreadsheet.
 * 
 * As spreadsheets (and unlike lists), a [CsvSheet] is indexed via 
 * column and then row, rather than row and column.
 * 
 * Columns can be referenced via their index number (1-based) or
 * via their column header [String].
 * 
 * CsvSheets can be visualized as such:
 * 
 *          1    2    3
 *       .----+----+----.
 *       |col1|col2|col3|
 *       +----+----+----+
 *     1 |  1 |  2 |  3 |
 *       +----+----+----+
 *     2 |  4 |  5 |  6 |
 *       +----+----+----+
 *     3 |  7 |  8 |  9 |
 *       '----+----+----'
 * 
 *     // access the value of cell 2,3 (in a spreadsheet as B3)
 *     var value = csvSheet[2][3]; // 8
 *     
 *     // If the cell has the header value of 'first name'
 *     var value = csvSheet['col1'][2]; // 4
 */
class CsvSheet {
  List _contents;
  List _rows;
  _CsvColumn _fakeColumn;
  
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
    _fakeColumn = new _CsvColumn(this);
    
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
  
  /**
   * Access the column specified by [index]. Index may be a 1-based integer
   * value or a string matching one of the header rows.
   * 
   * Throws a [RangeError] if invalid index or if a String index is used but
   * [hasHeaderRow] is false.
   */
  operator [](index) {
    if(index is String) {
      var tmp = index;
      if(!hasHeaderRow) {
        throw new RangeError('$tmp is not a valid column header');
      }
      
      index = _rows.indexOf(index);
      if(index == -1) throw new RangeError('$tmp is not a valid column header');
      _fakeColumn.row = index;
    } else {
      _fakeColumn.row = index-1;
    }
    
    return _fakeColumn;
  }
  
  /**
   * Iterate through each row in the spreadsheet, calling 'action' for each
   * row. It is an error if action tries to modify the list. The header row
   * is not passed as the first row.
   * 
   * Note: The list of cells passed to 'action' will be zero-indexed and not
   * 1-based index as the CsvSheet is.
   */
  void forEachRow(void action(List cells)) {
    _contents.forEach(action);
  }
  
  // Used by _CsvColumn to access rows spreadsheet style instead of list style.
  _getValue(row, index) => _contents[index][row];
  
}