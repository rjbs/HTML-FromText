use Test::More qw[no_plan];

use_ok( 'HTML::FromText' );

my $html = text2html( <<__TEXT__, paras => 1, bullets => 1, bold => 1 );
* An article on *how* to do test...
---

*With C/C++*
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'mixing bullets should not work' );
<ul>
<li> An article on <strong>how</strong> to do test...
---
</ul>

<p><strong>With C/C++</strong></p>
__HTML__

$html = text2html( <<__TEXT__, paras => 1, urls => 1 );
http://example.com/i-ndex.html#test
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'url with hash' );
<p><a href="http://example.com/i-ndex.html#test">http://example.com/i-ndex.html#test</a></p>
__HTML__

$html = text2html( <<__TEXT__, paras => 1, underline => 1 );
mod_perl/mod_ssl

_foo_

_foo_.
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'complex underlines' );
<p>mod_perl/mod_ssl</p>

<p><u>foo</u></p>

<p><u>foo</u>.</p>
__HTML__

$html = text2html( <<__TEXT__, paras => 1, bold => 1 );
foo*foo*foo

*foo*

*foo*.
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'complex bolds' );
<p>foo*foo*foo</p>

<p><strong>foo</strong></p>

<p><strong>foo</strong>.</p>
__HTML__


$html = text2html( <<__TEXT__, paras => 1, bullets => 1 );
* Fast, powerful and extensible template processing system. 
 *         Powerful presentation language supports all standard templating directives, e.g. variable substitution, includes, conditionals,
          loops. 
   *       Many additional features such as output filtering, exception handling, macro definition, support for plugin objects, definition
          of template metadata, embedded Perl code (only enabled by EVAL_PERL option), definition of template blocks, a 'switch'
          statement, and more. 
   *       Full support for complex Perl data types such as hashes, lists, objects and sub-routine references. 
  *        Clear separation of concerns between user interface (templates), application code (Perl objects/sub-routines) and data
          (Perl data). 
   *       Programmer-centric back end, allowing application logic and data structures to be built in Perl. 
   *       Designer-centric front end, hiding underlying complexity behind simple variable access. 
   *       Templates are compiled to Perl code for maximum runtime efficiency and performance. Compiled templates are cached
          and can be written to disk in "compiled form" (e.g. Perl code) to achieve cache persistance. 
    *      Well suited to online dynamic web content generation (e.g. Apache/mod_perl). 
    *      Also has excellent support for offline batch processing for generating static pages (e.g. HTML, POD, LaTeX, PostScript,
          plain text) from source templates. 
     *     Comprehensive documentation including tutorial and reference manuals. 
     *     Fully Open Source and Free 
__TEXT__
cmp_ok( $html, 'eq', <<__HTML__, 'complex bullets' );
<ul>
<li> Fast, powerful and extensible template processing system. 
 <ul>
 <li>         Powerful presentation language supports all standard templating directives, e.g. variable substitution, includes, conditionals,
          loops. 
   <ul>
   <li>       Many additional features such as output filtering, exception handling, macro definition, support for plugin objects, definition
          of template metadata, embedded Perl code (only enabled by EVAL_PERL option), definition of template blocks, a 'switch'
          statement, and more. 
   <li>       Full support for complex Perl data types such as hashes, lists, objects and sub-routine references. 
   </ul>
  <li>        Clear separation of concerns between user interface (templates), application code (Perl objects/sub-routines) and data
          (Perl data). 
   <ul>
   <li>       Programmer-centric back end, allowing application logic and data structures to be built in Perl. 
   <li>       Designer-centric front end, hiding underlying complexity behind simple variable access. 
   <li>       Templates are compiled to Perl code for maximum runtime efficiency and performance. Compiled templates are cached
          and can be written to disk in &quot;compiled form&quot; (e.g. Perl code) to achieve cache persistance. 
    <ul>
    <li>      Well suited to online dynamic web content generation (e.g. Apache/mod_perl). 
    <li>      Also has excellent support for offline batch processing for generating static pages (e.g. HTML, POD, LaTeX, PostScript,
          plain text) from source templates. 
     <ul>
     <li>     Comprehensive documentation including tutorial and reference manuals. 
     <li>     Fully Open Source and Free 
</ul>
</ul>
</ul>
</ul>
</ul>
__HTML__
