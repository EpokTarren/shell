#!/bin/sh

cd "$(dirname $0)"

singleton="pragma Singleton
import Quickshell

Singleton {}
"

[[ ! -f Theme.qml ]] && echo "$singleton" > Theme.qml
[[ ! -f Config.qml ]] && echo "$singleton" > Config.qml
