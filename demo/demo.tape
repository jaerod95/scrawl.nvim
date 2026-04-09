# scrawl.nvim demo
Output demo/scrawl-demo.gif

Set Shell "zsh"
Set FontSize 14
Set Width 1200
Set Height 700
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 50ms
Set CursorBlink false

# Start clean
Hide
Type "cd /Users/jrod/Documents/work/scrawl.nvim && clear"
Enter
Sleep 1s
Show

Type "nvim -u demo/init.lua lua/scrawl/note.lua"
Enter
Sleep 3s

# --- Toggle Claude Code terminal ---
Sleep 500ms
Type " cc"
Sleep 6s

# Ctrl+B exits terminal mode, Ctrl+B again closes the float
Ctrl+b
Sleep 500ms
Ctrl+b
Sleep 1s

# --- Visual select code and capture a note ---
Type "gg"
Sleep 300ms
Type "/function M.capture"
Enter
Sleep 500ms
Escape
Sleep 300ms

# Select the function
Type "V"
Sleep 300ms
Type "4j"
Sleep 1s

# Capture a note with the selection
Type " cn"
Sleep 1s
Type "refactor: extract shared format_selection helper"
Sleep 800ms
Enter
Sleep 2s

# --- Visual select and ask a question ---
Type "/function M.decision"
Enter
Sleep 500ms
Escape
Sleep 300ms

Type "V"
Sleep 300ms
Type "6j"
Sleep 1s

# Ask a question with selection context
Type " cq"
Sleep 1s
Type "should this validate input before formatting?"
Sleep 800ms
Enter

# Claude terminal opens with the question - wait for it
Sleep 6s

# Exit terminal and close
Ctrl+b
Sleep 500ms
Ctrl+b
Sleep 1s

# Exit nvim
Type ":q!"
Enter
Sleep 1s
