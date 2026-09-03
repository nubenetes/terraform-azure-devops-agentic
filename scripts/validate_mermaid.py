#!/usr/bin/env python3
"""
Mermaid Diagram Quality & Text-Clipping Auditor
================================================
Validates all Mermaid diagrams across repository markdown files to prevent:
1. Horizontal and vertical text clipping in nodes (line length > 24 chars).
2. Cylinder shape curve text collision ([("...")] -> [["..."]] or (["..."])).
3. Long edge labels crossing adjacent nodes or subgraph boundaries (> 26 chars).
4. Blank lines inside mermaid code blocks.
5. Deprecated/illegal '&' operators in relationships or headings.

Exit codes:
0: All diagrams pass validation cleanly.
1: One or more diagrams have clipping or syntax violations.
"""

import sys
import os
import re
import subprocess
from collections import defaultdict

MAX_LINE_LENGTH = 24
MAX_EDGE_LENGTH = 26

def parse_diagram(diag_text):
    nodes = []
    cylinders = []
    edges = []
    syntax_errors = []
    
    raw_lines = diag_text.splitlines()
    for idx, line in enumerate(raw_lines):
        if line.strip() == '' and idx > 0 and idx < len(raw_lines) - 1:
            syntax_errors.append(f"Line {idx+1}: Blank line inside mermaid block")
            
        if re.search(r'-->\s*[^&]+&\s*[^&]+', line) or re.search(r'==>\s*[^&]+&\s*[^&]+', line):
            syntax_errors.append(f"Line {idx+1}: Chained relationship with '&' is forbidden (split across lines)")
            
    lines = [l for l in raw_lines if not l.strip().startswith('%%')]
    clean_text = '\n'.join(lines)
    
    # 1. Cylinders: ID[("...")]
    for m in re.finditer(r'(\b\w+\b)\s*\[\(\s*["\']?(.*?)["\']?\s*\)\]', clean_text):
        cylinders.append((m.group(1), m.group(2)))
        
    # 2. Nodes: ID["..."], ID(["..."]), ID[["..."]]
    for line in lines:
        if line.strip().startswith('subgraph '):
            continue
        for m in re.finditer(r'(\b\w+\b)\s*(\[|\(\[|\[\[)\s*["\']?(.*?)["\']?\s*(\]|\)\]|\]\])', line):
            nid = m.group(1)
            raw_text = m.group(3)
            if nid.lower() in ('direction', 'subgraph', 'end', 'class', 'classdef', 'style'):
                continue
            if m.group(2) == '[' and raw_text.startswith('(') and raw_text.endswith(')'):
                continue
            nodes.append((nid, raw_text))
            
        # 3. Edge labels: |...|
        for m in re.finditer(r'\|([^\|]+)\|', line):
            edges.append(m.group(1))
            
    return nodes, cylinders, edges, syntax_errors

def main():
    repo_root = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], text=True).strip()
    os.chdir(repo_root)
    
    md_files = subprocess.check_output(['git', 'ls-files', '*.md'], text=True).splitlines()
    
    total_diagrams = 0
    issues = defaultdict(list)
    
    for f in md_files:
        content = open(f, 'r', encoding='utf-8').read()
        blocks = list(re.finditer(r'```mermaid\n(.*?)```', content, re.DOTALL))
        for b in blocks:
            total_diagrams += 1
            start_line = content[:b.start()].count('\n') + 1
            code = b.group(1)
            nodes, cylinders, edges, syn_errors = parse_diagram(code)
            
            for err in syn_errors:
                issues[f].append((start_line, 'SYNTAX_ERROR', err))
                
            for cid, clabel in cylinders:
                issues[f].append((
                    start_line,
                    'CYLINDER_SHAPE_RISK',
                    f'Node {cid}: Cylinder shape [("{clabel}")] curves slice text in browsers. Use [["{clabel}"]] instead.'
                ))
                
            for nid, raw_label in nodes:
                clean_label = re.sub(r'<(?!\/?br\b)[^>]+>', '', raw_label, flags=re.I)
                text_lines = re.split(r'<br\s*\/?>', clean_label, flags=re.I)
                for tl in text_lines:
                    t = tl.strip()
                    if len(t) > MAX_LINE_LENGTH:
                        issues[f].append((
                            start_line,
                            'NODE_TEXT_OVERFLOW',
                            f'Node {nid}: Line "{t}" is {len(t)} chars (exceeds {MAX_LINE_LENGTH} max). Risk of text clipping.'
                        ))
                        
            for el in edges:
                clean_el = re.sub(r'<(?!\/?br\b)[^>]+>', '', el, flags=re.I)
                edge_lines = re.split(r'<br\s*\/?>', clean_el, flags=re.I)
                for edge_t in edge_lines:
                    et = edge_t.strip()
                    if len(et) > MAX_EDGE_LENGTH:
                        issues[f].append((
                            start_line,
                            'LONG_EDGE_LABEL',
                            f'Edge label "{et}" is {len(et)} chars (exceeds {MAX_EDGE_LENGTH} max). Risk of boundary collision.'
                        ))

    print("=================================================================")
    print("        MERMAID TEXT-CLIPPING & DIAGRAM QUALITY AUDITOR          ")
    print("=================================================================")
    print(f"Audited {total_diagrams} diagrams across {len(md_files)} markdown files.\n")
    
    if not issues:
        print("✅ SUCCESS: All Mermaid diagrams pass validation with 0 issues!")
        print("   - All node text lines <= 24 characters")
        print("   - No cylinder shape text collisions")
        print("   - All edge labels <= 26 characters")
        print("   - No blank lines or forbidden chaining inside mermaid blocks")
        return 0
    else:
        total_issues = sum(len(v) for v in issues.values())
        print(f"❌ FAILED: Found {total_issues} issues across {len(issues)} files:\n")
        for f, f_issues in sorted(issues.items()):
            print(f"File: {f} ({len(f_issues)} issue(s))")
            for line_no, itype, desc in f_issues:
                print(f"  - Line {line_no} [{itype}] {desc}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
