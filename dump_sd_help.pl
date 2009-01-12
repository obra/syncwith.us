#!/usr/bin/perl 
# Process sd help output to put on the website (Mason/html)
use strict;
use warnings;

open GETHELP, 'sd help |' ;
my @cmds;

# grab what helps exist from the help index
while (<GETHELP>) {
    next if !m/sd help /;
    (undef, undef, my $cmd, undef, my $desc) = split ' ', $_, 5;
    # push @cmds, [$cmd, $desc];
    push @cmds, $cmd;
}

close GETHELP;

# @cmds = ('environment'); # debug

print "<&| /_elements/wrapper, title => 'Using SD' &>\n"; # mason header

for (@cmds) {
    open my $cmd, "sd help $_ |";
    my $text = slurp($cmd);

    # now we can do the real processing
    print process_help($text);
}

print "\n</&>\n"; # mason footer

sub process_help {
    my ( $text ) = shift;

    # escape any non-HTML-safe characters that might exist
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;

    # linkify http links, adapted from MRE 74
    $text =~ s{
        \b
        # Capture the URL to $1
        (
            # hostname
            http:// (?!example) [-a-z0-9]+(\.[-a-z0-9]+)*\.(com|org|us) \b
            (
                / [-a-z0-9_:\@&?=?=+,.!/~*`%\$]* # optional path
            )?
        )
    }{<a href="$1">$1</a>}gix;

    # strip off extraneous leading newlines and convert the header into a
    # headline
    $text =~ s/^\n+sd 0.01 - (.*)\n-+\n+/\n<h2>$1<\/h2>\n\n/;

    # strip off any lines that read 'see 'sd help $cmd'' which isn't
    # really appropriate for this as all the helpfiles are being displayed
    # in one place
    $text =~ s/^.*?(?=see 'sd help).*?$//mg;

    # XXX my god this stuff is ugly and probably also not quite right
    # put paragraph markers around paragraphs
    $text =~ s/^(\S+.*?)(\n\n|\n$)/\n<p>$1<\/p>\n/mgs;

    # put codeblock markers around code blocks
    $text =~ s/^ {4}(\S+.*)(?!(?:^\S+|^ {6}\S+|^\s*$))/<blockquote class="code"><code>$1<\/code><\/blockquote>/mg;

    # TODO: put code annotation markup around code annotations (lines indented
    # by 6 spaces in the raw help (this markup doesn't exist yet in the CSS)

    return $text;
}    # process_help_file

sub slurp {
    my $fh = shift;
    local( $/ ) ;
    my $text = <$fh>;

    return $text;
}
