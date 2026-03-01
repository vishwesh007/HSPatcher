import re

path = r'C:\Users\vishw\all_tools\app_mod\HSPatcher\src\in\startv\hspatcher\MainActivity.java'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the entire TRAFFIC MONITORING section (from the comment to APP BACKUP comment)
pattern = r'    // ======================== TRAFFIC MONITORING & BLOCKING TOGGLE ========================.*?// ======================== APP BACKUP ========================'
replacement = '    // ======================== APP BACKUP ========================'
content = re.sub(pattern, replacement, content, flags=re.DOTALL)

# Remove SharedPreferences import if not used elsewhere
content = content.replace('import android.content.SharedPreferences;\n', '')

# Remove btnTrafficToggle field declaration
content = content.replace('    private Button btnTrafficToggle, btnBackup, btnSigner;\n', '    private Button btnBackup, btnSigner;\n')

# Remove trafficMonitorEnabled field
content = content.replace('    private boolean trafficMonitorEnabled = true;\n', '')

# Remove traffic toggle button binding and click listener
content = content.replace(
    '        btnTrafficToggle = findViewById(R.id.btn_traffic_toggle);\n', '')
content = content.replace(
    '        btnTrafficToggle.setOnClickListener(v -> onTrafficToggleClick());\n', '')
content = content.replace(
    '        // Initialize traffic toggle state\n        initTrafficToggleState();\n\n', '')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

# Verify no traffic references remain
remaining = [line for i, line in enumerate(content.split('\n')) 
             if 'traffic' in line.lower() or 'TrafficToggle' in line]
if remaining:
    print(f'WARNING: {len(remaining)} traffic references still remain:')
    for r in remaining:
        print(f'  {r.strip()}')
else:
    print('Java cleaned up - all traffic toggle code removed')
