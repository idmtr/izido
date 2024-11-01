#!/bin/bash

IZIDO_FILE="$HOME/.config/starship_izido.txt"

# Ensure the izido task list file exists
touch "$IZIDO_FILE"

function add_izido() {
    local priority="$1"
    local due_date="$2"
    shift 2
    local task="${*// /_}"
    echo "pending,$priority,$due_date,$task" >> "$IZIDO_FILE"
    echo "Added: $task with priority $priority and due date $due_date"
}

function list_todos() {
    local filter="$1"
    if [ ! -s "$IZIDO_FILE" ]; then
        echo "No todos found."
        return
    fi
    printf "%-5s %-10s %-10s %-12s %s\n" "ID" "Status" "Priority" "Due_Date" "Task"
    awk -v filter="$filter" -F, '{
        if (filter == "" || $1 == filter || $2 == filter) {
            id=NR
            status=$1
            priority=$2
            due_date=$3
            task=$4
            status_color = (status == "pending") ? "\033[33m" : "\033[32m"
            priority_color = (priority == "high") ? "\033[31m" : ((priority == "normal") ? "\033[34m" : "\033[36m")
            printf "%-5d %s%-10s\033[0m %s%-10s\033[0m %-12s %s\n", id, status_color, status, priority_color, priority, due_date, task
        }
    }' "$IZIDO_FILE"
}

function mark_done() {
    local id="$1"
    if [ -z "$id" ]; then
        echo "Please provide the ID of the task to mark as done."
        return
    fi
    sed -i "" "${id}s/^pending/done/" "$IZIDO_FILE"
    echo "Marked task $id as done."
}

function remove_todo() {
    local id="$1"
    if [ -z "$id" ]; then
        echo "Please provide the ID of the task to remove."
        return
    fi
    sed -i "" "${id}d" "$IZIDO_FILE"
    echo "Removed task $id."
}

function clear_todos() {
    > "$IZIDO_FILE"
    echo "Cleared all todos."
}

function izido_view() {
    if [ "$1" == "on" ]; then
        touch ~/.config/show_izido
        echo "IziDo on."
    elif [ "$1" == "off" ]; then
        rm -f ~/.config/show_izido
        echo "IziDo off."
    else
        echo "Usage: $0 view {on|off}"
    fi
}

case "$1" in
  add)
    shift
    if [ "$1" == "-p" ]; then
        priority="$2"
        shift 2
    else
        priority="normal"
    fi
    if [ "$1" == "-d" ]; then
        due_date="$2"
        shift 2
    else
        due_date="none"
    fi
    add_izido "$priority" "$due_date" "$@"
    ;;
  list)
    list_todos
    ;;
  done)
    mark_done "$2"
    ;;
  remove)
    remove_todo "$2"
    ;;
  clear)
    clear_todos
    ;;
  view)
    shift
    izido_view "$1"
    ;;
  *)
    echo "Usage: $0 {add [-p priority] [-d due_date] task|list|done ID|remove ID|clear}"
    ;;
esac
