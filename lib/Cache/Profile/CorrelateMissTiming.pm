package Cache::Profile::CorrelateMissTiming;
BEGIN {
  $Cache::Profile::CorrelateMissTiming::AUTHORITY = 'cpan:NUFFIN';
}
BEGIN {
  $Cache::Profile::CorrelateMissTiming::VERSION = '0.02';
}
use Moose;

use Guard;
use Time::HiRes qw(tv_interval clock gettimeofday);

use namespace::autoclean;

extends qw(Cache::Profile);

has _last_get_timing => (
    traits => [qw(Hash)],
    isa => "HashRef",
    is => "rw",
    handles => {
        _missed_key => "delete",
        _clear_missed => "clear",
    },
);

has _in_compute => (
    isa => "Bool",
    is  => "rw",
);

sub compute {
    my $self = shift;

    scope_guard {
        $self->_in_compute(0);
    };

    $self->_in_compute(1);

    $self->SUPER::compute(@_);
}

sub clear {
    my $self = shift;

    $self->_clear_missed;

    $self->SUPER::clear(@_);
}

sub _record_get {
    my ( $self, %args ) = @_;

    $self->SUPER::_record_get(%args);

    return if $self->_in_compute;

    my ( @keys, @ret );

    if ( $self->cache->isa("Cache::Ref") ) {
        # mget by default
        @keys = @{ $args{args} };
        @ret  = @{ $args{ret} };
    } else {
        @keys = ( $args{args}[0] );
        @ret  = ( $args{ret}[0] );
    }

    my %timing;
    my %data;
    for ( my $i = 0; $i < @keys; $i++ ) {
        my ( $key, $value ) = ( $keys[$i], $ret[$i] );

        unless ( defined $value ) {
            $data{$key} = \%timing,
        }
    }

    $self->_last_get_timing(\%data);

    $timing{start_r} = [gettimeofday];
    $timing{start_c} = clock;
}

sub _record_set {
    my ( $self, %args ) = @_;

    unless ( $self->_in_compute ) {
        my %pairs = @{ $args{args} };

        foreach my $key ( keys %pairs ) {
            if ( my $start_timing = $self->_missed_key($key) ) {
                my $set_timing = $args{timing};

                my %timing = (
                    start_c => $start_timing->{start_c},
                    end_c => $set_timing->{start_c},
                    time_c => $set_timing->{start_c} - $start_timing->{start_c},
                    start_r => $start_timing->{start_r},
                    end_r => $set_timing->{end_r},
                    time_r => tv_interval($start_timing->{start_r}, $set_timing->{end_r}),
                );

                $self->_record_miss(
                    %args,
                    counter => "miss",
                    timing => \%timing,
                );
            }
        }
    }

    $self->SUPER::_record_set(%args);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__;


# ex: set sw=4 et:

__END__
=pod

=encoding utf-8

=head1 NAME

Cache::Profile::CorrelateMissTiming

=head1 SYNOPSIS

    # see Cache::Profile

=head1 DESCRIPTION

This class will make a guess at the time it took to generate values, by saving
the time just before returning from a C<get> with a cache miss, until the
begining of a C<set>.

This value is a guess and may be completely wrong.

It also fails to account for the overhead of profiling/delegating/etc, so it's
only really useful when the cost of a cache miss is more than a simple
computation.

Otherwise it works exactly like C<Cache::Profile>

=head1 NAME

Cache::Profile::CorrelateMissTiming - Guess the time to compute a cache miss by
correlating C<set> and C<get>

=head1 AUTHOR

Yuval Kogman

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Yuval Kogman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

