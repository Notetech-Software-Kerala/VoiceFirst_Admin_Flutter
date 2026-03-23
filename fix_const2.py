import re
with open('lib/features/custom_field/presentation/pages/add_custom_field_page.dart', 'r') as f:
    text = f.read()

# Replace const before specific common widgets that are now dynamic
patterns = [
    r'const\s+(Text\([^;]*?context\.[^;]*?\))',
    r'const\s+(TextStyle\([^;]*?context\.[^;]*?\))',
    r'const\s+(Icon\([^;]*?context\.[^;]*?\))',
    r'const\s+(BorderSide\([^;]*?context\.[^;]*?\))',
    r'const\s+(BoxDecoration\([^;]*?context\.[^;]*?\))',
    r'const\s+(InputDecoration\([^;]*?context\.[^;]*?\))',
    r'const\s+(Row\([^;]*?context\.[^;]*?\))',
    r'const\s+(Border\([^;]*?context\.[^;]*?\))',
]

for p in patterns:
    text = re.sub(p, r'\1', text, flags=re.DOTALL)

with open('lib/features/custom_field/presentation/pages/add_custom_field_page.dart', 'w') as f:
    f.write(text)
