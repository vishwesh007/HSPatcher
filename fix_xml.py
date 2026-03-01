import re

path = r'C:\Users\vishw\all_tools\app_mod\HSPatcher\res\layout\activity_main.xml'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the entire btn_traffic_toggle Button block
pattern = r'<Button\s+android:id="@\+id/btn_traffic_toggle"[^/]*/>\s*'
content = re.sub(pattern, '', content, flags=re.DOTALL)

# Also remove android:layout_marginStart from btn_backup since it's now first
content = content.replace(
    'android:layout_marginStart="4dp"\n            android:layout_marginEnd="4dp"',
    'android:layout_marginEnd="4dp"'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print('XML fixed - traffic toggle button removed')
