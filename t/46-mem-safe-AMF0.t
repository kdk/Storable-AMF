use lib 't';
use ExtUtils::testlib;
use Storable::AMF0 qw(freeze thaw ref_lost_memory ref_clear);
use Scalar::Util qw(refaddr);
use GrianUtils qw(ref_mem_safe);
use strict;
use warnings;
no warnings 'once';
use Data::Dumper;
our $msg;
sub tt(&);
sub tt(&){
    my $sub = shift;
    my $s = ref_mem_safe( $sub );
    $msg = $s;
    return $s if $s;
    return undef;
}


my $directory = qw(t/AMF0);
my @item ;
@item = GrianUtils->my_items($directory);


my @objs = grep !ref_lost_memory( $_->{obj} ), @item;;
my @recurrent = grep ref_lost_memory( $_->{obj} ), @item;
my $total = @item*1 + @objs*4 + @recurrent;
eval "use Test::More tests=>$total;";
warn $@ if $@;


my ($name, $obj, $image_amf3, $image_amf0);
sub get_item{
	($name, $obj, $image_amf3, $image_amf0) = @{ $_[0] }{qw(name obj amf3 amf0 eval)};
}
TEST_LOOP: for my $item (@recurrent){
		get_item( $item );
        ok(tt { my $a = thaw $image_amf0, 1;; 1}, "thaw $name - $msg - recurrent");
};

TEST_LOOP: for my $item (@item){
		get_item( $item );
        my $freeze = freeze $obj;        
        
        # ok(tt { my $a = thaw $image_amf0;ref_clear($a); 1}, "thaw destroy $item - $msg");
        ok(tt { my $a = thaw( $image_amf0);ref_clear($a); 1}, "thaw(strict) destroy $name - $msg");
}
TEST_LOOP: for my $item (@objs){
		get_item( $item );
        my $freeze = freeze $obj;        
        my $a1 = $freeze;
        my $a2 = $freeze;
        
        ok(tt { my $a = thaw $image_amf0; 1}, "thaw $name - $msg");
        ok(tt { my $a = freeze $obj; 1},  "freeze $name - $msg");
        ok(tt { my $a = thaw freeze $obj;$a = undef;1},  "thaw freeze $name - $msg");
        ok(tt { my $a = freeze thaw $image_amf0;1 },  "freeze thaw $name - $msg");
}


