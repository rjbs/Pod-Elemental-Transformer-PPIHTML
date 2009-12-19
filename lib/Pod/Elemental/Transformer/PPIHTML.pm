use 5.010;
package Pod::Elemental::Transformer::PPIHTML;
use Moose;
# ABSTRACT: convert "=begin perl" and shebang-marked blocks to XHTML

use utf8;
use PPI;
use PPI::HTML;

=head1 DESCRIPTION

This transformer looks for regions like this:

  =begin perl

    my $x = 1_00_000 ** $::xyzzy;

  =end perl

...into syntax-highlighted HTML that I can't really usefully represent here.
It uses L<PPI::HTML>, so you can read more about the kind of HTML it will
produce, there.

This form is also accepted, in a verbatim paragraph:

  #!perl
  my $x = 1_00_000 ** $::xyzzy;

In the above example, the shebang-like line will be stripped.

B<Achtung!>  Two leading spaces are stripped from each line of the content to
be highlighted.  This behavior may change and become more configurable in the
future.

=cut

has format_name => (is => 'ro', isa => 'Str', default => 'perl');

sub build_html {
  my ($self, $arg) = @_;
  my $perl = $arg->{content};
  my $opt  = $arg->{options};

  $perl =~ s/^  //gms;

  my $ppi_doc = PPI::Document->new(\$perl);
  my $ppihtml = PPI::HTML->new;
  my $html    = $ppihtml->html( $ppi_doc );

  $opt->{'stupid-hyphen'} and s/-/−/g for $html;

  $html =~ s/<br>\n?/\n/g;

  return $self->standard_code_block( $html );
}

sub parse_synhi_param {
  my ($self, $str) = @_;

  my @keys = split /\s+/, $str;
  return {} unless @keys;

  confess "couldn't parse PPIHTML region parameter"
    if @keys > 1 or $keys[0] ne 'stupid-hyphen';

  return { 'stupid-hyphen' => 1 };
}

with 'Pod::Elemental::Transformer::SynHi';
1;
