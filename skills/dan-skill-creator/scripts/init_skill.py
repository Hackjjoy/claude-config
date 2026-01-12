#!/usr/bin/env python3
"""
Skill Initializer - Creates a new skill from template

Usage:
    init_skill.py <skill-name> --path <path>

Examples:
    init_skill.py my-new-skill --path skills/public
    init_skill.py my-api-helper --path ~/.claude/skills
"""

import sys
from pathlib import Path


SKILL_TEMPLATE = """---
name: {skill_name}
description: [TODO: What the skill does AND when to use it. Include specific triggers.]
---

# {skill_title}

[TODO: Brief overview of what this skill enables]

## Workflow

[TODO: Add workflow steps or task-based sections]

## Resources

- scripts/ - Executable code (delete if unused)
- references/ - Documentation loaded as needed (delete if unused)
- assets/ - Output files like templates (delete if unused)
"""

EXAMPLE_SCRIPT = '''#!/usr/bin/env python3
"""
Example script for {skill_name}
Replace or delete this file.
"""

def main():
    print("Example script for {skill_name}")
    # TODO: Add implementation

if __name__ == "__main__":
    main()
'''

EXAMPLE_REFERENCE = """# Reference for {skill_title}

[TODO: Add reference documentation here or delete this file]

## Usage

This file is loaded into context when Claude needs detailed information.
Keep SKILL.md concise; put detailed docs here.
"""


def title_case_skill_name(skill_name):
    """Convert hyphenated skill name to Title Case."""
    return ' '.join(word.capitalize() for word in skill_name.split('-'))


def init_skill(skill_name, path):
    """Initialize a new skill directory with template SKILL.md."""
    skill_dir = Path(path).resolve() / skill_name

    if skill_dir.exists():
        print(f"Error: Directory already exists: {skill_dir}")
        return None

    try:
        skill_dir.mkdir(parents=True, exist_ok=False)
        print(f"Created: {skill_dir}")
    except Exception as e:
        print(f"Error creating directory: {e}")
        return None

    skill_title = title_case_skill_name(skill_name)

    # Create SKILL.md
    skill_content = SKILL_TEMPLATE.format(
        skill_name=skill_name,
        skill_title=skill_title
    )
    (skill_dir / 'SKILL.md').write_text(skill_content)
    print("Created: SKILL.md")

    # Create resource directories with examples
    try:
        scripts_dir = skill_dir / 'scripts'
        scripts_dir.mkdir(exist_ok=True)
        example_script = scripts_dir / 'example.py'
        example_script.write_text(EXAMPLE_SCRIPT.format(skill_name=skill_name))
        example_script.chmod(0o755)
        print("Created: scripts/example.py")

        references_dir = skill_dir / 'references'
        references_dir.mkdir(exist_ok=True)
        (references_dir / 'reference.md').write_text(
            EXAMPLE_REFERENCE.format(skill_title=skill_title)
        )
        print("Created: references/reference.md")

        assets_dir = skill_dir / 'assets'
        assets_dir.mkdir(exist_ok=True)
        (assets_dir / '.gitkeep').write_text('')
        print("Created: assets/")
    except Exception as e:
        print(f"Error creating resources: {e}")
        return None

    print(f"\nSkill '{skill_name}' initialized at {skill_dir}")
    print("\nNext steps:")
    print("1. Edit SKILL.md - complete TODOs and update description")
    print("2. Customize or delete example files in scripts/, references/, assets/")
    print("3. Run quick_validate.py to check structure")

    return skill_dir


def main():
    if len(sys.argv) < 4 or sys.argv[2] != '--path':
        print("Usage: init_skill.py <skill-name> --path <path>")
        print("\nSkill name: hyphen-case, lowercase, max 64 chars")
        print("\nExamples:")
        print("  init_skill.py my-skill --path ~/.claude/skills")
        print("  init_skill.py api-helper --path ./skills")
        sys.exit(1)

    skill_name = sys.argv[1]
    path = sys.argv[3]

    print(f"Initializing skill: {skill_name}")
    print(f"Location: {path}\n")

    result = init_skill(skill_name, path)
    sys.exit(0 if result else 1)


if __name__ == "__main__":
    main()
