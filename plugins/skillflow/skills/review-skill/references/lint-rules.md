# Lint Rules

Structural validation checks for skills. Each check reports PASS, WARN, or FAIL.

- **PASS** — meets the requirement
- **WARN** — technically valid but below recommended thresholds
- **FAIL** — invalid or missing

## Contents

- [Skills](#skills)
- [Settings.json](#settingsjson)
- [Common Issues](#common-issues)

## Skills

| Check              | PASS                                                         | WARN                            | FAIL                                 |
| ------------------ | ------------------------------------------------------------ | ------------------------------- | ------------------------------------ |
| Frontmatter syntax | Valid YAML, documented fields only                           | —                               | Invalid YAML or undocumented fields  |
| Name format        | Lowercase, hyphens, ≤64 chars, matches directory             | —                               | Invalid chars, too long, or mismatch |
| Description        | 200–1024 chars, three-part pattern, third-person prose       | 50–199 chars or missing pattern | Missing, <50 chars, or >1024 chars   |
| File organization  | SKILL.md present, refs in `references/`, assets in `assets/` | —                               | Missing SKILL.md or orphaned files   |
| Size budget        | SKILL.md <200 lines                                          | 200–500 lines                   | >500 lines with no reference files   |

**Documented frontmatter fields:** `name`, `description`, `argument-hint`, `disable-model-invocation`,
`user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `shell`

## Settings.json

| Check             | PASS                  | WARN                             | FAIL                           |
| ----------------- | --------------------- | -------------------------------- | ------------------------------ |
| Skill permissions | Match existing skills | Stale entries for renamed skills | Permissions for deleted skills |

## Common Issues

**Skills**

- "When to use" section in body instead of frontmatter description — hurts discoverability
- Description too short (<50 chars) or keyword-list format instead of prose
- SKILL.md >500 lines without reference files (violates progressive disclosure)
- Non-standard frontmatter fields or wrong field names (`user_invocable` vs `user-invocable`)
