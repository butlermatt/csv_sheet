CSV Sheet [![Build Status](https://drone.io/github.com/butlermatt/csv_sheet/status.png)](https://drone.io/github.com/butlermatt/csv_sheet/latest)
=========

Dart based CSV parser which for reading and accessing CSV Files as spreadsheets
(as opposed to lists). Currently the library is read-only and does not support
writing to a CSV file. This functionality may come in the future.

The aim of CsvSheet is to make handling CSV Data more like dealing directly with
a spreadsheet than with Lists or Arrays. As such the cells are all 1-base indexed
as opposed to 0-based like a List. Optionally if a header row is passed you may
use that to index the columns. Finally another important reminder is that unlike
lists, when referencing cells in the CsvSheet you index by column *first* then
row, just as you would a spreadsheet. More details found below and in the
[API Documentation](http://butlermatt.github.io/csv_sheet/).

The Library is available for use on either client or server side applications.
It does not currently rely on any other external packages.

Installation
------------

Add this line to your pubspec.yaml file:

    dependencies:
      csv_sheet: any

Then run `pub get` to download and link the package.

Basic Usage
-----------

First you will need to import the package into your application. Then create
a CsvSheet object passing in the CSV data.

```dart
import 'package:csv_sheet/csv_sheet.dart';
// ...
var sheet = new CsvSheet(data);
```

You can optionally pass `headerRow` if your CSV data contains header information

```dart
var sheet = new CsvSheet(data, headerRow: true);
```

You may also optionally specify field and row separators if you are using
separators such as tabs for field sepators or the file contains Windows carriage
returns `\r\n`.

```dart
var sheet = new CsvSheet(data, headerRow: true, fieldSep: '\t', lineSep: '\r\n');
```

CsvSheet will automatically truncate any extra lines from the input, so long as
they do not contain the field separators contained within the rest of the data.

Assuming the following spreadsheet, we'll look at how we can access the contents
of the cells.

     Sample Spreadsheet
         1    2    3
      .----+----+----.
      |col1|col2|col3|
      +----+----+----+
    1 |  1 |  2 |  3 |
      +----+----+----+
    2 |  4 |  5 |  6 |
      +----+----+----+
    3 |  7 |  8 |  9 |
      '----+----+----'
    csv:
    col1,col2,col3
    1,2,3
    4,5,6
    7,8,9

If this was a normal List and we wanted to access the values stored in
col2 row 3, we would reference it as `list[3][1] == 8` (assuming headers were 
also stored in the list). However with CsvSheet to access the same value, we 
would do so like this:

```dart
var value = sheet[2][3];
// Or alternatively:
var value = sheet['col2'][3];
```

For further details on usage. Check out the [API Documentation](http://butlermatt.github.io/csv_sheet/).

ChangeLog
---------

0.0.1 -- Initial release
0.0.2 -- Added support for quoted fields.

