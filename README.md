Just another ASCII art box generator for Perl, this time with Unicode box symbols!

## See Also

* https://metacpan.org/module/Text::Table

```perl
use Text::Table;
my $tb = Text::Table->new(
    "Planet", "Radius\nkm", "Density\ng/cm^3"
);
$tb->load(
    [ "Mercury", 2360, 3.7 ],
    [ "Venus", 6110, 5.1 ],
    [ "Earth", 6378, 5.52 ],
    [ "Jupiter", 71030, 1.3 ],
);
print $tb;
```

* https://metacpan.org/module/Text::TabularDisplay

```perl

```

* https://metacpan.org/module/Text::Table::Tiny 

```perl

```

* https://metacpan.org/module/Text::SimpleTable

```perl

```

* https://metacpan.org/module/Text::FormatTable

```perl
my $table = Text::FormatTable->new('r|l');
$table->head('a', 'b');
$table->rule('=');
$table->row('c', 'd');
print $table->render(20);
```

* https://metacpan.org/module/Text::SpanningTable

```perl
# create a table object with four columns of varying widths
my $t = Text::SpanningTable->new(10, 20, 15, 25);
 
# enable auto-newline adding
$t->newlines(1);
 
# print a top border
print $t->hr('top');
 
# print a row (with header information)
print $t->row('Column 1', 'Column 2', 'Column 3', 'Column 4');
 
# print a double horizontal rule
print $t->dhr; # also $t->hr('dhr');
 
# print a row of data
print $t->row('one', 'two', 'three', 'four');
 
print $t->hr;
 
# print another row, with one column that spans all four columns
print $t->row([4, 'Creedance Clearwater Revival']);
 
print $t->hr;
 
# print a row with the first column normally and another column
# spanning the remaining three columns
print $t->row(
        'normal column',
        [3, 'this column spans three columns and also wraps to the next line.']
);
 
# finally, print the bottom border
print $t->hr('bottom');
 
# the output from all these commands is:
.----------+------------------+-------------+-----------------------.
| Column 1 | Column 2         | Column 3    | Column 4              |
+==========+==================+=============+=======================+
| one      | two              | three       | four                  |
+----------+------------------+-------------+-----------------------+
| Creedance Clearwater Revival                                      |
+----------+------------------+-------------+-----------------------+
| normal   | this column spans three columns and also wraps to the  |
|          | next line.                                             |
'----------+------------------+-------------+-----------------------'
```

* https://metacpan.org/module/Text::UnicodeTable::Simple

```perl
use Text::UnicodeTable::Simple;
$t = Text::UnicodeTable::Simple->new();
 
$t->set_header(qw/Subject Score/);
$t->add_row('English',     '78');
$t->add_row('Mathematics', '91');
$t->add_row('Chemistry',   '64');
$t->add_row('Physics',     '95');
$t->add_row_line();
$t->add_row('Total', '328');
 
print "$t";
 
# Result:
.-------------+-------.
| Subject     | Score |
+-------------+-------+
| English     |    78 |
| Mathematics |    91 |
| Chemistry   |    64 |
| Physics     |    95 |
+-------------+-------+
| Total       |   328 |
'-------------+-------'
```
