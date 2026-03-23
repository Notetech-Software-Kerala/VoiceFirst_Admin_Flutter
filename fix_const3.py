with open('lib/features/custom_field/presentation/pages/add_custom_field_page.dart', 'r') as f:
    lines = f.readlines()

targets = [157, 260, 285, 360, 397, 404, 495, 514, 665, 740, 858, 883]
for t in targets:
    idx = t - 1
    for i in range(idx, max(-1, idx-10), -1):
        if 'const ' in lines[i]:
            lines[i] = lines[i].replace('const ', '')
            break

with open('lib/features/custom_field/presentation/pages/add_custom_field_page.dart', 'w') as f:
    f.writelines(lines)
