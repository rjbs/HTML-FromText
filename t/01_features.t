BEGIN {
    use Test::More qw[no_plan];
    use_ok 'HTML::FromText';
}

use strict;
use warnings;

my $t2h = HTML::FromText->new;
isa_ok( $t2h, 'HTML::FromText', 'default' );
my $html = $t2h->parse( '<>' );
cmp_ok( $html, 'eq', '&lt;&gt;', 'metachars encoded <> correctly' );


$t2h = HTML::FromText->new({underline => 1});
$html = $t2h->parse( '_underline_' );
cmp_ok( $html, 'eq', '<u>underline</u>', 'underline did' );

$t2h = HTML::FromText->new({underline => 1});
$html = $t2h->parse( "_should\nnot_" );
cmp_ok( $html, 'eq', "_should\nnot_", 'underline should not across lines' );


$t2h = HTML::FromText->new({bold => 1});
$html = $t2h->parse( '*bold*' );
cmp_ok( $html, 'eq', '<strong>bold</strong>', 'bold did' );


$t2h = HTML::FromText->new({urls => 1});
$html = $t2h->parse( 'http://example.com' );
cmp_ok( $html, 'eq', '<a href="http://example.com">http://example.com</a>', 'urls did' );


$t2h = HTML::FromText->new({urls => 1});
$html = $t2h->parse( 'http://example.com/?foo=bar&baz=quux' );
cmp_ok( $html, 'eq', '<a href="http://example.com/?foo=bar&amp;baz=quux">http://example.com/?foo=bar&amp;baz=quux</a>', 'urls and metachars did' );


$t2h = HTML::FromText->new({email => 1});
$html = $t2h->parse( 'casey@geeknest.com' );
cmp_ok( $html, 'eq', '<a href="mailto:casey@geeknest.com">casey@geeknest.com</a>', 'email did' );


$t2h = HTML::FromText->new({pre => 1});
$html = $t2h->parse( 'pre' );
cmp_ok( $html, 'eq', '<pre>pre</pre>', 'pre did' );


$t2h = HTML::FromText->new({lines => 1});
$html = $t2h->parse( "one\ntwo" );
cmp_ok( $html, 'eq', "one<br />\ntwo<br />", 'lines did' );


$t2h = HTML::FromText->new({lines => 1,spaces => 1});
$html = $t2h->parse( "one\n two" );
cmp_ok( $html, 'eq', "one<br />\n&nbsp;two<br />", 'lines and spaces did' );

$t2h = HTML::FromText->new({paras => 1});
$html = $t2h->parse( <<__TEXT__ );
One
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'one paragraph' );
<p>One</p>
__HTML__

$t2h = HTML::FromText->new({paras => 1});
$html = $t2h->parse( <<__TEXT__ );
One

Two
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'two paragraphs' );
<p>One</p>

<p>Two</p>
__HTML__

$t2h = HTML::FromText->new({paras => 1, bullets => 1});
$html = $t2h->parse( <<__TEXT__ );
  * One
  * Two
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'single bullet list' );
  <ul>
  <li> One
  <li> Two
</ul>
__HTML__

$t2h = HTML::FromText->new({paras => 1, bullets => 1});
$html = $t2h->parse( <<__TEXT__ );
- One
  - Half
- Two
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'nested bullet list' );
<ul>
<li> One
  <ul>
  <li> Half
  </ul>
<li> Two
</ul>
__HTML__

$t2h = HTML::FromText->new({paras => 1, bullets => 1, bold => 1});
$html = $t2h->parse( <<__TEXT__ );
* One
  * Half
  * Whole
    * Shabang
      Dude
* Two

*Normal* Text
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'nested bullets and normal paragraph' );
<ul>
<li> One
  <ul>
  <li> Half
  <li> Whole
    <ul>
    <li> Shabang
      Dude
    </ul>
  </ul>
<li> Two
</ul>

<p><strong>Normal</strong> Text</p>
__HTML__

$t2h = HTML::FromText->new({paras => 1, numbers => 1});
$html = $t2h->parse( <<__TEXT__ );
1 One
  1 Half
  2 Whole
    1 Shabang
      Dude
2 Two

Normal Text
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'nested numbers and normal paragraph' );
<ol>
<li> One
  <ol>
  <li> Half
  <li> Whole
    <ol>
    <li> Shabang
      Dude
    </ol>
  </ol>
<li> Two
</ol>

<p>Normal Text</p>
__HTML__

$t2h = HTML::FromText->new({paras => 1, headings => 1});
$html = $t2h->parse( <<__TEXT__ );
1. One

Normal Text

1.1. Sub section

2. Second Top

__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'headings' );
<h1>1. One</h1>

<p>Normal Text</p>

<h2>1.1. Sub section</h2>

<h1>2. Second Top</h1>
__HTML__

$t2h = HTML::FromText->new({paras => 1, title => 1});
$html = $t2h->parse( <<__TEXT__ );
Title

Normal Text
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'title' );
<h1>Title</h1>

<p>Normal Text</p>
__HTML__

$t2h = HTML::FromText->new({paras => 1, blockparas => 1});
$html = $t2h->parse( <<__TEXT__ );
  Test
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'blockparas' );
<blockquote>Test</blockquote>
__HTML__

$t2h = HTML::FromText->new({paras => 1, blockquotes => 1});
$html = $t2h->parse( <<__TEXT__ );
  Test
  This
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'blockquotes' );
<blockquote>Test<br />
This<br />
</blockquote>
__HTML__

$t2h = HTML::FromText->new({paras => 1, blockcode => 1});
$html = $t2h->parse( <<__TEXT__ );
  Test
  This Please

__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'blockcode' );
<blockquote><tt>Test</tt><br />
<tt>This Please</tt><br />
</blockquote>
__HTML__

$t2h = HTML::FromText->new({paras => 1, tables => 1});
$html = $t2h->parse( <<__TEXT__ );
Casey West     Daddy
Chastity West  Mommy
Evelina West   Baby
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'tables' );
<table>
  <tr><td>Casey West</td><td>Daddy</td></tr>
  <tr><td>Chastity West</td><td>Mommy</td></tr>
  <tr><td>Evelina West</td><td>Baby</td></tr>
</table>
__HTML__

$t2h = HTML::FromText->new({paras => 1, tables => 1});
$html = $t2h->parse( <<__TEXT__ );
    Casey West     Daddy
    Chastity West  Mommy
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'indented tables' );
<table>
  <tr><td>Casey West</td><td>Daddy</td></tr>
  <tr><td>Chastity West</td><td>Mommy</td></tr>
</table>
__HTML__

$t2h = HTML::FromText->new({paras => 1, tables => 1});
$html = $t2h->parse( <<__TEXT__ );
    Casey West     Daddy    Tall
    Chastity West  Mommy   Short

Normal Text.
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'indented tables with normal para' );
<table>
  <tr><td>Casey West</td><td>Daddy</td><td>Tall</td></tr>
  <tr><td>Chastity West</td><td>Mommy</td><td>Short</td></tr>
</table>

<p>Normal Text.</p>
__HTML__

$t2h = HTML::FromText->new({paras => 1, tables => 1});
$html = $t2h->parse( <<__TEXT__ );
http://www.pm.org           Perl Mongers
http://perl.com             O'Reilly Perl Center
http://lists.perl.org       List of Mailing Lists
http://use.perl.org         Perl News and Community Journals
http://perl.apache.org      mod_perl
http://theperlreview.com    The Perl Review
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'indented tables with normal para' );
<table>
  <tr><td>http://www.pm.org</td><td>Perl Mongers</td></tr>
  <tr><td>http://perl.com</td><td>O'Reilly Perl Center</td></tr>
  <tr><td>http://lists.perl.org</td><td>List of Mailing Lists</td></tr>
  <tr><td>http://use.perl.org</td><td>Perl News and Community Journals</td></tr>
  <tr><td>http://perl.apache.org</td><td>mod_perl</td></tr>
  <tr><td>http://theperlreview.com</td><td>The Perl Review</td></tr>
</table>
__HTML__

