# HiveRLE
HiveRLE is a simple run-length encoding compression format written for circumstances where speed is a concern. It was inspired by PackBits with some minor differences that should allow for faster decompression.

Flag | Description
--- | ---
```n = 1 to 127``` | Write the following ```n``` bytes as-is.
```n = -1 to -128``` | Write the next byte ```-n``` times.
```n = 0``` | End of archive.