import re

with open('lib/features/custom_field/presentation/pages/add_custom_field_page.dart', 'r') as f:
    text = f.read()

# Replace const TextStyle(...context...)
text = re.sub(r'const\s+TextStyle\s*\(\s*color:\s*context\.', r'TextStyle(color: context.', text)
text = re.sub(r'const\s+BorderSide\s*\(\s*color:\s*context\.', r'BorderSide(color: context.', text)
text = re.sub(r'const\s+Icon\s*\(\s*([^,]+),\s*(?:size:\s*\d+,\s*)?color:\s*context\.', r'Icon(\1, color: context.', text)
text = re.sub(r'const\s+Icon\s*\(\n\s*([^,]+),\n\s*size:\s*\d+,\n\s*color:\s*context\.', r'Icon(\n\1, \ncolor: context.', text)

with open('lib/features/custom_field/presentation/pages/add_custom_field_page.dart', 'w') as f:
    f.write(text)

