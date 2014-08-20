use v6;
use JSON::Unmarshal;

constant START = 0;
constant FINISH = Inf;

class Continuation {
    has $.n = START;
    has $.finished = False;
    has $.next;

    method goto($!next) {
    }

    method save($file) {
        spurt $file,
            sprintf '{ "n" : %d, "finished" : %s }', $.n, $.finished.lc;
    }

    our sub restore($file) {
        return unmarshal(slurp($file), Continuation);
    }
}

my class Part {
    has $.n;
    has &.block;

    method run($cont) {
        &.block.($cont);
    }
}

class X::Continuation::Finished is Exception {
    method message { "Continuation is spent" }
}

class X::Continuation::NoDestinationSet is Exception {
    method message { "No destination set" }
}

sub build_resumable(*@parts) is export {
    return sub (:$cont = Continuation.new) {
        die X::Continuation::Finished.new
            if $cont.finished;
        my $n = $cont.n;
        @parts[$n].run($cont);
        die X::Continuation::NoDestinationSet.new
            unless defined $cont.next;
        my $finished = $cont.next == FINISH;
        return Continuation.new(:n($cont.next), :$finished);
    };
}

sub part(Int $n, &block) is export {
    return Part.new(:$n, :&block);
}
