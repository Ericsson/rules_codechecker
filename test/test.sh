#!/bin/bash
# This file is tied to a CI job and thus can't be changed
python3 -m unittest discover unit $@
