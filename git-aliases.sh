#!/usr/bin/env sh

##
## Set up global git aliases
##

git config --global alias.a add
git config --global alias.b branch
git config --global alias.c commit
git config --global alias.cm 'commit -m'
git config --global alias.cam 'commit -a -m'
git config --global alias.co checkout
git config --global alias.f 'fetch --all'
git config --global alias.l 'log --graph --date=short --pretty="format:%Cred%h%Cblue%d%Creset %s%n %Cgreen %ad, %an <%ce>%n%Cblue┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"'
git config --global alias.m merge
git config --global alias.s 'status -s'
