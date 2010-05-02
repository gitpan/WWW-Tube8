package WWW::Tube8;

use warnings;
use strict;
use Carp qw( croak );

use version; our $VERSION = qv('1.1.3');

use LWP::UserAgent;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(
    qw( flv thumb get_3gp
        url id title title_inurl
        category category_url duration related_videos )
);

sub new {
    my $class = shift;
    my $opt   = shift;
    croak "opt needs hash ref" if ref $opt ne 'HASH';
    my $self = bless $opt, $class;

    $self->{ua} = LWP::UserAgent->new( agent => 'WWW::Tube8' )
        unless $self->{ua};

    croak "url is required" unless $self->url;
    croak "url is wrong (perhaps not movie page of tube8.com)"
        if $self->url !~ m!^http://www.tube8.com/[^/]+/([^/]+)/(\d+)/!;
    $self->title_inurl($1);
    $self->id($2);
    $self->_get_info;

    return $self;
}

sub _get_info {
    my $self = shift;

    my $res = $self->{ua}->get( $self->url );
    croak "can't get tube8 page" unless $res->is_success;
    my $tube8_page = $res->content;

    while ( $tube8_page
        =~ s/flashvars\.(videoUrl|imageUrl) = '([^']+\.(?:flv|jpg))'//
        )
    {
        my ( $key, $value ) = ( $1, $2 );
        if ( $key eq 'videoUrl' ) {
            $self->flv($value);
        }
        else {
            $self->thumb( 'http://www.tube8.com' . $value );
        }
    }
    $self->get_3gp(
        $tube8_page =~ /<a href="([^"]+\.3gp)"/ );
    $self->title( $tube8_page    =~ /<h1 class="main-title main-sprite-img">([^<]+)<\/h1>/ );
    $self->duration( $tube8_page =~ /<strong>Duration: <\/strong>([^<]+)/ );
    $tube8_page
        =~ /<strong>Category: <\/strong><a href='([^']+)'>([^<]+)<\/a>/;
    $self->category_url($1);
    $self->category($2);
    $self->_get_related($tube8_page);
}

sub _get_related {
    my $self       = shift;
    my $tube8_page = shift;

    my @related_videos;
    while ( $tube8_page
        =~ s!<h2><a href="([^"]+)" title="([^"]+)">.+</a></h2>!!
        )
    {
        push @related_videos, { url => $1, title => $2, };
    }
    $self->set('related_videos', @related_videos);
}

1;

__END__


=head1 NAME

WWW::Tube8 - Get video informations from tube8.com


=head1 SYNOPSIS

    use LWP::UserAgent;
    use WWW::Tube8;

    my $ua = LWP::UserAgent->new(
        timeout => 30,
    );

    my $t8 = WWW::Tube8->new({
        url => 'http://www.tube8.com/category/hoge-hoge-/00000/',
        ua  => $ua, # optional
    });

    print $t8->flv          . "\n";
    print $t8->thumb        . "\n";
    print $t8->get_3gp      . "\n";
    print $t8->url          . "\n";
    print $t8->id           . "\n";
    print $t8->title        . "\n";
    print $t8->title_inurl  . "\n";
    print $t8->category     . "\n";
    print $t8->category_url . "\n";
    print $t8->duration     . "\n";
    for my $rv ( @{ $t8->related_videos } ) {
        print "$rv->{title}\t$rv->{url}\n";
    }


=head1 METHOD

=over

=item new(I<$hash_ref>)

Creates a new WWW::Tube8 instance.
required param is url only.
you can get video infomations like follow.

=item flv

=item thumb

=item get_3gp

=item url

=item id

=item title

=item title_inurl

=item category

=item category_url

=item duration

=item related_videos

=back


=head1 AUTHOR

Copyright (c) 2009, Dai Okabayashi C<< <bayashi@cpan.org> >>


=head1 LICENCE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

