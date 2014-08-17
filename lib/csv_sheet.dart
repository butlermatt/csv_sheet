library CsvSheet;

import 'dart:collection' show HashMap;

part 'src/csv_column.dart';
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
 *     // If the cell has the header value of 'col1'
 *     var value = csvSheet['col1'][2]; // 4
 */
class CsvSheet {
  List _contents;
  HashMap _headers;
  _CsvColumn _fakeColumn;
  CsvRow _row;
  
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
    
    var allRows = contents.split(lineSep);
    hasHeaderRow = headerRow;
    
    if(hasHeaderRow) {
      var _rows = allRows[0].split(fieldSep);
      _headers = new HashMap();
      for(var i = 0; i < _rows.length; i ++) {
        var val = _rows[i].replaceAll('"', '');
        if(_rows.indexOf(val, i+1) != -1) {
          throw 
            new FormatException('The header column $val appears more than once');
        }
        _headers[val] = i;
      }
      _row = new CsvRow(_headers);
      _contents = new List<List<String>>();
      var allRowsLength = allRows.length;
      for(var index = 1; index < allRowsLength; index++) {
        
        // Find unterminated quotes per row
        // usually occurs if there are multiple line entries.
        var numQuotes = _countQuotes(allRows[index]);
        while(numQuotes % 2 != 0) {
          if((index + 1) > (allRowsLength - 1))
            throw new FormatException('Unterminated quoted field');
          
          allRows[index] = allRows[index] + lineSep + allRows[index + 1];
          allRows.removeAt(index + 1);
          allRowsLength -= 1;
          numQuotes = _countQuotes(allRows[index]);
        }
        
        // Find unterminated quotes in each cell
        var tmpRow = allRows[index].split(fieldSep);
        var rowLength = tmpRow.length;
        
        for(var ind = 0; ind < rowLength; ind++) {
          numQuotes = _countQuotes(tmpRow[ind]);
          while(numQuotes % 2 == 1) {
            if((ind + 1) > (rowLength - 1))
              throw new FormatException('Unterminated quoted field');
            
            tmpRow[ind] = tmpRow[ind] + fieldSep + tmpRow[ind + 1];
            tmpRow.removeAt(ind + 1);
            rowLength -= 1;
            numQuotes = _countQuotes(tmpRow[ind]);
          }
          tmpRow[ind] = tmpRow[ind].replaceAll('"', '').trim();
        }
            
        _contents.add(tmpRow);
      } // end for loop
    } else { // hasHeaderRow
      _row = new CsvRow();
      _contents = new List<List<String>>();
      var allRowsLength = allRows.length;
      for(var index = 0; index < allRowsLength; index++) {
        
        // Find unterminated quotes per row
        // usually occurs if there are multiple line entries.
        var numQuotes = _countQuotes(allRows[index]);
        while(numQuotes % 2 != 0) {
          if((index + 1) > (allRowsLength - 1))
            throw new FormatException('Unterminated quoted field');
          
          allRows[index] = allRows[index] + lineSep + allRows[index + 1];
          allRows.removeAt(index + 1);
          allRowsLength -= 1;
          numQuotes = _countQuotes(allRows[index]);
        }
        
        // Find unterminated quotes in each cell
        var tmpRow = allRows[index].split(fieldSep);
        var rowLength = tmpRow.length;
        
        for(var ind = 0; ind < rowLength; ind++) {
          numQuotes = _countQuotes(tmpRow[ind]);
          while(numQuotes % 2 == 1) {
            if((ind + 1) > (rowLength - 1))
              throw new FormatException('Unterminated quoted field');
            
            tmpRow[ind] = tmpRow[ind] + fieldSep + tmpRow[ind + 1];
            tmpRow.removeAt(ind + 1);
            rowLength -= 1;
            numQuotes = _countQuotes(tmpRow[ind]);
          }
          tmpRow[ind] = tmpRow[ind].replaceAll('"', '').trim();
        }
            
        _contents.add(tmpRow);
      } // end for loop
    }
    while(_contents.last.length != _contents.first.length) {
      _contents.removeLast();
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
      
      if(!_headers.containsKey(index)) throw new RangeError('$tmp is not a valid column header');
      index = _headers[index];
      _fakeColumn.row = index;
    } else {
      _fakeColumn.row = index-1;
    }
    
    return _fakeColumn;
  }
  
  /**
   * Iterate through each row in the spreadsheet as a CsvRow, calling 'action' 
   * for each row. It is an error if action tries to modify the list.
   * 
   * The CsvRow is indexable via the headers if applicable. 
   */
  void forEachRow(void action(CsvRow cells)) {
    _contents.forEach((row) {
      _row.row = row;
      action(_row);
    });
  }
  
  /**
   * Return the number of rows contained in this sheet. Does not included
   * the header row, if provided.
   */
  int get numRows => _contents.length;
  
  /**
   * Return the number of columns contained in this sheet.
   */
  int get numCols => _contents[0].length;
  
  // Used by _CsvColumn to access rows spreadsheet style instead of list style.
  _getValue(column, row) => _contents[row][column];
  
  num _countQuotes(String str) {
    var numQuotes = 0;
    var quoteIndex = str.indexOf('"');
    while(quoteIndex != -1) {
      numQuotes += 1;
      if((quoteIndex + 1) < str.length) {
        quoteIndex = str.indexOf('"', quoteIndex + 1);
      } else {
        break;
      }
    }
    return numQuotes;
  }
  
}