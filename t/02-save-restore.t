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

my $CONT_FILE = '_cont';

my $cont = ex1();
$cont.save($CONT_FILE);

### pretend we shut down and restart the program here
@res = ();
my $cont2 = Continuation::restore($CONT_FILE);

ex1(:cont($cont2));

is_deeply @res, ["bar"], "successfully ran second part after restart";

END { unlink $CONT_FILE }
