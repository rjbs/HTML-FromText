require 5.004;
use strict;

package HTML::FromText;
use Exporter;
use Text::Tabs 'expand';
use vars qw($RCSID $VERSION @EXPORT @ISA);

@ISA = qw(Exporter);
@EXPORT = qw(text2html);
$RCSID = q$Id: FromText.pm,v 1.12 1999/06/07 12:35:55 garethr Exp $;
$VERSION = '1.004';

# This list of protocols is taken from RFC 1630: "Universal Resource
# Identifiers in WWW".  The protocol "file" is omitted because
# experience suggests that it results in many false positives; "https"
# postdates RFC 1630.  The protocol "mailto" is handled separately, by
# the email address matching code.

my $protocol = join '|',
  qw(afs cid ftp gopher http https mid news nntp prospero telnet wais);

# The regular expressions matching email addresses use the following
# syntax elements from RFC 822.  Because HTML::FromText has to spot
# email addresses, not just verify them, I can't use the full details
# of structured field bodies (see
# http://www.perl.com/CPAN/authors/Tom_Christiansen/scripts/ckaddr.gz
# for more robust verification of email addresses).
#
#   addr-spec   =  local-part "@" domain
#   local-part  =  word *("." word)
#   word        =  atom
#   domain      =  sub-domain *("." sub-domain)
#   sub-domain  =  domain-ref
#   domain-ref  =  atom
#   atom        =  1*<any CHAR except specials, SPACE and CTLs>
#   specials    =  "(" / ")" / "<" / ">" / "@" /  "," / ";" / ":" / "\"
#   		   / <"> /  "." / "[" / "]"
#
# I have ignored quoting, domain literals and comments.
#
# Note that '&' can legally appear in email addresses (for example,
# 'fred&barney@stonehenge.com').  If the 'metachars' option is passed to
# text2html then I must use '&amp;' to recognize '&'.  Thus the regular
# expression $atom[0] recognizes an atom in the case where the option
# 'metachars' is false; $atom[1] recognizes an atom in the case where
# 'metachars' is true.  Similarly for the regular expressions $email[0]
# and $email[1], which recognize email addresses.

my @atom =
  ( '[!#$%&\'*+\\-/0123456789=?ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`abcdefghijklmnopqrstuvwxyz{|}~]+',
    '(?:&amp;|[!#$%\'*+\\-/0123456789=?ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`abcdefghijklmnopqrstuvwxyz{|}~])+' );

my @email = ( "$atom[0](\\.$atom[0])*\@$atom[0](\\.$atom[0])*",
	      "$atom[1](\\.$atom[1])*\@$atom[1](\\.$atom[1])*" );

my @alignments = ( '', '', ' ALIGN="RIGHT"', ' ALIGN="CENTER"' );

sub string2html ($$) {
  my $options = $_[1];
  for ($_[0]) {			# Modify in-place.

    # METACHARS: mark up HTML metacharacters as corresponding entities.
    if ($options->{metachars}) {
      s/&/&amp;/g;
      s/</&lt;/g;
      s/>/&gt;/g;
      s/\"/&quot;/g;
    }

    # EMAIL, URLS: spot electronic mail addresses and turn them into
    # links.  Note (1) if `urls' is set but not `email', then only
    # addresses prefixed by `mailto:' will be marked up; (2) that we leave
    # the `mailto:' prefix in the anchor text.
    if ($options->{email} or $options->{urls}) {
      s|((?:mailto:)?)($email[$options->{metachars}?1:0])|
	($options->{email} or $1)
	  ? "<TT><A HREF=\"mailto:$2\">$1$2</A></TT>" : $2|gex;
    }

    # URLS: mark up URLs as links (note that `mailto' links are handled
    # above).
    if ($options->{urls}) {
      s|\b((?:$protocol):\S+[\w/])|<TT><A HREF="$1">$1</A></TT>|g;
    }

    # BOLD: mark up words in *asterisks* as bold.
    if ($options->{bold}) {
      s#(^|\W)\*(\w+)\*(\W|$)#$1<B>$2</B>$3#g;
    }

    # UNDERLINE: mark up words in _underscores_ as underlined.
    if ($options->{underline}) {
      s#(^|\W)_(\w+)_(\W|$)#$1<U>$2</U>$3#g;
    }
  }

  return $_[0];
}

sub text2html {
  local $_ = shift;		# Take a copy; don't modify in-place.
  return $_ unless $_;

  my %options = ( metachars => 1, @_ );

  # Expand tabs.
  $_ = join "\n", expand(split /\r?\n/);

  # PRE: put text in <PRE> element.
  if ($options{pre}) {
    string2html($_, \%options);
    s|^|<PRE>|;
    s|$|</PRE>|;
  }

  # LINES: preserve line breaks from original text.
  elsif ($options{lines}) {
    string2html($_, \%options);
    s/\n/<BR>\n/gm;

    # SPACES: preserve spaces from original text.
    s/ /&nbsp;/g if $options{spaces};
  }

  # PARAS: treat text as sequence of paragraphs.
  elsif ($options{paras}) {
    my @paras;

    # Remove initial and final blank lines.
    s/^(?:\s*?\n)+//;
    s/(?:\n\s*?)+$//;

    # Split on a different regexp depending on what kinds of paragraphs
    # will be recognised later.  The idea is that bulleted lists like
    # this:
    #
    #     * item 1
    #     * item 2
    #
    # will be recognised as multiple paragraphs if the 'bullets' option
    # is supplied, but as a single paragraph otherwise.  (Similarly for
    # numbered lists).
    if ($options{bullets} and $options{numbers}) {
      @paras = split
	/(?:\s*\n)+                  # (0 or more blank lines, followed by LF)
         (?:\s*\n                    # Either 1 or more blank lines, or
          |(?=\s*[*-]\s+             #   bulleted item follows, or
            |\s*(?:\d+)[.\)\]]?\s+)) #   numbered item follows
        /x;
    } elsif ($options{bullets}) {
      @paras = split
	/(?:\s*\n)+                  # (0 or more blank lines, followed by LF)
         (?:\s*\n                    # Either 1 or more blank lines, or
          |(?=\s*[*-]\s+))           #   bulleted item follows.
        /x;
    } elsif ($options{numbers}) {
      @paras = split
	/(?:\s*\n)+                  # (0 or more blank lines, followed by LF)
         (?:\s*\n                    # Either 1 or more blank lines, or
         |(?=\s*(?:\d+)[.\)\]]?\s+)) #   numbered item follows.
        /x;
    } else {
      @paras = split
	/\s*\n(?:\s*\n)+	     # 1 or more blank lines.
        /x;
    }

    my $last = '';		# List type (OL/UL) of last paragraph
    my $this;			# List type (OL/UL) of this paragraph
    my $first = 1;		# True if this is first paragraph

    foreach (@paras) {
      my (@rows,@starts,@ends);
      $this = '';

      # TITLE: mark up first paragraph as level-1 heading.
      if ($options{title} and $first) {
	string2html($_,\%options);
	s|^|<H1>|;
	s|$|</H1>|;
      }

      # HEADINGS: mark up paragraphs with numbers at the start of the
      # first line as headings.
      elsif ($options{headings} and /^(\d+(\.\d+)*)\.?\s/) {
	my $number = $1;
	my $level = 1 + ($number =~ tr/././);
	$level = 6 if $level > 6;
	string2html($_,\%options);
	s|^|<H$level>|;
	s|$|</H$level>|;
      }

      # BULLETS: mark up paragraphs starting with bullets as items in an
      # unnumbered list.
      elsif ($options{bullets} and /^\s*[*-]\s+/) {
	string2html($_,\%options);
        s/^\s*[*-]\s+/<LI><P>/;
	s|$|</P>|;
	$this = 'UL';
      }

      # NUMBERS: mark up paragraphs starting with numbers as items in a
      # numbered list.
      elsif ($options{numbers} and /^\s*(\d+)[.\)\]]?\s+/) {
	string2html($_,\%options);
        s/^\s*(\d+)[.\)\]]?\s+/<LI VALUE="$1"><P>/;
	s|$|</P>|;
	$this = 'OL';
      }

      # TABLES: spot and mark up tables.  We combine the lines of the
      # paragraph using the string bitwise or (|) operator, the result
      # being in $spaces.  A character in $spaces is a space only if
      # there was a space at that position in every line of the
      # paragraph.  $space can be used to search for contiguous spaces
      # that occur on all lines of the paragraph.  If this results in at
      # least two columns, the paragraph is identified as a table.
      #
      # Note that this option appears before the various 'blockquotes'
      # options because a table may well have whitespace to the left, in
      # which case it must not be incorrectly recognised as a
      # blockquote.
      elsif ($options{tables} and do {
	@rows = split /\n/, $_;
	my $spaces;
	my $max = 0;
	my $min = length;
	foreach my $row (@rows) {
	  ($spaces |= $row) =~ tr/ /\xff/c;
	  $min = length $row if length $row < $min;
	  $max = length $row if $max < length $row;
	}
	$spaces = substr $spaces, 0, $min;
	push(@starts, 0) unless $spaces =~ /^ /;
	while ($spaces =~ /((?:^| ) +)(?=[^ ])/g) {
	  push @ends, pos($spaces) - length $1;
	  push @starts, pos($spaces);
	}
	shift(@ends) if $spaces =~ /^ /;
	push(@ends, $max);

	# Two or more rows and two or more columns indicate a table.
	2 <= @rows and 2 <= @starts
      }) {
	# For each column, guess whether it should be left, centre or
	# right aligned by examining all cells in that column for space
        # to the left or the right.  A simple majority among those cells
        # that actually have space to one side or another decides (if no
        # alignment gets a majority, left alignment wins by default).

	my @align;
	foreach my $col (0 .. $#starts) {
	  my @count = (0, 0, 0, 0);
          foreach my $row (@rows) {
	    my $width = $ends[$col] - $starts[$col];
	    my $cell = substr $row, $starts[$col], $width;
	    ++ $count[($cell =~ /^ / ? 2 : 0)
		      + ($cell =~ / $/ || length($cell) < $width ? 1 : 0)];
	  }
	  $align[$col] = 0;
	  my $population = $count[1] + $count[2] + $count[3];
	  foreach (1 .. 3) {
	    if ($count[$_] * 2 > $population) {
	      $align[$col] = $_;
	      last;
	    }
	  }
        }

	foreach my $row (@rows) {
	  $row = join '', '<TR>', (map {
	    my $cell = substr $row, $starts[$_], $ends[$_] - $starts[$_];
	    $cell =~ s/^ +//;
	    $cell =~ s/ +$//;
            string2html($cell,\%options);
	    ('<TD', $alignments[$align[$_]], '>', $cell, '</TD>')
	  } 0 .. $#starts), '</TR>';
	}
	my $tag = $starts[0] == 0 ? 'P' : 'BLOCKQUOTE';
	$_ = join "\n", "<$tag><TABLE>", @rows, "</TABLE></$tag>";
      }

      # BLOCKPARAS, BLOCKCODE, BLOCKQUOTES: mark up indented paragraphs
      # as block quotes of various kinds.
      elsif (($options{blockparas} or $options{blockquotes}
		or $options{blockcode}) and /^(\s+).*(?:\n\1.*)*$/) {
	string2html($_,\%options);

	# Every line in the paragraph starts with at white space, the common
	# whitespace being in $1.  Remove the common initial whitespace,
	s/^$1//gm;

	# BLOCKPARAS: treat as a paragraph.
	if ($options{blockparas}) {
          s|^|<P>|;
          s|$|</P>|;
	}

	# BLOCKCODE, BLOCKQUOTES: preserve line breaks.
	else {
	  s/\n/<BR>\n/gm;

	  # BLOCKCODE: preserve spaces, use fixed-width font.
	  if ($options{blockcode}) {
	    s| |&nbsp;|g;
            s|^|<TT>|;
	    s|$|</TT>|;
	  }
	}
        s|^|<BLOCKQUOTE>|;
        s|$|</BLOCKQUOTE>|;
      }

      # Didn't match any of the above, so just an ordinary paragraph.
      else {
        string2html($_,\%options);
	s|^|<P>|;
	s|$|</P>|;
      }

      # Insert <UL>, </UL>, <OL> or </OL> if this paragraph belongs to a
      # different list type than the previous one.
      if ($this ne $last) {
	s|^|<$this>| if ($this ne '');
	s|^|</$last>| if ($last ne '');
      }
      $last = $this;
      $first = 0;
    }
    if ($this ne '') {
      push @paras, "</$this>";
    }
    $_ = join "\n", @paras;
  }

  # None of PRE, LINES, PARAS specified: apply basic transformations.
  else {
    string2html($_,\%options);
  }
  return $_;
}

1;
