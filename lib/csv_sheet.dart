library csv_sheet;

class CsvSheet {
  List _contents;
  List _rows;
  
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
    var rows = contents.split(lineSep);
    hasHeaderRow = headerRow;
    
    if(hasHeaderRow) {
      _rows = rows[0].split(fieldSep);
      _contents = new List.generate(rows.length - 1, (index) =>
          rows[index+1].split(fieldSep).map((cell) => cell.trim()));
    } else {
      _contents = new List.generate(rows.length, (index) => 
        rows[index].split(fieldSep).map((cell) => cell.trim()));
    }
  }
}