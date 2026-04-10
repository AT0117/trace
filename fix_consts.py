import os, glob, re

for file in glob.glob("lib/screens/*.dart") + glob.glob("lib/widgets/*.dart"):
    with open(file, 'r') as f:
        content = f.read()

    # fix design_system.dart static const
    if "design_system.dart" in file:
        content = content.replace("static const Color lightSurface = Theme.of(context).colorScheme.onSurface;", "static const Color lightSurface = Color(0xFFFFFFFF);")

    # remove const before TextStyle if it contains Theme.of(context)
    content = re.sub(r'const\s+TextStyle\(([^)]*Theme\.of\(context\)[^)]*)\)', r'TextStyle(\1)', content)
    
    # remove const before Text if it contains Theme.of(context) directly or inside style
    content = re.sub(r'const\s+Text\(([^)]*Theme\.of\(context\)[^)]*)\)', r'Text(\1)', content)
    
    # remove const before Icon if it contains Theme.of(context)
    content = re.sub(r'const\s+Icon\(([^)]*Theme\.of\(context\)[^)]*)\)', r'Icon(\1)', content)
    
    # fix withValues warning since we're here
    content = content.replace(".withOpacity(", ".withValues(alpha: ")

    with open(file, 'w') as f:
        f.write(content)

