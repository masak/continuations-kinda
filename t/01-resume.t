use v6;
use Test;

use Continuations::Kinda;

# resumable sub ex1 {
#     say "if you turn on your water boiler...";
#     pause;
#     say "...the water should be boiling just about now";
# }

my @res;

my &ex1 = build_resumable(
    part(START, -> $cont {
        push @res, "foo";
        $cont.goto(1);
    }),
    part(1, -> $cont {
        push @res, "bar";
        $cont.goto(FINISH);
    });
);

my $cont = ex1();
is_deeply @res, ["foo"], "first half called";

$cont = ex1(:$cont);
is_deeply @res, ["foo", "bar"], "second half called";

ok $cont.finished, "it's finished now";

throws_like { ex1(:$cont) }, X::Continuation::Finished, "and trying to call it again fails";
