#!/usr/bin/env bash

set -ex

bin/setup

sudo -E bin/mitamae local $@ recipes/default.rb
