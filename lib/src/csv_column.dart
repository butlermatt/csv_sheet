part of CsvSheet;

class _CsvColumn {
  final CsvSheet sheet;
  int row = 0;
  
  _CsvColumn(this.sheet);
  
  // TODO: Should we have a CsvCell type? For now it's just strings.
  String operator [](index) => sheet._getValue(row, index-1);
}