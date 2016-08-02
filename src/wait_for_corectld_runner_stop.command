#!/bin/bash
#

# wait till corectld.runner stops
while ps aux | grep -w [c]orectld.runner >/dev/null 2>&1; do sleep 1; done

exit 0

