import requests
import json
import os
import click
from time import sleep

def extract_chat_history(group_id, page_size=20, max_pages=None):
    """
    Extracts chat history from the API and saves it as JSON files.
    
    :param group_id: ID of the group to extract messages from
    :param page_size: Number of messages per page (default 20, max 100)
    :param max_pages: Maximum number of pages to fetch (default None, fetches all available)
    :return: Number of pages successfully fetched
    """
    headers = {
        "Content-Type": "application/json"
    }

    token = os.environ["GROUPME_TOKEN"]
    
    url = f"https://api.groupme.com/v3/groups/{group_id}/messages?token={token}"
    params = {"limit": min(page_size, 100)}  # Ensure page_size doesn't exceed 100
    
    pages_fetched = 0
    last_message_id = None
    all_messages = []
    
    def write_to_file():
        if all_messages:
            oldest_timestamp = all_messages[-1]["created_at"]
            filename = f"{group_id}_{oldest_timestamp}_{last_message_id}.json"
            filepath = os.path.join("data", filename)
            with open(filepath, "w") as f:
                json.dump({"messages": all_messages}, f, indent=2)
            click.echo(f"\nSaved {len(all_messages)} messages to {filename}")
            all_messages.clear()
    
    try:
        with click.progressbar(length=max_pages or 100, label="Fetching messages") as bar:
            while True:
                if last_message_id:
                    params["before_id"] = last_message_id
                
                sleep(2)
                response = requests.get(url, headers=headers, params=params)
                response.raise_for_status()
                
                response_data = response.json()["response"]

                messages = response_data.get("messages", [])
                
                if not messages:
                    click.echo("No messages in the response.")
                    break
                
                all_messages.extend(messages)
                pages_fetched += 1
                last_message_id = messages[-1]["id"]
                
                bar.update(1)
                
                if pages_fetched % 10 == 0 or (max_pages and pages_fetched >= max_pages):
                    write_to_file()
                
                if max_pages and pages_fetched >= max_pages:
                    click.echo(f"Reached maximum number of pages ({max_pages}).")
                    break
    
    except requests.exceptions.RequestException as e:
        click.echo(f"Error occurred while fetching page {pages_fetched + 1}: {e}", err=True)
    
    finally:
        # Write any remaining messages
        write_to_file()
    
    click.echo(f"Successfully fetched {pages_fetched} pages.")
    return pages_fetched

@click.command()
@click.argument('group_id')
@click.option('--page-size', default=20, help='Number of messages per page (default 20, max 100)')
@click.option('--max-pages', default=None, type=int, help='Maximum number of pages to fetch (default: fetch all)')
def main(group_id, page_size, max_pages):
    """Extract chat history from API"""
    extract_chat_history(group_id, page_size, max_pages)

if __name__ == "__main__":
    main()
