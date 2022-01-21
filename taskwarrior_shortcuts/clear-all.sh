#!/bin/bash
task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off "$@" modify -NeedToLook -Waiting -Integration -Review -Learn
