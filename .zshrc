alias izido="/usr/local/bin/izido" # Path to todo.sh script for to-do-list on bash
# Function to enable to-do view
function izido_view_on() {
    touch ~/.config/show_izido
    echo "iZiDo view enabled."
}

# Function to disable to-do view
function izido_view_off() {
    rm -f ~/.config/show_izido
    echo "iZiDo view disabled."
}