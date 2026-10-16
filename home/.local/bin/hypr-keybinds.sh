#!/bin/sh
# Searchable cheatsheet of all Hyprland binds (keybinds.lua + user overrides).
exec python3 - <<'EOF' | fuzzel --dmenu --prompt="binds: " --width 58 --lines 14 --font="JetBrains Mono NF:size=13" >/dev/null
import os
import re
H = os.getenv('HOME')


def load_vars(path):
    d = {}
    try:
        src = open(path).read()
    except OSError:
        return d
    for m in re.finditer(r'(\w+)\s*=\s*(\{[^{}]*\}|"[^"]*")', src):
        if m.group(1).startswith('kb'):
            d[m.group(1)] = re.findall(r'"([^"]+)"', m.group(2))
    return d


v = load_vars(f'{H}/.config/hypr/variables.lua')
v.update(load_vars(f'{H}/.config/hypr/user/hypr-vars.lua'))


def split_top(s):
    """Split a call's arg string at depth-0 commas (string-aware)."""
    args, depth, cur, q = [], 0, '', None
    i = 0
    while i < len(s):
        c = s[i]
        if q:
            cur += c
            if c == q and s[i - 1] != '\\':
                q = None
        elif c in '"\'':
            q, cur = c, cur + c
        elif c in '([{':
            depth, cur = depth + 1, cur + c
        elif c in ')]}':
            depth, cur = depth - 1, cur + c
        elif c == ',' and depth == 0:
            args.append(cur)
            cur = ''
        else:
            cur += c
        i += 1
    args.append(cur)
    return args


def calls(src, name):
    """Yield full arg-strings of name(...) calls (paren-matched)."""
    out = []
    for m in re.finditer(r'(?:^|[^\w.])' + re.escape(name) + r'\(', src):
        i, depth, q = m.end() - 1, 0, None
        start = i
        while i < len(src):
            c = src[i]
            if q:
                if c == q and src[i - 1] != '\\':
                    q = None
            elif c in '"\'':
                q = c
            elif c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    out.append(src[start + 1:i])
                    break
            i += 1
    return out


def expand(expr):
    if '.. dir' in expr:
        base = 'SUPER + SHIFT + ' if 'SHIFT' in expr.split('..')[0] else 'SUPER + '
        return [base + d for d in ('left', 'right', 'up', 'down')]
    keys = re.findall(r'"([^"]+)"', expr)
    for m in re.findall(r'vars\.(\w+)', expr):
        keys += v.get(m, [])
    return keys


def pretty(action):
    a = ' '.join(action.split())
    if 'wsaction' in a:
        return 'workspace ' + ('move' if '"move"' in a else 'focus') + ' (1-0)'
    m = re.search(r'ukishima\("(\w+)"(?:,\s*"(\w+)")?\)', a)
    if m:
        return 'Ukishima: ' + m.group(1) + (f' {m.group(2)}' if m.group(2) else '')
    if '..' in a:  # Lua string concatenation — summarize by keyword
        if 'launch.sh' in a:
            return 'Ukishima: restart'
        if 'lock.sh' in a:
            return 'lock screen (hyprlock)'
        if 'hypr-keybinds' in a:
            return 'this cheatsheet'
        if 'notify-send' in a:
            return 'send test notification'
        if 'wpctl' in a:
            return 'volume ' + ('up' if '%+' in a else 'down' if '%-' in a else 'mute')
        if 'kill' in a:
            return 'Ukishima: kill'
        first = re.search(r'"([^"]+)"', a)
        return (first.group(1)[:77] + '...') if first else a[:80]
    m = re.search(r'exec_cmd\(\s*\[\[(.*?)\]\]', a, re.S) or re.search(r'exec_cmd\("(.*?)"\)', a, re.S) or re.search(r"exec_cmd\('(.*?)'\)", a, re.S)
    if m:
        t = ' '.join(m.group(1).split())
        return (t[:77] + '...') if len(t) > 80 else t
    m = re.search(r'exec_cmd\(vars\.(\w+)\)', a)
    if m:
        val = v.get(m.group(1), [m.group(1)])
        return (val[0][:77] + '...') if val and len(val[0]) > 80 else (val[0] if val else m.group(1))
    m = re.search(r'hl\.dsp\.([\w.]+)\(', a)
    if m:
        return m.group(1)
    if a.startswith('function'):
        return 'custom action'
    return a[:80]


rows = []
for path in (f'{H}/.config/hypr/modules/keybinds.lua', f'{H}/.config/hypr/user/hypr-user.lua'):
    try:
        src = open(path).read()
    except OSError:
        continue
    for argstr in calls(src, 'create_bind') + calls(src, 'hl.bind'):
        args = split_top(argstr)
        if len(args) < 2:
            continue
        for k in expand(args[0]):
            rows.append((k, pretty(args[1])))
seen, out = set(), []
for k, a in sorted(rows, key=lambda r: re.sub(r'\s+', '', r[0]).lower()):
    if (k, a) not in seen:
        seen.add((k, a))
        out.append(f'{k[:22]:<24} {a[:46]}')
print('\n'.join(out))
EOF
