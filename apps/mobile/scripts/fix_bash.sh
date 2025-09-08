#!/bin/bash

# Create the missing shell-snapshots directory
mkdir -p ~/.claude/shell-snapshots/

# Create a basic shell snapshot file with the expected name
cat > ~/.claude/shell-snapshots/snapshot-bash-1757292663887-sgo3k0.sh << 'EOF'
#!/bin/bash
# Shell snapshot for Claude Code
export PS1='$ '
cd /home/matt/FINAPP/Receipt\ Organizer/apps/mobile
EOF

# Make it executable
chmod +x ~/.claude/shell-snapshots/snapshot-bash-1757292663887-sgo3k0.sh

echo "Shell snapshot directory and file created successfully"