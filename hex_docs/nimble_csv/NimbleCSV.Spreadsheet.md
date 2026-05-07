# NimbleCSV.Spreadsheet

A parser with spreadsheet friendly settings.

The parser uses tab as separator and double-quotes as escape, as required by
common spreadsheet software such as Excel, Numbers and OpenOffice. It's encoded
in UTF-16 little-endian with a byte-order BOM.

Such files should still be saved with the `.csv` extension.