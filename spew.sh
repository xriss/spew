cd "$(dirname "${BASH_SOURCE[0]}")"

lua spewd.lua 1>>spew.log 2>>spew.err </dev/null &

