#!/bin/bash
export SSH_AUTH_SOCK=$(find /tmp/ -type s -name "agent.*" 2>/dev/null | head -n 1)
/usr/bin/git "$@"
