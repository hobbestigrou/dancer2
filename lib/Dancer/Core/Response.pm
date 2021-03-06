package Dancer::Core::Response;

use strict;
use warnings;
use Carp;
use Moo;
use Dancer::Moo::Types;

use Scalar::Util qw/looks_like_number blessed/;
use Dancer::HTTP;
use Dancer::MIME;
use Dancer::Exception qw(:all);

with 'Dancer::Core::Role::Headers';

# boolean to tell if the route passes or not
has has_passed => (
    is => 'rw',
    isa => sub { Dancer::Moo::Types::Bool(@_) },
    default => 0,
);

has is_encoded => (
    is => 'rw',
    isa => sub { Dancer::Moo::Types::Bool(@_) },
    default => 0,
);

has is_halted => (
    is => 'rw',
    isa => sub { Dancer::Moo::Types::Bool(@_) },
    default => 0,
);

has status => (
    is => 'rw',
    isa => sub { Dancer::Moo::Types::Num(@_) },
    default => sub { 200 },
    coerce => sub {
        my ($status) = @_;
        return $status if looks_like_number($status);
        Dancer::HTTP->status($status);
    },
);

has content => (
    is => 'rw',
    isa => sub { Dancer::Moo::Types::Str(@_) },
    default => '',
);

sub to_psgi {
    my ($self) = @_;

    return [
        $self->status,
        $self->headers_to_array,
        [ $self->content ],
    ];
}

# sugar for accessing the content_type header, with mimetype care
sub content_type {
    my $self = shift;

    if (scalar @_ > 0) {
        my $mimetype = Dancer::MIME->instance();
        $self->header('Content-Type' => $mimetype->name_or_type(shift));
    } else {
        return $self->header('Content-Type');
    }
}

has _forward => (
    is => 'rw',
    isa => sub { Dancer::Moo::Types::HashRef(@_) },
);

sub forward {
    my ($self, $uri, $params, $opts) = @_;
    $self->_forward({to_url => $uri, params => $params, options => $opts});
}

sub is_forwarded {
    my $self = shift;
    $self->_forward;
}

1;
__END__
=head1 NAME

Dancer::Response - Response object for Dancer

TODO ...
