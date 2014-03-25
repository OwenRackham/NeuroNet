#!/usr/bin/env perl

use strict;
use warnings;

open(FILE,$ARGV[0]) or die;

while(<FILE>){
    	chomp;
    unless($. == 1){
 	my @line=split(',',$_);
 		print "$line[0]\tEpi4K\tEpilepsy\t$line[1]\n";
 		print "$line[0]\tO'Roak\tAutism\t$line[2]\n";
 		print "$line[0]\tSanders\tAutism\t$line[3]\n";
 		print "$line[0]\tIossifov\tAutism\t$line[4]\n";
 		print "$line[0]\tBroad\tAutism\t$line[5]\n";
 		print "$line[0]\tLigt\tID\t$line[6]\n";
 		print "$line[0]\tRaunch\tID\t$line[7]\n";
 		print "$line[0]\tXu\tSchizophrenia\t$line[8]\n";
 		print "$line[0]\tGulsuner\tSchizophrenia\t$line[9]\n";
 		print "$line[0]\tFromer\tSchizophrenia\t$line[10]\n";
    }   	
}