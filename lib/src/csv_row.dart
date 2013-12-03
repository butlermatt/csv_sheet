part of CsvSheet;

/**
 * Currently CsvRow is only used as a type passed to the [CsvSheet.forEachRow]
 * method.
 * 
 * CsvRow is a 1-based index of the cells contained in that row. Alternatively
 * any headers that the [CsvSheet] contains my also be used to index the rows.
 */
class CsvRow {
  List<String> row;
  
  HashMap _headers;
  bool hasHeaders = false;
  
  CsvRow([this._headers, this.row]) {
    if(_headers != null) hasHeaders = true;
  }
  
  /**
   * 1-Based index of the contents in this row. Alternatively you may also
   * use any headers that the [CsvSheet] contains to index the values.
   * 
   *     var value = row['name'];
   *     var value = row['1'];
   *  
   *  Throws a [RangeError] if the column header provided does not exist
   *  or the index value is outside of the valid indexes.
   */
  String operator [](index) {
    if(index is String) {
      var tmp = index;
      if(!hasHeaders) {
        throw new RangeError('$tmp is not a valid column header');
      }
      
      if(!_headers.containsKey(index)) 
        throw new RangeError('$tmp is not a valid column header');
      
      index = _headers[index];
    } else {
      index -= 1;
    }
    return row[index];
  }
  
  /**
   * Currently writing back to the CsvRow is not supported. This operation
   * throws an [UnsupportedError].
   */
  operator []=(index, value) {
    throw new UnsupportedError('Unable to assign a value to a cell.');
  }
  
  String toString() => row.toString();
  
}