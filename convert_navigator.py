import re
import os

# List of emergency screen files to convert
files = [
    r"lib\features\emergency\screens\members\snake_identification_screen.dart",
    r"lib\features\emergency\screens\members\snake_identification_result_screen.dart",
    r"lib\features\emergency\screens\members\snake_selection_by_location_screen.dart",
    r"lib\features\emergency\screens\members\snake_identification_questions_screen.dart",
    r"lib\features\emergency\screens\members\snake_filtered_results_screen.dart",
    r"lib\features\emergency\screens\members\snake_confirmation_screen.dart",
    r"lib\features\emergency\screens\members\generic_first_aid_screen.dart",
    r"lib\features\emergency\screens\members\first_aid_steps_screen.dart",
    r"lib\features\emergency\screens\members\symptom_report_screen.dart",
    r"lib\features\emergency\screens\members\severity_assessment_screen.dart",
    r"lib\features\emergency\screens\members\emergency_tracking_screen.dart",
    r"lib\features\emergency\screens\members\rescuer_arrived_screen.dart",
    r"lib\features\emergency\screens\members\emergency_service_completion_screen.dart",
]

def convert_file(filepath):
    """Convert Navigator calls to context calls in a single file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    changes = {}
    
    # Count Navigator.pop(context)
    pop_count = content.count('Navigator.pop(context)')
    if pop_count > 0:
        content = content.replace('Navigator.pop(context)', 'context.pop()')
        changes['pop'] = pop_count
    
    # Count Navigator.push patterns (MaterialPageRoute)
    push_pattern = r'Navigator\.push\s*\(\s*context,\s*MaterialPageRoute'
    push_matches = len(re.findall(push_pattern, content))
    if push_matches > 0:
        changes['push'] = push_matches
    
    # Count Navigator.pushReplacement patterns
    push_repl_pattern = r'Navigator\.pushReplacement\s*\(\s*context,\s*MaterialPageRoute'
    push_repl_matches = len(re.findall(push_repl_pattern, content))
    if push_repl_matches > 0:
        changes['pushReplacement'] = push_repl_matches
    
    # Write back if changed
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
    
    return changes

# Main execution
total_pop = 0
total_push = 0
total_push_repl = 0

for file in files:
    filepath = os.path.join(r"d:\A-SnakeAid\SnakeAid.Mobile", file)
    if os.path.exists(filepath):
        changes = convert_file(filepath)
        if changes:
            parts = []
            if 'pop' in changes:
                parts.append(f"{changes['pop']} pop")
                total_pop += changes['pop']
            if 'push' in changes:
                parts.append(f"{changes['push']} push")
                total_push += changes['push']
            if 'pushReplacement' in changes:
                parts.append(f"{changes['pushReplacement']} pushReplacement")
                total_push_repl += changes['pushReplacement']
            
            print(f"✓ {os.path.basename(file)}: {', '.join(parts)}")
    else:
        print(f"✗ {file}: File not found")

print(f"\nTotal: {total_pop} pop, {total_push} push, {total_push_repl} pushReplacement calls found")
print(f"\nManual conversion needed for {total_push + total_push_repl} Navigator.push/pushReplacement calls")
