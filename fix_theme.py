import os, glob, re

for file in glob.glob("lib/screens/*.dart") + glob.glob("lib/widgets/*.dart"):
    with open(file, 'r') as f:
        content = f.read()

    # Clean up empty properties caused by previous perl replacement
    content = re.sub(r'backgroundColor:\s*,', '', content)
    content = re.sub(r'backgroundColor:\s*\.withOpacity', 'backgroundColor: Theme.of(context).colorScheme.surface.withOpacity', content)
    content = re.sub(r'color:\s*,', '', content)
    content = re.sub(r'backgroundColor:\s*const Color\(0xFF080B16\),?', '', content)
    
    # Text colors to be theme responsive
    content = re.sub(r'Colors\.white([^\.])', r'Theme.of(context).colorScheme.onSurface\1', content)
    content = re.sub(r'Colors\.white24', r'Theme.of(context).colorScheme.onSurface.withOpacity(0.24)', content)
    content = re.sub(r'Colors\.white54', r'Theme.of(context).colorScheme.onSurface.withOpacity(0.54)', content)

    with open(file, 'w') as f:
        f.write(content)
