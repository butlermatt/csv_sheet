part of csv_sheet;

class CsvRow {
  List<String> row;
  
  HashMap _headers;
  bool hasHeaders = false;
  
  CsvRow([this._headers, this.row]) {
    if(_headers != null) hasHeaders = true;
  }
  
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
  
  operator []=(index, value) {
    throw new UnsupportedError('Unable to assign a value to a cell.');
  }
  
  String toString() => row.toString();
  
}